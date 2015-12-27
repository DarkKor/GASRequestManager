//
//  RequestManager.m
//  testFem
//
//  Created by Виктор Заикин on 17.03.15.
//  Copyright (c) 2015 Виктор Заикин. All rights reserved.
//

#import "GASRequestManager.h"
#import <AFNetworking/AFNetworking.h>
#import <FastEasyMapping.h>
#import <MagicalRecord/MagicalRecord.h>

#define GET_METHOD @"GET"
#define POST_METHOD @"POST"
#define PUT_METHOD @"PUT"
#define PATCH_METHOD @"PATCH"
#define DELETE_METHOD @"DELETE"


@interface GASRequestManager()

@property (nonatomic, copy) NSString *baseUrlString;

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) AFHTTPRequestSerializer *requestSerializer;
@property (nonatomic, strong) AFHTTPResponseSerializer *responseSerializer;

@property (nonatomic, strong) NSMutableDictionary *mappings;
@property (nonatomic, strong) NSMutableDictionary *modifiers;

@end

@implementation GASRequestManager

#pragma mark - Private request methods

+ (instancetype)managerWithBaseURL:(NSString *)baseURL context: (NSManagedObjectContext *)context {
    static GASRequestManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GASRequestManager alloc] initWithBaseURL:baseURL context:context];
    });
    return manager;
}

- (instancetype)initWithBaseURL:(NSString *)baseURL context: (NSManagedObjectContext *)context {
    self = [super init];
    if (self != nil) {
        self.mappings = [NSMutableDictionary dictionary];
        self.modifiers = [NSMutableDictionary dictionary];
        
        self.savingContext = context;
        NSAssert(context != nil, @"Saving context cannot be nil");
        
        self.baseUrlString = baseURL;
        self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[self baseUrl]];
        
        self.verboseLogging = YES;
    }
    return self;
}

- (void)stopAllRequests {
    if (self.manager != nil)
        [self.manager.operationQueue cancelAllOperations];
}

- (void)addResponseModifier: (ResponseModifierBlock)modifier
                   forRoute: (NSString *)route {
    self.modifiers[route] = modifier;
}

- (void)addMapping: (GASMapping *)mapping
          forRoute: (NSString *)route
           keypath: (NSString *)keypath {
    NSMutableDictionary *keypaths = self.mappings[route];
    if(keypaths == nil) {
        keypaths = [NSMutableDictionary dictionary];
    }
    keypaths[keypath] = mapping;
    
    self.mappings[route] = keypaths;
}

- (NSDictionary *)map: (id)results route: (NSString *)route {
    NSMutableDictionary *mappedObjects = [NSMutableDictionary dictionary];
    
    NSDictionary *mappings = self.mappings[route];
    
    NSArray *keypaths = [mappings allKeys];
    for(NSString *keypath in keypaths) {
        id keypathResult = results;
        
        //  Find server response for this keypath
        NSArray *multiPath = [keypath componentsSeparatedByString:@"."];
        if (multiPath.count > 1) {
            for (NSString *partKeypath in multiPath) {
                keypathResult = keypathResult[partKeypath];
            }
        } else {
            keypathResult = results[keypath];
        }
        
        if(keypathResult != nil) {
            //  Find mapping for this keypath
            GASMapping *mapping = mappings[keypath];
            if(mapping != nil) {
                //  Try to map it using mapping
                NSArray *objects = nil;
                if([keypathResult isKindOfClass:[NSArray class]]) {
                    objects = [self mapObjects:keypathResult
                                       mapping:mapping];
                }
                else if([keypathResult isKindOfClass:[NSDictionary class]]) {
                    id mappedObject = [self mapObject:keypathResult
                                              mapping:mapping];
                    if(mappedObject != nil) {
                        objects = [NSArray arrayWithObject:mappedObject];
                    }
                }
                
                //  Save
                [mappedObjects setObject:objects
                                  forKey:keypath];
            }
        }
    }
    
    return mappedObjects;
}

// Method sending an object to server

