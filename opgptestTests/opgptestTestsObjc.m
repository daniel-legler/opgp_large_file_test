//
//  opgptestTestsObjc.m
//  opgptestTests
//
//  Created by Daniel Legler on 2/1/18.
//  Copyright © 2018 opgptest. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <mach/mach.h>
#import <ObjectivePGP/ObjectivePGP.h>
#import "opgptestTests-Bridging-Header.h"

@interface opgptestTestsObjc : XCTestCase

@end

@implementation opgptestTestsObjc

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    report_memory();
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"LargeFile" ofType:@"pdf"];
    NSData *unencryptedData = [NSData dataWithContentsOfFile:path];
    NSLog(@"Size of Unencrypted Data (in MB): %lu", unencryptedData.length/1024/1024);
    
    PGPKeyGenerator *generator = [[PGPKeyGenerator alloc] init];
    PGPKey *key = [generator generateFor:@"Marcin <marcin@example.com>" passphrase:nil];
    
    report_memory();
    
    NSData *encryptedData = [ObjectivePGP encrypt:unencryptedData usingKeys:@[key] armored:YES error:nil];
    
    report_memory();
    sleep(10);
    
}

void report_memory(void) {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"Memory in use (in MB): %f", ((CGFloat)info.resident_size / 1000000));
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
}

@end
