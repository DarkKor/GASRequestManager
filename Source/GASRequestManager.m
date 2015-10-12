         //
//  RequestManager.m
//  testFem
//
//  Created by Виктор Заикин on 17.03.15.
//  Copyright (c) 2015 Виктор Заикин. All rights reserved.
//

#import "GASRequestManager.h"
#import <AFNetworking/AFNetworking.h>
#import "FEMManagedObjectDeserializer+DefaultContext.h"
#import <FEMSerializer.h>
#import <CoreData+MagicalRecord.h>

#define GET_METHOD @"GET"
#define POST_METHOD @"POST"

@interface GASRequestManager()

@property (weak, nonatomic) __weak __block GASRequestManager *weakSelf;
@property (nonatomic, strong) NSMutableDictionary *mappings;

@end

@implementation GASRequestManager

#pragma mark - Private request methods

+ (instancetype)managerWithBaseURL:(NSString *)baseURL {
    static GASRequestManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GASRequestManager alloc] initWithBaseURL:baseURL];
    });
    return manager;
}

- (instancetype)initWithBaseURL:(NSString *)baseURL {
    self = [super init];
    if (self != nil) {
        self.weakSelf = self;
        self.mappings = [NSMutableDictionary dictionary];
        self.baseURL = baseURL;
        self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[self baseUrl]];
    }
    return self;
}

- (void)stopAllRequests {
    if (self.manager != nil)
        [self.manager.operationQueue cancelAllOperations];
}

- (void)addMapping: (Mapping *)mapping
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
        id keypathResult = results[keypath];
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
            Mapping *mapping = mappings[keypath];
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

- (void)request:(NSString *)route
         method:(NSString *)method
         object:(NSObject *)object
     completion:(MappedCompletionBlock)completion {
    
    NSDictionary *params = [self dictionaryFromObject:object route:route];
    
    [self request:route
           method:method
       parameters:params
       completion:completion];
}

- (void)request:(NSString *)route
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
                requestRoute = [route stringByReplacingOccurrencesOfString:param_ withString:params[param]];
                [paramsDict removeObjectForKey:param];
            }
        } else {
            if ([route rangeOfString:param_].length > 0) {
                requestRoute = [route stringByReplacingOccurrencesOfString:param_ withString:params[param]];
                [paramsDict removeObjectForKey:param];
            }
        }
    }
    
    // nil dictionary if it is empty
    // if not doing this we will get "?" at the end of the request
    if (paramsDict.allKeys.count == 0)
        paramsDict = nil;
    
    [self sendRequest:requestRoute method:method parameters:paramsDict completion:^(id result, NSError *error) {
        if (error == nil) {
            if (result != nil) {
                id results = result[@"result"];
                
                NSDictionary *mappedObjects = [self map:results route:route];
                
                if (completion != nil) {
                    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                    [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
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
}

- (void)sendRequest:(NSString *)route
             method:(NSString *)method
         parameters:(NSDictionary *)params
         completion:(CompletionBlock)completion {
    
    if ([method isEqualToString:GET_METHOD]) {
        [self getRequest:route
              parameters:params
              completion:^(id result, NSError *error) {
                  id preparedResult = [_weakSelf beforeMappingChanges:result forRoute:route];
                  if (completion != nil)
                      completion(preparedResult, error);
              }];
    } else if ([method isEqualToString:POST_METHOD]) {
        [self postRequest:route
               parameters:params
               completion:^(id result, NSError *error) {
                   id preparedResult = [_weakSelf beforeMappingChanges:result forRoute:route];
                   if (completion != nil)
                       completion(preparedResult, error);
               }];
    }
}

- (void)getRequest:(NSString *)route
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
    
    AFHTTPRequestOperation *operation = [self.manager GET:route
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             DLog(@"%@\n%@",
                  operation.request.URL.absoluteString,
                  [responseObject description]);
             
             if (completion != nil)
                 completion(responseObject, nil);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             DLog(@"errorCode %ld error %@",  (long)error.code, error.description);
             
             if (completion != nil)
                 completion(nil, error);
         }];
    DLog(@"%@", operation.request.URL.absoluteString);
}

- (void)postRequest:(NSString *)route
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
    
    AFHTTPRequestOperation *operation = [self.manager POST:route
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              DLog(@"%@\n%@",
                   operation.request.URL.absoluteString,
                   [responseObject description]);
              
              if (completion != nil)
                  completion(responseObject, nil);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              DLog(@"errorCode %ld error %@",  (long)error.code, error.description);
              
              if (completion != nil)
                  completion(operation.responseObject, error);
          }];
    
    DLog(@"request %@\nbody %@", operation.request.URL.absoluteString, [[NSString alloc] initWithData:operation.request.HTTPBody encoding:4]);
}

- (NSURL *)baseUrl {
    return [NSURL URLWithString:self.baseURL];
}

- (NSArray *)mapObjects:(NSArray *)objects mapping: (Mapping *)mapping {
    return [FEMManagedObjectDeserializer deserializeCollectionExternalRepresentation:objects
                                                                        usingMapping:mapping];
}

- (id)mapObject: (NSDictionary *)object mapping: (Mapping *)mapping {
    return [FEMManagedObjectDeserializer deserializeObjectExternalRepresentation:object
                                                                    usingMapping:mapping];
}

- (id)beforeMappingChanges:(id)result forRoute:(NSString *)route {
    // make changes with incomming JSON for certain route before mapping
    return result;
}

// Parsing object to NSDictionary

- (NSDictionary *)dictionaryFromObject:(NSObject *)object route:(NSString *)route {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if ([object isKindOfClass:[NSArray class]]) {
        // TODO: parse array
    } else if ([object isKindOfClass:[NSManagedObject class]]) {
        // Parse object from DB
        NSDictionary *mappings = self.mappings[route];
        
        NSDictionary *dictionary = @{};
        
        for (NSString *key in mappings.allKeys) {
            Mapping *mapping = mappings[key];
            dictionary = [FEMSerializer serializeObject:object
                                           usingMapping:mapping];
        }
        
        parameters = [dictionary mutableCopy];
        
    }
    
    return parameters;
}

#pragma mark - Fake delays

- (void)fakeDelayedWithBlock:(MappedCompletionBlock)completion {
    [self fakeDelayedWithBlock:completion time:1.0];
}

- (void)fakeDelayedWithBlock:(MappedCompletionBlock)completion time:(NSTimeInterval)time {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, nil, nil);
        });
    });
}

#pragma mark -

@end
