//
//  ViewController.m
//  Facebook_linkTest
//
//  Created by SDT-1 on 2014. 1. 21..
//  Copyright (c) 2014년 T. All rights reserved.
//

#import "ViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>


#define FACEBOOK_APPID @"344325922372478"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *gender;
@property (weak, nonatomic) IBOutlet UITextView *about;
@property (weak, nonatomic) IBOutlet UIImageView *profile;
@property (weak, nonatomic) IBOutlet UILabel *link;
@property (weak, nonatomic) IBOutlet UILabel *update;

@property (strong,nonatomic)ACAccount *facebookAccount;
@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated{
    [self showMyProfile];
}

- (void)showMyProfile{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    
    NSDictionary *options = @{ACFacebookAppIdKey: FACEBOOK_APPID,
                              ACFacebookPermissionsKey: @[@"basic_info"],
                              ACFacebookAudienceKey:ACFacebookAudienceEveryone};
    [accountStore requestAccessToAccountsWithType:accountType options:options completion:^(
                                                                                           BOOL granted,NSError *error){
        if(granted){
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            self.facebookAccount = [accounts lastObject];
            [self requestProfile];
        }
        else{
            NSLog(@"fall %@",error);
        }
    }];
}

-(void)requestProfile{
    NSString *serviceType = SLServiceTypeFacebook;
    SLRequestMethod method =SLRequestMethodGET;
    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me"];
    NSDictionary *param = @{@"fields": @"picture,name,about,gender,link,updated_time"};
    SLRequest *request = [SLRequest requestForServiceType:serviceType requestMethod:method URL:url parameters:param];
    request.account = self.facebookAccount;
    
    [request performRequestWithHandler:^(NSData *responseData,NSHTTPURLResponse *urlResponse,NSError *error){
        if(nil != error){
            NSLog(@"프로필 정보 얻기 실패 %@",error);
            return ;
        }
        
        __autoreleasing NSError *parseError = nil;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&parseError];
        
        NSDictionary *picture = result[@"picture"][@"data"];
        NSString *imageUrlStr = picture[@"url"];
        NSURL *url = [NSURL URLWithString:imageUrlStr];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.name.text = result[@"name"];
            self.about.text = result[@"about"];
            self.gender.text = result[@"gender"];
            self.update.text = result[@"updated_time"];
            self.link.text = result[@"link"];
            self.profile.image = image;
        }];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
