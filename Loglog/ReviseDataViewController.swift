//
//  ReviseDataViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/09/18.
//  Copyright © 2018年 高野翔. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD


class ReviseDataViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var postCode: UITextField!
    @IBOutlet weak var postedReviseButton: UIButton!
    @IBOutlet weak var postedDeleteButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    //user defaultsを使う準備
    let userDefaults:UserDefaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //背景の設定
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "背景new13")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        
        postCode.delegate = self
        //何も入力されていなくてもReturnキーを押せるようにする。
        postCode.enablesReturnKeyAutomatically = false
        postCode.text = userDefaults.string(forKey: "reviseDataId")
        
        //ボタン同時押しによるアプリクラッシュを防ぐ
        postedReviseButton.isExclusiveTouch = true
        postedDeleteButton.isExclusiveTouch = true
        cancelButton.isExclusiveTouch = true
    }
    
    //念のため（※userDefaultsの更新タイミングが遅かった場合のために）
    override func viewWillAppear(_ animated: Bool) {
        postCode.text = userDefaults.string(forKey: "reviseDataId")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // Returnボタンを押した際にキーボードを消す
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        postCode.resignFirstResponder()
        return true
    }
    
    
    // テキスト以外の場所をタッチした際にキーボードを消す
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        postCode.resignFirstResponder()
    }
    
    
    // 修正ボタンを押した際のアクション
    @IBAction func postedReviseButton(_ sender: Any) {
        
        if self.postCode.text == "" {
            SVProgressHUD.showError(withStatus: "「投稿ナンバー」を入力して下さい")
            return
        }
        // postCodeに対象の投稿ナンバーが入っている場合
        else {
            var ref: DatabaseReference!
            ref = Database.database().reference().child("posts").child("\(self.postCode.text!)").child("userID")
            print("refの中身は：\(ref!)")
            
            //  FirebaseからobserveSingleEventで1回だけデータ検索
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? String
                print("valueの中身は：\(value!)")
                
                let uid = Auth.auth().currentUser?.uid
                if uid == value {
                    
                    //Firebaseから該当データを抽出
                    let refToRevise = Database.database().reference().child("posts").child("\(self.postCode.text!)")
                    print("refToReviseの中身は：\(refToRevise)")
                    
                    refToRevise.observeSingleEvent(of: .value, with: { (snapshot) in
                        var valueToRevise = snapshot.value as! [String: AnyObject]
                        //使わない画像データのkeyを配列から削除
                        //*_ = valueToRevise.removeValue(forKey: "image")
                            
                        //中身の確認
                        print("valueToReviseの中身は：\(valueToRevise)")
                        
                        //userDefaultsに保存
                        self.userDefaults.set(valueToRevise["category"], forKey: "reviseCategory")
                        self.userDefaults.set(valueToRevise["contents"], forKey: "reviseContents")
                        self.userDefaults.set(valueToRevise["relatedURL"], forKey: "reviseRelatedURL")
                        self.userDefaults.set(valueToRevise["secretpass"], forKey: "reviseSecretpass")
                        self.userDefaults.set(valueToRevise["image"], forKey: "reviseImage")
                        self.userDefaults.synchronize()
                    })
                    
                    self.performSegue(withIdentifier: "toReviseDetail", sender: nil)
                }
                else {
                    SVProgressHUD.showError(withStatus: "投稿者ではない\nまたは\n「投稿ナンバー」が存在しない為、\n削除できません！\n\nもう一度確認して下さい")
                    return
                }
                
            }) { (error) in
                print(error.localizedDescription)
                SVProgressHUD.showError(withStatus: "「投稿ナンバー」をもう一度確認して下さい")
                return
            }
        }
    }
    
    
    // 削除ボタンを押した際のアクション
    @IBAction func postedDeleteButton(_ sender: Any) {
        
        if self.postCode.text == "" {
            SVProgressHUD.showError(withStatus: "「投稿ナンバー」を入力して下さい")
            return
        }
        // postCodeに対象の投稿ナンバーが入っている場合
        else {
            var ref: DatabaseReference!
            ref = Database.database().reference().child("posts").child("\(self.postCode.text!)").child("userID")
            
            //中身の確認
            print("refの中身は：\(ref!)")
            
            //  FirebaseからobserveSingleEventで1回だけデータ検索
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? String
                
                let uid = Auth.auth().currentUser?.uid
                if uid == value {
                    
                    //Firebaseからデータを削除
                    let refOfDelete = Database.database().reference().child("posts").child("\(self.postCode.text!)")
                    refOfDelete.removeValue()
                    
                    SVProgressHUD.showSuccess(withStatus: "対象の投稿が削除されました")
                    
                    // 画面を閉じてPostedDataViewControllerに戻る&その画面先でTableViewをReload
                    self.navigationController!.popToRootViewController(animated: true)
                    
                }
                else {
                    SVProgressHUD.showError(withStatus: "投稿者ではない\nまたは\n「投稿ナンバー」が存在しない為、\n削除できません！\n\nもう一度確認して下さい")
                    return
                }
                
            }) { (error) in
                print(error.localizedDescription)
                SVProgressHUD.showError(withStatus: "「投稿ナンバー」をもう一度確認して下さい")
                return
            }
        }
    }
    
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        // 他の画面から segue を使って戻ってきた時に呼ばれる
    }
    
}
