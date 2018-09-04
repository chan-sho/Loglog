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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        categoryText.resignFirstResponder()
        secretPass.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        categoryText.resignFirstResponder()
        secretPass.resignFirstResponder()
        contentsText.resignFirstResponder()
        relatedURL.resignFirstResponder()
    }
    
    @IBAction func postWithoutPhoto(_ sender: Any) {
        let postFinalizeViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostFinalize") as! PostFinalizeViewController
        postFinalizeViewController.categoryTextToPost.text = "\(self.categoryText!)"
        postFinalizeViewController.contentsTextToPost.text = "\(self.contentsText!)"
        postFinalizeViewController.relatedURLToPost.text = "\(self.relatedURL!)"
        postFinalizeViewController.secretPassToPost.text = "\(self.secretPass!)"
        postFinalizeViewController.image = nil
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryText.delegate = self
        contentsText.delegate = self
        relatedURL.delegate = self
        secretPass.delegate = self

        // 枠のカラー
        categoryText.layer.borderColor = UIColor.black.cgColor
        contentsText.layer.borderColor = UIColor.black.cgColor
        relatedURL.layer.borderColor = UIColor.black.cgColor
        secretPass.layer.borderColor = UIColor.black.cgColor
        // 枠の幅
        categoryText.layer.borderWidth = 1.0
        contentsText.layer.borderWidth = 1.0
        relatedURL.layer.borderWidth = 1.0
        secretPass.layer.borderWidth = 1.0
        // 枠を角丸にする場合
        categoryText.layer.cornerRadius = 10.0
        categoryText.layer.masksToBounds = true
        contentsText.layer.cornerRadius = 10.0
        contentsText.layer.masksToBounds = true
        relatedURL.layer.cornerRadius = 10.0
        relatedURL.layer.masksToBounds = true
        secretPass.layer.cornerRadius = 10.0
        secretPass.layer.masksToBounds = true
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
