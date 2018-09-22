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


@objc protocol PostedPinOnCurrentDelegate {
    func postedPinOnCurrent(pinOfPostedLatitude: Double, pinOfPostedLongitude: Double, pinTitle: String, pinSubTitle: String)
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
    weak var delegate: PostedPinOnCurrentDelegate?
    
    
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
                        print("①のvalueの中身は：\(value!)")
                        
                        //緯度と経度をvalue[]から取得
                        let pinOfPostedLatitude = value!["pincoodinateLatitude"] as! Double
                        let pinOfPostedLongitude = value!["pincoodinateLongitude"] as! Double
                        let pinTitle = "\(value!["category"] ?? "カテゴリーなし" as AnyObject)(\(value!["name"] ?? "投稿者名なし" as AnyObject))"
                        let pinSubTitle = "\(value!["pinAddress"] ?? "投稿場所情報なし" as AnyObject))"
                        
                        //データの確認
                        print("①の緯度は：\(pinOfPostedLatitude)")
                        print("①の経度は：\(pinOfPostedLongitude)")
                        print("①のTitleは：\(pinTitle)")
                        print("①のSubTitleは：\(pinSubTitle)")
                        
                        //Delegateされているfunc()を実行
                        self.delegate?.postedPinOnCurrent(pinOfPostedLatitude: pinOfPostedLatitude, pinOfPostedLongitude: pinOfPostedLongitude, pinTitle: pinTitle, pinSubTitle: pinSubTitle)
                        
                        //funcの通過確認
                        print("①のfunc postedPinOnCurrent()のDelegateを通過")
                        
