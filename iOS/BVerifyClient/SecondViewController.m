//
//  SecondViewController.m
//  BVerifyClient
//
//  Created by Gert-Jaap Glasbergen on 26/03/2019.
//  Copyright © 2019 Gert-Jaap Glasbergen. All rights reserved.
//

#import "SecondViewController.h"
#import "QRCodeReaderViewController/QRCodeReaderViewController.h"
#import "BVerifyManager.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    if(_foreignStatementBase64 == nil && !self.cancelled){
        [self scanQR];
    }
}

- (IBAction)scanNew {
    [self scanQR];
}

- (void)scanQR {
    self.cancelled = false;
    [self.statement setText:@""];
    [self.signedBy setText:@""];
    [self.valid setText:@""];
    [self.blockButton setTitle:@"" forState:UIControlStateNormal];
    [self.txButton setTitle:@"" forState:UIControlStateNormal];
    [self.time setText:@""];
    
    // Create the reader object
    QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // Instantiate the view controller
    QRCodeReaderViewController *qrvc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
    
    // Set the presentation style
    qrvc.modalPresentationStyle = UIModalPresentationFormSheet;
    
    // Or use blocks
    [qrvc setCompletionWithBlock:^(NSString *resultAsString) {
        if(resultAsString != nil) {
            self.foreignStatementBase64 = resultAsString;
            [self updateVerification];
        } else {
            self.cancelled = true;
        }
        [qrvc dismissViewControllerAnimated:YES completion:nil];
    }];
    
  
    

    
    [self presentViewController:qrvc animated:YES completion:nil];
}

- (void)openUrl:(NSString *)url {
    if( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (IBAction) viewBlock {
    NSString *blockHash = [self.blockButton currentTitle];
    [self openUrl:[NSString stringWithFormat:@"https://live.blockcypher.com/btc-testnet/block/%@", blockHash]];
}

- (IBAction) viewTx {
    NSString *txHash = [self.txButton currentTitle];
    [self openUrl:[NSString stringWithFormat:@"https://live.blockcypher.com/btc-testnet/tx/%@", txHash]];
}

- (void) updateVerification {
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];

    
    [BVerifyManager verifyOnce:_foreignStatementBase64 withCallback:^(BVerifyVerificationResult *result) {
        [self.statement setText:result.statement];
        [self.signedBy setText:result.pubKey];
        if(result.valid) {
            [self.blockButton setTitle:result.blockHash forState:UIControlStateNormal];
            [self.txButton setTitle:result.txHash forState:UIControlStateNormal];           
            [self.valid setText:@"OK"];
            [self.time setText:[df stringFromDate:result.time]];
        } else {
            [self.valid setText:[NSString stringWithFormat:@"ERROR: %@", result.error]];
            [self.blockButton setTitle:@"" forState:UIControlStateNormal];
            [self.txButton setTitle:@"" forState:UIControlStateNormal];
            [self.time setText:@""];
        }
    }];
}


@end
