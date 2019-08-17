//
//  ViewChannel.m
//  Watchback
//
//  Created by perk on 06/07/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "ViewChannel.h"
#import <SDWebImage.h>
#import "Constants.h"

@implementation ViewChannel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imvLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 100)];
        [self addSubview:_imvLogo];
        
        _lblName = [[UILabel alloc] initWithFrame:CGRectMake(0, _imvLogo.bounds.size.height+10, self.bounds.size.width, 50)];
        _lblName.numberOfLines = 0;
        _lblName.backgroundColor = [UIColor clearColor];
        _lblName.textColor = [UIColor whiteColor];
        _lblName.lineBreakMode = NSLineBreakByWordWrapping;
        _lblName.textAlignment = NSTextAlignmentCenter;
        _lblName.font = kFontSemiBold14;
        [self addSubview:_lblName];
        
        _btnChannel = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnChannel.frame = self.bounds;
        _btnChannel.backgroundColor = [UIColor clearColor];
        [_btnChannel addTarget:self action:@selector(BtnViewChannelTapped:) forControlEvents:UIControlEventTouchDown];
        [self bringSubviewToFront:_btnChannel];
        [self addSubview:_btnChannel];
    }
    return self;
}

- (IBAction)BtnViewChannelTapped:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenChannelNotification object:dictChannelInfo];
}

-(void)setChannel:(NSDictionary *)dict{
    dictChannelInfo = [[NSDictionary alloc] initWithDictionary:dict];
    
    if(dict != nil && (id)dict != [NSNull null]){
        
        if(_isfavorite){
        if([dict valueForKey:@"details_screen_logo_url"] != nil &&
           [dict valueForKey:@"details_screen_logo_url"] != [NSNull null]){
            NSURL * imageURL = [NSURL URLWithString:[dict valueForKey:@"details_screen_logo_url"]];
            [self.imvLogo sd_setImageWithURL:imageURL placeholderImage:nil];
        }else if([dict valueForKey:@"list_screen_logo_url"] != nil &&
                 [dict valueForKey:@"list_screen_logo_url"] != [NSNull null]){
            NSURL * imageURL = [NSURL URLWithString:[dict valueForKey:@"list_screen_logo_url"]];
            [self.imvLogo sd_setImageWithURL:imageURL placeholderImage:nil];
        }
        }else{
            if([dict valueForKey:@"list_screen_logo_url"] != nil &&
               [dict valueForKey:@"list_screen_logo_url"] != [NSNull null]){
                NSURL * imageURL = [NSURL URLWithString:[dict valueForKey:@"list_screen_logo_url"]];
                [self.imvLogo sd_setImageWithURL:imageURL placeholderImage:nil];
            }
        }
     
        if([dict valueForKey:@"name"] != nil &&
           [dict valueForKey:@"name"] != [NSNull null]){
            self.lblName.text = [dict valueForKey:@"name"];
        }
        
        if(_isfavorite){
            self.imvLogo.layer.cornerRadius = self.imvLogo.bounds.size.width/2.0;
            self.imvLogo.layer.masksToBounds = YES;
        }else{
            self.imvLogo.layer.cornerRadius = NO;
            self.imvLogo.layer.masksToBounds = YES;
        }
        
    }
    
}

-(void)hideChannel:(BOOL)yesOrNo{
    if(yesOrNo){
        self.userInteractionEnabled = false;
        self.imvLogo.image = nil;
        self.lblName.text = @"";
    }else{
        self.userInteractionEnabled = true;
    }
}

@end
