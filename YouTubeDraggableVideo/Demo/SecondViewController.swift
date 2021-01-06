//
//  SecondViewController.swift
//  YouTubeDraggableVideo
//
//  Created by Sandeep Mukherjee on 02/02/15.
//  Copyright (c) 2015 Sandeep Mukherjee. All rights reserved.
//

import Foundation

class SecondViewController: UIViewController {
    
    
    @objc func onTapButton() {
        (UIApplication.shared.delegate as! AppDelegate).videoViewController.show()//👈
    }

    @objc func onTapDismissButton() {
        _ = self.presentingViewController
        self.dismiss(animated: true, completion: nil)
//        NSTimer.schedule(delay: 0.2) { timer in
//            AppDelegate.videoController().changeParentVC(parentVC)//👈
//        }
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = .white

        let btn = UIButton()
        btn.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        btn.backgroundColor = .blue
        btn.addTarget(self, action: #selector(onTapButton), for: .touchUpInside)
        self.view.addSubview(btn)
        
        let dismissBtn = UIButton()
        dismissBtn.frame = CGRect(x: 150, y: 150, width: 100, height: 100)
        dismissBtn.backgroundColor = .orange
        dismissBtn.addTarget(self, action: #selector(onTapDismissButton), for: .touchUpInside)
        self.view.addSubview(dismissBtn)

    }
    
}
