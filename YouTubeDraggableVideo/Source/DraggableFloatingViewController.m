//
//  BSVideoDetailController.m
//  YouTubeDraggableVideo
//
//  Created by Sandeep Mukherjee on 02/02/15.
//  Copyright (c) 2015 Sandeep Mukherjee. All rights reserved.
//


#import "DraggableFloatingViewController.h"
#import "QuartzCore/CALayer.h"

typedef NS_ENUM(NSUInteger, UIPanGestureRecognizerDirection) {
    UIPanGestureRecognizerDirectionUndefined,
    UIPanGestureRecognizerDirectionUp,
    UIPanGestureRecognizerDirectionDown,
    UIPanGestureRecognizerDirectionLeft,
    UIPanGestureRecognizerDirectionRight
};

@interface DraggableFloatingViewController ()
@end


@implementation DraggableFloatingViewController
{
    
    //local Frame storee
    CGRect videoWrapperFrame;
    CGRect minimizedVideoFrame;
    CGRect pageWrapperFrame;

    // animation Frame
    CGRect wFrame;
    CGRect vFrame;
    
    //local touch location
    CGFloat _touchPositionInHeaderY;
    CGFloat _touchPositionInHeaderX;
    
    //detecting Pan gesture Direction
    UIPanGestureRecognizerDirection direction;
    
    UITapGestureRecognizer *tapRecognizer;
    
    //Creating a transparent Black layer view
    UIView *transparentBlackSheet;
    
    //Just to Check wether view  is expanded or not
    BOOL isExpandedMode;
    
    
    UIView *pageWrapper;
    UIView *videoWrapper;
//    UIButton *foldButton;

    UIView *videoView;
    // border of mini vieo view
    UIView *borderView;

    CGFloat maxH;
    CGFloat maxW;
    CGFloat videoHeightRatio;
    CGFloat finalViewOffsetY;
    CGFloat minimamVideoHeight;

    UIView *parentView;
    
    BOOL isDisplayController;
    NSTimer *hideControllerTimer;
    
    BOOL isMinimizingByGesture;
    
    BOOL isAppear;
    BOOL isSetuped;

    CGRect windowFrame;
}

const CGFloat finalMargin = 3.0;
const CGFloat minimamVideoWidth = 140;
const CGFloat flickVelocity = 1000;

// please override if you want
- (void) didExpand {}
- (void) didMinimize {}
- (void) didStartMinimizeGesture {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (void) didFullExpandByGesture {}// TODO: meke this stable
- (void) didDisappear{}
- (void) didReAppear{}

- (id)init
{
    self = [super init];
    if (self) {
        self.bodyView = [[UIView alloc] init];
        self.controllerView = [[UIView alloc] init];
        self.messageView = [[UIView alloc] init];
    }
    return self;
}
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.bodyView = [[UIView alloc] init];
        self.controllerView = [[UIView alloc] init];
        self.messageView = [[UIView alloc] init];
    }
    return self;
}



# pragma mark - init

- (void) show {
    if (!isSetuped) {
        [self setup];
    }
    else {
        if (!isAppear) {
            [self reAppearWithAnimation];
        }
    }
}


- (void) setup {
    
    isSetuped = true;
    
    NSLog(@"showVideoViewControllerOnParentVC");
    
//    if( ![parentVC conformsToProtocol:@protocol(DraggableFloatingViewControllerDelegate)] ) {
//        NSAssert(NO, @"❌❌Parent view controller must confirm to protocol <DraggableFloatingViewControllerDelegate>.❌❌");
//    }
//    self.delegate = parentVC;
    
    // set portrait
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
//    parentView = parentVC.view;
//    [parentView addSubview:self.view];// then, "viewDidLoad" called
    [[self getWindow] addSubview:self.view];
    
    // wait to run "viewDidLoad" before "showThisView"
    [self performSelector:@selector(showThisView) withObject:nil afterDelay:0.0];
    
    isAppear = true;
}
// ↓
// VIEW DID LOAD
- (void) setupViewsWithVideoView: (UIView *)vView
            videoViewHeight: (CGFloat) videoHeight
