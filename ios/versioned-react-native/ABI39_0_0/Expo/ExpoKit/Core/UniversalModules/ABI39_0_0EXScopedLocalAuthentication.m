// Copyright © 2019-present 650 Industries. All rights reserved.

#if __has_include(<ABI39_0_0EXLocalAuthentication/ABI39_0_0EXLocalAuthentication.h>)
#import "ABI39_0_0EXScopedLocalAuthentication.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <ABI39_0_0UMCore/ABI39_0_0UMUtilities.h>
#import "ABI39_0_0EXConstantsBinding.h"
#import <ABI39_0_0UMConstantsInterface/ABI39_0_0UMConstantsInterface.h>

@interface ABI39_0_0EXScopedLocalAuthentication ()

@property (nonatomic, assign) BOOL isInExpoClient;

@end

@implementation ABI39_0_0EXScopedLocalAuthentication

- (void)setModuleRegistry:(ABI39_0_0UMModuleRegistry *)moduleRegistry
{
  _isInExpoClient = [((ABI39_0_0EXConstantsBinding *)[moduleRegistry getModuleImplementingProtocol:@protocol(ABI39_0_0UMConstantsInterface)]).appOwnership isEqualToString:@"expo"];
}

ABI39_0_0UM_EXPORT_METHOD_AS(authenticateAsync,
                    authenticateWithOptions:(NSDictionary *)options
                    resolve:(ABI39_0_0UMPromiseResolveBlock)resolve
                    reject:(ABI39_0_0UMPromiseRejectBlock)reject)
{
  BOOL isInExpoClient = _isInExpoClient;
  [super authenticateWithOptions:options resolve:^(NSDictionary *result) {
    if (isInExpoClient && [[self class] isFaceIdDevice]) {
      NSString *usageDescription = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"NSFaceIDUsageDescription"];

      if (!usageDescription) {
        NSMutableDictionary *scopedResult = [[NSMutableDictionary alloc] initWithDictionary:result];
        scopedResult[@"warning"] = @"FaceID is not available in Expo Client. You can use it in a standalone Expo app by providing `NSFaceIDUsageDescription`.";
        resolve(scopedResult);
        return;
      }
    }
    resolve(result);
  } reject:reject];
}

@end
#endif
