//
//  Guide4ViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/10/20.
//  Copyright © 2018 高野翔. All rights reserved.
//

import UIKit

class Guide4ViewController: UIViewController {
    
    @IBOutlet weak var view1: UIImageView!
    @IBOutlet weak var view2: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //背景の設定
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "背景(ver1.10)_8")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
