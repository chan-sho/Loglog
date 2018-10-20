//
//  Guide1ViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/10/20.
//  Copyright © 2018 高野翔. All rights reserved.
//

import UIKit

class Guide1ViewController: UIViewController {

    
    @IBOutlet weak var guideHome1Image: UIImageView!
    @IBOutlet weak var guideHome2Image: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guideHome1Image.layer.borderWidth = 1.0
        guideHome1Image.layer.borderColor = UIColor.gray.cgColor
        
        guideHome2Image.layer.borderWidth = 1.0
        guideHome2Image.layer.borderColor = UIColor.gray.cgColor
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