//                 minimizeButton: (UIButton *)foldBtn
{
    NSLog(@"setupViewsWithVideoView");
    
    videoView = vView;
//    foldButton = foldBtn;//control show and hide
    
    windowFrame = [[UIScreen mainScreen] bounds];
    maxH = windowFrame.size.height;
    maxW = windowFrame.size.width;
    CGFloat videoWidth = maxW;
    videoHeightRatio = videoHeight / videoWidth;
    minimamVideoHeight = minimamVideoWidth * videoHeightRatio;
    finalViewOffsetY = maxH - minimamVideoHeight - finalMargin;
    
    videoWrapper = [[UIView alloc] init];
    videoWrapper.frame = CGRectMake(0, 0, videoWidth, videoHeight);
    
    videoView.frame = videoWrapper.frame;
    self.controllerView.frame = videoWrapper.frame;
    self.messageView.frame = videoWrapper.frame;
    
    pageWrapper = [[UIView alloc] init];
    pageWrapper.frame = CGRectMake(0, 0, maxW, maxH);
    
    videoWrapperFrame = videoWrapper.frame;
    pageWrapperFrame = pageWrapper.frame;
    
    
    borderView = [[UIView alloc] init];
    borderView.clipsToBounds = YES;
    borderView.layer.masksToBounds = NO;
    borderView.layer.borderColor = [[UIColor whiteColor] CGColor];
    borderView.layer.borderWidth = 0.5f;
//    borderView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
//    borderView.layer.shadowColor = [UIColor blackColor].CGColor;
//    borderView.layer.shadowRadius = 1.0;
//    borderView.layer.shadowOpacity = 1.0;
    borderView.alpha = 0;
    borderView.frame = CGRectMake(videoView.frame.origin.y - 1,
                                  videoView.frame.origin.x - 1,
                                  videoView.frame.size.width + 1,
                                  videoView.frame.size.height + 1);

    self.bodyView.frame = CGRectMake(0, videoHeight, maxW, maxH - videoHeight);
}
// ↓
- (void) showThisView {
    // only first time, SubViews add to "self.view".
    // After animation, they move to "parentView"
    videoView.backgroundColor = [UIColor blackColor];
    videoWrapper.backgroundColor = [UIColor blackColor];
    [pageWrapper addSubview:self.bodyView];
    [videoWrapper addSubview:videoView];
    // move subviews from "self.view" to "parentView" after animation
    [self.view addSubview:pageWrapper];
    [self.view addSubview:videoWrapper];
    
    transparentBlackSheet = [[UIView alloc] initWithFrame:windowFrame];
    transparentBlackSheet.backgroundColor = [UIColor blackColor];
    transparentBlackSheet.alpha = 1;
    
    [self appearAnimation];
}
// ↓
- (void) appearAnimation {
    
    self.view.frame = CGRectMake(windowFrame.size.width - 50,
                                 windowFrame.size.height - 50,
                                 windowFrame.size.width,
                                 windowFrame.size.height);
    self.view.transform = CGAffineTransformMakeScale(0.2, 0.2);
    self.view.alpha = 0;
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         self.view.alpha = 1;
                         self.view.frame = CGRectMake(windowFrame.origin.x,
                                                      windowFrame.origin.y,
                                                      windowFrame.size.width,
                                                      windowFrame.size.height);
                     }
                     completion:^(BOOL finished) {
                         [self afterAppearAnimation];
                     }];
}
// ↓
-(void) afterAppearAnimation {
    videoView.backgroundColor = videoWrapper.backgroundColor = [UIColor clearColor];

    
//    [parentView addSubview:transparentBlackSheet];
    // move from self.view
//    [parentView addSubview:pageWrapper];
//    [parentView addSubview:videoWrapper];

    [[self getWindow] addSubview:transparentBlackSheet];
    [[self getWindow] addSubview:pageWrapper];
    [[self getWindow] addSubview:videoWrapper];

    
    self.view.hidden = TRUE;

    [videoView addSubview:borderView];
    
    [videoWrapper addSubview:self.controllerView];
    
    self.messageView.hidden = TRUE;
    [videoWrapper addSubview:self.messageView];
    
    [self showControllerView];
    
    UITapGestureRecognizer* expandedTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapExpandedVideoView)];
    expandedTap.numberOfTapsRequired = 1;
    expandedTap.delegate = self;
    [videoWrapper addGestureRecognizer:expandedTap];

    vFrame = videoWrapperFrame;
    wFrame = pageWrapperFrame;
    
    // adding Pan Gesture
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    pan.delegate = self;
    [videoWrapper addGestureRecognizer:pan];
    
    isExpandedMode = TRUE;
}






