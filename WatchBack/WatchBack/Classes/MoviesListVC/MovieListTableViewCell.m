//
//  MovieListTableViewCell.m
//  Watchback
//
//  Created by perk on 16/06/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

#import "MovieListTableViewCell.h"
#import <SDWebImage/SDWebImage.h>
#import "Constants.h"
#import "JLManager.h"

@interface MovieListTableViewCell (){
    NSDictionary * movie;
}
@end
@implementation MovieListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _btnMovieInfo.layer.cornerRadius = 8.0;
    self.backgroundColor = [UIColor clearColor];
    _imvMovie.layer.cornerRadius = 5.0;
    _imvMovie.clipsToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnMovieInfoTapped:(id)sender {
    if(movie != nil && (id)movie != [NSNull null]){
        if([movie valueForKey:@"channel"] != nil &&
           [movie valueForKey:@"channel"] != [NSNull null]){
            NSString * destination_url;
            
            if([[movie valueForKey:@"channel"] valueForKey:@"ios_destination_url"] != nil &&
               [[movie valueForKey:@"channel"] valueForKey:@"ios_destination_url"] != [NSNull null]){
                 destination_url = [[movie valueForKey:@"channel"] valueForKey:@"ios_destination_url"];
            }else if([[movie valueForKey:@"channel"] valueForKey:@"default_destination_url"] != nil &&
                     [[movie valueForKey:@"channel"] valueForKey:@"default_destination_url"] != [NSNull null]){
                 destination_url = [[movie valueForKey:@"channel"] valueForKey:@"default_destination_url"];
                
            }else if([[movie valueForKey:@"channel"] valueForKey:@"destination_url"] != nil &&
                     [[movie valueForKey:@"channel"] valueForKey:@"destination_url"] != [NSNull null]){
                 destination_url = [[movie valueForKey:@"channel"] valueForKey:@"destination_url"];
            }
            
            if (destination_url && [destination_url isKindOfClass:[NSString class]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:destination_url] options:@{} completionHandler:nil];
            }

        }
    }
}

-(void)setMovie:(NSDictionary *)dictMovie{
    movie = dictMovie;
    _lblMovieTitle.textColor = kPrimaryTextColor;
    
    if(dictMovie != nil && (id)dictMovie != [NSNull null]){
        
        if([dictMovie valueForKey:@"name"] != nil &&
           (id)[dictMovie valueForKey:@"name"] != [NSNull null]){
            _lblMovieTitle.text = [dictMovie valueForKey:@"name"];
        }
        
        if([dictMovie valueForKey:@"thumbnail"] != nil &&
           (id)[dictMovie valueForKey:@"thumbnail"] != [NSNull null]){
//            [_imvMovie setImageURL:[NSURL URLWithString:[dictMovie valueForKey:@"thumbnail"]]];
            [_imvMovie sd_setImageWithURL:[NSURL URLWithString:[dictMovie valueForKey:@"thumbnail"]] placeholderImage:nil];
        }

        _btnMovieInfo.hidden = YES;
        if([dictMovie valueForKey:@"channel"] != nil &&
           [dictMovie valueForKey:@"channel"] != [NSNull null]){
            if([[dictMovie valueForKey:@"channel"] valueForKey:@"name"] != nil &&
               [[dictMovie valueForKey:@"channel"] valueForKey:@"name"] != [NSNull null])
                _btnMovieInfo.hidden = NO;
            [_btnMovieInfo setTitle:[NSString stringWithFormat:@"watch on %@",[[dictMovie valueForKey:@"channel"] valueForKey:@"name"]] forState:UIControlStateNormal];
        }
        
    }
}

@end
