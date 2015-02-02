//
//  BSVideoDetailController.m
//  YouTubeDraggableVideo
//
//  Created by Sandeep Mukherjee on 02/02/15.
//  Copyright (c) 2015 Sandeep Mukherjee. All rights reserved.
//


#import "BSVideoDetailController.h"
#import "QuartzCore/CALayer.h"






@interface BSVideoDetailController ()

@end

@implementation BSVideoDetailController
{
    
    
    
    //local Frame store
    CGRect youtubeFrame;
    CGRect tblFrame;
    CGRect menuFrame;
    CGRect viewFrame;
    CGRect minimizedYouTubeFrame;
    CGRect growingTextViewFrame;;
    
    //local touch location
    CGFloat _touchPositionInHeaderY;
    CGFloat _touchPositionInHeaderX;
    
    //local restriction Offset--- for checking out of bound
    float restrictOffset,restrictTrueOffset,restictYaxis;
    
    //detecting Pan gesture Direction
    UIPanGestureRecognizerDirection direction;
    
    
    //Creating a transparent Black layer view
    UIView *transaparentVw;
    
    //Just to Check wether view  is expanded or not
    BOOL isExpandedMode;
    
    
    
    
}
@synthesize player;



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // [[BSUtils sharedInstance] showLoadingMode:self];
    
    //adding demo Video -- giving a little delay to store correct frame size
    [self performSelector:@selector(addVideo) withObject:nil afterDelay:0.8];
    
    //adding Pan Gesture
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    pan.delegate=self;
    [self.viewYouTube addGestureRecognizer:pan];
    //setting view to Expanded state
    isExpandedMode=TRUE;
    
    self.btnDown.hidden=TRUE;
    
    
    
    
    
    
}

#pragma mark- Status Bar Hidden function

- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (NSUInteger) supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
}
- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark- Add Video on View
-(void)addVideo
{
    
    NSURL *urlString = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp4"]];
    player  = [[MPMoviePlayerController alloc] initWithContentURL:urlString];
    
    [player.view setFrame:self.viewYouTube.frame];
    player.controlStyle =  MPMovieControlStyleNone;
    player.shouldAutoplay=YES;
    player.repeatMode = NO;
    player.scalingMode = MPMovieScalingModeAspectFit;
    
    [self.viewYouTube addSubview:player.view];
    [player prepareToPlay];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviePlayerLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [self calculateFrames];
    
    
}
#pragma mark- Calculate Frames and Store Frame Size
-(void)calculateFrames
{
    youtubeFrame=self.viewYouTube.frame;
    tblFrame=self.viewTable.frame;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    self.viewYouTube.translatesAutoresizingMaskIntoConstraints = YES;
    self.viewTable.translatesAutoresizingMaskIntoConstraints = YES;
    CGRect frame=self.viewGrowingTextView.frame;
    growingTextViewFrame=self.viewGrowingTextView.frame;
    self.viewGrowingTextView.translatesAutoresizingMaskIntoConstraints = YES;
    self.viewGrowingTextView.frame=frame;
    frame=self.txtViewGrowing.frame;
    self.txtViewGrowing.translatesAutoresizingMaskIntoConstraints = YES;
    self.txtViewGrowing.frame=frame;
    
    
    
    
    
    self.viewYouTube.frame=youtubeFrame;
    self.viewTable.frame=tblFrame;
    menuFrame=self.viewTable.frame;
    viewFrame=self.viewYouTube.frame;
    self.player.view.backgroundColor=self.viewYouTube.backgroundColor=[UIColor clearColor];
    //self.player.view.layer.shouldRasterize=YES;
    // self.viewYouTube.layer.shouldRasterize=YES;
    //self.viewTable.layer.shouldRasterize=YES;
    
    restrictOffset=self.initialFirstViewFrame.size.width-200;
    restrictTrueOffset = self.initialFirstViewFrame.size.height - 180;
    restictYaxis=self.initialFirstViewFrame.size.height-self.viewYouTube.frame.size.height;
    
    //[[BSUtils sharedInstance] hideLoadingMode:self];
    self.view.hidden=TRUE;
    transaparentVw=[[UIView alloc]initWithFrame:self.initialFirstViewFrame];
    transaparentVw.backgroundColor=[UIColor blackColor];
    transaparentVw.alpha=0.9;
    [self.onView addSubview:transaparentVw];
    
    [self.onView addSubview:self.viewTable];
    [self.onView addSubview:self.viewYouTube];
    [self stGrowingTextViewProperty];
    [self.player.view addSubview:self.btnDown];
    
    
    
    //animate Button Down
    
    
    self.btnDown.translatesAutoresizingMaskIntoConstraints = YES;
    self.btnDown.frame=CGRectMake( self.btnDown.frame.origin.x,  self.btnDown.frame.origin.y-22,  self.btnDown.frame.size.width,  self.btnDown.frame.size.width);
    CGRect frameBtnDown=self.btnDown.frame;
    
    [UIView animateKeyframesWithDuration:2.0 delay:0.0 options:UIViewKeyframeAnimationOptionAutoreverse | UIViewKeyframeAnimationOptionRepeat|UIViewAnimationOptionAllowUserInteraction animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
            self.btnDown.transform=CGAffineTransformMakeScale(1.5, 1.5);
            
            [self addShadow];
            self.btnDown.frame=CGRectMake(frameBtnDown.origin.x, frameBtnDown.origin.y+17, frameBtnDown.size.width, frameBtnDown.size.width);
            
            
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            self.btnDown.frame=CGRectMake(frameBtnDown.origin.x, frameBtnDown.origin.y, frameBtnDown.size.width, frameBtnDown.size.width);
            self.btnDown.transform=CGAffineTransformIdentity;
            [self addShadow];
        }];
    } completion:nil];
    
}
-(void)addShadow
{
    self.btnDown.imageView.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.btnDown.imageView.layer.shadowOffset = CGSizeMake(0, 1);
    self.btnDown.imageView.layer.shadowOpacity = 1;
    self.btnDown.imageView.layer.shadowRadius = 4.0;
    self.btnDown.imageView.clipsToBounds = NO;
}
#pragma mark- MPMoviePlayerLoadStateDidChange Notification
- (void)MPMoviePlayerLoadStateDidChange:(NSNotification *)notification {
    
    if ((player.loadState & MPMovieLoadStatePlaythroughOK) == MPMovieLoadStatePlaythroughOK) {
        //add your code
        NSLog(@"Playing OK");
        self.btnDown.hidden=FALSE;
        
        //[self.btnDown bringSubviewToFront:self.player.view];
        
        
    }
    NSLog(@"loadState=%lu",player.loadState);
    //[self.btnDown bringSubviewToFront:self.player.view];
    
}