- (void) disappear {
    isAppear = false;
//    [self.delegate removeDraggableFloatingViewController];
}


- (void) reAppearWithAnimation {
    borderView.alpha = 0;
    transparentBlackSheet.alpha = 0;

    videoWrapper.alpha = 0;
    pageWrapper.alpha = 0;

    pageWrapper.frame = pageWrapperFrame;
    videoWrapper.frame = videoWrapperFrame;
    videoView.frame = videoWrapperFrame;
    self.controllerView.frame = videoView.frame;
    self.bodyView.frame = CGRectMake(0,
                                     videoView.frame.size.height,// keep stay on bottom of videoView
                                     self.bodyView.frame.size.width,
                                     self.bodyView.frame.size.height);
    borderView.frame = CGRectMake(videoView.frame.origin.y - 1,
                                  videoView.frame.origin.x - 1,
                                  videoView.frame.size.width + 1,
                                  videoView.frame.size.height + 1);

    // parentViewにのってるViewは pageWrapper と videoWrapper と transparentView
    // pageWrapper と videoWrapper をself.viewと同様のアニメーションをさせた後に、parentViewに戻す
    // transparentView は あとで1にすればいい
    pageWrapper.frame = CGRectMake(windowFrame.size.width - 50,
                                 windowFrame.size.height - 150,
                                 pageWrapper.frame.size.width,
                                 pageWrapper.frame.size.height);
//    pageWrapper.transform = CGAffineTransformMakeScale(0.2, 0.2);

    videoWrapper.frame = CGRectMake(windowFrame.size.width - 50,
                                   windowFrame.size.height - 150,
                                   videoWrapper.frame.size.width,
                                   videoWrapper.frame.size.height);
//    videoWrapper.transform = CGAffineTransformMakeScale(0.2, 0.2);
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
//                         pageWrapper.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         pageWrapper.alpha = 1;
                         pageWrapper.frame = CGRectMake(windowFrame.origin.x,
                                                         windowFrame.origin.y,
                                                         pageWrapper.frame.size.width,
                                                         pageWrapper.frame.size.height);

//                         videoWrapper.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         videoWrapper.alpha = 1;
                         videoWrapper.frame = CGRectMake(windowFrame.origin.x,
                                                      windowFrame.origin.y,
                                                      videoWrapper.frame.size.width,
                                                      videoWrapper.frame.size.height);
                         
                     }
                     completion:^(BOOL finished) {
                         
                         transparentBlackSheet.alpha = 1.0;

                         for (UIGestureRecognizer *recognizer in videoWrapper.gestureRecognizers) {
                             if([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
                                 [videoWrapper removeGestureRecognizer:recognizer];
                             }
                         }
                         UITapGestureRecognizer* expandedTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapExpandedVideoView)];
                         expandedTap.numberOfTapsRequired = 1;
                         expandedTap.delegate = self;
                         [videoWrapper addGestureRecognizer:expandedTap];

                         isExpandedMode = TRUE;
                         [self didExpand];
                         [self didReAppear];
                     }];
}



