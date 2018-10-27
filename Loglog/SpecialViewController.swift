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


class SpecialViewController: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
        // 枠のカラー
        textField.layer.borderColor = UIColor.black.cgColor
        // 枠の幅
        textField.layer.borderWidth = 1.0
        // 枠を角丸にする場合
        textField.layer.cornerRadius = 10.0
        textField.layer.masksToBounds = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // ユーザー情報を取得して各Labelに設定する
        let user = Auth.auth().currentUser
        if let user = user {
            let userName = user.displayName
            userNameLabel.text = "\(userName!)さん"
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
    }
    
}
