//
//  NSTimerHelper.swift
//  YouTubeDraggableVideo
//
//  Created by Sandeep Mukherjee on 02/02/15.
//  Copyright (c) 2015 Sandeep Mukherjee. All rights reserved.
//

import Foundation

extension Timer {
    static func schedule(delay: TimeInterval, handler: @escaping(Timer?)  -> Void) -> Timer? {
        let fireDate = delay + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
        return timer
    }
    
    static func schedule(repeatInterval interval: TimeInterval, handler: @escaping(Timer?)  -> Void) -> Timer? {
        let fireDate = interval + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
        return timer
    }
}


// Usage:

//var count = 0
//NSTimer.schedule(repeatInterval: 1) { timer in
//    println(++count)
//    if count >= 10 {
//        timer.invalidate()
//    }
//}
//
//NSTimer.schedule(delay: 5) { timer in
//    println("5 seconds")
//}
