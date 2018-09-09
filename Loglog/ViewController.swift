//
//  ViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/09/01.
//  Copyright © 2018年 高野翔. All rights reserved.
//

import UIKit
import ESTabBarController
import Firebase
import FirebaseAuth

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTab()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("ログイン画面処理チェックポイント①")
        
        // currentUserがnilならログインしていない
        if Auth.auth().currentUser == nil {
            
            print("ログイン画面処理チェックポイント②")
            
            // ログインしていないときの処理
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(loginViewController!, animated: true, completion: nil)
        }
    }
    
    func setupTab() {
        
        // 画像のファイル名を指定してESTabBarControllerを作成する
        let tabBarController: ESTabBarController! = ESTabBarController(tabIconNames: ["Home-1", "Current-1","Search-1", "Posted"])
        
        // 背景色、選択時の色を設定する
        tabBarController.selectedColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha:1.0)
        tabBarController.buttonsBackgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha:0.5)
        tabBarController.selectionIndicatorHeight = 2
        
        // 作成したESTabBarControllerを親のViewController（＝self）に追加する
        addChildViewController(tabBarController)
        let tabBarView = tabBarController.view!
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBarView)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tabBarView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            tabBarView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            ])
        tabBarController.didMove(toParentViewController: self)
        
        // タブをタップした時に表示するViewControllerを設定する
        let homeViewController = storyboard?.instantiateViewController(withIdentifier: "Home")
        let currentViewController = storyboard?.instantiateViewController(withIdentifier: "CurrentMap")
        let searchViewController = storyboard?.instantiateViewController(withIdentifier: "SearchMap")
        let postedDataViewController = storyboard?.instantiateViewController(withIdentifier: "PostedData")
        
        tabBarController.setView(homeViewController, at: 0)
        tabBarController.setView(currentViewController, at: 1)
        tabBarController.setView(searchViewController, at: 2)
        tabBarController.setView(postedDataViewController, at: 3)
        
    }
}