- (void) bringToFront {
//    [parentView addSubview:self.view];// then, "viewDidLoad" called
//    [parentView addSubview:transparentBlackSheet];
//    [parentView addSubview:pageWrapper];
//    [parentView addSubview:videoWrapper];
    if (isSetuped) {
        [[self getWindow] bringSubviewToFront:self.view];
        [[self getWindow] bringSubviewToFront:transparentBlackSheet];
        [[self getWindow] bringSubviewToFront:pageWrapper];
        [[self getWindow] bringSubviewToFront:videoWrapper];
    }
}
//
//- (void) changeParentVC: (UIViewController*) parentVC {
////    if (isSetuped) {
////        parentView = parentVC.view;
////        [parentView addSubview:self.view];// then, "viewDidLoad" called
////        [parentView addSubview:transparentBlackSheet];
////        [parentView addSubview:pageWrapper];
////        [parentView addSubview:videoWrapper];
////    }
//}
//

- (UIWindow *) getWindow {
    return [[[UIApplication sharedApplication] delegate] window];
}


-(void)removeAllViews
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [videoWrapper removeFromSuperview];
    [pageWrapper removeFromSuperview];
    [transparentBlackSheet removeFromSuperview];
    [self.view removeFromSuperview];
}

- (void)dealloc
{
    //    NSLog(@"dealloc DraggableFloatingViewController");
}









-(void) showMessageView {
    self.messageView.hidden = FALSE;
}
-(void) hideMessageView {
    self.messageView.hidden = TRUE;
}



-(void) setHideControllerTimer {
    if ([hideControllerTimer isValid]) {
        [hideControllerTimer invalidate];
    }
    hideControllerTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f
                                                           target:self
                                                         selector:@selector(hideControllerView)
                                                         userInfo:nil
                                                          repeats:NO];
}
-(void) showControllerView {
    NSLog(@"showControllerView");
    isDisplayController = true;
    [self setHideControllerTimer];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.controllerView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];
}
-(void) hideControllerView {
    NSLog(@"hideControllerView");
    isDisplayController = false;
    if ([hideControllerTimer isValid]) {
        [hideControllerTimer invalidate];
    }
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.controllerView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                     }];
}












- (void) showControllerAfterExpanded {
    [NSTimer scheduledTimerWithTimeInterval:0.5f
                                     target:self
                                   selector:@selector(showControllerView)
                                   userInfo:nil
                                    repeats:NO];
}




# pragma  mark - tap action
//- (void) onTapDownButton {
//    [self minimizeView];
//}


- (void) onTapExpandedVideoView {
    NSLog(@"onTapExpandedVideoView");
    if (self.controllerView.alpha == 0.0) {
        [self showControllerView];
    }
    else if (self.controllerView.alpha == 1.0){
        [self hideControllerView];
    }
}

- (void)expandViewOnTap:(UITapGestureRecognizer*)sender {
    [self expandView];
    [self showControllerAfterExpanded];
    
}



#pragma mark- Pan Gesture Selector Action

