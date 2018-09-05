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
    }
    
    @IBAction func handleLogoutButton(_ sender: Any) {
        // ログアウトする
        try! Auth.auth().signOut()
        
        // ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        self.present(loginViewController!, animated: true, completion: nil)
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
