//
//  PaymentWebController.m
//  PayUIntegration
//
//  Created by pulkitarora on 4/27/17.
//  Copyright © 2017 pulkitarora. All rights reserved.
//

#import "PaymentWebController.h"
#import <CommonCrypto/CommonDigest.h>
#import "SHA512.h"

#define TEST 1

#define KEY TEST ? @"gtKFFx" : @"YOUR_PRODUCTION_KEY"
#define SALT TEST ? @"eCwWELxi" : @"YOUR_PRODUCTION_KEY"
#define PAYU_BASE_URL TEST ? @"https://test.payu.in" : @"https://secure.payu.in"

@interface PaymentWebController ()<UIWebViewDelegate>{
    //var merchantKey = “xxxx”
    //var salt = “xxxxx”
    //var PayUBaseUrl = "https://test.payu.in"
    
    //Production
    
//    NSString * merchantKey = “xxxxxx”;
//    NSString * salt = “xxxxx”;
//    NSString * PayUBaseUrl = "https://secure.payu.in";
    
    NSString * merchantKey;
    NSString * salt;
    NSString * PayUBaseUrl;
    
    NSString * hashKey;
    NSString * productInfo;
    NSString * firstName;
    NSString * email;
    NSString * phone;
    NSString * successUrl;
    NSString * failureUrl;
    NSString * service_provider;
    NSString * txnid1;
    NSString * totalPriceAmount;
    
    UIActivityIndicatorView *activityIndicatorView;

}

@property(nonatomic, strong) IBOutlet UIWebView * webView;
@end

@implementation PaymentWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    activityIndicatorView = [[UIActivityIndicatorView alloc] init];
    activityIndicatorView.center = self.view.center;
    [activityIndicatorView setColor:[UIColor blackColor]];
    [self.view addSubview:activityIndicatorView];
    
    
    _webView.delegate = self;
    
    txnid1 = [NSString stringWithFormat:@"%ld", arc4random() % 9999999999];
    totalPriceAmount = @"10";
    merchantKey = KEY;
    salt = SALT;
    PayUBaseUrl = PAYU_BASE_URL;
    
    productInfo = @"MyApp";
    firstName = @"John";
    email = @"pulkit29@gmail.com";
    phone = @"9884588487";
    successUrl = @"http://www.google.com/"; // Your Success URL
    failureUrl = @"http://www.bing.com/";   // Your Failure URL
    service_provider = @"payu_paisa";
    
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self initPayment];
}

-(void)initPayment {
    
    NSString * hashValue = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|||||||||||%@",merchantKey,txnid1,totalPriceAmount,productInfo,firstName,email,salt];
    
    NSString *hash = [[SHA512 sha512WithString:hashValue] description];//[self createSHA512:hashValue];

    
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:txnid1,merchantKey,totalPriceAmount,productInfo,firstName,email,phone,successUrl,failureUrl,hash,service_provider
                                                                    , nil] forKeys:[NSArray arrayWithObjects:@"txnid",@"key",@"amount",@"productinfo",@"firstname",@"email",@"phone",@"surl",@"furl",@"hash",@"service_provider", nil]];
    __block NSString *post = @"";
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([post isEqualToString:@""]) {
            post = [NSString stringWithFormat:@"%@=%@",key,obj];
        } else {
            post = [NSString stringWithFormat:@"%@&%@=%@",post,key,obj];
        }
    }];

    // Creating a POST Request
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/_payment",PayUBaseUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setHTTPBody:postData];
    
    [_webView loadRequest:request];
    [activityIndicatorView startAnimating];
}

/*
 
 Use this to create SHA512 Hash or use the SHA512.m file
 
-(NSString *)createSHA512:(NSString *)string {
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString* output = [NSMutableString  stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}
*/


- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"webViewDidStartLoad");
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [activityIndicatorView stopAnimating];

    if (webView.isLoading) {
        return;
    }
    
    NSURL * requestURL = self.webView.request.URL;
    NSString * requestString = [requestURL absoluteString];
    if ([requestString containsString:successUrl]){
        NSLog(@"success payment done");
        
    }
    else if ([requestString containsString:failureUrl]
             ){
        NSLog(@"payment failure");
    }
}


-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSURL * requestURL = self.webView.request.URL;
    [NSString stringWithFormat:@"WebView failed loading with requestURL: %@ with error: %@ error code: %@", requestURL, error.localizedDescription, error];
    
    if (error.code == -1009 || error.code == -1003) {
        NSLog(@"Please check your internet connection!");
    }else if (error.code == -1001) {
        NSLog(@"The request timed out.");
    }
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