-(void)panAction:(UIPanGestureRecognizer *)recognizer
{
    CGFloat touchPosInViewY = [recognizer locationInView:self.view].y;
    
    
    if(recognizer.state == UIGestureRecognizerStateBegan) {

        direction = UIPanGestureRecognizerDirectionUndefined;
        //storing direction
        CGPoint velocity = [recognizer velocityInView:recognizer.view];
        [self detectPanDirection:velocity];
        
        isMinimizingByGesture = false;
        //Snag the Y position of the touch when panning begins
        _touchPositionInHeaderY = [recognizer locationInView:videoWrapper].y;
        _touchPositionInHeaderX = [recognizer locationInView:videoWrapper].x;
        if(direction == UIPanGestureRecognizerDirectionDown) {
            if(videoView.frame.size.height > minimamVideoHeight) {
                // player.controlStyle = MPMovieControlStyleNone;
                NSLog(@"minimize gesture start");
                isMinimizingByGesture = true;
                [self didStartMinimizeGesture];
            }
        }
    }

    
    else if(recognizer.state == UIGestureRecognizerStateChanged) {
        if(direction == UIPanGestureRecognizerDirectionDown || direction == UIPanGestureRecognizerDirectionUp) {

//            CGFloat appendY = 20;
//            if (direction == UIPanGestureRecognizerDirectionUp) appendY = -appendY;
            
            CGFloat newOffsetY = touchPosInViewY - _touchPositionInHeaderY;// + appendY;

            // CGFloat newOffsetX = newOffsetY * 0.35;
            [self adjustViewOnVerticalPan:newOffsetY recognizer:recognizer];
        }
        else if (direction==UIPanGestureRecognizerDirectionRight || direction==UIPanGestureRecognizerDirectionLeft) {
            [self adjustViewOnHorizontalPan:recognizer];
        }
    }


    
    else if(recognizer.state == UIGestureRecognizerStateEnded) {

        CGPoint velocity = [recognizer velocityInView:recognizer.view];

        if(direction == UIPanGestureRecognizerDirectionDown || direction == UIPanGestureRecognizerDirectionUp)
        {
            if(velocity.y < -flickVelocity)
            {
//                NSLog(@"flick up");
                [self expandView];
                if (isMinimizingByGesture == false) {
                    [self showControllerAfterExpanded];
                }
                [recognizer setTranslation:CGPointZero inView:recognizer.view];
                return;
            }
            else if(velocity.y > flickVelocity)
            {
//                NSLog(@"flick down");
                [self minimizeView];
                [recognizer setTranslation:CGPointZero inView:recognizer.view];
                return;
            }
            else if(recognizer.view.frame.origin.y>(windowFrame.size.width/2))
            {
                [self minimizeView];
                [recognizer setTranslation:CGPointZero inView:recognizer.view];
                return;
            }
            else if(recognizer.view.frame.origin.y < (windowFrame.size.width/2) || recognizer.view.frame.origin.y < 0)
            {
                [self expandView];
                if (isMinimizingByGesture == false) {
                    [self showControllerAfterExpanded];
                }
                [recognizer setTranslation:CGPointZero inView:recognizer.view];
                return;
            }
        }
        
        else if (direction==UIPanGestureRecognizerDirectionLeft)
        {
            if(pageWrapper.alpha <= 0)
            {
                if(velocity.x < -flickVelocity || pageWrapper.alpha < 0.3)
                {
                    [self fadeOutViewToLeft:recognizer completion: ^{
                        [self disappear];
                    }];
                    return;
                }
                else if(recognizer.view.frame.origin.x < 0)
                {
                    [self disappear];
                }
                else
                {
                    [self animateMiniViewToNormalPosition:recognizer completion:nil];
                    
                }
            }
        }
        
        else if (direction==UIPanGestureRecognizerDirectionRight)
        {
            if(pageWrapper.alpha <= 0)
            {
                if(velocity.x > flickVelocity)
                {
                    [self fadeOutViewToRight:recognizer completion: ^{
                        [self disappear];
                    }];
                    return;
                }
                if(recognizer.view.frame.origin.x > windowFrame.size.width - 50)
                {
                    [self disappear];
                }
                else
                {
                    [self animateMiniViewToNormalPosition:recognizer completion:nil];
                }
            }
        }

        isMinimizingByGesture = false;
    }
}


