//
//  HomeViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/09/01.
//  Copyright © 2018年 高野翔. All rights reserved.
//

import UIKit


class HomeViewController: UIViewController {

    @IBOutlet weak var HomeBackgroundView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HomeBackgroundView.image = UIImage(named: "背景new6")
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
