//
//  ViewChannel.h
//  Watchback
//
//  Created by perk on 06/07/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewChannel : UIView{
    NSDictionary * dictChannelInfo;
}
@property (strong, nonatomic) IBOutlet UILabel * lblName;
@property (strong, nonatomic) IBOutlet UIImageView * imvLogo;
@property (strong, nonatomic) IBOutlet UIButton * btnChannel;
@property (atomic, readwrite) BOOL isfavorite;
- (IBAction)BtnViewChannelTapped:(id)sender;
-(void)setChannel:(NSDictionary *)dict;
-(void)hideChannel:(BOOL)yesOrNo;
@end

NS_ASSUME_NONNULL_END