- (NSURLSessionDataTask *)request:(NSString *)route
                           method:(NSString *)method
                           object:(NSObject *)object
                       completion:(MappedCompletionBlock)completion {
    NSDictionary *params = [self dictionaryFromObject:object
                                                route:route];
    NSURLSessionDataTask *op = [self request:route
                                      method:method
                                  parameters:params
                                  completion:completion];
    return op;
}

- (NSURLSessionDataTask *)request:(NSString *)route
                           method:(NSString *)method
                       parameters:(NSDictionary *)params
                       completion:(MappedCompletionBlock)completion {
    NSMutableDictionary *paramsDict = [params mutableCopy];
    NSString *requestRoute = [route copy];
    
    // If route must be like /country/2/cities
    // search in /country/:id/cities from route for parameter from params
    // if such param (:id) founds it changed for its definition in requestRoute
    // and this parameter deletes from paramsDict
    for (NSString *param in params.allKeys) {
        NSString *param_ = [NSString stringWithFormat:@":%@", param];
        if ([route respondsToSelector:@selector(containsString:)]) {
            if ([route containsString:param_]) {
                requestRoute = [route stringByReplacingOccurrencesOfString:param_
                                                                withString:params[param]];
                [paramsDict removeObjectForKey:param];
            }
        } else {
            if ([route rangeOfString:param_].length > 0) {
                requestRoute = [route stringByReplacingOccurrencesOfString:param_
                                                                withString:params[param]];
                [paramsDict removeObjectForKey:param];
            }
        }
    }
    
    // nil dictionary if it is empty
    // if not doing this we will get "?" at the end of the request
    if (paramsDict.allKeys.count == 0) {
        paramsDict = nil;
    }
    
    NSURLSessionDataTask *dataTask = nil;
    dataTask = [self sendRequest:requestRoute
                          method:method
                      parameters:paramsDict
                      completion:^(id result, NSError *error) {
                          if (error == nil) {
                              if (result != nil) {
                                  NSDictionary *mappedObjects = [self map:result route:route];
                                  
                                  if (completion != nil) {
                                      NSManagedObjectContext *ctx = self.savingContext;
                                      [ctx MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              completion(mappedObjects, result, error);
                                          });
                                      }];
                                  }
                              }
                          } else {
                              if (completion != nil) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      completion(nil, result, error);
                                  });
                              }
                          }
                      }];
    return dataTask;
}

- (NSURLSessionDataTask *)sendRequest:(NSString *)route
                               method:(NSString *)method
                           parameters:(NSDictionary *)params
                           completion:(CompletionBlock)completion {
    
    if (self.responseContentTypeSet != nil) {
        [self.manager.responseSerializer setAcceptableContentTypes:self.responseContentTypeSet];
    }
    
    if (self.requestSerializer != nil)
        self.manager.requestSerializer = self.requestSerializer;
    if (self.responseSerializer != nil)
        self.manager.responseSerializer = self.responseSerializer;
    
    if (self.requestHeaders != nil) {
        for (NSString *key in self.requestHeaders) {
            [self.manager.requestSerializer setValue:self.requestHeaders[key]
                                  forHTTPHeaderField:key];
        }
    }
    
    __block __weak typeof(self) weakSelf = self;
    
    void(^finalCompletionBlock)(id result, NSError *error) =  ^(id result, NSError *error){
        id preparedResult = [weakSelf beforeMappingChanges:result forRoute:route];
        if (completion != nil) {
            completion(preparedResult, error);
        }
    };
    
    void(^successBlock)(NSURLSessionTask *task, id responseObject) = ^(NSURLSessionTask *task, id responseObject) {
        if(self.verboseLogging) {
            NSLog(@"%@\n%@",
                  task.originalRequest.URL.absoluteString,
                  [responseObject description]);
        }
        
        finalCompletionBlock(responseObject, nil);
    };
    
    void(^failureBlock)(NSURLSessionTask *task, NSError *error) = ^(NSURLSessionTask *task, NSError *error) {
        if(self.verboseLogging) {
            NSLog(@"errorCode %ld error %@",  (long)error.code, error.description);
            [self handleServerError:error];
        }
        
        finalCompletionBlock(nil, error);
    };
    
    NSURLSessionDataTask *dataTask = nil;
    
    if ([method isEqualToString:GET_METHOD]) {
        dataTask = [self.manager GET:route parameters:params progress:nil success:successBlock failure:failureBlock];
    }
    else if ([method isEqualToString:POST_METHOD]) {
        dataTask = [self.manager POST:route parameters:params progress:nil success:successBlock failure:failureBlock];
    }
    else if ([method isEqualToString:PUT_METHOD]) {
        dataTask = [self.manager PUT:route parameters:params success:successBlock failure:failureBlock];
    }
    else if ([method isEqualToString:PATCH_METHOD]) {
        dataTask = [self.manager PATCH:route parameters:params success:successBlock failure:failureBlock];
    }
    else if ([method isEqualToString:DELETE_METHOD]) {
        dataTask = [self.manager DELETE:route parameters:params success:successBlock failure:failureBlock];
    }
    else {
        NSLog(@"Unsupported HTTP Method: %@", method);
    }
    
    if(self.verboseLogging) {
        if(![method isEqualToString:POST_METHOD]) {
            NSLog(@"%@", dataTask.originalRequest.URL.absoluteString);
        }
        else {
            NSLog(@"request %@\nbody %@",
                  dataTask.originalRequest.URL.absoluteString,
                  [[NSString alloc] initWithData:dataTask.originalRequest.HTTPBody
                                        encoding:NSUTF8StringEncoding]);
        }
    }
    
    return dataTask;
}

