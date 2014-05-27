//
//  KeychainWrapper.h
//  ChristmasKeeper
//
//  Created by Chris Lowe on 10/31/11.
//  Copyright (c) 2011 USAA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Security;
#import <CommonCrypto/CommonDigest.h>

@interface KeychainWrapper : NSObject

// Generic exposed method to search the keychain for a given value.  Limit one result per search.
+ (NSData *)searchKeychainCopyMatchingIdentifier:(NSString *)identifier;

// Calls searchKeychainCopyMatchingIdentifier: and converts to a string value.
+ (NSString *)keychainStringFromMatchingIdentifier:(NSString *)identifier;

// Default initializer to store a value in the keychain.  
// Associated properties are handled for you (setting Data Protection Access, Company Identifer (to uniquely identify string, etc).
+ (BOOL)createKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;

// Updates a value in the keychain.  If you try to set the value with createKeychainValue: and it already exists
// this method is called instead to update the value in place.
+ (BOOL)updateKeychainValue:(NSString *)value forIdentifier:(NSString *)identifier;

// Delete a value in the keychain
+ (void)deleteItemFromKeychainWithIdentifier:(NSString *)identifier;

// Generates an SHA256 (much more secure than MD5) Hash
+ (NSString *)securedSHA256DigestHashForPIN:(NSUInteger)pinHash;
+ (NSString*)computeSHA256DigestForString:(NSString*)input;
+ (NSString*)computeSHA256DigestForData:(NSData*)data;

@end
