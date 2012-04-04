//
//  ViewController.h
//  SimpleUDID
//
//  Created by Weipin Xia on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
  kSimpleUDIDKeychainErrorUnknown = -1001,
};


@interface ViewController : UIViewController
@property (retain, nonatomic) IBOutlet UILabel *label;

@end
