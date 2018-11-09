//
//  GuideViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/10/20.
//  Copyright © 2018 高野翔. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController {

    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var view5: UIView!
    @IBOutlet weak var view6: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //背景の設定
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "背景(ver1.10)_8")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        
        view1.layer.borderWidth = 1.0
        view1.layer.borderColor = UIColor.gray.cgColor
        
        view2.layer.borderWidth = 1.0
        view2.layer.borderColor = UIColor.gray.cgColor
        
        view3.layer.borderWidth = 1.0
        view3.layer.borderColor = UIColor.gray.cgColor
        
        view4.layer.borderWidth = 1.0
        view4.layer.borderColor = UIColor.gray.cgColor
        
        view5.layer.borderWidth = 1.0
        view5.layer.borderColor = UIColor.gray.cgColor
        
        view6.layer.borderWidth = 1.0
        view6.layer.borderColor = UIColor.gray.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func tapOnView1(_ sender: Any) {
    }
    
    @IBAction func tapOnView2(_ sender: Any) {
    }
    
    @IBAction func tapOnView3(_ sender: Any) {
    }
    
    @IBAction func tapOnView4(_ sender: Any) {
    }
    
    @IBAction func tapOnView5(_ sender: Any) {
    }
    
    @IBAction func tapOnView6(_ sender: Any) {
    }
    
    
}
