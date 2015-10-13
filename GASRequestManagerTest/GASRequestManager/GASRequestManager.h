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

#define LOGGING YES

typedef void(^MappedCompletionBlock)(NSDictionary *resultMapped, id serverResponse, NSError *error);
typedef void(^CompletionBlock)(id result, NSError *error);
typedef id(^ResponseModifierBlock)(id responseToModify);

@interface GASRequestManager : NSObject

//  Use this to setup request headers
@property (nonatomic, strong) NSDictionary *requestHeaders;

//  Use this to setup response headers
@property (nonatomic, strong) NSDictionary *responseHeaders;

//  Use this to setup response content types
@property (nonatomic, strong) NSSet *responseContentTypeSet;

//  Init
+ (instancetype)managerWithBaseURL:(NSString *)baseURL;
- (instancetype)initWithBaseURL:(NSString *)baseURL;
- (NSURL *)baseUrl;

//  Requests
- (void)request:(NSString *)route
         method:(NSString *)method
         object:(NSObject *)object
     completion:(MappedCompletionBlock)completion;
- (void)request:(NSString *)route
         method:(NSString *)method
     parameters:(NSDictionary *)params
     completion:(MappedCompletionBlock)completion;
- (void)stopAllRequests;

//  Mappings
- (void)addMapping: (Mapping *)mapping
          forRoute: (NSString *)route
           keypath: (NSString *)keypath;
- (NSDictionary *)map: (id)results
                route: (NSString *)route;

//  Response modifiers
- (void)addResponseModifier: (ResponseModifierBlock)modifier
                   forRoute: (NSString *)route;

@end