-(void)detectPanDirection:(CGPoint )velocity
{
//    foldButton.hidden=TRUE;
    BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
    
    if (isVerticalGesture)
    {
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



-(void)adjustViewOnVerticalPan:(CGFloat)newOffsetY recognizer:(UIPanGestureRecognizer *)recognizer
{
    CGFloat touchPosInViewY = [recognizer locationInView:self.view].y;
    
    CGFloat progressRate = newOffsetY / finalViewOffsetY;
    
    if(progressRate >= 0.99) {
        progressRate = 1;
        newOffsetY = finalViewOffsetY;
    }
    
    [self calcNewFrameWithParsentage:progressRate newOffsetY:newOffsetY];
    
    if (progressRate <= 1 && pageWrapper.frame.origin.y >= 0) {
        pageWrapper.frame = wFrame;
        videoWrapper.frame = vFrame;
        videoView.frame = CGRectMake(
                                     videoView.frame.origin.x,  videoView.frame.origin.x,
                                     vFrame.size.width, vFrame.size.height
                                     );
        self.bodyView.frame = CGRectMake(
                                         0,
                                         videoView.frame.size.height,// keep stay on bottom of videoView
                                         self.bodyView.frame.size.width,
                                         self.bodyView.frame.size.height
                                         );
        
        borderView.frame = CGRectMake(videoView.frame.origin.y - 1,
                                      videoView.frame.origin.x - 1,
                                      videoView.frame.size.width + 1,
                                      videoView.frame.size.height + 1);
        
        self.controllerView.frame = videoView.frame;
        
        CGFloat percentage = touchPosInViewY / windowFrame.size.height;
        
        pageWrapper.alpha = transparentBlackSheet.alpha = 1.0 - (percentage * 1.5);
        if (percentage > 0.2) borderView.alpha = percentage;
        else borderView.alpha = 0;
        
        if (isDisplayController) {
            self.controllerView.alpha = 1.0 - (percentage * 2);
//            if (percentage > 0.2) borderView.alpha = percentage;
//            else borderView.alpha = 0;
        }
        
        if(direction==UIPanGestureRecognizerDirectionDown)
        {
//            [parentView bringSubviewToFront:self.view];
            [self bringToFront];
        }
        
        
        if(direction==UIPanGestureRecognizerDirectionUp && videoView.frame.origin.y <= 10)
        {
            [self didFullExpandByGesture];
        }
    }
    // what is this case...?
    else if (wFrame.origin.y < finalViewOffsetY && wFrame.origin.y > 0)
    {
        pageWrapper.frame = wFrame;
        videoWrapper.frame = vFrame;
        videoView.frame=CGRectMake( videoView.frame.origin.x,  videoView.frame.origin.x, vFrame.size.width, vFrame.size.height);
        
        self.bodyView.frame = CGRectMake(
                                         0,
                                         videoView.frame.size.height,// keep stay on bottom of videoView
                                         self.bodyView.frame.size.width,
                                         self.bodyView.frame.size.height
                                         );
        borderView.frame = CGRectMake(videoView.frame.origin.y - 1,
                                      videoView.frame.origin.x - 1,
                                      videoView.frame.size.width + 1,
                                      videoView.frame.size.height + 1);
        
        borderView.alpha = progressRate;
        
        self.controllerView.frame = videoView.frame;
    }
    
    
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
    
}




-(void)adjustViewOnHorizontalPan:(UIPanGestureRecognizer *)recognizer {
    //    [self.txtViewGrowing resignFirstResponder];
    if(pageWrapper.alpha<=0) {
        
        CGFloat x = [recognizer locationInView:self.view].x;
        
        if (direction==UIPanGestureRecognizerDirectionLeft)
        {
//            NSLog(@"recognizer x=%f",recognizer.view.frame.origin.x);
            CGPoint velocity = [recognizer velocityInView:recognizer.view];
            
            BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
            
            
            CGPoint translation = [recognizer translationInView:recognizer.view];
            
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                                 recognizer.view.center.y );
            
            
            if (!isVerticalGesture) {
                
                CGFloat percentage = (x/windowFrame.size.width);
                
                recognizer.view.alpha = percentage;
                
            }
            
            [recognizer setTranslation:CGPointZero inView:recognizer.view];
        }
        else if (direction==UIPanGestureRecognizerDirectionRight)
        {
//            NSLog(@"recognizer x=%f",recognizer.view.frame.origin.x);
            CGPoint velocity = [recognizer velocityInView:recognizer.view];
            
            BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
            
            CGPoint translation = [recognizer translationInView:recognizer.view];
            
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                                 recognizer.view.center.y );
            
            if (!isVerticalGesture) {
                
                if(velocity.x > 0)
                {
                    
                    CGFloat percentage = (x/windowFrame.size.width);
                    recognizer.view.alpha =1.0- percentage;                }
                else
                {
                    CGFloat percentage = (x/windowFrame.size.width);
                    recognizer.view.alpha =percentage;
                    
                    
                }
                
            }
            
            [recognizer setTranslation:CGPointZero inView:recognizer.view];
        }
    }
}