                        // 移動先ViewControllerのインスタンスを取得（ストーリーボードIDから）
                        let currentMapViewController = self.storyboard?.instantiateViewController(withIdentifier: "CurrentMap")
                        self.tabBarController?.navigationController?.present(currentMapViewController!, animated: true, completion: nil)
                        
                    }
                    else {
                    print("①のvalueの中身は：nil")
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
                //中身の確認
                print("uidの中身は：\(uid!)")
                
                //  FirebaseからobserveSingleEventで1回だけデータ検索
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    for item in snapshot.children {
                        let snap = item as! DataSnapshot
                        var value = snap.value as! [String: AnyObject]
                        //使わない画像データのkeyを配列から削除
                        _ = value.removeValue(forKey: "image")
                        
                        //中身の確認
                        print("②のvalueの中身は：\(value)")
                        
                        //"myMap"の要素を持たない配列に"なし"を入れる処理
                        if value["myMap"] != nil {
                            continue
                        } else {
                            value["myMap"] = "なし" as AnyObject
                        }
                        
                        //中身の確認
                        print("②のmyMapの要素を追加後のvalueの中身は：\(value)")
                        
                        //条件分岐（categoryが一致　且つ　myMapのIDがログインユーザーのIDと同じ）
                        //       または（categoryが一致　且つ　myMapのIDが"なし"）
                        if ((value["category"]?.contains(self.category.text!))! && (value["myMap"]?.contains(self.uid!))!) || ((value["category"]?.contains(self.category.text!))! && (value["myMap"]?.contains("なし"))! ) {
                            
                            //中身の確認
                            print("条件分岐if後の②のvalueの中身は：\(value)")
                            
                            //緯度と経度をvalue[]から取得
                            let pinOfPostedLatitude = value["pincoodinateLatitude"] as! Double
                            let pinOfPostedLongitude = value["pincoodinateLongitude"] as! Double
                            let pinTitle = "\(value["category"] ?? "カテゴリーなし" as AnyObject)(\(value["name"] ?? "投稿者名なし" as AnyObject))"
                            let pinSubTitle = "\(value["pinAddress"] ?? "投稿場所情報なし" as AnyObject)"
                            
                            //データの確認
                            print("条件分岐if後の②の緯度は：\(pinOfPostedLatitude)")
                            print("条件分岐if後の②の経度は：\(pinOfPostedLongitude)")
                            print("条件分岐if後の②のTitleは：\(pinTitle)")
                            print("条件分岐if後の②のSubTitleは：\(pinSubTitle)")
                            
                            //Delegateされているfunc()を実行
                            self.delegate?.postedPinOnCurrent(pinOfPostedLatitude: pinOfPostedLatitude, pinOfPostedLongitude: pinOfPostedLongitude, pinTitle: pinTitle, pinSubTitle: pinSubTitle)
                            
                            //funcの通過確認
                            print("条件分岐if後の②のfunc postedPinOnCurrent()のDelegateを通過")
                            
                        }
                        else {
                            continue
                        }
                    }
                })
                // 移動先ViewControllerのインスタンスを取得（ストーリーボードIDから）
                let currentMapViewController = self.storyboard?.instantiateViewController(withIdentifier: "CurrentMap")
                self.tabBarController?.navigationController?.present(currentMapViewController!, animated: true, completion: nil)
                
                }
            
            
            //③postedNameが打ち込まれている場合　→ 対象の情報をobserveで抽出できる
            if category.text == "" && postedName.text != "" && postedNumber.text == "" {
                var ref: DatabaseReference!
                ref = Database.database().reference().child("posts")
                
                //中身の確認
                print("category.textの中身は：\(postedName.text!)")
                //中身の確認
                print("uidの中身は：\(uid!)")
                
                //  FirebaseからobserveSingleEventで1回だけデータ検索
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    for item in snapshot.children {
                        let snap = item as! DataSnapshot
                        var value = snap.value as! [String: AnyObject]
                        //使わない画像データのkeyを配列から削除
                        _ = value.removeValue(forKey: "image")
                        
                        //中身の確認
                        print("③のvalueの中身は：\(value)")
                        
                        //"myMap"の要素を持たない配列に"なし"を入れる処理
                        if value["myMap"] != nil {
                            continue
                        } else {
                            value["myMap"] = "なし" as AnyObject
                        }
                        
                        //中身の確認
                        print("③のmyMapの要素を追加後のvalueの中身は：\(value)")
                        
                        //条件分岐（postedNameが部分一致　且つ　myMapのIDがログインユーザーのIDと同じ）
                        //       または（postedNameが部分一致　且つ　myMapのIDが"なし"）
                        if ((value["name"]?.localizedCaseInsensitiveContains(self.postedName.text!))! && (value["myMap"]?.contains(self.uid!))!) || ((value["name"]?.localizedCaseInsensitiveContains(self.postedName.text!))! && (value["myMap"]?.contains("なし"))! ) {
                            
                            //中身の確認
                            print("条件分岐if後の③のvalueの中身は：\(value)")
                            
                            //緯度と経度をvalue[]から取得
                            let pinOfPostedLatitude = value["pincoodinateLatitude"] as! Double
                            let pinOfPostedLongitude = value["pincoodinateLongitude"] as! Double
                            let pinTitle = "\(value["category"] ?? "カテゴリーなし" as AnyObject)(\(value["name"] ?? "投稿者名なし" as AnyObject))"
                            let pinSubTitle = "\(value["pinAddress"] ?? "投稿場所情報なし" as AnyObject)"
                            
                            //データの確認
                            print("条件分岐if後の③の緯度は：\(pinOfPostedLatitude)")
                            print("条件分岐if後の③の経度は：\(pinOfPostedLongitude)")
                            print("条件分岐if後の③のTitleは：\(pinTitle)")
                            print("条件分岐if後の③のSubTitleは：\(pinSubTitle)")
                            
                            //Delegateされているfunc()を実行
                            self.delegate?.postedPinOnCurrent(pinOfPostedLatitude: pinOfPostedLatitude, pinOfPostedLongitude: pinOfPostedLongitude, pinTitle: pinTitle, pinSubTitle: pinSubTitle)
                            
                            //funcの通過確認
                            print("条件分岐if後の③のfunc postedPinOnCurrent()のDelegateを通過")
                            
                        }
                        else {
                            continue
                        }
                    }
                })
                // 移動先ViewControllerのインスタンスを取得（ストーリーボードIDから）
                let currentMapViewController = self.storyboard?.instantiateViewController(withIdentifier: "CurrentMap")
                self.tabBarController?.navigationController?.present(currentMapViewController!, animated: true, completion: nil)
                
            }
            
            
            //④categoryとpostedNameが打ち込まれている場合　→ 対象の情報をobserveで抽出できる
            if category.text == "" && postedName.text != "" && postedNumber.text == "" {
                var ref: DatabaseReference!
                ref = Database.database().reference().child("posts")
                
                //中身の確認
                print("category.textの中身は：\(postedName.text!)")
                //中身の確認
                print("uidの中身は：\(uid!)")
                
                //  FirebaseからobserveSingleEventで1回だけデータ検索
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    for item in snapshot.children {
                        let snap = item as! DataSnapshot
                        var value = snap.value as! [String: AnyObject]
                        //使わない画像データのkeyを配列から削除
                        _ = value.removeValue(forKey: "image")
                        
                        //中身の確認
                        print("④のvalueの中身は：\(value)")
                        
                        //"myMap"の要素を持たない配列に"なし"を入れる処理
                        if value["myMap"] != nil {
                            continue
                        } else {
                            value["myMap"] = "なし" as AnyObject
                        }
                        
                        //中身の確認
                        print("④のmyMapの要素を追加後のvalueの中身は：\(value)")
                        
                        //条件分岐④（②と③の条件を両方満たす場合と同じ）
                        if ((value["category"]?.contains(self.category.text!))! && (value["name"]?.localizedCaseInsensitiveContains(self.postedName.text!))! && (value["myMap"]?.contains(self.uid!))!) || ((value["category"]?.contains(self.category.text!))! && (value["name"]?.localizedCaseInsensitiveContains(self.postedName.text!))! && (value["myMap"]?.contains("なし"))! ) {
                            
                            //中身の確認
                            print("条件分岐if後の③のvalueの中身は：\(value)")
                            
                            //緯度と経度をvalue[]から取得
                            let pinOfPostedLatitude = value["pincoodinateLatitude"] as! Double
                            let pinOfPostedLongitude = value["pincoodinateLongitude"] as! Double
                            let pinTitle = "\(value["category"] ?? "カテゴリーなし" as AnyObject)(\(value["name"] ?? "投稿者名なし" as AnyObject))"
                            let pinSubTitle = "\(value["pinAddress"] ?? "投稿場所情報なし" as AnyObject)"
                            
                            //データの確認
                            print("条件分岐if後の④の緯度は：\(pinOfPostedLatitude)")
                            print("条件分岐if後の④の経度は：\(pinOfPostedLongitude)")
                            print("条件分岐if後の④のTitleは：\(pinTitle)")
                            print("条件分岐if後の④のSubTitleは：\(pinSubTitle)")
                            
                            //Delegateされているfunc()を実行
                            self.delegate?.postedPinOnCurrent(pinOfPostedLatitude: pinOfPostedLatitude, pinOfPostedLongitude: pinOfPostedLongitude, pinTitle: pinTitle, pinSubTitle: pinSubTitle)
                            
                            //funcの通過確認
                            print("条件分岐if後の④のfunc postedPinOnCurrent()のDelegateを通過")
                            
                        }
                        else {
                            continue
                        }
                    }
                })
                // 移動先ViewControllerのインスタンスを取得（ストーリーボードIDから）
                let currentMapViewController = self.storyboard?.instantiateViewController(withIdentifier: "CurrentMap")
                self.tabBarController?.navigationController?.present(currentMapViewController!, animated: true, completion: nil)
                
            }
        
        // 検索フィールドに何も打ち込まれていない場合：
        if category.text == "" && postedName.text == "" && postedNumber.text == ""  {
            SVProgressHUD.showError(withStatus: "検索条件を指定して下さい")
            return
        }
    }
  }
}
