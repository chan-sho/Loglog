//
//  PostedPinOnCurrentViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/09/20.
//  Copyright © 2018年 高野翔. All rights reserved.
//

import UIKit

class PostedPinOnCurrentViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var postedName: UITextField!
    @IBOutlet weak var postedNumber: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        category.delegate = self
        postedName.delegate = self
        postedNumber.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Returnボタンを押した際にキーボードを消す（※TextViewには設定できない。改行できなくなる為＾＾）
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        category.resignFirstResponder()
        postedName.resignFirstResponder()
        postedNumber.resignFirstResponder()
        return true
    }
    
    
    // テキスト以外の場所をタッチした際にキーボードを消す
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        category.resignFirstResponder()
        postedName.resignFirstResponder()
        postedNumber.resignFirstResponder()
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
