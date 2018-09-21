//
//  PostedPinOnCurrentViewController.swift
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
import ESTabBarController
import Foundation


@objc protocol PinOfPostedInCurrentDelegate {
    @objc func pinOfPostedInCurrent(pinOfPostedLatitude: Double, pinOfPostedLongitude: Double, pinTitle: String, pinSubTitle: String)
}

class PostedPinOnCurrentViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    

    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var postedName: UITextField!
    @IBOutlet weak var postedNumber: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // 投稿データから「投稿者」限定のデータを判断する為の準備
    let uid = Auth.auth().currentUser?.uid
    
    //Delegateを使う準備
    weak var delegate:PinOfPostedInCurrentDelegate?
    
    
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
        
        // 検索フィールドの少なくとも１箇所にテキストが打ち込まれている場合：
        if category.text != "" || postedName.text != "" || postedNumber.text != "" {
            
            
            //①postedNumberが打ち込まれている場合　→ 対象の情報は1つに絞られる為すぐにobserveで抽出できる
            if postedNumber.text != "" {
                var ref: DatabaseReference!
                ref = Database.database().reference().child("posts").child("\(self.postedNumber.text!)")
                
                //中身の確認
                print("refの中身は：\(ref!)")
                
                //  FirebaseからobserveSingleEventで1回だけデータ検索
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    var value = snapshot.value as? [String : AnyObject]
                    //使わない画像データのkeyを配列から削除
                    _ = value?.removeValue(forKey: "image")
                    
                    //中身の確認
                    if value != nil{
                        print(" valueの中身は：\(value!)")
                        
                        //緯度と経度をvalue[]から取得
                        let pinOfPostedLatitude = value!["pincoodinateLatitude"] as! Double
                        let pinOfPostedLongitude = value!["pincoodinateLongitude"] as! Double
                        let pinTitle = "\(value!["category"] ?? "カテゴリーなし" as AnyObject)(\(value!["name"] ?? "投稿者名なし" as AnyObject))"
                        let pinSubTitle = "\(value!["pinAddress"] ?? "投稿場所情報なし" as AnyObject))"
                        
                        //データの確認
                        print("緯度は：\(pinOfPostedLatitude)")
                        print("経度は：\(pinOfPostedLongitude)")
                        print("Titleは：\(pinTitle)")
                        print("SubTitleは：\(pinSubTitle)")
                        
                        //Delegateされているfunc()を実行
                        self.delegate?.pinOfPostedInCurrent(pinOfPostedLatitude: pinOfPostedLatitude, pinOfPostedLongitude: pinOfPostedLongitude, pinTitle: pinTitle, pinSubTitle: pinSubTitle)
                        
                        // 移動先ViewControllerのインスタンスを取得（ストーリーボードIDから）
                        let currentMapViewController = self.storyboard?.instantiateViewController(withIdentifier: "CurrentMap")
                        self.tabBarController?.navigationController?.present(currentMapViewController!, animated: true, completion: nil)

                        //let viewController = self.storyboard?.instantiateViewController(withIdentifier: "View") as! ViewController
                        //self.view.window?.rootViewController?.present(viewController, animated:true, completion: nil)
                        
                        
                        // 画面遷移後にCurrentMap画面（index = 1）を選択している状態にしておく
                        //let tabBarController = self.parent as! ESTabBarController
                        //tabBarController.setSelectedIndex(1, animated: false)
                        
                        
                        //let currentMapViewController = self.storyboard?.instantiateViewController(withIdentifier: "CurrentMap")
                        //self.present(currentMapViewController!, animated: true, completion: nil)
                        
                        
                        //self.presentingViewController?.dismiss(animated: true, completion: nil)
                        
                        
                        // UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                        
                        
                        //self.navigationController!.popToRootViewController(animated: true)
                        
                    }
                    else {
                    print("valueの中身は：nil")
                    SVProgressHUD.showError(withStatus: "検索条件をもう一度確認して下さい")
                    return
                    }
                    
                })
            }
            
            
            //②categoryが打ち込まれている場合　→ 対象の情報をobserveで抽出できる
            if category.text != "" && postedName.text == "" && postedNumber.text == "" {
                var ref: DatabaseReference!
                ref = Database.database().reference().child("posts")
                
                //中身の確認
                print("category.textの中身は：\(category.text!)")
                
                //  FirebaseからobserveSingleEventで1回だけデータ検索
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    for item in snapshot.children {
                        let snap = item as! DataSnapshot
                        var value = snap.value as! [String: AnyObject]
                        //使わない画像データのkeyを配列から削除
                        _ = value.removeValue(forKey: "image")
                        // データの中身を確認
                        print("valueの中身は\(value)")
                        
                        // pinを立てる為に座標点を取得
                        let postedLatitude = value["pincoodinateLatitude"]
                        let postedLongitude = value["pincoodinateLongitude"]
                        print(" valueの緯度は：\(postedLatitude!)")
                        print(" valueの経度は：\(postedLongitude!)")
                        
                        // 画面を閉じてCurrentMapViewControllerに戻る&その画面先でpinを立てる
                        let currentMapViewController = self.presentingViewController as? CurrentMapViewController
                        self.dismiss(animated: true, completion: {
                            
                            // pinを立てる処理
                        
                        })
                    }
                }) { (error) in
                    print(error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "検索条件をもう一度確認して下さい")
                    return
                }
            }
            
            
            //③postedNameが打ち込まれている場合　→ 対象の情報をobserveで抽出できる
            if category.text == "" && postedName.text != "" && postedNumber.text == "" {
                var ref: DatabaseReference!
                ref = Database.database().reference().child("posts").child("userID").child("\(self.postedName.text!)")
                
                //中身の確認
                print("refの中身は：\(ref!)")
                
                //  FirebaseからobserveSingleEventで1回だけデータ検索
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? [String : AnyObject]
                    
                    //中身の確認
                    if value != nil{
                        print("valueの中身は：\(value!)")
                        
                        // 画面を閉じてPostedDataViewControllerに戻る&その画面先でTableViewをReload
                        let currentMapViewController = self.presentingViewController as? CurrentMapViewController
                        self.dismiss(animated: true, completion: {
                            
                            // pinを立てる処理
                            
                        })
                    }
                    else {
                        print("valueの中身は：nil")
                        SVProgressHUD.showError(withStatus: "検索条件をもう一度確認して下さい")
                        return
                    }
                    
                }) { (error) in
                    print(error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "検索条件をもう一度確認して下さい")
                    return
                }
            }
            
            
            //④categoryとpostedNameが打ち込まれている場合　→ 対象の情報をobserveで抽出できる
            if category.text != "" && postedName.text != "" && postedNumber.text == "" {
                var ref: DatabaseReference!
                ref = Database.database().reference().child("posts").child("userID").child("\(self.category.text!)").child("\(self.postedNumber.text!)")
                
                //中身の確認
                print("refの中身は：\(ref!)")
                
                //  FirebaseからobserveSingleEventで1回だけデータ検索
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? [String : AnyObject]
                    
                    //中身の確認
                    if value != nil{
                        print("valueの中身は：\(value!)")
                        
                        // 画面を閉じてPostedDataViewControllerに戻る&その画面先でTableViewをReload
                        let currentMapViewController = self.presentingViewController as? CurrentMapViewController
                        self.dismiss(animated: true, completion: {
                            
                            // pinを立てる処理
                            
                        })
                    }
                    else {
                        print("valueの中身は：nil")
                        SVProgressHUD.showError(withStatus: "検索条件をもう一度確認して下さい")
                        return
                    }
                    
                }) { (error) in
                    print(error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "検索条件をもう一度確認して下さい")
                    return
                }
            }
            
        }
        
        // 検索フィールドに何も打ち込まれていない場合：
        if category.text == "" && postedName.text == "" && postedNumber.text == ""  {
            SVProgressHUD.showError(withStatus: "検索条件を指定して下さい")
            return
        }
        
    }
    
}