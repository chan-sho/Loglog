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


@objc protocol HomeViewDelegate {
    func homeViewAllPosted()
    func likeSelect()
    func myMapSelect()
}


class HomeViewController: UIViewController {

    @IBOutlet weak var HomeBackgroundView: UIImageView!
    
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var userPostedSummary: UILabel!
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    
    @IBOutlet weak var allPostedSelectButton: UIButton!
    @IBOutlet weak var likeSelectButton: UIButton!
    @IBOutlet weak var myMapSelectButton: UIButton!
    @IBOutlet weak var newsSelectButton: UIButton!
    @IBOutlet weak var shoppingButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var matchingButton: UIButton!
    
    @IBOutlet weak var loglogLogoImage: UIImageView!
    
    //Delegateを使う準備
    weak var delegate: HomeViewDelegate?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // ユーザー情報を取得して各Labelに設定する
        let user = Auth.auth().currentUser
        if let user = user {
            let userName = user.displayName
            helloLabel.text = "Let's enjoy Loglog ! \n\(userName!)さん"
            userPostedSummary.text = "\(userName!)さんの全投稿"
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HomeBackgroundView.image = UIImage(named: "背景new10R")
        
        view1.layer.borderWidth = 1.0
        view1.layer.borderColor = UIColor.red.cgColor
        view1.layer.cornerRadius = 10.0 //丸みを数値で変更できる
        
        view2.layer.borderWidth = 1.0
        view2.layer.borderColor = UIColor.orange.cgColor
        view2.layer.cornerRadius = 10.0 //丸みを数値で変更できる
        
        view3.layer.borderWidth = 1.0
        view3.layer.borderColor = UIColor.yellow.cgColor
        view3.layer.cornerRadius = 10.0 //丸みを数値で変更できる
        
        view4.layer.borderWidth = 1.0
        view4.layer.borderColor = UIColor.green.cgColor
        view4.layer.cornerRadius = 10.0 //丸みを数値で変更できる
        
        loglogLogoImage.image = UIImage(named: "Loglogロゴ")
        loglogLogoImage.layer.borderWidth = 1.0
        loglogLogoImage.layer.borderColor = UIColor.white.cgColor
        loglogLogoImage.layer.cornerRadius = 30.0 //丸みを数値で変更できる
        
        //ボタン同時押しによるアプリクラッシュを防ぐ
        allPostedSelectButton.isExclusiveTouch = true
        likeSelectButton.isExclusiveTouch = true
        myMapSelectButton.isExclusiveTouch = true
        newsSelectButton.isExclusiveTouch = true
        shoppingButton.isExclusiveTouch = true
        eventButton.isExclusiveTouch = true
        matchingButton.isExclusiveTouch = true
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func allPostedSelectButton(_ sender: Any) {
        
        self.tabBarController?.selectedIndex = 3
        
        //Delegateされているfunc()を実行
        self.delegate?.homeViewAllPosted()
        
        print("Delegate Funcの通過@allPostedSelectButton")
        
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
