//
//  SearchMapViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/09/01.
//  Copyright © 2018年 高野翔. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SVProgressHUD


class SearchMapViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate, PostedPinOnSearchDelegate {
    
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var displayMap: MKMapView!
    @IBOutlet weak var postWithSearch: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var userLocationButton: UIButton!
    
    //投稿準備に移るためのpinを管理
    let pin = MKPointAnnotation()
    //投稿済みのpinを管理
    var displayMapManager:CLLocationManager = CLLocationManager()
    
    //投稿一覧からのpin作成に使う準備
    var pinsOfPosted:Array<MKPointAnnotation> = []
    var pinOfPostedLatitude : Double = 0.0
    var pinOfPostedLongitude : Double = 0.0
    var pinTitle : String?
    var pinSubTitle : String?
    
    //user defaultsを使う準備
    let userDefaults:UserDefaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputText.delegate = self
        
        //デリゲート先に自分を設定する。
        displayMapManager.delegate = self
        
        postWithSearch.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        postWithSearch.layer.borderColor = UIColor.darkGray.cgColor
        postWithSearch.layer.borderWidth = 1.0
        postWithSearch.layer.cornerRadius = 10.0 //丸みを数値で変更できる
        
        searchButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        searchButton.layer.borderColor = UIColor.darkGray.cgColor
        searchButton.layer.borderWidth = 1.0
        searchButton.layer.cornerRadius = 10.0 //丸みを数値で変更できる
        
        //ボタン同時押しによるアプリクラッシュを防ぐ
        postWithSearch.isExclusiveTouch = true
        searchButton.isExclusiveTouch = true
        userLocationButton.isExclusiveTouch = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputText.resignFirstResponder()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputText.resignFirstResponder()
        
