//
//  HomeViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/09/01.
//  Copyright © 2018年 高野翔. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class HomeViewController: UIViewController {

    @IBOutlet weak var HomeBackgroundView: UIImageView!
    
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var userPostedSummary: UILabel!
    
    @IBOutlet weak var allPostedSelectButton: UIButton!
    @IBOutlet weak var likeSelectButton: UIButton!
    @IBOutlet weak var myMapSelectButton: UIButton!
    @IBOutlet weak var newsSelectButton: UIButton!
    @IBOutlet weak var shoppingButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var matchingButton: UIButton!
    
    @IBOutlet weak var loglogLogoImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HomeBackgroundView.image = UIImage(named: "背景new6")
        
        let userName = Auth.auth().currentUser?.displayName
        helloLabel.text = "Let's enjoy Loglog ! \n\(userName!)さん"
        userPostedSummary.text = "\(userName!)さんの全投稿"
        
        loglogLogoImage.image = UIImage(named: "Loglogロゴ")
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func allPostedSelectButton(_ sender: Any) {
    }
    
    
    @IBAction func likeSelectButton(_ sender: Any) {
    }
    
    
    @IBAction func myMapSelectButton(_ sender: Any) {
    }
    
    
    @IBAction func newsSelectButton(_ sender: Any) {
    }
    
    
    @IBAction func shoppingButton(_ sender: Any) {
    }
    
    
    @IBAction func eventButton(_ sender: Any) {
    }
    
    
    @IBAction func matchingButton(_ sender: Any) {
    }
    
}
