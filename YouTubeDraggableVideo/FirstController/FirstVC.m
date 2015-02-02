//
//  FirstVC.m
//  YouTubeDraggableVideo
//
//  Created by Sandeep Mukherjee on 02/02/15.
//  Copyright (c) 2015 Sandeep Mukherjee. All rights reserved.
//

#import "FirstVC.h"
#define PAGESIZE 1


@interface FirstVC ()



@end
@implementation FirstVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.pageno=1;
     _discussionArray=[[NSMutableArray alloc]initWithObjects:@"demoContent",@"demoContent", @"demoContent", @"demoContent", @"demoContent",  nil];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    if(self.secondViewController!=nil && !self.secondViewController.player.isFullscreen)
    {
        [self.secondViewController removeView];
        [self.secondViewController.view removeFromSuperview];
        self.secondViewController=nil;
        
        
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  
      [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
  
    
  }
- (void)orientationChanged:(NSNotification *)notification{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];

}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            //load the portrait view
            if(self.secondViewController!=nil)
            {
                
               
                if(!self.secondViewController.player .fullscreen)
                {
                    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
                [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
                }
            }
        }
            
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            if(self.secondViewController!=nil)
            {
                 NSLog(@"landscape called;");
            
                
               // if(!self.secondViewController.player.fullscreen && self.secondViewController.viewTable.alpha>=1)
                //{
               
                 self.secondViewController.player.controlStyle =  MPMovieControlStyleDefault;
                self.secondViewController.player .fullscreen = YES;
                 
                      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willExitFullscreen:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
                //}
               /* else if( self.secondViewController.viewTable.alpha<=0)
                {
                    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
                        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
                } */
                
          
            }
            
            
        }
            break;
        case UIInterfaceOrientationUnknown:break;
    }
}

- (void)willExitFullscreen:(NSNotification*)notification {
    
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerWillExitFullscreenNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
   

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/






#pragma mark -
#pragma mark - UITableViewDataSource & delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
    return self.discussionArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

        return [self tableView:tableView discussionCellForAtIndexPath:indexPath];

    
}

// create discussion cell
-(UITableViewCell *)tableView:(UITableView *)tableView discussionCellForAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"commentsCell";
    UITableViewCell *cell;
    cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    UIImageView *bgImage=(UIImageView *)[cell.contentView viewWithTag:1];
    UIImageView *profileImage=(UIImageView *)[cell.contentView viewWithTag:2];
    
        // create border of the background image
    bgImage.layer.borderColor=[UIColor lightGrayColor].CGColor;
    bgImage.layer.borderWidth=0.5;
    // create rounded player image
    profileImage.layer.cornerRadius=profileImage.frame.size.width/2;
    profileImage.layer.masksToBounds=YES;
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.secondViewController==nil)
    {
        [self showSecondController];
    }
    else
    {
        [self.secondViewController removeView];
        [self.secondViewController.view removeFromSuperview];
        self.secondViewController=nil;
        
        [self showSecondController];
        
    }

    
    
   
}

#pragma mark -
#pragma mark -Important Methods

-(void)showSecondController
{
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];

    self.secondViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BSVideoDetailController"];
    //initial frame
    self.secondViewController.view.frame=CGRectMake(self.view.frame.size.width-50, self.view.frame.size.height-50, self.view.frame.size.width, self.view.frame.size.height);
    self.secondViewController.initialFirstViewFrame=self.view.frame;
    
    
    self.secondViewController.view.alpha=0;
    self.secondViewController.view.transform=CGAffineTransformMakeScale(0.2, 0.2);
    
    
    [self.view addSubview:self.secondViewController.view];
    self.secondViewController.onView=self.view;
    
    [UIView animateWithDuration:0.9f animations:^{
        self.secondViewController.view.transform=CGAffineTransformMakeScale(1.0, 1.0);
        self.secondViewController.view.alpha=1;
        
        self.secondViewController.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    }];

}
- (void)removeController
{
    
    self.secondViewController=nil;
    
}




@end