- (void) calcNewFrameWithParsentage:(CGFloat) persentage newOffsetY:(CGFloat) newOffsetY{
    CGFloat newWidth = minimamVideoWidth + ((maxW - minimamVideoWidth) * (1 - persentage));
    CGFloat newHeight = newWidth * videoHeightRatio;
    
    CGFloat newOffsetX = maxW - newWidth - (finalMargin * persentage);
    
    vFrame.size.width = newWidth;//self.view.bounds.size.width - xOffset;
    vFrame.size.height = newHeight;//(200 - xOffset * 0.5);
    
    vFrame.origin.y = newOffsetY;//trueOffset - finalMargin * 2;
    wFrame.origin.y = newOffsetY;
    
    vFrame.origin.x = newOffsetX;//maxW - vFrame.size.width - finalMargin;
    wFrame.origin.x = newOffsetX;
    //    vFrame.origin.y = realNewOffsetY;//trueOffset - finalMargin * 2;
    //    wFrame.origin.y = realNewOffsetY;
    
}

-(void) setFinalFrame {
    vFrame.size.width = minimamVideoWidth;//self.view.bounds.size.width - xOffset;
    // ↓
    vFrame.size.height = vFrame.size.width * videoHeightRatio;//(200 - xOffset * 0.5);
    vFrame.origin.y = maxH - vFrame.size.height - finalMargin;//trueOffset - finalMargin * 2;
    vFrame.origin.x = maxW - vFrame.size.width - finalMargin;
    wFrame.origin.y = vFrame.origin.y;
    wFrame.origin.x = vFrame.origin.x;
}









# pragma mark - animations

-(void)expandView
{
    //        [self.txtViewGrowing resignFirstResponder];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         pageWrapper.frame = pageWrapperFrame;
                         videoWrapper.frame = videoWrapperFrame;
                         videoWrapper.alpha = 1;
                         videoView.frame = videoWrapperFrame;
                         pageWrapper.alpha = 1.0;
                         transparentBlackSheet.alpha = 1.0;
                         borderView.alpha = 0.0;

                         self.bodyView.frame = CGRectMake(0,
                                                          videoView.frame.size.height,// keep stay on bottom of videoView
                                                          self.bodyView.frame.size.width,
                                                          self.bodyView.frame.size.height);

                         borderView.frame = CGRectMake(videoView.frame.origin.y - 1,
                                                       videoView.frame.origin.x - 1,
                                                       videoView.frame.size.width + 1,
                                                       videoView.frame.size.height + 1);
                         
                         self.controllerView.frame = videoView.frame;
                     }
                     completion:^(BOOL finished) {

                         for (UIGestureRecognizer *recognizer in videoWrapper.gestureRecognizers) {
                             if([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
                                 [videoWrapper removeGestureRecognizer:recognizer];
                             }
                         }
                         
                         UITapGestureRecognizer* expandedTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapExpandedVideoView)];
                         expandedTap.numberOfTapsRequired = 1;
                         expandedTap.delegate = self;
                         [videoWrapper addGestureRecognizer:expandedTap];

                         
                         // player.controlStyle = MPMovieControlStyleDefault;
                         // [self showVideoControl];
                         isExpandedMode = TRUE;
//                         self.controllerView.hidden = FALSE;
                         [self didExpand];
                     }];
}



