//
//  SecondViewController.h
//  BVerifyClient
//
//  Created by Gert-Jaap Glasbergen on 26/03/2019.
//  Copyright © 2019 Gert-Jaap Glasbergen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController
@property (nonatomic, retain) NSString *foreignStatementBase64;
@property bool cancelled;
@property (nonatomic, retain) IBOutlet UITextView *statement;
@property (nonatomic, retain) IBOutlet UILabel *signedBy;
@property (nonatomic, retain) IBOutlet UILabel *valid;
@property (nonatomic, retain) IBOutlet UILabel *time;
@property (nonatomic, retain) IBOutlet UIButton *blockButton;
@property (nonatomic, retain) IBOutlet UIButton *txButton;

@end


