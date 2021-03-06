/**
    This file is part of Adguard for iOS (https://github.com/AdguardTeam/AdguardForiOS).
    Copyright © 2015 Performix LLC. All rights reserved.

    Adguard for iOS is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Adguard for iOS is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Adguard for iOS.  If not, see <http://www.gnu.org/licenses/>.
*/
#import "AEUIEditRuleController.h"
#import "ASDFilterObjects.h"

/////////////////////////////////////////////////////////////////////
#pragma mark - AEUIEditRuleController Constants
/////////////////////////////////////////////////////////////////////
NSString *AENbspCode = @"\u00A0";

NSString *AERuleDocunebtationUrlString = @"http://adguard.com/filterrules.html";

/////////////////////////////////////////////////////////////////////
#pragma mark - AEUIEditRuleController
/////////////////////////////////////////////////////////////////////

@interface AEUIEditRuleController (){
    
    CGFloat _initialConstantOfBottomConstraint;
}

@end

@implementation AEUIEditRuleController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(keyboardDidChangeFrameWithNotification:)
               name:UIKeyboardDidChangeFrameNotification
             object:nil];

    _initialConstantOfBottomConstraint = self.bottomConstraint.constant;
    _done = NO;
    
    [self initBottomText];
    
    if (!self.rule) {
        self.rule = [ASDFilterRule new];
        self.rule.isEnabled = @(YES);
        self.rule.ruleText = @"";
    }
    else
        self.ruleTextField.text = self.rule.ruleText;
    
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
          [self.ruleTextField becomeFirstResponder];
        });
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

/////////////////////////////////////////////////////////////////////
#pragma mark Delegate methods
/////////////////////////////////////////////////////////////////////

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    [self clickDone:textField];
    
    return NO;
}

/////////////////////////////////////////////////////////////////////
#pragma mark Actions
/////////////////////////////////////////////////////////////////////
- (IBAction)clickDone:(id)sender {

    self.rule.ruleText = self.ruleTextField.text;
    _done = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

/////////////////////////////////////////////////////////////////////
#pragma mark Private methods
/////////////////////////////////////////////////////////////////////


- (void)keyboardDidChangeFrameWithNotification:(NSNotification *)notification {
    CGFloat keyboardVerticalIncrease = [self keyboardVerticalIncreaseForNotification:notification];
    [self animateTextViewFrameForVerticalOffset:keyboardVerticalIncrease];
}

- (CGFloat)keyboardVerticalIncreaseForNotification:(NSNotification *)notification {
    CGFloat keyboardBeginY = [[UIScreen mainScreen] bounds].size.height;
    CGFloat keyboardEndY = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    
    CGFloat keyboardVerticalIncrease = keyboardBeginY - keyboardEndY;
    return keyboardVerticalIncrease / 2;
}

- (void)animateTextViewFrameForVerticalOffset:(CGFloat)offset {
    [UIView animateWithDuration:0.5 animations:^{
//        [self.view layoutIfNeeded];
        self.bottomConstraint.constant = _initialConstantOfBottomConstraint - offset;
    }];
}

- (void)initBottomText{

    NSString *messageBegin = NSLocalizedString(@"You can learn more about filter rules syntax from [this article].", @"(AEUIEditRuleController) On screen of rule adding/editing. Text, that describes where user can find info about rule syntax. Where text in square brackets is the link text of the website with the decription.");
    
    NSString *linkText;
    NSString *messageEnd;
    NSArray *first = [messageBegin componentsSeparatedByString:@"["];
    if (first.count == 2) {

        NSArray *second = [first[1] componentsSeparatedByString:@"]"];
        if (second.count == 2) {
            
            messageBegin = first[0];
            linkText = [second[0] stringByReplacingOccurrencesOfString:@" "
                                                            withString:AENbspCode];
            messageEnd = second[1];
        }
    }
    
    NSMutableAttributedString *textString = [[NSMutableAttributedString alloc] initWithString:messageBegin];
    
    if (linkText) {
        
        NSAttributedString *link = [[NSAttributedString alloc]
                                    initWithString: linkText
                                    attributes:@{NSLinkAttributeName: [NSURL URLWithString:AERuleDocunebtationUrlString]}];
        [textString appendAttributedString:link];
        [textString appendAttributedString:[[NSAttributedString alloc] initWithString:messageEnd]];
    }

    self.bottomTexView.attributedText = textString;
    self.bottomTexView.textAlignment = NSTextAlignmentCenter;
}

@end
