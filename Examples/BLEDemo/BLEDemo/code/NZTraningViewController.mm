//
//  NZTraningViewController.m
//  BLEDemo
//
//  Created by Natalia Zarawska on 06/04/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import "NZTraningViewController.h"

@interface NZTraningViewController ()

@end


@implementation NZTraningViewController

@synthesize classNameTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // set the text field delegate to manage the input thext
    self.classNameTextField.delegate = self;
    [self.classNameTextField setText:self.currentClassLable];
    
 //   [self.recordControlButton setTitle:@"record" forState: (UIControlState)UIControlStateNormal];
//    [self.recordControlButton setTitle:@"" forState: (UIControlState)UIControlStateHighlighted];
    [self.recordControlButton addTarget:self action:@selector(recordControlButtonTapped:) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-  (void)recordControlButtonTapped:(id)sender {
    if ( [self.recordControlButton.titleLabel.text isEqualToString:@"stop"] ) {
        NSLog(@"start recording");
        self.menuVC.recordingData = true;
        // disable edidting
        self.recordControlButton.titleLabel.text = @"record";
    } else {
        NSLog(@"stop recording");
        self.menuVC.recordingData = true;
        self.recordControlButton.titleLabel.text = @"stop";
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate
#pragma mark -

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // NSLog(@"textFieldShouldReturn");
    self.menuVC.currentClassLabel = textField.text;
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // NSLog(@"textFieldShouldBeginEditing");
    textField.text = nil;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   // NSLog(@"textFieldDidBeginEditing");
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
   // NSLog(@"textFieldDidEndEditing");
}

@end
