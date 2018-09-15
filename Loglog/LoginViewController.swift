//
//  LoginViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/09/01.
//  Copyright © 2018年 高野翔. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate, GIDSignInDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Facebookサインイン
        let fbLoginBtn = FBSDKLoginButton()
        fbLoginBtn.readPermissions = ["public_profile", "email"]
        fbLoginBtn.frame = CGRect(x: 40.0, y: (UIScreen.main.bounds.size.height-100.0), width: 100.0, height: 40.0)
        fbLoginBtn.delegate = self
        self.view.addSubview(fbLoginBtn)
        
        //Googleサインイン
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        mailAddressTextField.delegate = self
        passwordTextField.delegate = self
        displayNameTextField.delegate = self
        
        //背景の設定
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "背景10")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
    }
    
    
    // Returnボタンを押した際にキーボードを消す
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        mailAddressTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        displayNameTextField.resignFirstResponder()
        return true
    }
    
    
    // テキスト以外の場所をタッチした際にキーボードを消す
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        mailAddressTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        displayNameTextField.resignFirstResponder()
    }

    
    // ログインボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleLoginButton(_ sender: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            
            // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を全て入力して下さい")
                return
            }
            
            // HUDで処理中を表示
            SVProgressHUD.show()
            
            Auth.auth().signIn(withEmail: address, password: password) { user, error in
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "サインインに失敗しました。")
                    return
                }
                else {
                    print("DEBUG_PRINT: ログインに成功しました。")
                    
                    // HUDを消す
                    SVProgressHUD.dismiss()
                    // 画面を閉じてViewControllerに戻る
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    // アカウント作成ボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleCreateAccountButton(_ sender: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text, let displayName = displayNameTextField.text {
            
            // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty || displayName.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                SVProgressHUD.showError(withStatus: "必要項目を全て入力して下さい")
                return
            }
            
            // HUDで処理中を表示
            SVProgressHUD.show()
            
            // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
            Auth.auth().createUser(withEmail: address, password: password) { user, error in
                if let error = error {
                    // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました")
                    return
                }
                print("DEBUG_PRINT: ユーザー作成に成功しました。")
                
                // 表示名を設定する
                let user = Auth.auth().currentUser
                if let user = user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            // プロフィールの更新でエラーが発生
                            print("DEBUG_PRINT: " + error.localizedDescription)
                            SVProgressHUD.showError(withStatus: "表示名の設定に失敗しました。")
                            return
                        }
                        print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                        
                        // HUDを消す
                        SVProgressHUD.dismiss()
                        // 画面を閉じてViewControllerに戻る
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }

    
    //Facebookサインイン（パターン②：成功！！）
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
        if let error = error {
            print("DEBUG_PRINT: " + error.localizedDescription)
            SVProgressHUD.showError(withStatus: "facebookサインインに失敗しました。")
            return
        }
        
        if result.isCancelled {
            SVProgressHUD.showError(withStatus: "facebookサインインをキャンセルしました。")
            return
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
            if let error = error {
                print("DEBUG_PRINT: " + error.localizedDescription)
                SVProgressHUD.showError(withStatus: "facebookサインインに失敗しました。")
                return
            }
            print("DEBUG_PRINT: facebookサインインに成功しました！！（by パターン②）")
            // HUDを消す
            SVProgressHUD.dismiss()
            // 画面を閉じてViewControllerに戻る
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // ログアウトする
        try! Auth.auth().signOut()
    }
    
    
    //Googleサインイン
    @IBAction func tapGoogleSingIn(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            print("DEBUG_PRINT: " + error.localizedDescription)
            SVProgressHUD.showError(withStatus: "Googleサインインに失敗しました。")
            return
        }
        
        let authentication = user.authentication
        // Googleのトークンを渡し、Firebaseクレデンシャルを取得する。
        let credential = GoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,accessToken: (authentication?.accessToken)!)
        
        // Firebaseにログインする。
        Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
            print("DEBUG_PRINT: Googleサインインに成功しました。")
            // HUDを消す
            SVProgressHUD.dismiss()
            // 画面を閉じてViewControllerに戻る
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //エラー処理
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("DEBUG_PRINT: Google Disconnectしました。")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
