//
//  SettingViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/09/01.
//  Copyright © 2018年 高野翔. All rights reserved.
//

import UIKit
import ESTabBarController
import Firebase
import FirebaseAuth
import SVProgressHUD


class SettingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passWordTextField: UITextField!
    
    @IBOutlet weak var handleNameChangeButton: UIButton!
    @IBOutlet weak var handleMailChangeButton: UIButton!
    @IBOutlet weak var handlePasswordChangeButton: UIButton!
    @IBOutlet weak var handleLogoutButton: UIButton!
    @IBOutlet weak var accountDeleteRequestButton: UIButton!
    
    //user defaultsを使う準備
    let userDefaults:UserDefaults = UserDefaults.standard
    
    
    @IBAction func handleNameChangeButton(_ sender: Any) {
        if let displayName = displayNameTextField.text {
            
            // 表示名が入力されていない時はHUDを出して何もしない
            if displayName.isEmpty {
                SVProgressHUD.showError(withStatus: "修正後のアカウント名（表示名）を入力して下さい")
                return
            }
            
            // 表示名を設定する
            let user = Auth.auth().currentUser
            if let user = user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges { error in
                    if let error = error {
                        SVProgressHUD.showError(withStatus: "アカウント名（表示名）の変更に失敗しました。")
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        return
                    }
                    print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                    
                    // HUDで完了を知らせる
                    SVProgressHUD.showSuccess(withStatus: "アカウント名（表示名）を変更しました")
                }
            }
        }
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    
    @IBAction func handleMailChangeButton(_ sender: Any) {
        if let mailAddress = mailAddressTextField.text {
            
            // 表示名が入力されていない時はHUDを出して何もしない
            if mailAddress.isEmpty {
                SVProgressHUD.showError(withStatus: "修正後のメールアドレスを入力して下さい")
                return
            }
            
                Auth.auth().currentUser?.updateEmail(to: self.mailAddressTextField.text!) { error in
                    if let error = error {
                        SVProgressHUD.showError(withStatus: "メールアドレスの変更に失敗しました。")
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        return
                    }
                    print("DEBUG_PRINT: [emailAddress = \(self.mailAddressTextField.text!)]の設定に成功しました。")
                    
                    // HUDで完了を知らせる
                    SVProgressHUD.showSuccess(withStatus: "メールアドレスを変更しました")
                }
            }
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    
    @IBAction func handlePasswordChangeButton(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: (Auth.auth().currentUser?.email)! ) { error in
            if let error = error {
                print(error)
                SVProgressHUD.showError(withStatus: "登録済みのメールアドレス\nである事を再確認して下さい")
                return
            }
            SVProgressHUD.showSuccess(withStatus: "登録済みのメールアドレスに\nパスワード再設定のメール\nをお送りしました")
            return
        }
    }
    
    
    @IBAction func handleLogoutButton(_ sender: Any) {
        // ログアウトする
        try! Auth.auth().signOut()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func accountDeleteRequestButton(_ sender: Any) {
        //アカウント削除のボタンを押した事をFlagに反映("NO" → "YES")
        userDefaults.set("YES", forKey: "AccountDeleteFlag")
        userDefaults.synchronize()
        print("アカウント削除ボタンが押された！：AccountDeleteFlag = 「YES」に変更")
        
        showAlertWithVC()
    }
    
    
    //アカウント削除確認画面のポップアップページを出す
    func showAlertWithVC(){
        AJAlertController.initialization().showAlert(aStrMessage: "Loglogをご愛顧頂き、\n本当にありがとうございます！\n\nアカウント削除が完了すると投稿データを含む全てのデータを変更できません。残したくない投稿データはご自身で必ず削除をお願い致します。\n\n（※同一のメールアドレス／アカウント名で再登録頂きましてもデータは復元致しません。）\n\n上記内容をご確認の上で、\n以下選択ください。", aCancelBtnTitle: "キャンセル", aOtherBtnTitle: "アカウント削除") { (index, title) in
            print(index,title)
        }
    }
    
    // Returnボタンを押した際にキーボードを消す
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        mailAddressTextField.resignFirstResponder()
        passWordTextField.resignFirstResponder()
        displayNameTextField.resignFirstResponder()
        return true
    }
    
    
    // テキスト以外の場所をタッチした際にキーボードを消す
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        mailAddressTextField.resignFirstResponder()
        passWordTextField.resignFirstResponder()
        displayNameTextField.resignFirstResponder()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // ユーザー情報を取得して各TextFieldに設定する（パスワード以外）
        let user = Auth.auth().currentUser
        if let user = user {
            displayNameTextField.text = user.displayName
        }
        let userAddress = Auth.auth().currentUser!.email
        if let userAddress = userAddress {
            mailAddressTextField.text = userAddress
        }

    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        mailAddressTextField.delegate = self
        passWordTextField.delegate = self
        displayNameTextField.delegate = self
        
        //背景の設定
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "背景new12")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        
        //ボタン同時押しによるアプリクラッシュを防ぐ
        handleNameChangeButton.isExclusiveTouch = true
        handleMailChangeButton.isExclusiveTouch = true
        handlePasswordChangeButton.isExclusiveTouch = true
        handleLogoutButton.isExclusiveTouch = true
        accountDeleteRequestButton.isExclusiveTouch = true
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
