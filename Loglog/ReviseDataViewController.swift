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
        
        //ボタン同時押しによるアプリクラッシュを防ぐ
        postedReviseButton.isExclusiveTouch = true
        postedDeleteButton.isExclusiveTouch = true
        cancelButton.isExclusiveTouch = true
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
            SVProgressHUD.showError(withStatus: "現在、修正ボタンの機能を停止しています")
            return
        }
        else {
            SVProgressHUD.showError(withStatus: "現在、修正ボタンの機能を停止しています")
            return
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
                    let postedDataViewController = self.presentingViewController as? PostedDataViewController
                    self.dismiss(animated: true, completion: {
                        postedDataViewController?.tableView.reloadData()
                    })
                    
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
    
}
