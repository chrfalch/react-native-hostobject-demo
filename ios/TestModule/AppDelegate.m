/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "AppDelegate.h"

#import <React/RCTBridge+Private.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>

#import "Test.h"
#import "TestBinding.h"

@implementation AppDelegate {
  bool _hostObjectsInstalled;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
                                                   moduleName:@"TestModule"
                                            initialProperties:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleJavaScriptDidLoadNotification:)
                                               name:RCTJavaScriptDidLoadNotification
                                             object:bridge];
  
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

- (void)handleJavaScriptDidLoadNotification:(__unused NSNotification*)notification {
  
  // Guard against installing the module multiple times
  if(self->_hostObjectsInstalled) return;
  self->_hostObjectsInstalled = true;
  
  RCTCxxBridge* bridge = notification.userInfo[@"bridge"];
  facebook::jsi::Runtime* runtime = (facebook::jsi::Runtime*)bridge.runtime;
  auto test = std::make_unique<facebook::react::Test>();
  std::shared_ptr<facebook::react::TestBinding> testBinding_ = std::make_shared<facebook::react::TestBinding>(std::move(test));
  facebook::react::TestBinding::install((*runtime),  testBinding_);
}

@end