#pragma mark- Pan Gesture Delagate

- (BOOL)gestureRecognizerShould:(UIGestureRecognizer *)gestureRecognizer {
    
    if(gestureRecognizer.view.frame.origin.y<0)
    {
        return NO;
    }
    return YES;
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


#pragma mark- Pan Gesture Selector Action

-(void)panAction:(UIPanGestureRecognizer *)recognizer
{
    
    CGFloat y = [recognizer locationInView:self.view].y;
    
    if(recognizer.state == UIGestureRecognizerStateBegan){
        
        direction = UIPanGestureRecognizerDirectionUndefined;
        //storing direction
        CGPoint velocity = [recognizer velocityInView:recognizer.view];
        [self detectPanDirection:velocity];
        
        //Snag the Y position of the touch when panning begins
        _touchPositionInHeaderY = [recognizer locationInView:self.viewYouTube].y;
        _touchPositionInHeaderX = [recognizer locationInView:self.viewYouTube].x;
        if(direction==UIPanGestureRecognizerDirectionDown)
        {
            player.controlStyle=MPMovieControlStyleNone;
            
        }
        
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged){
        
        
        if(direction==UIPanGestureRecognizerDirectionDown || direction==UIPanGestureRecognizerDirectionUp)
        {
            
            CGFloat trueOffset = y - _touchPositionInHeaderY;
            CGFloat xOffset = (y - _touchPositionInHeaderY)*0.35;
            [self adjustViewOnVerticalPan:trueOffset :xOffset recognizer:recognizer];
            
        }
        else if (direction==UIPanGestureRecognizerDirectionRight || direction==UIPanGestureRecognizerDirectionLeft)
        {
            [self adjustViewOnHorizontalPan:recognizer];
        }
        
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded){
        
        if(direction==UIPanGestureRecognizerDirectionDown || direction==UIPanGestureRecognizerDirectionUp)
        {
            
            if(recognizer.view.frame.origin.y<0)
            {
                [self expandViewOnPan];
                
                [recognizer setTranslation:CGPointZero inView:recognizer.view];
                
                return;
                
            }
            else if(recognizer.view.frame.origin.y>(self.initialFirstViewFrame.size.width/2))
            {
                
                [self minimizeViewOnPan];
                [recognizer setTranslation:CGPointZero inView:recognizer.view];
                return;
                
                
            }
            else if(recognizer.view.frame.origin.y<(self.initialFirstViewFrame.size.width/2))
            {
                [self expandViewOnPan];
                [recognizer setTranslation:CGPointZero inView:recognizer.view];
                return;
                
            }
        }
        
        else if (direction==UIPanGestureRecognizerDirectionLeft)
        {
            if(self.viewTable.alpha<=0)
            {
                
                if(recognizer.view.frame.origin.x<0)
                {
                    [self.view removeFromSuperview];
                    [self removeView];
                    [self.delegate removeController];
                    
                }
                else
                {
                    [self animateViewToRight:recognizer];
                    
                }
            }
        }
        
        else if (direction==UIPanGestureRecognizerDirectionRight)
        {
            if(self.viewTable.alpha<=0)
            {
                
                
                if(recognizer.view.frame.origin.x>self.initialFirstViewFrame.size.width-50)
                {
                    [self.view removeFromSuperview];
                    [self removeView];
                    [self.delegate removeController];
                    
                }
                else
                {
                    [self animateViewToLeft:recognizer];
                    
                }
            }
        }
        
        
    }
    
}

#pragma mark - Keyboard events

//Handling the keyboard appear and disappering events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    //__weak typeof(self) weakSelf = self;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         float yPosition=self.view.frame.size.height- kbSize.height- self.viewGrowingTextView.frame.size.height;
                         self.viewGrowingTextView.frame=CGRectMake(0, yPosition, self.viewGrowingTextView.frame.size.width, self.viewGrowingTextView.frame.size.height);
                         
                         //                         [weakSelf.registerScrView setContentOffset:CGPointMake(0, (weakSelf.userNameTxtfld.frame.origin.y+weakSelf.userNameTxtfld.frame.size.height)-kbSize.height) animated:YES];
                         
                     }
                     completion:^(BOOL finished) {
                     }];
    
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    // __weak typeof(self) weakSelf = self;
    //NSDictionary* info = [aNotification userInfo];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         float yPosition=self.view.frame.size.height-self.viewGrowingTextView.frame.size.height;
                         self.viewGrowingTextView.frame=CGRectMake(0, yPosition, self.viewGrowingTextView.frame.size.width, self.viewGrowingTextView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                     }];
}
#pragma mark -
#pragma mark - Text View delegate -

