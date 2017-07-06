//
//  ViewController.swift
//  LWInfiniteScrollView
//
//  Created by wang on 05/07/2017.
//  Copyright © 2017 wang. All rights reserved.
//

import UIKit


let SCREEN_WIDTH = UIScreen.main.bounds.size.width

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        testInifiteScrollView()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    func testInifiteScrollView() {
        
        var arr = [UIView]()
        
        for i in 0...3 {
            let imageView = UIImageView.init(frame: CGRect(x: SCREEN_WIDTH * CGFloat(i), y: 0, width: SCREEN_WIDTH, height: 200))
            imageView.image = UIImage.init(named: "\(i)")
            arr.append(imageView)
        }
        
        
        let view = LWInfiniteScrollView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 300), viewsArray: arr)
        self.view.addSubview(view)
    }
}

