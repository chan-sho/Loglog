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
    
    func allPinRemove()
}

class PostedPinOnCurrentViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    

    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var postedName: UITextField!
    @IBOutlet weak var postedNumber: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var removeAllPinButton: UIButton!
    
    // 投稿データから「投稿者」限定のデータを判断する為の準備
    let uid = Auth.auth().currentUser?.uid
    
    //Delegateを使う準備
    weak var delegate: PostedPinOnCurrentDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        category.delegate = self
        postedName.delegate = self
        postedNumber.delegate = self
        
        category.layer.borderColor = UIColor.black.cgColor
        postedName.layer.borderColor = UIColor.black.cgColor
        postedNumber.layer.borderColor = UIColor.black.cgColor
        // 枠の幅
        category.layer.borderWidth = 0.5
        postedName.layer.borderWidth = 0.5
        postedNumber.layer.borderWidth = 0.5
        // 枠を角丸にする場合
        category.layer.cornerRadius = 10.0
        category.layer.masksToBounds = true
        postedName.layer.cornerRadius = 10.0
        postedName.layer.masksToBounds = true
        postedNumber.layer.cornerRadius = 10.0
        postedNumber.layer.masksToBounds = true
        
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
        
        //ボタン同時押しによるアプリクラッシュを防ぐ
        searchButton.isExclusiveTouch = true
        cancelButton.isExclusiveTouch = true
        removeAllPinButton.isExclusiveTouch = true
        
        //背景の設定
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "背景(ver1.10)_10")
        bg.contentMode = UIViewContentMode.scaleAspectFill
        bg.clipsToBounds = true
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
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
    let list = ["(カテゴリーなし)", "思い出", "伝えられなかったありがとう", "名前を知らない貴方へありがとう", "ジョブマッチング", "秘密の場所", "観光スポット", "グルメ（ランチ）", "グルメ（ディナー）", "レジャー", "その他"]
    
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
                
                //  FirebaseからobserveSingleEventで1回だけデータ検索
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    var value = snapshot.value as? [String : AnyObject]
                    //使わない画像データのkeyを配列から削除
                    _ = value?.removeValue(forKey: "image")
                    
                    //中身の確認
                    if value != nil{
                   
                        //緯度と経度をvalue[]から取得
                        let pinOfPostedLatitude = value!["pincoodinateLatitude"] as! Double
                        let pinOfPostedLongitude = value!["pincoodinateLongitude"] as! Double
                        let pinTitle = "\(value!["category"] ?? "カテゴリーなし" as AnyObject) \(value!["name"] ?? "投稿者名なし" as AnyObject)"
                        let pinSubTitle = "\(value!["pinAddress"] ?? "投稿場所情報なし" as AnyObject)"
                        
                        //Delegateされているfunc()を実行
                        self.delegate?.postedPinOnCurrent(pinOfPostedLatitude: pinOfPostedLatitude, pinOfPostedLongitude: pinOfPostedLongitude, pinTitle: pinTitle, pinSubTitle: pinSubTitle)
                        
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
                
                //  FirebaseからobserveSingleEventで1回だけデータ検索
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    for item in snapshot.children {
                        let snap = item as! DataSnapshot
                        var value = snap.value as! [String: AnyObject]
                        //使わない画像データのkeyを配列から削除
                        _ = value.removeValue(forKey: "image")
                        
                        //"myMap"の要素確認＆要素を持たない配列に"なし"を入れる処理
                        if value.keys.contains("myMap") {
                            // myMapを変数に格納
                            let checkArray = value["myMap"] as! NSArray
                            // myMapに要素があれば0番目要素を変数に格納
                            if checkArray.count > 0 {
                                let checkValue = checkArray[0]
                                value["myMap"] = checkValue as AnyObject
                            }
                            else {
                                // ifでOKだったが、myMapに要素が無いケース（※要確認）
                                value["myMap"] = "なし" as AnyObject
                                //念の為アラートのprint
                                print("ifでOKだったが、myMapに要素が無いケース（※要確認）")
                            }
                        }
                        else {
                            //"myMap"というkey自体を持たない場合
                            value["myMap"] = "なし" as AnyObject
                        }
                        
                        //条件分岐（categoryが一致　且つ　myMapのIDがログインユーザーのIDと同じ）
                        //       または（categoryが一致　且つ　myMapのIDが"なし"）
                        if ((value["category"]?.contains(self.category.text!))! && (value["myMap"]?.contains(self.uid!))!) || ((value["category"]?.contains(self.category.text!))! && (value["myMap"]?.contains("なし"))! ) {
                            
                            //緯度と経度をvalue[]から取得
                            let pinOfPostedLatitude = value["pincoodinateLatitude"] as! Double
                            let pinOfPostedLongitude = value["pincoodinateLongitude"] as! Double
                            let pinTitle = "\(value["category"] ?? "カテゴリーなし" as AnyObject) \(value["name"] ?? "投稿者名なし" as AnyObject)"
                            let pinSubTitle = "\(value["pinAddress"] ?? "投稿場所情報なし" as AnyObject)"
                            
                            //Delegateされているfunc()を実行
                            self.delegate?.postedPinOnCurrent(pinOfPostedLatitude: pinOfPostedLatitude, pinOfPostedLongitude: pinOfPostedLongitude, pinTitle: pinTitle, pinSubTitle: pinSubTitle)
                            
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
                
                //  FirebaseからobserveSingleEventで1回だけデータ検索
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    for item in snapshot.children {
                        let snap = item as! DataSnapshot
                        var value = snap.value as! [String: AnyObject]
                        //使わない画像データのkeyを配列から削除
                        _ = value.removeValue(forKey: "image")
                        
                        //"myMap"の要素確認＆要素を持たない配列に"なし"を入れる処理
                        if value.keys.contains("myMap") {
                            // myMapを変数に格納
                            let checkArray = value["myMap"] as! NSArray
                            // myMapに要素があれば0番目要素を変数に格納
                            if checkArray.count > 0 {
                                let checkValue = checkArray[0]
                                value["myMap"] = checkValue as AnyObject
                            }
                            else {
                                // ifでOKだったが、myMapに要素が無いケース（※要確認）
                                value["myMap"] = "なし" as AnyObject
                                //念の為アラートのprint
                                print("ifでOKだったが、myMapに要素が無いケース（※要確認）")
                            }
                        }
                        else {
                            //"myMap"というkey自体を持たない場合
                            value["myMap"] = "なし" as AnyObject
                        }
                        
                        //条件分岐（postedNameが部分一致　且つ　myMapのIDがログインユーザーのIDと同じ）
                        //       または（postedNameが部分一致　且つ　myMapのIDが"なし"）
                        if ((value["name"]?.localizedCaseInsensitiveContains(self.postedName.text!))! && (value["myMap"]?.contains(self.uid!))!) || ((value["name"]?.localizedCaseInsensitiveContains(self.postedName.text!))! && (value["myMap"]?.contains("なし"))! ) {
                            
                            //緯度と経度をvalue[]から取得
                            let pinOfPostedLatitude = value["pincoodinateLatitude"] as! Double
                            let pinOfPostedLongitude = value["pincoodinateLongitude"] as! Double
                            let pinTitle = "\(value["category"] ?? "カテゴリーなし" as AnyObject) \(value["name"] ?? "投稿者名なし" as AnyObject)"
                            let pinSubTitle = "\(value["pinAddress"] ?? "投稿場所情報なし" as AnyObject)"
                            
                            //Delegateされているfunc()を実行
                            self.delegate?.postedPinOnCurrent(pinOfPostedLatitude: pinOfPostedLatitude, pinOfPostedLongitude: pinOfPostedLongitude, pinTitle: pinTitle, pinSubTitle: pinSubTitle)
                            
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
            if category.text != "" && postedName.text != "" && postedNumber.text == "" {
                var ref: DatabaseReference!
                ref = Database.database().reference().child("posts")
                
                //  FirebaseからobserveSingleEventで1回だけデータ検索
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    for item in snapshot.children {
                        let snap = item as! DataSnapshot
                        var value = snap.value as! [String: AnyObject]
                        //使わない画像データのkeyを配列から削除
                        _ = value.removeValue(forKey: "image")
                        
                        //"myMap"の要素確認＆要素を持たない配列に"なし"を入れる処理
                        if value.keys.contains("myMap") {
                            // myMapを変数に格納
                            let checkArray = value["myMap"] as! NSArray
                            // myMapに要素があれば0番目要素を変数に格納
                            if checkArray.count > 0 {
                                let checkValue = checkArray[0]
                                value["myMap"] = checkValue as AnyObject
                            }
                            else {
                                // ifでOKだったが、myMapに要素が無いケース（※要確認）
                                value["myMap"] = "なし" as AnyObject
                                //念の為アラートのprint
                                print("ifでOKだったが、myMapに要素が無いケース（※要確認）")
                            }
                        }
                        else {
                            //"myMap"というkey自体を持たない場合
                            value["myMap"] = "なし" as AnyObject
                        }
                        
                        //条件分岐④（②と③の条件を両方満たす場合と同じ）
                        if ((value["category"]?.contains(self.category.text!))! && (value["name"]?.localizedCaseInsensitiveContains(self.postedName.text!))! && (value["myMap"]?.contains(self.uid!))!) || ((value["category"]?.contains(self.category.text!))! && (value["name"]?.localizedCaseInsensitiveContains(self.postedName.text!))! && (value["myMap"]?.contains("なし"))! ) {
                            
                            //緯度と経度をvalue[]から取得
                            let pinOfPostedLatitude = value["pincoodinateLatitude"] as! Double
                            let pinOfPostedLongitude = value["pincoodinateLongitude"] as! Double
                            let pinTitle = "\(value["category"] ?? "カテゴリーなし" as AnyObject) \(value["name"] ?? "投稿者名なし" as AnyObject)"
                            let pinSubTitle = "\(value["pinAddress"] ?? "投稿場所情報なし" as AnyObject)"
                            
                            //Delegateされているfunc()を実行
                            self.delegate?.postedPinOnCurrent(pinOfPostedLatitude: pinOfPostedLatitude, pinOfPostedLongitude: pinOfPostedLongitude, pinTitle: pinTitle, pinSubTitle: pinSubTitle)
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
    
    
    //表示中の投稿ピンを全て削除
    @IBAction func removeAllPinButton(_ sender: Any) {
        self.delegate!.allPinRemove()
        
        // 移動先ViewControllerのインスタンスを取得（ストーリーボードIDから）
        let currentMapViewController = self.storyboard?.instantiateViewController(withIdentifier: "CurrentMap")
        self.tabBarController?.navigationController?.present(currentMapViewController!, animated: true, completion: nil)
    }
    
}
