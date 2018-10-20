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
        
        view1.layer.borderWidth = 1.0
        view1.layer.borderColor = UIColor.gray.cgColor
        
        view2.layer.borderWidth = 1.0
        view2.layer.borderColor = UIColor.gray.cgColor

        // Do any additional setup after loading the view.
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
