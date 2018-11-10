//
//  ReviseDetailViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/11/04.
//  Copyright © 2018 高野翔. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD


class ReviseDetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var contents: UITextView!
    @IBOutlet weak var relatedURL: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var reviseImageButton: UIButton!
    @IBOutlet weak var reviseFinalizeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var imageString: String?
    var UIimage: UIImage?
    
    //user defaultsを使う準備
    let userDefaults:UserDefaults = UserDefaults.standard
    
    // categoryTextにPickerを実装する準備
    var pickerView: UIPickerView = UIPickerView()
    let list = ["(カテゴリーなし)", "思い出", "伝えられなかったありがとう", "名前を知らない貴方へありがとう", "ジョブマッチング", "秘密の場所", "観光スポット", "グルメ（ランチ）", "グルメ（ディナー）", "レジャー", "その他"]
    
    // Returnボタンを押した際にキーボードを消す（※TextViewには設定できない。改行できなくなる為＾＾）
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        category.resignFirstResponder()
        relatedURL.resignFirstResponder()
        password.resignFirstResponder()
        return true
    }
    
    // テキスト以外の場所をタッチした際にキーボードを消す
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        category.resignFirstResponder()
        contents.resignFirstResponder()
        relatedURL.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        category.delegate = self
        contents.delegate = self
        relatedURL.delegate = self
        password.delegate = self
        
        // 枠のカラー
        category.layer.borderColor = UIColor.black.cgColor
        contents.layer.borderColor = UIColor.black.cgColor
        relatedURL.layer.borderColor = UIColor.black.cgColor
        password.layer.borderColor = UIColor.black.cgColor
        // 枠の幅
        category.layer.borderWidth = 0.5
        contents.layer.borderWidth = 0.5
        relatedURL.layer.borderWidth = 0.5
        password.layer.borderWidth = 0.5
        // 枠を角丸にする場合
        category.layer.cornerRadius = 10.0
        category.layer.masksToBounds = true
        contents.layer.cornerRadius = 10.0
        contents.layer.masksToBounds = true
        relatedURL.layer.cornerRadius = 10.0
        relatedURL.layer.masksToBounds = true
        password.layer.cornerRadius = 10.0
        password.layer.masksToBounds = true
        
        reviseImageButton.layer.borderColor = UIColor.red.cgColor
        // 枠の幅
        reviseImageButton.layer.borderWidth = 0.5
        // 枠を角丸にする場合
        reviseImageButton.layer.cornerRadius = 10.0
        reviseImageButton.layer.masksToBounds = true
        
        // categoryTextにPickerを実装する準備
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PostViewController.done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PostViewController.cancel))
        toolbar.setItems([cancelItem, doneItem], animated: true)
        
        self.category.inputView = pickerView
        self.category.inputAccessoryView = toolbar
        
        //ボタン同時押しによるアプリクラッシュを防ぐ
        reviseFinalizeButton.isExclusiveTouch = true
        reviseImageButton.isExclusiveTouch = true
        cancelButton.isExclusiveTouch = true

        //背景の設定
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "背景(ver1.10)_11")
        bg.contentMode = UIViewContentMode.scaleAspectFill
        bg.clipsToBounds = true
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        
        // userdefaultsで受け取ったデータを各TextView, TextFieldに設定する
        category.text = userDefaults.string(forKey: "reviseCategory")
        contents.text = userDefaults.string(forKey: "reviseContents")
        relatedURL.text = userDefaults.string(forKey: "reviseRelatedURL")
        password.text = userDefaults.string(forKey: "reviseSecretpass")
        
        // userdefaultsで受け取ったデータをImageに設定する
        imageString = userDefaults.string(forKey: "reviseImage")
        if imageString != nil {
            UIimage = UIImage(data: Data(base64Encoded: imageString!, options: .ignoreUnknownCharacters)!)
            image.image = UIimage
            image?.contentMode = UIViewContentMode.scaleAspectFit
        }
        
        //初期値設定
        userDefaults.register(defaults: ["reviseImageButtonFlag" : "NO"])
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        // userdefaultsで受け取ったデータを各TextView, TextFieldに設定する
        category.text = userDefaults.string(forKey: "reviseCategory")
        contents.text = userDefaults.string(forKey: "reviseContents")
        relatedURL.text = userDefaults.string(forKey: "reviseRelatedURL")
        password.text = userDefaults.string(forKey: "reviseSecretpass")
        
        // userdefaultsで受け取ったデータをImageに設定する
        imageString = userDefaults.string(forKey: "reviseImage")
        if imageString != nil {
            UIimage = UIImage(data: Data(base64Encoded: imageString!, options: .ignoreUnknownCharacters)!)
            image.image = UIimage
            image?.contentMode = UIViewContentMode.scaleAspectFit
        }
        
        //初期値設定
        userDefaults.register(defaults: ["reviseImageButtonFlag" : "NO"])
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // categoryTextにPickerを実装する
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
    

    //「上記内容で修正」ボタンを押された際のアクション
    @IBAction func reviseFinalizeButton(_ sender: Any) {
        let reviseDataId = userDefaults.string(forKey: "reviseDataId")
        let reviseImageString = userDefaults.string(forKey: "reviseImage")
        print("\(reviseDataId!)")
        
        if category.text == ""{
            let Data = ["category": "(カテゴリーなし)", "contents": "\(contents.text ?? "")", "relatedURL": "\(relatedURL.text ?? "")", "secretpass": "\(password.text ?? "")", "image": "\(reviseImageString!)"]
            
            //Firebaseから該当データを選択し、データの各項目をアップデート
            let refToReviseData = Database.database().reference().child("posts").child("\(reviseDataId!)")
            print("refToReviseDataの中身は：\(refToReviseData)")
            refToReviseData.updateChildValues(Data)
        }
        else{
            let Data = ["category": "\(category.text!)", "contents": "\(contents.text ?? "")", "relatedURL": "\(relatedURL.text ?? "")", "secretpass": "\(password.text ?? "")", "image": "\(reviseImageString!)"]
            
            //Firebaseから該当データを選択し、データの各項目をアップデート
            let refToReviseData = Database.database().reference().child("posts").child("\(reviseDataId!)")
            print("refToReviseDataの中身は：\(refToReviseData)")
            refToReviseData.updateChildValues(Data)
        }
        
        let reviseImageButtonFlag = userDefaults.string(forKey: "reviseImageButtonFlag")
        self.userDefaults.synchronize()
        print("reviseImageButtonFlag① = \(reviseImageButtonFlag!)")
        
        //投稿画像を修正したかどうかの条件分岐
        if reviseImageButtonFlag == "YES" {
            
            //Flagの初期化
            self.userDefaults.set("NO", forKey: "reviseImageButtonFlag")
            //Flagのチェック
            let checkReviseImageButtonFlag = userDefaults.string(forKey: "reviseImageButtonFlag")
            self.userDefaults.synchronize()
            print("*Check of reviseImageButtonFlag = \(checkReviseImageButtonFlag!)")
            
            let navigationController = self.presentingViewController!.presentingViewController as! UINavigationController
            navigationController.popToRootViewController(animated: true)
            navigationController.dismiss(animated: false, completion: nil)
        }
        else{
            self.navigationController!.popToRootViewController(animated: true)
        }
    }
    
}