-(void)minimizeView
{
//    self.controllerView.hidden = TRUE;
    
    [self setFinalFrame];
    [self hideControllerView];

    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         pageWrapper.frame = wFrame;
                         videoWrapper.frame = vFrame;
                         videoView.frame=CGRectMake( videoView.frame.origin.x,  videoView.frame.origin.x, vFrame.size.width, vFrame.size.height);
                         pageWrapper.alpha=0;
                         transparentBlackSheet.alpha=0.0;
                         borderView.alpha = 1.0;

                         borderView.frame = CGRectMake(videoView.frame.origin.y - 1,
                                                       videoView.frame.origin.x - 1,
                                                       videoView.frame.size.width + 1,
                                                       videoView.frame.size.height + 1);

                         self.controllerView.frame = videoView.frame;
                     }
                     completion:^(BOOL finished) {
//                         [self hideVideoControl];
                         [self didMinimize];
                         //add tap gesture
                         tapRecognizer = nil;
                         if(tapRecognizer == nil)
                         {
                             
                             for (UIGestureRecognizer *recognizer in videoWrapper.gestureRecognizers) {
                                 if([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
                                     [videoWrapper removeGestureRecognizer:recognizer];
                                 }
                             }
                             
                             tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandViewOnTap:)];
                             tapRecognizer.numberOfTapsRequired = 1;
                             tapRecognizer.delegate = self;
                             [videoWrapper addGestureRecognizer:tapRecognizer];
                         }
                         
                         isExpandedMode=FALSE;
                         minimizedVideoFrame = videoWrapper.frame;
                         
                         if(direction==UIPanGestureRecognizerDirectionDown)
                         {
//                             [parentView bringSubviewToFront:self.view];
                             [self bringToFront];
                         }
                     }];
}

-(void)animateMiniViewToNormalPosition:(UIPanGestureRecognizer *)recognizer completion:(void (^)())completion {

    [self setFinalFrame];

    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         pageWrapper.frame = wFrame;
                         videoWrapper.frame = vFrame;
                         videoView.frame=CGRectMake(
                                                    videoView.frame.origin.x,
                                                    videoView.frame.origin.x,
                                                    vFrame.size.width,
                                                    vFrame.size.height
                                                );
                         pageWrapper.alpha = 0;
                         videoWrapper.alpha = 1;
                         borderView.alpha = 1;
                         
                         self.controllerView.frame = videoView.frame;
                     }
                     completion:^(BOOL finished) {
                         if (completion) completion();
                     }];
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
}

-(void)fadeOutViewToRight:(UIPanGestureRecognizer *)recognizer completion:(void (^)())completion {
//    [self.txtViewGrowing resignFirstResponder];
    
    vFrame.origin.x = maxW + minimamVideoWidth;
    wFrame.origin.x = maxW + minimamVideoWidth;

    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         pageWrapper.frame = wFrame;
                         videoWrapper.frame = vFrame;
                         videoView.frame=CGRectMake( videoView.frame.origin.x,  videoView.frame.origin.x, vFrame.size.width, vFrame.size.height);
                         pageWrapper.alpha = 0;
                         videoWrapper.alpha = 0;
                         borderView.alpha = 0;
                         
                         self.controllerView.frame = videoView.frame;
                     }
                     completion:^(BOOL finished) {
                         if (completion) completion();
                         [self didDisappear];
                     }];
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
}

-(void)fadeOutViewToLeft:(UIPanGestureRecognizer *)recognizer completion:(void (^)())completion {
//    [self.txtViewGrowing resignFirstResponder];
    
    vFrame.origin.x = -maxW;
    wFrame.origin.x = -maxW;

    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         pageWrapper.frame = wFrame;
                         videoWrapper.frame = vFrame;
                         videoView.frame=CGRectMake( videoView.frame.origin.x,  videoView.frame.origin.x, vFrame.size.width, vFrame.size.height);
                         pageWrapper.alpha = 0;
                         videoWrapper.alpha = 0;
                         borderView.alpha = 0;
                         
                         self.controllerView.frame = videoView.frame;
                     }
                     completion:^(BOOL finished) {
                         if (completion) completion();
                         [self didDisappear];
                     }];
    
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
}


#pragma mark- Pan Gesture Delagate

- (BOOL)gestureRecognizerShould:(UIGestureRecognizer *)gestureRecognizer {
    if(gestureRecognizer.view.frame.origin.y < 0)
    {
        return NO;
    }
    else {
        return YES;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}



#pragma mark- Status Bar Hidden function

- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotate
{
    return NO;
}

@end
