//
//  YYGAboutViewController.m
//  Ledger
//
//  Created by Ян on 23/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YYGAboutViewController.h"
#import "YGTools.h"

@interface YYGAboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelApplicationName;

@property (weak, nonatomic) IBOutlet UILabel *labelApplicationVersion;

@property (weak, nonatomic) IBOutlet UILabel *labelCopyright;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsCommon;

@end

@implementation YYGAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"About Ledger";
    
    self.labelApplicationName.text = @"Ledger";
    self.labelApplicationVersion.text = [NSString stringWithFormat:@"Version: %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];

    self.labelCopyright.text = @"© Yan Gerasimuk";
    
    // name
    NSDictionary *attributesName = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:[YGTools defaultFontSize]+6]
                                     };
    NSAttributedString *attributedName = [[NSAttributedString alloc] initWithString:self.labelApplicationName.text attributes:attributesName];
    
    self.labelApplicationName.attributedText = attributedName;
    
    // other labels
    for(UILabel *label in self.labelsCommon){
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]]
                                     };
        
        NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:label.text attributes:attributes];
        
        label.attributedText = attributed;
    }
    
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
