//
//  PostViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/09/01.
//  Copyright © 2018年 高野翔. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

class PostViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var categoryText: UITextField!
    @IBOutlet weak var contentsText: UITextView!
    @IBOutlet weak var relatedURL: UITextView!
    @IBOutlet weak var secretPass: UITextField!
    
    
    @IBOutlet weak var postWithoutPhoto: UIButton!
    @IBOutlet weak var postWithPhoto: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    @IBAction func postWithoutPhoto(_ sender: Any) {
        let postFinalizeViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostFinalize") as! PostFinalizeViewController
        postFinalizeViewController.categoryTextToPost.text = "\(self.categoryText!)"
        postFinalizeViewController.contentsTextToPost.text = "\(self.contentsText!)"
        postFinalizeViewController.relatedURLToPost.text = "\(self.relatedURL!)"
        postFinalizeViewController.secretPassToPost.text = "\(self.secretPass!)"
        postFinalizeViewController.image = nil
        
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        // 画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryText.delegate = self
        contentsText.delegate = self
        relatedURL.delegate = self
        secretPass.delegate = self

        // 枠のカラー
        contentsText.layer.borderColor = UIColor.black.cgColor
        relatedURL.layer.borderColor = UIColor.black.cgColor
        // 枠の幅
        contentsText.layer.borderWidth = 1.0
        relatedURL.layer.borderWidth = 1.0
        // 枠を角丸にする場合
        contentsText.layer.cornerRadius = 10.0
        contentsText.layer.masksToBounds = true
        relatedURL.layer.cornerRadius = 10.0
        relatedURL.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        // 他の画面から segue を使って戻ってきた時に呼ばれる
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
