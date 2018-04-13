//
//  QRDLoginViewController.m
//  QNRTCKitDemo
//
//  Created by 冯文秀 on 2018/1/16.
//  Copyright © 2018年 PILI. All rights reserved.
//

#import "QRDLoginViewController.h"
#import "QRDSettingViewController.h"
#import "QRDRTCViewController.h"
#import "QRDAgreementViewController.h"
#import "QRDUserNameView.h"
#import "QRDJoinRoomView.h"

#define QRD_LOGIN_TOP_SPACE (QRD_iPhoneX ? 140: 100)

@interface QRDLoginViewController ()
<
UITextFieldDelegate
>
@property (nonatomic, strong) QRDUserNameView *userView;
@property (nonatomic, strong) QRDJoinRoomView *joinRoomView;
@property (nonatomic, strong) UIButton *setButton;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, copy) NSString *userString;
@end

@implementation QRDLoginViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.view.backgroundColor = QRD_GROUND_COLOR;

    _userString = [[NSUserDefaults standardUserDefaults] objectForKey:@"QN_USER_ID"];
    
    BOOL isStorage = NO;
    if (_userString.length != 0) {
        isStorage = YES;
    }
    [self setupLoginViewWithStorage:isStorage];
    [self setupLogoView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(95, QRD_LOGIN_TOP_SPACE + 192, QRD_SCREEN_WIDTH - 198, QRD_SCREEN_HEIGHT - QRD_LOGIN_TOP_SPACE - 340)];
    self.imageView.image = [UIImage imageNamed:@"qn_niu"];
    [self.view addSubview:_imageView];
}

- (void)setupLoginViewWithStorage:(BOOL)storage {
    if (storage) {
        [self setupJoinRoomView];
    } else{
        _userView = [[QRDUserNameView alloc] initWithFrame:CGRectMake(QRD_SCREEN_WIDTH/2 - 150, QRD_LOGIN_TOP_SPACE, 308, 152)];
        _userView.userTextField.delegate = self;
        [_userView.nextButton addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *tapgesturerecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(agreementLabelTapped:)];
        [_userView.agreementLabel addGestureRecognizer:tapgesturerecognizer];
        [_userView.agreementButton addTarget:self action:@selector(agreementButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_userView];
    }
}

- (void)setupJoinRoomView {
    _joinRoomView = [[QRDJoinRoomView alloc] initWithFrame:CGRectMake(QRD_SCREEN_WIDTH/2 - 150, QRD_LOGIN_TOP_SPACE, 308, 185)];
    _joinRoomView.roomTextField.delegate = self;
    [_joinRoomView.joinButton addTarget:self action:@selector(joinAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_joinRoomView];
    
    _setButton = [[UIButton alloc] initWithFrame:CGRectMake(QRD_SCREEN_WIDTH - 36, QRD_LOGIN_TOP_SPACE - 68, 24, 24)];
    [_setButton setImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    [_setButton addTarget:self action:@selector(settingAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setButton];
    
    self.imageView.frame = CGRectMake(95, QRD_LOGIN_TOP_SPACE + 242, QRD_SCREEN_WIDTH - 190, QRD_SCREEN_HEIGHT - QRD_LOGIN_TOP_SPACE - 340);
}

- (void)setupLogoView {
    CGFloat bottomSpace = QRD_SCREEN_HEIGHT - 60;
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(QRD_SCREEN_WIDTH/2 - 1, bottomSpace - 29, 2, 22)];
    lineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:lineView];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(QRD_SCREEN_WIDTH/2 - 57, bottomSpace - 36, 36, 36)];
    logoImageView.image = [UIImage imageNamed:@"logo"];
    [self.view addSubview:logoImageView];
    
    UILabel *logoLabel = [[UILabel alloc] initWithFrame:CGRectMake(QRD_SCREEN_WIDTH/2 + 19, bottomSpace - 36, 68, 36)];
    logoLabel.textColor = [UIColor whiteColor];
    logoLabel.textAlignment = NSTextAlignmentLeft;
    logoLabel.font = QRD_LIGHT_FONT(16);
    logoLabel.text = @"牛会议";
    [self.view addSubview:logoLabel];
}

#pragma mark - button action
- (void)nextAction:(UIButton *)next {
    if (!_userView.agreementButton.selected) {
        [self showAlertWithMessage:@"需要同意用户协议才能继续！"];
        return;
    }

    if (_userView.userTextField.text.length != 0) {
        _userView.userTextField.text = [_userView.userTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([self checkUserId:_userView.userTextField.text]) {
            [_userView.userTextField resignFirstResponder];
            _userString = _userView.userTextField.text;
            [[NSUserDefaults standardUserDefaults] setObject:_userString forKey:@"QN_USER_ID"];
            [_userView removeFromSuperview];
            [self setupJoinRoomView];
        } else{
            [self showAlertWithMessage:@"请按要求正确填写昵称！"];
        }
    } else{
        [self showAlertWithMessage:@"请填写昵称！"];
    }
}

- (void)joinAction:(UIButton *)join {
    [self.view endEditing:YES];
    
    NSString *roomId;
    if (_joinRoomView.roomTextField.text.length != 0) {
        _joinRoomView.roomTextField.text = [_joinRoomView.roomTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([self checkRoomName:_joinRoomView.roomTextField.text]) {
            roomId = _joinRoomView.roomTextField.text;
        } else{
            [self showAlertWithMessage:@"请按要求正确填写房间名称！"];
            return;
        }
    } else{
        [self showAlertWithMessage:@"请填写房间名称！"];
        return;
    }
    QRDRTCViewController *rtcVC = [[QRDRTCViewController alloc] init];
    rtcVC.roomId = roomId;
    rtcVC.userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"QN_USER_ID"];
    
    NSDictionary *configDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"QN_SET_CONFIG"];
    if (configDic) {
        rtcVC.configDic = configDic;
    } else{
        rtcVC.configDic = @{@"VideoSize":NSStringFromCGSize(CGSizeMake(480, 640)), @"FrameRate":@20, @"Bitrate":@600};
    }
    [self.navigationController pushViewController:rtcVC animated:YES];
}

- (void)settingAction:(UIButton *)setting {
    QRDSettingViewController *settingVC = [[QRDSettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)agreementButtonClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.isSelected;
}

- (void)agreementLabelTapped:(id)sender {
    QRDAgreementViewController *agreementViewController = [[QRDAgreementViewController alloc] init];
    [self presentViewController:agreementViewController animated:YES completion:nil];
}

#pragma mark - textField delegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

#pragma mark --- 点击空白 ---
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark --- 键盘回收 ---
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
}

- (BOOL)checkUserId:(NSString *)userId {
    NSString *regString = @"^[a-zA-Z0-9_-]{3,50}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regString];
    BOOL result = [predicate evaluateWithObject:userId];
    return result;
}

- (BOOL)checkRoomName:(NSString *)roomName {
    NSString *regString = @"^[a-zA-Z0-9_-]{3,64}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regString];
    BOOL result = [predicate evaluateWithObject:roomName];
    return result;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end