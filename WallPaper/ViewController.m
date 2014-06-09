//
//  ViewController.m
//  WallPaper
//
//  Created by James VanBeverhoudt on 6/6/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"




@interface ViewController ()

@property(nonatomic, strong, readwrite)NSMutableArray *wallPaperArrayOfStringURLS;
@property(nonatomic, strong) UIImageView *ImageView;
@property(nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation ViewController

NSInteger wallPaperIndex;

@synthesize wallPaperArrayOfStringURLS = _wallPaperArrayOfStringURLS;
@synthesize ImageView = _ImageView;
@synthesize indicator = _indicator;

/**
 * initWithCoder: Returns an object initialized from data in a given unarchiver
 **/
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        //Initialize
        
        wallPaperIndex = 0;
        
        //Will want to host this and get via AFNetworking.
        self.wallPaperArrayOfStringURLS = [[NSMutableArray alloc] initWithObjects:@"http://www.windowswallpaper.com/thumbnails/large_Digital_Art_Hd_19477.jpg",
                                           @"http://upload.wikimedia.org/wikipedia/commons/9/92/Space_Shuttle_Atlantis_landing_at_KSC_following_STS-122.jpg",
                                           @"http://upload.wikimedia.org/wikipedia/commons/4/44/Space_Shuttle_Challenger_(04-04-1983).JPEG",
                                           @"http://upload.wikimedia.org/wikipedia/commons/d/d3/Atlantis_taking_off_on_STS-27.jpg",
                                           @"http://thumbs.dreamstime.com/z/spooky-scary-man-aged-cracked-peeling-skin-13755199.jpg",
                                           nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self programmaticallyAddImageViewAndIndicatorView];
    [self addTouchGesture];

    //initial load of wall paper.
    [self loadWallPaper];
    
}

-(void)addTouchGesture
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadWallPaper)];
    [self.ImageView addGestureRecognizer:tapGestureRecognizer];
}


-(void)programmaticallyAddImageViewAndIndicatorView
{
    self.ImageView = [[UIImageView alloc] initWithImage:nil];
    self.ImageView.frame = self.view.bounds;
    self.ImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.ImageView];
    
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicator.hidesWhenStopped = YES;
    self.indicator.center = self.view.center;
    [self.view addSubview: self.indicator];
    
}

-(void)loadWallPaper
{
    if(wallPaperIndex == [self.wallPaperArrayOfStringURLS count]){
        wallPaperIndex = 0;
    }
    self.ImageView.userInteractionEnabled = NO; //Disable image view tapping when the user just tapped it
    [self.indicator startAnimating];
    //[SVProgressHUD show];


    if([self.tabBarItem.title isEqualToString:@"AFNetworking"]){
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self.wallPaperArrayOfStringURLS objectAtIndex:wallPaperIndex]]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            UIImage *image = [[UIImage alloc] initWithData:responseObject];
            self.ImageView.image = image;
            self.ImageView.userInteractionEnabled = YES; //once image is done loading, user can tap again for next image.
            [self.indicator stopAnimating];
            //[SVProgressHUD dismiss];

            wallPaperIndex +=1;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self.indicator stopAnimating];
            //[SVProgressHUD dismiss];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Image"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }];
        
        [operation start];

    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^ {
            NSURL *url = [NSURL URLWithString:[self.wallPaperArrayOfStringURLS objectAtIndex:wallPaperIndex]];
            NSError *error = nil;
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:url options:NSDataReadingUncached error:&error];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
        
            //Once the data has been retrieved and stored into an image, completion block must go back to main thread and set visual elements.
            dispatch_async(dispatch_get_main_queue(), ^{
                if(error){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Image"
                                                                        message:[error localizedDescription]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil];
                    [alertView show];
                    [self.indicator stopAnimating];
                    //[SVProgressHUD dismiss];
                } else {
                    self.ImageView.image = image;
                    self.ImageView.userInteractionEnabled = YES; //once image is done loading, user can tap again for next image.
                    [self.indicator stopAnimating];
                    //[SVProgressHUD dismiss];
                    wallPaperIndex +=1;
                }
            });
        });
        
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
