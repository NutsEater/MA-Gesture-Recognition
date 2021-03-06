//
//  NZClassifyViewController.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 13/04/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NZClassifyViewController;

@protocol NZClassifyViewControllerDelegate <NSObject>

@required
- (void)startClassifying;
- (void)updateClassifiedLable:(NZClassifyViewController *)classificationVC withLabel:(NSString *)classLabel;

@end

@interface NZClassifyViewController : UIViewController

@property (weak, nonatomic) id<NZClassifyViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *classifyButton;
@property (nonatomic) NSString *currentClassifyButtonLable;
@property (weak, nonatomic) IBOutlet UILabel *classifiedClassLabel;
@property (nonatomic) NSString *currentClassifiedLabel;
@property (nonatomic) BOOL isPipelineTrained;

- (IBAction)classifyButtonTapped:(id)sender;
@end
