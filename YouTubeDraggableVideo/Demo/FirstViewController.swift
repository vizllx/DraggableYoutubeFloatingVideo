//
//  FirstViewController.swift
//  YouTubeDraggableVideo
//
//  Created by Sandeep Mukherjee on 02/02/15.
//  Copyright (c) 2015 Sandeep Mukherjee. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController  {
    
    
    override func viewDidLoad() {
        self.view.backgroundColor = .white

        let btn = UIButton()
        btn.frame = CGRect(x: self.view.center.x-100, y: self.view.center.y, width: 200, height: 100)
        btn.backgroundColor = .blue
        btn.setTitle("Show Video Screen", for: .normal)
        btn.addTarget(self, action: #selector(onTapShowButton), for: .touchUpInside)
        self.view.addSubview(btn)
        
      
        
    }

    @objc func onTapShowButton() {
        (UIApplication.shared.delegate as! AppDelegate).videoViewController.show() //👈
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

   
    
}
