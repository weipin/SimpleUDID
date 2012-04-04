//
//  ViewController.m
//  SimpleUDID
//
//  Created by Weipin Xia on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Security/Security.h>

#import "ViewController.h"

NSString *const kSimpleUDIDKeychainDomain = @"com.xiaweipin.SimpleUDID";

@interface ViewController ()

@end

@implementation ViewController
@synthesize label;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  self.label.text = [self UUID];
}

- (void)viewDidUnload
{
  [self setLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSMutableDictionary *)keychainQuery {
  NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                (id)kSecClassGenericPassword, (id)kSecClass,
                                @"SimpleUDID", (id)kSecAttrGeneric,
                                nil];
  return query;
}

// check errSecItemNotFound
- (NSString *)UUIDFromKeychain:(NSError **)error {
  OSStatus status = kSimpleUDIDKeychainErrorUnknown;
  NSString *result = nil;
  CFDataRef passwordData = NULL;
  NSMutableDictionary *keychainQuery = [self keychainQuery];
  [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
  [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    
  status = SecItemCopyMatching((CFDictionaryRef)keychainQuery,
                                 (CFTypeRef *)&passwordData);
  if (status == noErr && [(NSData *)passwordData length]) {
    result = [[[NSString alloc] initWithData:(NSData *)passwordData
                                    encoding:NSUTF8StringEncoding] autorelease];
  }
  if (passwordData) {
    CFRelease(passwordData);
  }

  if (status != noErr && error != NULL) {
    *error = [NSError errorWithDomain:kSimpleUDIDKeychainDomain
                                 code:status
                             userInfo:nil];
  }
  
  return result;
}

- (BOOL)removeUUIDFromKeychain:(NSError **)error {
  OSStatus status = kSimpleUDIDKeychainErrorUnknown;
  NSMutableDictionary *keychainQuery = [self keychainQuery];
  status = SecItemDelete((CFDictionaryRef)keychainQuery);
  
  if (status != noErr && error != NULL) {
    *error = [NSError errorWithDomain:kSimpleUDIDKeychainDomain
                                 code:status
                             userInfo:nil];
  }
  return status == noErr;
}

- (BOOL)setUUIDToKeychain:(NSString *)UUID
                    error:(NSError **)error {
  OSStatus status = kSimpleUDIDKeychainErrorUnknown;
  [self removeUUIDFromKeychain:error];
  
  NSMutableDictionary *keychainQuery = [self keychainQuery];
  NSData *UUIDData = [UUID dataUsingEncoding:NSUTF8StringEncoding];
  [keychainQuery setObject:UUIDData forKey:(id)kSecValueData];
  status = SecItemAdd((CFDictionaryRef)keychainQuery, NULL);

  if (status != noErr && error != NULL) {
    *error = [NSError errorWithDomain:kSimpleUDIDKeychainDomain
                                 code:status
                             userInfo:nil];
  }
  return status == noErr;
}

- (NSString *)UUID {
  NSError *error = nil;
  NSString *UUIDString = [self UUIDFromKeychain:&error];  
  if (!UUIDString) {
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidStringRef = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);    
    UUIDString = (NSString *)uuidStringRef;
    [self setUUIDToKeychain:UUIDString error:&error];
    
    CFRelease(uuidRef);    
    [UUIDString autorelease];    
  }
  
  return UUIDString;
}

- (void)dealloc {
  [label release];
  [super dealloc];
}


@end
