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
    
    // 投稿ボタンをタップしたときに呼ばれるメソッド
    
    @IBAction func handlePostButton(_ sender: UIButton) {
    }
    
    // キャンセルボタンをタップしたときに呼ばれるメソッド
    
    @IBAction func handleCancelButton(_ sender: Any) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTextToPost.delegate = self
        contentsTextToPost.delegate = self
        relatedURLToPost.delegate = self
        secretPassToPost.delegate = self
        
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
