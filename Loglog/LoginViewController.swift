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
    
    @IBOutlet weak var handleLoginButton: UIButton!
    @IBOutlet weak var handleCreateAccountButton: UIButton!
    @IBOutlet weak var passwordResetButton: UIButton!
    
    //facebookサインインボタンの生成準備
    let fbLoginBtn = FBSDKLoginButton()
    
    //user defaultsを使う準備
    let userDefaults:UserDefaults = UserDefaults.standard
    var EULAagreement : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Googleサインインボタン
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        //facebookサインインボタン
        fbLoginBtn.readPermissions = ["public_profile", "email"]
        fbLoginBtn.frame = CGRect(x: 40.0, y: self.view.frame.size.height - 105.0, width: 112.0, height: 40.0)
        fbLoginBtn.delegate = self
        self.view.addSubview(fbLoginBtn)
        
        mailAddressTextField.delegate = self
        passwordTextField.delegate = self
        displayNameTextField.delegate = self
        
        //背景の設定
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "背景new2R")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        
        //ボタン同時押しによるアプリクラッシュを防ぐ
        handleLoginButton.isExclusiveTouch = true
        handleCreateAccountButton.isExclusiveTouch = true
        passwordResetButton.isExclusiveTouch = true
        
        passwordResetButton.layer.borderWidth = 1.0
        passwordResetButton.layer.borderColor = UIColor.white.cgColor
        passwordResetButton.layer.cornerRadius = 10.0 //丸みを数値で変更できる
        
        //利用規約同意の判別要素
        EULAagreement = userDefaults.string(forKey: "EULAagreement")
        print("利用規約同意有無の確認＝\(String(describing: (EULAagreement)))")
        
        //アカウント削除の2重チェックに使うFlagの初期設定
        userDefaults.set("NO", forKey: "AccountDeleteFlag")
        userDefaults.synchronize()
        print("初期設定：AccountDeleteFlag = 「NO」")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Facebookサインインボタンの生成
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var bottomSafeArea: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            bottomSafeArea = view.safeAreaInsets.bottom
        }
        
        fbLoginBtn.frame = CGRect(x: 40.0, y: self.view.frame.size.height - 105.0 - bottomSafeArea, width: 112.0, height: 40.0)
    }
    
    
    //利用規約同意確認ポップアップの生成
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //利用規約に同意していない場合：
        if EULAagreement == nil {
            showAlertWithVC()
        }
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
                    SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました。\n※「メールアドレス」を間違えていないか念の為ご確認下さい\n（実際に使用可能なメールアドレスが必須です）")
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
    
    
    //PasswordResetボタンを押された際のアクション
    @IBAction func passwordResetButton(_ sender: Any) {
        
        if mailAddressTextField.text == "" {
            SVProgressHUD.showError(withStatus: "登録済みのメールアドレス\nを入力して下さい")
            return
        }
        else {
            Auth.auth().sendPasswordReset(withEmail: mailAddressTextField.text! ) { error in
                if let error = error {
                    print(error)
                    SVProgressHUD.showError(withStatus: "登録済みのメールアドレス\nである事を再確認して下さい")
                    return
                }
                SVProgressHUD.showSuccess(withStatus: "登録済みのメールアドレスに\nパスワード再設定のメール\nをお送りしました")
                return
            }
        }
    }
    
    
    //EULA同意画面のポップアップページを出す
    func showAlertWithVC(){
        AJAlertController.initialization().showAlert(aStrMessage: "Loglogをダウンロード頂き、\n本当にありがとうございます！\n\nご利用頂くにあたり必ず以下リンクから「プライバシーポリシー」「利用規約」をご確認下さい。\n皆様の大切な個人情報に関する記載がございますのでどうかよろしくお願い致します。\n\n内容をご確認の上で、\n以下選択ください。", aCancelBtnTitle: "リンク", aOtherBtnTitle: "同意する") { (index, title) in
            print(index,title)
        }
    }
    
}