- (NSURL *)baseUrl {
    return [NSURL URLWithString:self.baseUrlString];
}

- (NSArray *)mapObjects:(NSArray *)objects mapping: (GASMapping *)mapping {
    NSManagedObjectContext *ctx = self.savingContext;
    return [FEMDeserializer collectionFromRepresentation:objects
                                                 mapping:mapping
                                                 context:ctx];
}

- (id)mapObject: (NSDictionary *)object mapping: (GASMapping *)mapping {
    NSManagedObjectContext *ctx = self.savingContext;
    return [FEMDeserializer objectFromRepresentation:object
                                             mapping:mapping
                                             context:ctx];
}

- (id)beforeMappingChanges:(id)result forRoute:(NSString *)route {
    ResponseModifierBlock modifier = self.modifiers[route];
    if(modifier != nil) {
        return modifier(result);
    }
    else {
        return result;
    }
}

// Parsing object to NSDictionary

- (NSDictionary *)dictionaryFromObject:(NSObject *)object route:(NSString *)route {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if ([object isKindOfClass:[NSArray class]]) {
        // No-op
    } else if ([object isKindOfClass:[NSManagedObject class]]) {
        // Parse object from DB
        NSDictionary *mappings = self.mappings[route];
        
        NSDictionary *dictionary = @{};
        
        for (NSString *key in mappings.allKeys) {
            GASMapping *mapping = mappings[key];
            dictionary = [FEMSerializer serializeObject:object
                                           usingMapping:mapping];
        }
        
        parameters = [dictionary mutableCopy];
    }
    
    return parameters;
}

// Handle server exception

- (void)handleServerError:(NSError *)error {
    NSString *serverError = [self parseServerError:error];
    
    if (serverError.length > 0)
        NSLog(@"Parsed server exception: %@", serverError);
}

- (NSString *)parseServerError:(NSError *)error {
    NSString *errorString = @"";
    
    NSDictionary *errUserInfo = error.userInfo;
    if (errUserInfo != nil) {
        NSError *undelyningServerError = error.userInfo[@"NSUnderlyingError"];
        NSDictionary *underlyningServerErrorUserInfo = undelyningServerError.userInfo;
        if (underlyningServerErrorUserInfo != nil) {
            NSData *errorData = nil;
            errorData = underlyningServerErrorUserInfo[@"com.alamofire.serialization.response.error.data"];
            errorString = [[NSString alloc] initWithData:errorData encoding:4];
        }
    }
    
    return errorString;
}

@end
