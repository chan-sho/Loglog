//
//  HomeViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/09/01.
//  Copyright © 2018年 高野翔. All rights reserved.
//

import UIKit
import ESTabBarController
import Firebase
import FirebaseAuth


class HomeViewController: UIViewController {

    @IBOutlet weak var HomeBackgroundView: UIImageView!
    
    @IBOutlet weak var userProfilePhoto: UIImageView!
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
    @IBOutlet weak var termsOfServiceButton: UIButton!
    
    @IBOutlet weak var loglogLogoImage: UIImageView!
    
    //真っ白な背景のImageView
    var whiteBackGround: UIView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // ユーザー情報を取得して各Labelに設定する
        let user = Auth.auth().currentUser
        if let user = user {
            let userName = user.displayName
            helloLabel.text = "Let's enjoy Loglog ! \n\(userName!)さん"
            userPostedSummary.text = "\(userName!)さんの全投稿"
        }
        
        //ログインユーザーのプロフィール画像をロード
        let currentUser = Auth.auth().currentUser
        
        if currentUser != nil {
            whiteBackGround.removeFromSuperview()
            
            let userProfileurl = Auth.auth().currentUser?.photoURL
            if userProfileurl != nil {
            let url = URL(string: "\(userProfileurl!)")
            print("\(url!)")
            
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                DispatchQueue.main.async {
                    self.userProfilePhoto.image = UIImage(data: data!)
                    self.userProfilePhoto.clipsToBounds = true
                    self.userProfilePhoto.layer.cornerRadius = 25
                }
            }).resume()
            }
        }
        else {
            self.view.addSubview(whiteBackGround)
        }
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //真っ白な背景のImageView
        whiteBackGround = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width))
        whiteBackGround.backgroundColor = UIColor.white
        whiteBackGround.layer.zPosition = +1
        self.view.addSubview(whiteBackGround)
        
        HomeBackgroundView.image = UIImage(named: "背景new10R")
        
        //ログインユーザーのプロフィール画像をロード
        let currentUser = Auth.auth().currentUser
        
        if currentUser != nil {
        let userProfileurl = Auth.auth().currentUser?.photoURL
        
        if userProfileurl != nil {
        let url = URL(string: "\(userProfileurl!)")
        
        print("\(url!)")
        
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.userProfilePhoto.image = UIImage(data: data!)
                self.userProfilePhoto.clipsToBounds = true
                self.userProfilePhoto.layer.cornerRadius = 27.5
            }
         }).resume()
        }
        
        }
        
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
        termsOfServiceButton.isExclusiveTouch = true
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func allPostedSelectButton(_ sender: Any) {
        print("ボタン押印確認　@ allPostedSelectButton")
        
        let tabBarController = parent as! ESTabBarController
        tabBarController.setSelectedIndex(3, animated: false)
        for viewController in tabBarController.childViewControllers {
            if viewController is PostedDataViewController {
                let postedViewContoller = viewController as! PostedDataViewController
                postedViewContoller.allPostedSelection()
                break
            }
        }
    }
    
    
    @IBAction func likeSelectButton(_ sender: Any) {
        print("ボタン押印確認　@ likeSelectButton")
        
        let tabBarController = parent as! ESTabBarController
        tabBarController.setSelectedIndex(3, animated: false)
        for viewController in tabBarController.childViewControllers {
            if viewController is PostedDataViewController {
                let postedViewContoller = viewController as! PostedDataViewController
                postedViewContoller.likeSelection()
                break
            }
        }
    }
    
    
    @IBAction func myMapSelectButton(_ sender: Any) {
        print("ボタン押印確認　@ myMapSelectButton")
        
        let tabBarController = parent as! ESTabBarController
        tabBarController.setSelectedIndex(3, animated: false)
        for viewController in tabBarController.childViewControllers {
            if viewController is PostedDataViewController {
                let postedViewContoller = viewController as! PostedDataViewController
                postedViewContoller.myMapSelection()
                break
            }
        }
    }
    
    
    @IBAction func newsSelectButton(_ sender: Any) {
    }
    
    
    @IBAction func shoppingButton(_ sender: Any) {
    }
    
    
    @IBAction func eventButton(_ sender: Any) {
    }
    
    
    @IBAction func matchingButton(_ sender: Any) {
    }
    
    
    //View1を押した際のアクション（今後View上のボタンを隠しボタンにして面白いアクションを設定するために）
    @IBAction func tapOnView1(_ sender: Any) {
        print("ボタン押印確認　@ tapOnView1")
        
        let tabBarController = parent as! ESTabBarController
        tabBarController.setSelectedIndex(3, animated: false)
        for viewController in tabBarController.childViewControllers {
            if viewController is PostedDataViewController {
                let postedViewContoller = viewController as! PostedDataViewController
                postedViewContoller.allPostedSelection()
                break
            }
        }
    }
    
    
    //View2を押した際のアクション（今後View上のボタンを隠しボタンにして面白いアクションを設定するために）
    @IBAction func tapOnView2(_ sender: Any) {
        print("ボタン押印確認　@ likeSelectButton")
        
        let tabBarController = parent as! ESTabBarController
        tabBarController.setSelectedIndex(3, animated: false)
        for viewController in tabBarController.childViewControllers {
            if viewController is PostedDataViewController {
                let postedViewContoller = viewController as! PostedDataViewController
                postedViewContoller.likeSelection()
                break
            }
        }
    }
    
    
    //View3を押した際のアクション（今後View上のボタンを隠しボタンにして面白いアクションを設定するために）
    @IBAction func tapOnView3(_ sender: Any) {
        print("ボタン押印確認　@ myMapSelectButton")
        
        let tabBarController = parent as! ESTabBarController
        tabBarController.setSelectedIndex(3, animated: false)
        for viewController in tabBarController.childViewControllers {
            if viewController is PostedDataViewController {
                let postedViewContoller = viewController as! PostedDataViewController
                postedViewContoller.myMapSelection()
                break
            }
        }
    }
    
    
    //*View4を押した際のアクション（今後View上のボタンを隠しボタンにして面白いアクションを設定するために）
    @IBAction func tapOnView4(_ sender: Any) {
    }
    
    
    @IBAction func termsOfServiceButton(_ sender: Any) {
        //プライバシーポリシー・利用規約のページをSafariで開くアクション
        let url = URL(string: "https://chan-sho.github.io/")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
}
