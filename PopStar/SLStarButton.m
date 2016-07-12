//
//  SLStarButton.m
//  PopStar
//
//  Created by songlong on 16/7/12.
//  Copyright © 2016年 SaberGame. All rights reserved.
//

#import "SLStarButton.h"

@implementation SLStarButton

- (void)dismiss {
    CGRect frame = self.frame;
    
    
    
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(frame.origin.x + frame.size.width / 2, frame.origin.y + frame.size.height / 2, 0, 0);
    }];
}

@end
