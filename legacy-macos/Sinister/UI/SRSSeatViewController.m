//
//  SRSSeatViewController.m
//  Sinister
//
//  Created by Cameron Hotchkies on 3/2/14.
//  Copyright (c) 2014 Srs Biznas. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


#import "SRSSeatViewController.h"

#import "Player+Stats.h"
#import "SRSDealerButtonView.h"
#import "SRSSeatBackgroundView.h"
#import "Card+Constants.h"

@interface SRSSeatViewController ()

@end

@implementation SRSSeatViewController

Seat* __strong _seat;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    if (_seat == nil) {
        self.playerNameView.stringValue = @"[vacant]";
        self.playerNameView.textColor = [NSColor grayColor];
    } else {
        NSString* pn = _seat.player.name;
    }
}

- (void)addCardImages:(Seat*)s {
    
    NSString* img1eps = @"Blue_Back.eps";
    NSString* img2eps = @"Blue_Back.eps";
    
    NSArray* arr = [s.holeCards allObjects];
    
    if (arr.count > 0) {
        img1eps = [NSString stringWithFormat:@"%@.eps", [[((Card*) [arr objectAtIndex:0]) printable] uppercaseString]];
        img2eps = [NSString stringWithFormat:@"%@.eps", [[((Card*) [arr objectAtIndex:1]) printable] uppercaseString]];
    }
    
    NSImage* img1Pre = [NSImage imageNamed:img1eps];
    NSImage* img2Pre = [NSImage imageNamed:img2eps];
    
    CGRect c1Frame = CGRectMake(15, 20, 50, 70);
    CGRect c2Frame = CGRectMake(25, 16, 50, 70);
    NSImageView* c1 = [[NSImageView alloc] initWithFrame:c1Frame];
    NSImageView* c2 = [[NSImageView alloc] initWithFrame:c2Frame];
    
    c1.identifier = @"card";
    c2.identifier = @"card";
    
    [c1 setImage:img1Pre];
    [c2 setImage:img2Pre];
    
    
    [self.view addSubview:c1];
    [self.view addSubview:c2];
}

- (void)fold {
    
    NSMutableArray* cardViews = [NSMutableArray array];
    
    for (NSView* v in self.view.subviews) {
        if ([v.identifier isEqualToString:@"card"]) {
            [cardViews addObject:v];
        }
    }
    
    for (NSView* vc in cardViews) {
        [vc removeFromSuperview];
    }
    
}

- (void)setSeat:(Seat *)seat {
    _seat = seat;
    self.playerName = seat.player.name;
    
    [self.playerNameView setStringValue:self.playerName];
    self.playerNameView.textColor = [NSColor blackColor];
    
    NSRect bgFrame = CGRectMake(0, 0, self.backCircle.frame.size.width, self.backCircle.frame.size.height);
    SRSSeatBackgroundView* bg = [[SRSSeatBackgroundView alloc] initWithFrame:bgFrame];
    [self.backCircle addSubview:bg];
    
    [self addCardImages:seat];
    
    if (seat.isDealer) {
        [self.dealerButton setHidden:NO];
        
        
        CGRect dFrm = CGRectMake(0, 0, self.dealerButton.frame.size.width, self.dealerButton.frame.size.height);
        SRSDealerButtonView* dbtn = [[SRSDealerButtonView alloc] initWithFrame:dFrm];
        
        [self.dealerButton addSubview:dbtn];
        
    } else {
        [self.dealerButton setHidden:YES];
    }
}

- (Seat*)seat {
    return _seat;
}

@end
