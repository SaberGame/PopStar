//
//  SLMainViewController.m
//  PopStar
//
//  Created by songlong on 16/7/6.
//  Copyright © 2016年 SaberGame. All rights reserved.
//

#import "SLMainViewController.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface SLMainViewController ()

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) NSMutableArray *linkedButtonsArray;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) BOOL isPopScore;

@end

@implementation SLMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _linkedButtonsArray = [NSMutableArray array];
    _score = 0;
    [self setupUI];
}

- (void)setupUI {
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (kScreenHeight - kScreenWidth) / 4 - 15, kScreenWidth, 30)];
    _scoreLabel.text = [NSString stringWithFormat:@"分数：%zd", _score];
    _scoreLabel.textAlignment = NSTextAlignmentCenter;
    _scoreLabel.font = [UIFont systemFontOfSize:15];
    _scoreLabel.textColor = [UIColor redColor];
    [self.view addSubview:_scoreLabel];
    
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (kScreenHeight - kScreenWidth) / 2 - 50, kScreenWidth, 30)];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.font = [UIFont systemFontOfSize:24];
    _tipLabel.textColor = [UIColor redColor];
    [self.view addSubview:_tipLabel];

    
    _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, (kScreenHeight - kScreenWidth) / 2, kScreenWidth, kScreenWidth)];
    _mainView.tag = 9999;
    _mainView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_mainView];
    
    for (int i = 0; i < 100; i++) {
    
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i % 10 * (kScreenWidth / 10), i / 10 * (kScreenWidth / 10), kScreenWidth / 10, kScreenWidth / 10)];
        button.backgroundColor = [self randomColor];
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 2;
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [_mainView addSubview:button];
    }
    [self setButtonTag];
}

- (void)clickButton:(UIButton *)sender {
    
    NSLog(@"%zd", sender.tag);
    _tipLabel.text = nil;
    
    if (!_isPopScore ) {
        [self getLinkedButtons:sender];
        [self popScore];
    } else {
        if ([_linkedButtonsArray containsObject:sender]) {
            [self deleteLinkedButtons];
            [self resetButtons];
        } else {
            [self resetBorderColor];
            [_linkedButtonsArray removeAllObjects];
            [self getLinkedButtons:sender];
            [self popScore];
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setButtonTag];
    });
}

- (void)resetBorderColor {
    for (UIButton *btn in _linkedButtonsArray) {
        btn.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

- (void)popScore {
    _isPopScore = YES;
    
    _tipLabel.text = [NSString stringWithFormat:@"%zd连消除%zd分", _linkedButtonsArray.count, [self addScore:_linkedButtonsArray]];
    
    for (UIButton *btn in _linkedButtonsArray) {
        btn.layer.borderColor = [UIColor blackColor].CGColor;
        CGRect frame = btn.frame;
        [UIView animateWithDuration:0.1 animations:^{
            btn.frame = CGRectMake(frame.origin.x, frame.origin.y - kScreenWidth / 20, frame.size.width, frame.size.height);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                btn.frame = frame;
            }];
        }];
    }
}

- (void)resetButtons {
    for (int i = 0; i < 10; i++) {
        NSMutableArray *columnArray = [NSMutableArray array];
        NSMutableArray *blankArray = [NSMutableArray array];
        for (int j = 0; j < 10; j++) {
            NSInteger tagNum = i + j * 10;
            UIButton *button = [_mainView viewWithTag:tagNum];
            if (button) {
                [columnArray addObject:button];
            } else {
                [blankArray addObject:@(j)];
            }
        }
        
        for (int i = 0; i < columnArray.count; i++) {
            UIButton *btn = columnArray[i];
            NSInteger deleteCount = [blankArray.lastObject integerValue] + 1 - blankArray.count;
            NSInteger target = [blankArray.lastObject integerValue] - deleteCount + 1 + i;
            CGRect originFrame = btn.frame;
            if (btn.tag / 10 < [blankArray.lastObject integerValue]) {
                [UIView animateWithDuration:0.3 animations:^{
                    btn.frame = CGRectMake(originFrame.origin.x, originFrame.origin.y + (target - btn.tag / 10) * (kScreenWidth / 10), originFrame.size.width, originFrame.size.height);
                }];
            }
        }
       
        
    }
}



