//
//  PostedPinOnSearchViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/09/20.
//  Copyright © 2018年 高野翔. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD


class PostedPinOnSearchViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

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
        
        // categoryにPickerを実装する準備
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PostViewController.done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PostViewController.cancel))
        toolbar.setItems([cancelItem, doneItem], animated: true)
        
        self.category.inputView = pickerView
        self.category.inputAccessoryView = toolbar
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

    // categoryTextにPickerを実装する準備
    var pickerView: UIPickerView = UIPickerView()
    let list = ["", "思い出", "伝えられなかったありがとう", "名前を知らない貴方へありがとう", "ジョブマッチング", "秘密の場所", "観光スポット", "グルメ（ランチ）", "グルメ（ディナー）", "レジャー", "その他"]
    
    // categoryにPickerを実装する
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.category.text = list[row]
    }
    
    @objc func cancel() {
        self.category.text = ""
        self.category.endEditing(true)
    }
    
    @objc func done() {
        self.category.endEditing(true)
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    
    //検索＆ピン表示ボタンを押されたときの処理
    @IBAction func searchButton(_ sender: Any) {
    }

}
