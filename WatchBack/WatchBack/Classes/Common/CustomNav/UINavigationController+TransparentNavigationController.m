//
//  UINavigationController+TransparentNavigationController.m
//  Watchback
//
//  Created by Nilesh on 3/28/18.
//  Copyright © 2018 Nilesh. All rights reserved.
//

#import "UINavigationController+TransparentNavigationController.h"
#import "Constants.h"
#import "JLManager.h"
@implementation UINavigationController (TransparentNavigationController)
- (void)showTransparentNavigationBar
{
    self.navigationBar.translucent = YES;
    self.view.backgroundColor = [UIColor clearColor];
    self.navigationBar.backgroundColor = [UIColor clearColor];


}

- (void)showNonTransparentNavigationBar
{
    self.navigationBar.translucent = NO;
    self.view.backgroundColor = kPrimaryBGColor;
    self.navigationBar.backgroundColor = kPrimaryBGColor;

}
@end