#pragma mark- View Function Methods
-(void)stGrowingTextViewProperty
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)animateViewToRight:(UIPanGestureRecognizer *)recognizer{
    [self.txtViewGrowing resignFirstResponder];
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.viewTable.frame = menuFrame;
                         self.viewYouTube.frame=viewFrame;
                         player.view.frame=CGRectMake( player.view.frame.origin.x,  player.view.frame.origin.x, viewFrame.size.width, viewFrame.size.height);
                         self.viewTable.alpha=0;
                         self.viewYouTube.alpha=1;
                         
                         
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
    
}

-(void)animateViewToLeft:(UIPanGestureRecognizer *)recognizer{
    [self.txtViewGrowing resignFirstResponder];
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.viewTable.frame = menuFrame;
                         self.viewYouTube.frame=viewFrame;
                         player.view.frame=CGRectMake( player.view.frame.origin.x,  player.view.frame.origin.x, viewFrame.size.width, viewFrame.size.height);
                         self.viewTable.alpha=0;
                         self.viewYouTube.alpha=1;
                         
                         
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
    
}


-(void)adjustViewOnHorizontalPan:(UIPanGestureRecognizer *)recognizer {
    [self.txtViewGrowing resignFirstResponder];
    CGFloat x = [recognizer locationInView:self.view].x;
    
    if (direction==UIPanGestureRecognizerDirectionLeft)
    {
        if(self.viewTable.alpha<=0)
        {
            
            NSLog(@"recognizer x=%f",recognizer.view.frame.origin.x);
            CGPoint velocity = [recognizer velocityInView:recognizer.view];
            
            BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
            
            
            
            CGPoint translation = [recognizer translationInView:recognizer.view];
            
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                                 recognizer.view.center.y );
            
            
            if (!isVerticalGesture) {
                
                CGFloat percentage = (x/self.initialFirstViewFrame.size.width);
                
                recognizer.view.alpha = percentage;
                
            }
            
            [recognizer setTranslation:CGPointZero inView:recognizer.view];
        }
    }
    else if (direction==UIPanGestureRecognizerDirectionRight)
    {
        if(self.viewTable.alpha<=0)
        {
            
            NSLog(@"recognizer x=%f",recognizer.view.frame.origin.x);
            CGPoint velocity = [recognizer velocityInView:recognizer.view];
            
            BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
            
            
            
            CGPoint translation = [recognizer translationInView:recognizer.view];
            
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                                 recognizer.view.center.y );
            
            
            if (!isVerticalGesture) {
                
                if(velocity.x > 0)
                {
                    
                    CGFloat percentage = (x/self.initialFirstViewFrame.size.width);
                    recognizer.view.alpha =1.0- percentage;                }
                else
                {
                    CGFloat percentage = (x/self.initialFirstViewFrame.size.width);
                    recognizer.view.alpha =percentage;
                    
                    
                }
                
            }
            
            [recognizer setTranslation:CGPointZero inView:recognizer.view];
        }
    }
    
    
    
    
    
}

