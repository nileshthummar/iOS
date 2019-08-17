//
//  MovieListTableViewCell.h
//  Watchback
//
//  Created by perk on 16/06/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/SDWebImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface MovieListTableViewCell : UITableViewCell
- (IBAction)btnMovieInfoTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnMovieInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblMovieDate;
@property (weak, nonatomic) IBOutlet UILabel *lblMovieTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imvMovie;
-(void)setMovie:(NSDictionary *)dictMovie;
@end

NS_ASSUME_NONNULL_END
