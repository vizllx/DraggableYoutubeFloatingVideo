//
//  BSVideoDetailController.h
//  YouTubeDraggableVideo
//
//  Created by Sandeep Mukherjee on 02/02/15.
//  Copyright (c) 2015 Sandeep Mukherjee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>



@protocol DraggableFloatingViewControllerDelegate
@required
- (void)removeDraggableFloatingViewController;
@end


// please extend
@interface DraggableFloatingViewController : UIViewController<UIGestureRecognizerDelegate>



// ---------- use from SubClass ------------------------

// please add subview on this
@property(nonatomic, strong) UIView *bodyView;
//please add controller on this
@property(nonatomic, strong) UIView *controllerView;
//please add loading spiner on this
@property(nonatomic, strong) UIView *messageView;

// please call from "viewDidLoad" from sub class
- (void) setupViewsWithVideoView: (UIView *)vView
                 videoViewHeight: (CGFloat) videoHeight;

// please override if you want
- (void) didExpand;
- (void) didMinimize;
- (void) didStartMinimizeGesture;
- (void) didFullExpandByGesture;//stil dev
- (void) didDisappear;
- (void) didReAppear;


// please call if you want
- (void) minimizeView;
- (void) expandView;
- (void) hideControllerView;
- (void) showControllerView;
- (void) showMessageView;
- (void) hideMessageView;



// ---------- use from other class ------------------------
// please call from parent view controller
- (void) show;
- (void) bringToFront;



@end