-(void)adjustViewOnVerticalPan:(CGFloat)trueOffset :(CGFloat)xOffset recognizer:(UIPanGestureRecognizer *)recognizer
{
    [self.txtViewGrowing resignFirstResponder];
    CGFloat y = [recognizer locationInView:self.view].y;
    
    if(trueOffset>=restrictTrueOffset+60||xOffset>=restrictOffset+60)
    {
        CGFloat trueOffset = self.initialFirstViewFrame.size.height - 100;
        CGFloat xOffset = self.initialFirstViewFrame.size.width-160;
        //Use this offset to adjust the position of your view accordingly
        menuFrame.origin.y = trueOffset;
        menuFrame.origin.x = xOffset;
        menuFrame.size.width=self.initialFirstViewFrame.size.width-xOffset;
        
        viewFrame.size.width=self.view.bounds.size.width-xOffset;
        viewFrame.size.height=200-xOffset*0.5;
        viewFrame.origin.y=trueOffset;
        viewFrame.origin.x=xOffset;
        
        
        
        
        [UIView animateWithDuration:0.05
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^ {
                             self.viewTable.frame = menuFrame;
                             self.viewYouTube.frame=viewFrame;
                             player.view.frame=CGRectMake( player.view.frame.origin.x,  player.view.frame.origin.x, viewFrame.size.width, viewFrame.size.height);
                             self.viewTable.alpha=0;
                             
                             
                             
                         }
                         completion:^(BOOL finished) {
                             minimizedYouTubeFrame=self.viewYouTube.frame;
                             
                             isExpandedMode=FALSE;
                         }];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
        
    }
    else
    {
        
        //Use this offset to adjust the position of your view accordingly
        menuFrame.origin.y = trueOffset;
        menuFrame.origin.x = xOffset;
        menuFrame.size.width=self.initialFirstViewFrame.size.width-xOffset;
        viewFrame.size.width=self.view.bounds.size.width-xOffset;
        viewFrame.size.height=200-xOffset*0.5;
        viewFrame.origin.y=trueOffset;
        viewFrame.origin.x=xOffset;
        float restrictY=self.initialFirstViewFrame.size.height-self.viewYouTube.frame.size.height-10;
        
        
        if (self.viewTable.frame.origin.y<restrictY && self.viewTable.frame.origin.y>0) {
            [UIView animateWithDuration:0.09
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^ {
                                 self.viewTable.frame = menuFrame;
                                 self.viewYouTube.frame=viewFrame;
                                 player.view.frame=CGRectMake( player.view.frame.origin.x,  player.view.frame.origin.x, viewFrame.size.width, viewFrame.size.height);
                                 
                                 CGFloat percentage = y/self.initialFirstViewFrame.size.height;
                                 self.viewTable.alpha= transaparentVw.alpha = 1.0 - percentage;
                                 
                                 
                                 
                                 
                             }
                             completion:^(BOOL finished) {
                                 if(direction==UIPanGestureRecognizerDirectionDown)
                                 {
                                     [self.onView bringSubviewToFront:self.view];
                                 }
                             }];
        }
        else if (menuFrame.origin.y<restrictY&& menuFrame.origin.y>0)
        {
            [UIView animateWithDuration:0.09
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^ {
                                 self.viewTable.frame = menuFrame;
                                 self.viewYouTube.frame=viewFrame;
                                 player.view.frame=CGRectMake( player.view.frame.origin.x,  player.view.frame.origin.x, viewFrame.size.width, viewFrame.size.height);
                             }completion:nil];
            
            
        }
        
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
    }
    
}
-(void)detectPanDirection:(CGPoint )velocity
{
    self.btnDown.hidden=TRUE;
    BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
    
    if (isVerticalGesture) {
        if (velocity.y > 0) {
            direction = UIPanGestureRecognizerDirectionDown;
            
        } else {
            direction = UIPanGestureRecognizerDirectionUp;
        }
    }
    else
        
    {
        if(velocity.x > 0)
        {
            direction = UIPanGestureRecognizerDirectionRight;
        }
        else
        {
            direction = UIPanGestureRecognizerDirectionLeft;
        }
        
    }
    
}

