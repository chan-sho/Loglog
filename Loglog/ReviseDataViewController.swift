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


class ReviseDataViewController: UIViewController {
    
    
    @IBOutlet weak var postCode: UITextField!
    @IBOutlet weak var postedReviseButton: UIButton!
    @IBOutlet weak var postedDeleteButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //背景の設定
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "背景11")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // 修正ボタンを押した際のアクション
    @IBAction func postedReviseButton(_ sender: Any) {
        
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
                //中身の確認
                
                let uid = Auth.auth().currentUser?.uid
                if uid == value {
                    
                    //Firebaseからデータを削除
                    let refOfDelete = Database.database().reference().child("posts").child("\(self.postCode.text!)")
                    refOfDelete.removeValue()
                    
                    SVProgressHUD.showSuccess(withStatus: "対象の投稿が削除されました")
                    
                    // 画面を閉じてViewControllerに戻る
                    //self.dismiss(animated: true, completion: nil)
                    return
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