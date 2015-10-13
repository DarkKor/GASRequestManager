//
//  ViewController.m
//  GASRequestManagerTest
//
//  Created by Dmitriy on 13.10.15.
//  Copyright (c) 2015 GrowApp Solutions. All rights reserved.
//

#import "ViewController.h"
#import "GASRequestManager.h"

#import <MagicalRecord.h>
#import "Comics.h"
#import "Editor.h"

#import <CommonCrypto/CommonCrypto.h>

#define API_KEY @"568e3a671e6a812c6c39a4fee15e2152"
#define PRVT_KEY @"e54a87201fa6e0fce8c1f1fc402e09bdab90d686"
#define BASE_URL @"https://gateway.marvel.com/"
#define URL @"v1/public/comics"
#define ROOT_KEYPATH @"data.results"
#define GET @"GET"

@interface ViewController ()

@property (nonatomic, strong) GASRequestManager *manager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupDataBase];
    
    [self setupReuqestManager];
    
    [self runRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request Methods

- (void)setupDataBase {
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"marvel"];
}

- (void)setupReuqestManager {
    //
    //  Create request manager
    //
    self.manager = [GASRequestManager managerWithBaseURL:BASE_URL];
    
    //
    //  Setup mappings
    //
    
    //  Main mapping
    Mapping *mappingComics = [Mapping createWithDict:@{@"uid" : @"id",
                                                       @"isbn" : @"isbn",
                                                       @"title" : @"title",
                                                       @"caption" : @"description",
                                                       @"format" : @"format",
                                                       @"pageCount" : @"pageCount"}
                                          primaryKey:@"uid"
                                          entityName:@"Comics"];
    
    //  Tranformer attribute
    [mappingComics addAttribute:[FEMAttribute mappingOfProperty:@"thumbUrl"
                                                      toKeyPath:@"thumbnail"
                                                            map:^id(id value) {
                                                                NSDictionary *dict = value;
                                                                return [NSString stringWithFormat:@"%@.%@",
                                                                        dict[@"path"], dict[@"extension"]];
                                                            }]];
    
    //  To many relationship
    Mapping *mappingEditor = [Mapping createWithDict:@{@"name" : @"name",
                                                       @"role" : @"role"}
                                          primaryKey:@"name"
                                          entityName:@"Editor"];
    [mappingComics addToManyRelationshipMapping:mappingEditor
                                    forProperty:@"editors"
                                        keyPath:@"creators.items"];
    
    //  Add constructed mapping
    [self.manager addMapping:mappingComics
                    forRoute:URL
                     keypath:ROOT_KEYPATH];
    
    //
    //  Setup modifier
    //
    [self.manager addResponseModifier:^id(id responseToModify) {
        
        NSMutableDictionary *rootDict = [responseToModify mutableCopy];
        NSMutableDictionary *dataDict = [rootDict[@"data"] mutableCopy];
        NSMutableArray *results = [dataDict[@"results"] mutableCopy];
        NSMutableArray *newResults = [NSMutableArray array];
        
        //  Replace all isbn, for example
        for(NSDictionary *comicsDict in results) {
            NSMutableDictionary *newComicsDict = [comicsDict mutableCopy];
            newComicsDict[@"isbn"] = [NSString stringWithFormat:@"%d", arc4random() % 100000];
            [newResults addObject:newComicsDict];
        }
        
        dataDict[@"results"] = newResults;
        rootDict[@"data"] = dataDict;
        
        return rootDict;
    }
                             forRoute:URL];
}

- (void)runRequest {
    NSString *ts = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    
    //
    //  Run request with parameters
    //
    [self.manager request:URL
                   method:GET
               parameters:@{@"apikey" : API_KEY,
                            @"ts" : ts,
                            @"hash" : [self hashOfTs:ts]}
               completion:^(NSDictionary *resultMapped, id serverResponse, NSError *error) {
                   if(error == nil) {
                       [self showResults:resultMapped];
                   }
               }];
}

- (void)showResults: (NSDictionary *)results {
    NSArray *comicsArray = results[ROOT_KEYPATH];
    for(Comics *comics in comicsArray) {
        NSLog(@"%@", comics);
    }
}

#pragma mark - Private Methods

- (NSString *)hashOfTs: (NSString *)ts {
    NSString *hash = [NSString stringWithFormat:@"%@%@%@", ts, PRVT_KEY, API_KEY];
    
    const char *cStr = [hash UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (unsigned int) strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