- (void)expandViewOnTap:(UITapGestureRecognizer*)sender {
    
    [self expandViewOnPan];
    for (UIGestureRecognizer *recognizer in self.viewYouTube.gestureRecognizers) {
        
        if([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            [self.viewYouTube removeGestureRecognizer:recognizer];
        }
    }
    
}

-(void)minimizeViewOnPan
{
    self.btnDown.hidden=TRUE;
    [self.txtViewGrowing resignFirstResponder];
    CGFloat trueOffset = self.initialFirstViewFrame.size.height - 100;
    CGFloat xOffset = self.initialFirstViewFrame.size.width-160;
    
    //Use this offset to adjust the position of your view accordingly
    menuFrame.origin.y = trueOffset;
    menuFrame.origin.x = xOffset;
    menuFrame.size.width=self.initialFirstViewFrame.size.width-xOffset;
    //menuFrame.size.height=200-xOffset*0.5;
    
    // viewFrame.origin.y = trueOffset;
    //viewFrame.origin.x = xOffset;
    viewFrame.size.width=self.view.bounds.size.width-xOffset;
    viewFrame.size.height=200-xOffset*0.5;
    viewFrame.origin.y=trueOffset;
    viewFrame.origin.x=xOffset;
    
    
    
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.viewTable.frame = menuFrame;
                         self.viewYouTube.frame=viewFrame;
                         player.view.frame=CGRectMake( player.view.frame.origin.x,  player.view.frame.origin.x, viewFrame.size.width, viewFrame.size.height);
                         self.viewTable.alpha=0;
                         transaparentVw.alpha=0.0;
                         
                         
                     }
                     completion:^(BOOL finished) {
                         //add tap gesture
                         self.tapRecognizer=nil;
                         if(self.tapRecognizer==nil)
                         {
                             self.tapRecognizer= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandViewOnTap:)];
                             self.tapRecognizer.numberOfTapsRequired=1;
                             self.tapRecognizer.delegate=self;
                             [self.viewYouTube addGestureRecognizer:self.tapRecognizer];
                         }
                         
                         isExpandedMode=FALSE;
                         minimizedYouTubeFrame=self.viewYouTube.frame;
                         
                         if(direction==UIPanGestureRecognizerDirectionDown)
                         {
                             [self.onView bringSubviewToFront:self.view];
                         }
                     }];
    
}
-(void)expandViewOnPan
{
    [self.txtViewGrowing resignFirstResponder];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.viewTable.frame = tblFrame;
                         self.viewYouTube.frame=youtubeFrame;
                         self.viewYouTube.alpha=1;
                         player.view.frame=youtubeFrame;
                         self.viewTable.alpha=1.0;
                         transaparentVw.alpha=1.0;
                         
                         
                     }
                     completion:^(BOOL finished) {
                         player.controlStyle = MPMovieControlStyleDefault;
                         isExpandedMode=TRUE;
                         self.btnDown.hidden=FALSE;
                     }];
    
    
    
}

-(void)removeView
{
    [self.player stop];
    [self.viewYouTube removeFromSuperview];
    [self.viewTable removeFromSuperview];
    [transaparentVw removeFromSuperview];
    
    
}

#pragma mark - UITableViewDataSource
// number of section(s), now I assume there is only 1 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

// number of row in the section, I assume there is only 1 row
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

// the cell will be returned to the tableView
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"videoCommentCell";
    
    
    UITableViewCell *cell;
    cell = (UITableViewCell *)[theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 88.0;
    
    
}

#pragma mark - UITableViewDelegate
// when user tap the row, what action you want to perform
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected %ld row", (long)indexPath.row);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Action
- (IBAction)btnDownTapAction:(id)sender {
    
    [self minimizeViewOnPan];
    
}
- (IBAction)btnSendAction:(id)sender {
    [self.txtViewGrowing resignFirstResponder];
    self.txtViewGrowing.text=@"";
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.viewGrowingTextView.frame=growingTextViewFrame;
                     }completion:^(BOOL finished) {
                         
                     }];
    
}
@end