- (void)deleteLinkedButtons {
    _isPopScore = NO;
    NSInteger addScore = [self addScore:_linkedButtonsArray];
    _score += addScore;
    _scoreLabel.text = [NSString stringWithFormat:@"分数：%zd", _score];
    
    for (UIButton *button in _linkedButtonsArray) {
        [button removeFromSuperview];
    }
    _linkedButtonsArray = [NSMutableArray array];
}

- (NSInteger)addScore:(NSArray *)array {
    return ((array.count - 2) * 5 + 10) * array.count;
}

- (void)getLinkedButtons:(UIButton *)sender {
    [self checkFourButtons:sender];
}

- (void)checkFourButtons:(UIButton *)sender {
    
    UIButton *buttonLeft = nil;
    UIButton *buttonRight = nil;
    UIButton *buttonTop = nil;
    UIButton *buttonBottom = nil;
    
    if (sender.tag % 10 != 0) {
        buttonLeft = [self.view viewWithTag:sender.tag - 1];
    }
    
    if (sender.tag % 10 != 9) {
        buttonRight = [self.view viewWithTag:sender.tag + 1];
    }
    
    if (sender.tag / 10 != 0) {
        buttonTop = [self.view viewWithTag:sender.tag - 10];
    }
    
    if (sender.tag / 10 != 9) {
        buttonBottom = [self.view viewWithTag:sender.tag + 10];
    }
    
    
    if ((buttonLeft && buttonLeft.backgroundColor == sender.backgroundColor && ![_linkedButtonsArray containsObject:buttonLeft]) || (buttonRight && buttonRight.backgroundColor == sender.backgroundColor && ![_linkedButtonsArray containsObject:buttonRight]) || (buttonTop && buttonTop.backgroundColor == sender.backgroundColor && ![_linkedButtonsArray containsObject:buttonTop]) || (buttonBottom && buttonBottom.backgroundColor == sender.backgroundColor && ![_linkedButtonsArray containsObject:buttonBottom])) {
       
        [_linkedButtonsArray addObject:sender];
    } else {
        if (_linkedButtonsArray.count > 0) {
            [_linkedButtonsArray addObject:sender];
        }
        return;
    }
    
    if (buttonLeft && buttonLeft.backgroundColor == sender.backgroundColor && ![_linkedButtonsArray containsObject:buttonLeft]) {
        [self checkFourButtons:buttonLeft];
    }
    
    if (buttonRight && buttonRight.backgroundColor == sender.backgroundColor && ![_linkedButtonsArray containsObject:buttonRight]) {
        [self checkFourButtons:buttonRight];
    }
    
    if (buttonTop && buttonTop.backgroundColor == sender.backgroundColor && ![_linkedButtonsArray containsObject:buttonTop]) {
        [self checkFourButtons:buttonTop];
    }
    
    if (buttonBottom && buttonBottom.backgroundColor == sender.backgroundColor && ![_linkedButtonsArray containsObject:buttonBottom]) {
        [self checkFourButtons:buttonBottom];
    }
}

- (UIColor *)randomColor {
    NSInteger num = arc4random() % 5;
    switch (num) {
        case 0:
            return [UIColor redColor];
            break;
            
        case 1:
            return [UIColor yellowColor];
            break;
            
        case 2:
            return [UIColor blueColor];
            break;
            
        case 3:
            return [UIColor greenColor];
            break;
            
        case 4:
            return [UIColor purpleColor];
            break;
            
        default:
            return nil;
            break;
    }
}

- (void)setButtonTag {
    for (UIButton *button in _mainView.subviews) {
        button.tag = button.frame.origin.x / (kScreenWidth / 10) + button.frame.origin.y / (kScreenWidth / 10) * 10;
    }
}


@end
