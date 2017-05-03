# PAYUIntegrationCustomBrowser

PAYU Custom Browser  Integration in iOS

Prerequisites:

	1	Add libz.tbd libraries into your project (Project->Build Phases->Link Binary With Libraries)

	2	Add -ObjC and $(OTHER_LDFLAGS)in Other Linker Flags in Project Build Settings(Project->Build Settings->Other Linker Flags)

	3	To run the app on iOS9, please add the below code in info.plist NSAppTransportSecurity NSAllowsArbitraryLoads

Steps :

1) Setup Webview in a view controller

2) Setup the initial Parameters required to create a POST request

Sample :

In Test Mode :
KEY : “gtKFFx”
SALT : “eCwWELxi” 

In Production Mode : 
KEY : Generate your key from PayU Money portal
SALT :  Generate your key from PayU Money portal

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


3) Create Hash using the below Formula // Create it on server side for Security Purpose

Sample : 

NSString * hashValue = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|||||||||||%@",merchantKey,txnid1,totalPriceAmount,productInfo,firstName,email,salt];

NSString * hash = [self createSHA512:hashValue]

// User this function to create SHA512 in Objective C

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

4) Create a POST request using above parameters

Sample :

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


5) Load request in the browser

Sample : 

[_webView loadRequest:request];


6) Handle Webview delegates


Sample : 

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

	// Handle Success screen here
        
    }
    else if ([requestString containsString:failureUrl]
             ){
        NSLog(@"payment failure");

	// Handle Failure screen here
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