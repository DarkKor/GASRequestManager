//
//  KBRequestManager.h
//  KidBeed
//
//  Created by Виктор Заикин on 16.03.15.
//  Copyright (c) 2015 Виктор Заикин. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "Mapping.h"
#import "Relationship.h"

typedef void(^MappedCompletionBlock)(NSDictionary *resultMapped, id serverResponse, NSError *error);
typedef void(^CompletionBlock)(id result, NSError *error);

@interface GASRequestManager : NSObject

@property (nonatomic, copy) NSString *baseURL;

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@property (nonatomic, strong) NSDictionary *requestHeaders;
@property (nonatomic, strong) NSDictionary *responseHeaders;

@property (nonatomic, strong) NSSet *responseContentTypeSet;

@property (nonatomic, strong) AFHTTPRequestSerializer *requestSerializer;
@property (nonatomic, strong) AFHTTPResponseSerializer *responseSerializer;

+ (instancetype)managerWithBaseURL:(NSString *)baseURL;
- (instancetype)initWithBaseURL:(NSString *)baseURL;

- (void)stopAllRequests;
- (void)request:(NSString *)route
         method:(NSString *)method
         object:(NSObject *)object
     completion:(MappedCompletionBlock)completion;
- (void)request:(NSString *)route
         method:(NSString *)method
     parameters:(NSDictionary *)params
     completion:(MappedCompletionBlock)completion;

- (void)addMapping: (Mapping *)mapping
          forRoute: (NSString *)route
           keypath: (NSString *)keypath;

- (NSDictionary *)map: (id)results
                route: (NSString *)route;

- (void)fakeDelayedWithBlock:(MappedCompletionBlock)completion;

@end
