//
//  PostFinalizeViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/09/04.
//  Copyright © 2018年 高野翔. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

class PostFinalizeViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var image: UIImage!
    
    @IBOutlet weak var categoryTextToPost: UITextField!
    @IBOutlet weak var contentsTextToPost: UITextView!
    @IBOutlet weak var relatedURLToPost: UITextView!
    @IBOutlet weak var secretPassToPost: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    //user defaultsを使う準備
    let userDefaults:UserDefaults = UserDefaults.standard
    var pincoordinateToPost : String?
    
    // 投稿ボタンをタップしたときに呼ばれるメソッド
    @IBAction func handlePostButton(_ sender: UIButton) {
        // ImageViewから画像を取得する
        let imageData = UIImageJPEGRepresentation(imageView.image!, 0.5)
        let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)
        
        // postDataに必要な情報を取得しておく
        let time = Date.timeIntervalSinceReferenceDate
        let name = Auth.auth().currentUser?.displayName
        
        // **重要** 辞書を作成してFirebaseに保存する 【※後でAnnotationの位置情報も追加する！！】
        let postRef = Database.database().reference().child(Const.PostPath)
        let postDic = ["category": categoryTextToPost.text!, "contents": contentsTextToPost.text!, "related URL": relatedURLToPost.text!, "secretpass": secretPassToPost.text!, "image": imageString, "time": String(time), "name": name!]
        postRef.childByAutoId().setValue(postDic)
        
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    // キャンセルボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleCancelButton(_ sender: Any) {
        // 画面を閉じてViewControllerに戻る
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTextToPost.delegate = self
        contentsTextToPost.delegate = self
        relatedURLToPost.delegate = self
        secretPassToPost.delegate = self
        
        // userdefaultsで受け取ったデータを各TextView, TextFieldに設定する
        categoryTextToPost.text = userDefaults.string(forKey: "categoryText")
        contentsTextToPost.text = userDefaults.string(forKey: "contentsText")
        relatedURLToPost.text = userDefaults.string(forKey: "relatedURL")
        secretPassToPost.text = userDefaults.string(forKey: "secretPass")
        pincoordinateToPost = userDefaults.string(forKey: "pincoordinate")
        
        //pin座標値の確認
        //print("\(pincoordinateToPost!)")
        
        // 受け取った画像をImageViewに設定する
        imageView.image = image
        
        // 枠のカラー
        categoryTextToPost.layer.borderColor = UIColor.black.cgColor
        contentsTextToPost.layer.borderColor = UIColor.black.cgColor
        relatedURLToPost.layer.borderColor = UIColor.black.cgColor
        secretPassToPost.layer.borderColor = UIColor.black.cgColor
        // 枠の幅
        categoryTextToPost.layer.borderWidth = 1.0
        contentsTextToPost.layer.borderWidth = 1.0
        relatedURLToPost.layer.borderWidth = 1.0
        secretPassToPost.layer.borderWidth = 1.0
        // 枠を角丸にする場合
        categoryTextToPost.layer.cornerRadius = 10.0
        categoryTextToPost.layer.masksToBounds = true
        contentsTextToPost.layer.cornerRadius = 10.0
        contentsTextToPost.layer.masksToBounds = true
        relatedURLToPost.layer.cornerRadius = 10.0
        relatedURLToPost.layer.masksToBounds = true
        secretPassToPost.layer.cornerRadius = 10.0
        secretPassToPost.layer.masksToBounds = true
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
