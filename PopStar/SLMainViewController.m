//
//  SLMainViewController.m
//  PopStar
//
//  Created by songlong on 16/7/6.
//  Copyright © 2016年 SaberGame. All rights reserved.
//

#import "SLMainViewController.h"
#import "SLStarButton.h"
#import "Masonry.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface SLMainViewController ()

@property (nonatomic, strong) NSMutableArray *linkedButtonsArray;
@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIView *mainView;

@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, assign) NSInteger score;

@property (nonatomic, strong) UILabel *targetLabel;
@property (nonatomic, assign) NSInteger target;

@property (nonatomic, strong) UILabel *chapterLabel;

@property (nonatomic, assign) BOOL isPopScore;


@end

@implementation SLMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _linkedButtonsArray = [NSMutableArray array];
    _score = 0;
    _target = 1000;
    [self setupUI];
}

- (void)setupUI {
    
    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_layer"]];
    bgView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:bgView];
    
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    
    _chapterLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _chapterLabel.font = [UIFont fontWithName:@"FZJianZhi-M23S" size:18];
    _chapterLabel.textColor = [UIColor whiteColor];
    _chapterLabel.text = [NSString stringWithFormat:@"关卡: 1"];
    [topView addSubview:_chapterLabel];
    [_chapterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(20);
    }];

    
    _targetLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _targetLabel.font = [UIFont fontWithName:@"FZJianZhi-M23S" size:18];
    _targetLabel.textColor = [UIColor whiteColor];
    _targetLabel.text = [NSString stringWithFormat:@"目标: %zd", _target];
    [topView addSubview:_targetLabel];
    [_targetLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
    }];
    
    UIView *midView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:midView];
    [midView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
        make.top.equalTo(topView.mas_bottom);
    }];
    
    _scoreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _scoreLabel.text = [NSString stringWithFormat:@"%zd", _score];
    _scoreLabel.font = [UIFont fontWithName:@"FZJianZhi-M23S" size:22];
    _scoreLabel.textColor = [UIColor yellowColor];
    [midView addSubview:_scoreLabel];
    [_scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
    }];
    
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _tipLabel.font = [UIFont fontWithName:@"FZJianZhi-M23S" size:17];
    _tipLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_tipLabel];
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(midView.mas_bottom);
    }];
    
    
    
    _mainView = [[UIView alloc] initWithFrame:CGRectZero];
    _mainView.tag = 9999;
    _mainView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_mainView];
    [_mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(kScreenWidth);
        make.bottom.mas_equalTo(-50);
    }];
    
    for (int i = 0; i < 100; i++) {
    
        SLStarButton *button = [[SLStarButton alloc] initWithFrame:CGRectMake(i % 10 * (kScreenWidth / 10), i / 10 * (kScreenWidth / 10), kScreenWidth / 10, kScreenWidth / 10)];
        button.colorType = [self randomType];
        [button setBackgroundImage:[UIImage imageNamed:[self randomBackGroundByColorType:button.colorType]] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [_mainView addSubview:button];
    }
    [self setButtonTag];
}

- (void)clickButton:(SLStarButton *)sender {
    
    NSLog(@"%zd", sender.tag);
    _tipLabel.text = nil;
    
    if (!_isPopScore ) {
        [self getLinkedButtons:sender];
        [self popScore];
    } else {
        if ([_linkedButtonsArray containsObject:sender]) {
            [self deleteLinkedButtons];
            [self resetButtons];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self setButtonTag];
            });
        } else {
            [self resetBorderColor];
            [_linkedButtonsArray removeAllObjects];
            [self getLinkedButtons:sender];
            [self popScore];
        }
    }
}

- (void)resetBorderColor {
    for (SLStarButton *btn in _linkedButtonsArray) {
        btn.layer.borderColor = [UIColor clearColor].CGColor;
        btn.layer.borderWidth = 0;
    }
}

- (void)popScore {
    _isPopScore = YES;
    
    if (_linkedButtonsArray.count >= 2) {
        _tipLabel.text = [NSString stringWithFormat:@"%zd 连消 %zd 分", _linkedButtonsArray.count, [self addScore:_linkedButtonsArray]];
    }
    
    for (SLStarButton *btn in _linkedButtonsArray) {
        btn.layer.borderColor = [UIColor whiteColor].CGColor;
        btn.layer.borderWidth = 0.5;
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
            SLStarButton *button = [_mainView viewWithTag:tagNum];
            if (button) {
                [columnArray addObject:button];
            } else {
                [blankArray addObject:@(j)];
            }
        }
        
        for (int i = 0; i < columnArray.count; i++) {
            SLStarButton *btn = columnArray[i];
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
    _scoreLabel.text = [NSString stringWithFormat:@"%zd", _score];
    
    for (SLStarButton *button in _linkedButtonsArray) {
        [button removeFromSuperview];
    }
    _linkedButtonsArray = [NSMutableArray array];
}

- (NSInteger)addScore:(NSArray *)array {
    return ((array.count - 2) * 5 + 10) * array.count;
}

- (void)getLinkedButtons:(SLStarButton *)sender {
    [self checkFourButtons:sender];
}

- (void)checkFourButtons:(SLStarButton *)sender {
    
    SLStarButton *buttonLeft = nil;
    SLStarButton *buttonRight = nil;
    SLStarButton *buttonTop = nil;
    SLStarButton *buttonBottom = nil;
    
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
    
    
    if ((buttonLeft && buttonLeft.colorType == sender.colorType && ![_linkedButtonsArray containsObject:buttonLeft]) || (buttonRight && buttonRight.colorType == sender.colorType && ![_linkedButtonsArray containsObject:buttonRight]) || (buttonTop && buttonTop.colorType == sender.colorType && ![_linkedButtonsArray containsObject:buttonTop]) || (buttonBottom && buttonBottom.colorType == sender.colorType && ![_linkedButtonsArray containsObject:buttonBottom])) {
       
        [_linkedButtonsArray addObject:sender];
    } else {
        if (_linkedButtonsArray.count > 0) {
            [_linkedButtonsArray addObject:sender];
        }
        return;
    }
    
    if (buttonLeft && buttonLeft.colorType == sender.colorType && ![_linkedButtonsArray containsObject:buttonLeft]) {
        [self checkFourButtons:buttonLeft];
    }
    
    if (buttonRight && buttonRight.colorType == sender.colorType && ![_linkedButtonsArray containsObject:buttonRight]) {
        [self checkFourButtons:buttonRight];
    }
    
    if (buttonTop && buttonTop.colorType == sender.colorType && ![_linkedButtonsArray containsObject:buttonTop]) {
        [self checkFourButtons:buttonTop];
    }
    
    if (buttonBottom && buttonBottom.colorType == sender.colorType && ![_linkedButtonsArray containsObject:buttonBottom]) {
        [self checkFourButtons:buttonBottom];
    }
}

- (NSInteger)randomType {
    return arc4random() % 5;
}

- (NSString *)randomBackGroundByColorType:(NSInteger)colorType {
    switch (colorType) {
        case 0:
            return @"block_blue";
            break;
            
        case 1:
            return @"block_green";
            break;

            
        case 2:
            return @"block_purple";
            break;

            
        case 3:
            return @"block_yellow";
            break;

            
        case 4:
            return @"block_red";
            break;

            
        default:
            return nil;
            break;
    }
}

- (void)setButtonTag {
    for (SLStarButton *button in _mainView.subviews) {
        button.tag = button.frame.origin.x / (kScreenWidth / 10) + button.frame.origin.y / (kScreenWidth / 10) * 10;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


@end