        let searchKeyword = textField.text
        print(searchKeyword!)
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchKeyword!, completionHandler: { (placemarks:[CLPlacemark]?, error:Error?) in
            
            if let placemark = placemarks?[0] {
                if let targetCoordinate = placemark.location?.coordinate {
                    print(targetCoordinate)
                    
                    self.pin.coordinate = targetCoordinate
                    self.pin.title = searchKeyword
                    self.pin.subtitle = "OKなら「投稿準備」をクリック"
                    
                    self.displayMap.addAnnotation(self.pin)
                    self.displayMap.region = MKCoordinateRegionMakeWithDistance(targetCoordinate,500.0,500.0)
                    
                    //座標確認
                    print("\(self.pin.coordinate)")
                    print("\(self.pin.coordinate.latitude)")
                    print("\(self.pin.coordinate.longitude)")
                }
            }
        })
        // キーボードを閉じる
        self.view.endEditing(true)
        return true
    }
    
    
    @IBAction func longPressGesture(_ sender: UILongPressGestureRecognizer) {
        //この処理を書くことにより、指を離したときだけ反応するようにする（何回も呼び出されないようになる。最後に離したタイミングで呼ばれる）
        if sender.state != UIGestureRecognizerState.began {
            // キーボードを閉じる
            self.view.endEditing(true)
            return
        }
        
        //senderから長押しした地図上の座標を取得
        let tappedLocation = sender.location(in: displayMap)
        let tappedPoint = displayMap.convert(tappedLocation, toCoordinateFrom: displayMap)
        // update annotation
        self.displayMap.removeAnnotation(pin)
        //ピンを置く場所を指定
        pin.coordinate = tappedPoint
        //ピンのタイトルを設定
        pin.title = "この場所で良いですか？"
        //ピンのサブタイトルの設定
        pin.subtitle = "OKなら「投稿準備」をクリック"
        //ピンをdisplayMapの上に置く
        self.displayMap.addAnnotation(pin)
        
        //座標確認
        print("\(pin.coordinate)")
        print("\(pin.coordinate.latitude)")
        print("\(pin.coordinate.longitude)")
    }
    
    
    @IBAction func postWithSearch(_ sender: Any) {
        
        // ピンが立てられていない場合（＝場所を指定せずに投稿準備ボタンを押した場合）
        if pin.coordinate.latitude == 0.0 && pin.coordinate.longitude == 0.0  {
            SVProgressHUD.showError(withStatus: "場所が指定されていません！\n\n希望の場所を長押し&ピンを立てて投稿準備をしてください。\n\nこのままでも投稿可能ですが後程地図上に再表示できません。")
            SVProgressHUD.dismiss(withDelay: 7.0)
        }
        
        //最後に表示されているpinの座標値を緯度と経度に分けてuserDefaultsに入れる
        userDefaults.set(pin.coordinate.latitude, forKey: "pincoodinateLatitude")
        userDefaults.set(pin.coordinate.longitude, forKey: "pincoodinateLongitude")
        userDefaults.synchronize()
        
        //座標値の最終確認
        print("Lati座標確認＝\(pin.coordinate.latitude)")
        print("Long座標確認＝\(pin.coordinate.longitude)")
        
        //座標から住所を作成
        let pinGeocoder = CLGeocoder()
        let pinLocation = CLLocation(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude )
        
        //座標確認
        print("\(pinLocation)")
        
        // 逆ジオコーディング開始
        pinGeocoder.reverseGeocodeLocation(pinLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                if let pm = placemarks.first {
                    
                    //獲得した住所をuserDefaultsに入れる：現時点ではcontoryは入れず
                    self.userDefaults.set("\(pm.postalCode ?? "")\n\(pm.administrativeArea ?? "")\(pm.locality ?? "")\(pm.name ?? "")", forKey: "pinAddress")
                    
                    print("name: \(pm.name ?? "")")
                    print("isoCountryCode: \(pm.isoCountryCode ?? "")")
                    print("country: \(pm.country ?? "")")
                    print("postalCode: \(pm.postalCode ?? "")")
                    print("administrativeArea: \(pm.administrativeArea ?? "")")
                    print("subAdministrativeArea: \(pm.subAdministrativeArea ?? "")")
                    print("locality: \(pm.locality ?? "")")
                    print("subLocality: \(pm.subLocality ?? "")")
                    print("thoroughfare: \(pm.thoroughfare ?? "")")
                    print("subThoroughfare: \(pm.subThoroughfare ?? "")")
                    if let region = pm.region {
                        print("region: \(region)")
                    }
                    if let timeZone = pm.timeZone {
                        print("timeZone: \(timeZone)")
                    }
                    print("inlandWater: \(pm.inlandWater ?? "")")
                    print("ocean: \(pm.ocean ?? "")")
                    if let areasOfInterest = pm.areasOfInterest {
                        print("areasOfInterest: \(areasOfInterest)")
                    }
                }
            }
        }
    }
    
    
    @IBAction func userLocationButton(_ sender: Any) {
        //位置情報許可の確認
        if(CLLocationManager.locationServicesEnabled() == true){
            switch CLLocationManager.authorizationStatus() {
                
            //未設定の場合
            case CLAuthorizationStatus.notDetermined:
                displayMapManager.requestWhenInUseAuthorization()
                
            //機能制限されている場合
            case CLAuthorizationStatus.restricted:
                alertMessage(message: "位置情報サービスの利用が制限されている為、利用できません。\n\n「設定」⇒「一般」⇒「機能制限」で確認ください。")
                
            //「許可しない」に設定されている場合
            case CLAuthorizationStatus.denied:
                alertMessage(message: "位置情報の利用が許可されていない為、利用できません。\n\n「設定」⇒「プライバシー」⇒「位置情報サービス」⇒「アプリ名」で確認ください。")
                
            //「このAppの使用中のみ許可」に設定されている場合
            case CLAuthorizationStatus.authorizedWhenInUse:
                //位置情報の取得を開始する。
                displayMapManager.startUpdatingLocation()
                
            //「常に許可」に設定されている場合
            case CLAuthorizationStatus.authorizedAlways:
                //位置情報の取得を開始する。
                displayMapManager.startUpdatingLocation()
            }
            
        } else {
            //位置情報サービスがOFFの場合
            alertMessage(message: "位置情報サービスがONになっていない為、利用できません。\n\n「設定」⇒「プライバシー」⇒「位置情報サービス」で確認ください。")
        }
        
        self.displayMap.showsUserLocation = true
        self.displayMap.userTrackingMode = MKUserTrackingMode.followWithHeading
        displayMap.setCenter(displayMap.userLocation.coordinate, animated: true)
    }
    
    
    //メッセージ出力メソッド
    func alertMessage(message:String) {
        let aleartController = UIAlertController(title: "【アラート】", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title:"【OK】", style: .default, handler:nil)
        aleartController.addAction(defaultAction)
        
        present(aleartController, animated:true, completion:nil)
    }
    
    
    //Delegate管理したアクション
    func postedPinOnSearch(pinOfPostedLatitude: Double, pinOfPostedLongitude: Double, pinTitle: String, pinSubTitle: String) {
        
        //funcの通過確認
        print(" func postedPinOnCurrent()を通過")
        //pinsOfPostedの中身を確認
        print("配列pinsOfPostedの中身＠初回：　\(pinsOfPosted)")
        
         let pinOfPosted = ColorMKPointAnnotation()
        
        //一旦古いpinを全て消す
        self.displayMap.removeAnnotation(pinOfPosted)
        
        //pinを立てる準備
        let coordinate = CLLocationCoordinate2DMake(pinOfPostedLatitude, pinOfPostedLongitude)
        //表示範囲（※ここは複数のpinを生成する際には毎回画面が変わって見にくいので削除も検討）
        let span = MKCoordinateSpanMake(0.02, 0.02)
        //中心座標と表示範囲をマップに登録（※ここは複数のpinを生成する際には毎回画面が変わって見にくいので削除も検討）
        let region = MKCoordinateRegionMake(coordinate, span)
        displayMap.setRegion(region, animated:true)
        
        pinOfPosted.coordinate = CLLocationCoordinate2DMake(pinOfPostedLatitude, pinOfPostedLongitude)
        pinOfPosted.title = pinTitle
        pinOfPosted.subtitle = pinSubTitle
        
        //中身の確認
        print("最終確認：　緯度＝\(pinOfPostedLatitude)")
        print("最終確認：　経度＝\(pinOfPostedLongitude)")
        print("最終確認：　Title＝\(pinTitle)")
        print("最終確認：　SubTitle＝\(pinSubTitle)")
        
        //pinsOfPostedの中身を確認
        print("配列pinsOfPostedの中身＠最終チェツク：　\(pinsOfPosted)")
        
        //pinの色を通常と異なる色に個別に設定
        pinOfPosted.pinColor = UIColor.blue
        
        pinsOfPosted.append(pinOfPosted)
        
        self.displayMap.addAnnotation(pinOfPosted)
    }
    
    
    //Delegate管理したアクション（投稿ピンの削除）
    func allPinRemove() {
        self.displayMap.removeAnnotations(pinsOfPosted)
    }
    
    //PostedPinOnCurrentViewControllerクラスのインスタンスを作り、そのプロパティ（delegate）にselfを代入
    //※且つそれをSegueの中で定義するとうまくいった！（viewDidLoadに書くとうまくいかなかった）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let postedPinOSVC = segue.destination as? PostedPinOnSearchViewController {
            postedPinOSVC.delegate = self
        }
    }

    
    //PinAnnotationViewを使う
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        //投稿者自身の場所を表す青い丸には適応しない。
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            //アノテーションビューに色を設定する。
            if let color = annotation as? ColorMKPointAnnotation {
                pinView?.markerTintColor = color.pinColor
            }
            
        }
        else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        // 他の画面から segue を使って戻ってきた時に呼ばれる
    }

}
