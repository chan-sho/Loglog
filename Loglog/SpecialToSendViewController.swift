//
//  SpecialToSendViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/10/27.
//  Copyright © 2018 高野翔. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD


class SpecialToSendViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailAddress: UITextField!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var finalSendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    //user defaultsを使う準備
    let userDefaults:UserDefaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userEmailAddress.delegate = self
        textField.delegate = self
        
        // 枠のカラー
        userEmailAddress.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderColor = UIColor.black.cgColor
        // 枠の幅
        userEmailAddress.layer.borderWidth = 0.5
        textField.layer.borderWidth = 0.5
        // 枠を角丸にする場合
        userEmailAddress.layer.cornerRadius = 10.0
        userEmailAddress.layer.masksToBounds = true
        textField.layer.cornerRadius = 10.0
        textField.layer.masksToBounds = true
        
        //ボタン同時押しによるアプリクラッシュを防ぐ
        finalSendButton.isExclusiveTouch = true
        cancelButton.isExclusiveTouch = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // ユーザー情報を取得して各Labelに設定する
        let user = Auth.auth().currentUser
        if let user = user {
            let userName = user.displayName
            userNameLabel.text = "\(userName!)さん"
        }
        let userAddress = Auth.auth().currentUser!.email
        if let userAddress = userAddress {
            userEmailAddress.text = userAddress
        }
        
        textField.text = userDefaults.string(forKey: "textField")!
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Returnボタンを押した際にキーボードを消す
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userEmailAddress.resignFirstResponder()
        return true
    }
    
    
    // テキスト以外の場所をタッチした際にキーボードを消す
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        userEmailAddress.resignFirstResponder()
        textField.resignFirstResponder()
    }
    
    
    @IBAction func finalSendButton(_ sender: Any) {
        if textField.text == "※記載なし" {
            SVProgressHUD.showError(withStatus: "ご意見・ご要望の記載が空白の様です。ご確認下さい。")
            return
        }
        else {
            //FireBase上に辞書型データで残す処理
            //postDataに必要な情報を取得しておく
            let time = Date.timeIntervalSinceReferenceDate
            let name = Auth.auth().currentUser?.displayName

            //メールアドレスが空白だった際のデータ準備
            if userEmailAddress.text == "" {
                let email = "e-mail記載なし"
                userEmailAddress.text = email
            }
            
            //**重要** 辞書を作成してFirebaseに保存する
            let postRef = Database.database().reference().child(Const2.PostPath2)
            let postDic = ["userID": Auth.auth().currentUser!.uid, "time": String(time), "name": name!, "requestTextField": String(textField.text!), "requestUserEmail": userEmailAddress.text!, "answerTextField": "", "answerCategory": "", "answerFlag": ""] as [String : Any]
            postRef.childByAutoId().setValue(postDic)
            
            SVProgressHUD.showSuccess(withStatus: "\(name!)さん\n\n貴重なご意見、本当にありがとうございました！\nこれからも頑張ってより良いLoglogにしていきますので、どうか宜しくお願い致します！")
            
            //送信完了した事をfinalFlagで判別し、画面遷移させる
            userDefaults.set("YES", forKey: "finalFlag")
            userDefaults.synchronize()
            self.navigationController!.popToRootViewController(animated: true)
        }
    }
    
}
