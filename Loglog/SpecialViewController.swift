//
//  SpecialViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/10/27.
//  Copyright © 2018 高野翔. All rights reserved.
//

import UIKit
import ESTabBarController
import Firebase
import FirebaseAuth
import SVProgressHUD


class SpecialViewController: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    
    //user defaultsを使う準備
    let userDefaults:UserDefaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
        // 枠のカラー
        textField.layer.borderColor = UIColor.black.cgColor
        // 枠の幅
        textField.layer.borderWidth = 0.5
        // 枠を角丸にする場合
        textField.layer.cornerRadius = 10.0
        textField.layer.masksToBounds = true
        
        //userDefauktsの初期値設定
        userDefaults.register(defaults: ["textField" : "※記載なし", "finalFlag" : "NO"])
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // ユーザー情報を取得して各Labelに設定する
        let user = Auth.auth().currentUser
        if let user = user {
            let userName = user.displayName
            userNameLabel.text = "\(userName!)さん"
        }
        
        let finalFlag = userDefaults.string(forKey: "finalFlag")!
        if finalFlag == "YES" {
            textField.text = ""
            userDefaults.set("NO", forKey: "finalFlag")
            userDefaults.synchronize()
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // テキスト以外の場所をタッチした際にキーボードを消す
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
    }
    
    
    @IBAction func sendButton(_ sender: Any) {
        if textField.text == "" {
            SVProgressHUD.showError(withStatus: "ご意見・ご要望の記載が空白の様です。ご確認下さい。")
            userDefaults.set("※記載なし", forKey: "textField")
        }
        else {
            userDefaults.set(textField.text, forKey: "textField")
            userDefaults.synchronize()
        }
    }
    
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        // 他の画面から segue を使って戻ってきた時に呼ばれる
    }
}
