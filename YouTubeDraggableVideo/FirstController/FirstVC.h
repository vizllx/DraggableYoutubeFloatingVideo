//
//  FirstVC.h
//  YouTubeDraggableVideo
//
//  Created by Sandeep Mukherjee on 02/02/15.
//  Copyright (c) 2015 Sandeep Mukherjee. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "BSVideoDetailController.h"

//Define the protocol for the delegate

@interface FirstVC : UIViewController<RemoveViewDelegate>


@property(strong,nonatomic)BSVideoDetailController *secondViewController;

@property (weak, nonatomic) IBOutlet UITableView *commentsTable;

@property (strong, nonatomic)NSMutableArray *discussionArray;
@property (nonatomic, readwrite)NSInteger totalCount;
@property (nonatomic, readwrite)NSInteger pageno;
@property (nonatomic, readwrite)NSString *topicID;
@property (nonatomic,assign) BOOL isCanceledOperation;

@end
