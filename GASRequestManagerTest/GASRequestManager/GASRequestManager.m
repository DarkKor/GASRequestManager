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

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
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
        self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[self baseUrl]];
        
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

- (AFHTTPRequestOperation *)request:(NSString *)route
                           method:(NSString *)method
                           object:(NSObject *)object
                       completion:(MappedCompletionBlock)completion {
    NSDictionary *params = [self dictionaryFromObject:object
                                                route:route];
    AFHTTPRequestOperation *op = [self request:route
                                        method:method
                                    parameters:params
                                    completion:completion];
    return op;
}

- (AFHTTPRequestOperation *)request:(NSString *)route
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
    
    AFHTTPRequestOperation *op = nil;
    op = [self sendRequest:requestRoute
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
    return op;
}

- (AFHTTPRequestOperation *)sendRequest:(NSString *)route
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
    
    void(^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if(self.verboseLogging) {
            NSLog(@"%@\n%@",
                  operation.request.URL.absoluteString,
                  [responseObject description]);
        }
        
        finalCompletionBlock(responseObject, nil);
    };
    
    void(^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if(self.verboseLogging) {
            NSLog(@"errorCode %ld error %@",  (long)error.code, error.description);
        }
        
        finalCompletionBlock(nil, error);
    };
    
    AFHTTPRequestOperation *op = nil;
    
    if ([method isEqualToString:GET_METHOD]) {
        op = [self.manager GET:route parameters:params success:successBlock failure:failureBlock];
    }
    else if ([method isEqualToString:POST_METHOD]) {
        op = [self.manager POST:route parameters:params success:successBlock failure:failureBlock];
    }
    else if ([method isEqualToString:PUT_METHOD]) {
        op = [self.manager PUT:route parameters:params success:successBlock failure:failureBlock];
    }
    else if ([method isEqualToString:PATCH_METHOD]) {
        op = [self.manager PATCH:route parameters:params success:successBlock failure:failureBlock];
    }
    else if ([method isEqualToString:DELETE_METHOD]) {
        op = [self.manager DELETE:route parameters:params success:successBlock failure:failureBlock];
    }
    else {
        NSLog(@"Unsupported HTTP Method: %@", method);
    }
    
    if(self.verboseLogging) {
        if(![method isEqualToString:POST_METHOD]) {
            NSLog(@"%@", op.request.URL.absoluteString);
        }
        else {
            NSLog(@"request %@\nbody %@",
                  op.request.URL.absoluteString,
                  [[NSString alloc] initWithData:op.request.HTTPBody
                                        encoding:NSUTF8StringEncoding]);
        }
    }
    
    return op;
}

- (NSURL *)baseUrl {
    return [NSURL URLWithString:self.baseUrlString];
}

- (NSArray *)mapObjects:(NSArray *)objects mapping: (GASMapping *)mapping {
    NSManagedObjectContext *ctx = self.savingContext;
    return [FEMManagedObjectDeserializer collectionFromRepresentation:objects
                                                              mapping:mapping
                                                              context:ctx];
}

- (id)mapObject: (NSDictionary *)object mapping: (GASMapping *)mapping {
    NSManagedObjectContext *ctx = self.savingContext;
    return [FEMManagedObjectDeserializer objectFromRepresentation:object
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

@end
