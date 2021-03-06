//
//  CurrentMapViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/09/01.
//  Copyright © 2018年 高野翔. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SVProgressHUD
import ESTabBarController


class CurrentMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, PostedPinOnCurrentDelegate {
    
    
    @IBOutlet weak var currentMapView: MKMapView!
    @IBOutlet weak var postFromCurrent: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var userLocationButton: UIButton!
    
    let pin = MKPointAnnotation()
    
    //投稿一覧からのpin作成に使う準備
    var pinsOfPosted:Array<MKPointAnnotation> = []
    var pinOfPostedLatitude : Double = 0.0
    var pinOfPostedLongitude : Double = 0.0
    var pinTitle : String?
    var pinSubTitle : String?
    
    
    //user defaultsを使う準備
    let userDefaults:UserDefaults = UserDefaults.standard
    
    var currentMapManager:CLLocationManager = CLLocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ユーザーの場所を表示する
        self.currentMapView.showsUserLocation = true
        self.currentMapView.userTrackingMode = MKUserTrackingMode.followWithHeading
        
        //デリゲート先に自分を設定する。
        currentMapManager.delegate = self
        //位置情報の取得を開始する。
        currentMapManager.startUpdatingLocation()
        //位置情報の利用許可を変更する画面をポップアップ表示する。
        currentMapManager.requestWhenInUseAuthorization()
        
        postFromCurrent.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        postFromCurrent.layer.borderColor = UIColor.darkGray.cgColor
        postFromCurrent.layer.borderWidth = 1.0
        postFromCurrent.layer.cornerRadius = 10.0 //丸みを数値で変更できる
        
        searchButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        searchButton.layer.borderColor = UIColor.darkGray.cgColor
        searchButton.layer.borderWidth = 1.0
        searchButton.layer.cornerRadius = 10.0 //丸みを数値で変更できる
        
        //ボタン同時押しによるアプリクラッシュを防ぐ
        postFromCurrent.isExclusiveTouch = true
        searchButton.isExclusiveTouch = true
        userLocationButton.isExclusiveTouch = true
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //画面表示後の呼び出しメソッド
    override func viewDidAppear(_ animated: Bool) {
        
        if(CLLocationManager.locationServicesEnabled() == true){
            switch CLLocationManager.authorizationStatus() {
                
            //未設定の場合
            case CLAuthorizationStatus.notDetermined:
                currentMapManager.requestWhenInUseAuthorization()
                
            //機能制限されている場合
            case CLAuthorizationStatus.restricted:
                alertMessage(message: "位置情報サービスの利用が制限されている為、利用できません。\n\n「設定」⇒「一般」⇒「機能制限」で確認ください。")
                
            //「許可しない」に設定されている場合
            case CLAuthorizationStatus.denied:
                alertMessage(message: "位置情報の利用が許可されていない為、利用できません。\n\n「設定」⇒「プライバシー」⇒「位置情報サービス」⇒「アプリ名」で確認ください。")
                
            //「このAppの使用中のみ許可」に設定されている場合
            case CLAuthorizationStatus.authorizedWhenInUse:
                //位置情報の取得を開始する。
                currentMapManager.startUpdatingLocation()
                
            //「常に許可」に設定されている場合
            case CLAuthorizationStatus.authorizedAlways:
                //位置情報の取得を開始する。
                currentMapManager.startUpdatingLocation()
            }
            
        } else {
            //位置情報サービスがOFFの場合
            alertMessage(message: "位置情報サービスがONになっていない為、利用できません。\n\n「設定」⇒「プライバシー」⇒「位置情報サービス」で確認ください。")
        }
    }
    
    
    //メッセージ出力メソッド
    func alertMessage(message:String) {
        let aleartController = UIAlertController(title: "【注意】", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title:"【成功】", style: .default, handler:nil)
        aleartController.addAction(defaultAction)
        
        present(aleartController, animated:true, completion:nil)
    }
    
    
    //位置情報取得時の呼び出しメソッド
    var firstFlg = false
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if (firstFlg == false) {
            for location in locations {
                
                //中心座標
                let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                //表示範囲
                let span = MKCoordinateSpanMake(0.01, 0.01)
                //中心座標と表示範囲をマップに登録する。
                let region = MKCoordinateRegionMake(center, span)
                currentMapView.setRegion(region, animated:true)
                
            }
            firstFlg = true
        }
    }
    
    
    @IBAction func longPressGesture(_ sender: UILongPressGestureRecognizer) {
        //この処理を書くことにより、指を離したときだけ反応するようにする（何回も呼び出されないようになる。最後の離したタイミングで呼ばれる）
        if sender.state != UIGestureRecognizerState.began {
            return
        }
        
        //senderから長押しした地図上の座標を取得
        let tappedLocation = sender.location(in: currentMapView)
        let tappedPoint = currentMapView.convert(tappedLocation, toCoordinateFrom: currentMapView)
        // update annotation
        self.currentMapView.removeAnnotation(pin)
        //ピンを置く場所を指定
        pin.coordinate = tappedPoint
        //ピンのタイトルを設定
        pin.title = "この場所で良いですか？"
        //ピンのサブタイトルの設定
        pin.subtitle = "OKなら「投稿準備」をクリック"
        //ピンをdisplayMapの上に置く
        self.currentMapView.addAnnotation(pin)
    }
    
    
    @IBAction func postFromCurrent(_ sender: Any) {
        
        // ピンが立てられていない場合（＝場所を指定せずに投稿準備ボタンを押した場合）
        if pin.coordinate.latitude == 0.0 && pin.coordinate.longitude == 0.0  {
            SVProgressHUD.showError(withStatus: "場所が指定されていません！\n\n希望の場所を長押し&ピンを立てて投稿準備をしてください。\n\nこのままでも投稿可能ですが後程地図上に再表示できません。")
            SVProgressHUD.dismiss(withDelay: 7.0)
        }
        
        //最後に表示されているpinの座標値を緯度と経度に分けてuserDefaultsに入れる
        userDefaults.set(pin.coordinate.latitude, forKey: "pincoodinateLatitude")
        userDefaults.set(pin.coordinate.longitude, forKey: "pincoodinateLongitude")
        userDefaults.synchronize()
        
        //座標から住所を作成
        let pinGeocoder = CLGeocoder()
        let pinLocation = CLLocation(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude )
        
        // 逆ジオコーディング開始
        pinGeocoder.reverseGeocodeLocation(pinLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                if let pm = placemarks.first {
                    
                    //獲得した住所をuserDefaultsに入れる：現時点ではcontoryは入れず
                    self.userDefaults.set("\(pm.postalCode ?? "") \(pm.administrativeArea ?? "")\(pm.locality ?? "")\(pm.name ?? "")", forKey: "pinAddress")
                    
                    //*print("name: \(pm.name ?? "")")
                    //*print("isoCountryCode: \(pm.isoCountryCode ?? "")")
                    //*print("country: \(pm.country ?? "")")
                    //*print("postalCode: \(pm.postalCode ?? "")")
                    //*print("administrativeArea: \(pm.administrativeArea ?? "")")
                    //*print("subAdministrativeArea: \(pm.subAdministrativeArea ?? "")")
                    //*print("locality: \(pm.locality ?? "")")
                    //*print("subLocality: \(pm.subLocality ?? "")")
                    //*print("thoroughfare: \(pm.thoroughfare ?? "")")
                    //*print("subThoroughfare: \(pm.subThoroughfare ?? "")")
                    //*if let region = pm.region {
                        //*print("region: \(region)")
                    //*}
                    //*if let timeZone = pm.timeZone {
                        //*print("timeZone: \(timeZone)")
                    //*}
                    //*print("inlandWater: \(pm.inlandWater ?? "")")
                    //*print("ocean: \(pm.ocean ?? "")")
                    //*if let areasOfInterest = pm.areasOfInterest {
                        //*print("areasOfInterest: \(areasOfInterest)")
                    //*}
                }
            }
        }
    }
    
    
    @IBAction func userLocationButton(_ sender: Any) {
        self.currentMapView.userTrackingMode = MKUserTrackingMode.followWithHeading
        currentMapView.setCenter(currentMapView.userLocation.coordinate, animated: true)
    }
    
    
    //Delegate管理したアクション（投稿ピンの表示）
    func postedPinOnCurrent(pinOfPostedLatitude: Double, pinOfPostedLongitude: Double, pinTitle: String, pinSubTitle: String) {
        
        let pinOfPosted = ColorMKPointAnnotation()
        
        //一旦古いpinを全て消す
        self.currentMapView.removeAnnotation(pinOfPosted)
        
        //pinを立てる準備
        let coordinate = CLLocationCoordinate2DMake(pinOfPostedLatitude, pinOfPostedLongitude)
        //表示範囲（※ここは複数のpinを生成する際には毎回画面が変わって見にくいので削除も検討）
        let span = MKCoordinateSpanMake(0.02, 0.02)
        //中心座標と表示範囲をマップに登録（※ここは複数のpinを生成する際には毎回画面が変わって見にくいので削除も検討）
        let region = MKCoordinateRegionMake(coordinate, span)
        currentMapView.setRegion(region, animated:true)
        
        pinOfPosted.coordinate = CLLocationCoordinate2DMake(pinOfPostedLatitude, pinOfPostedLongitude)
        pinOfPosted.title = pinTitle
        pinOfPosted.subtitle = pinSubTitle
        
        //pinの色を通常と異なる色に個別に設定
        pinOfPosted.pinColor = UIColor.blue
        
        pinsOfPosted.append(pinOfPosted)
        
        self.currentMapView.addAnnotation(pinOfPosted)
        
        //吹き出しを出したままにする
        self.currentMapView.selectAnnotation(pinOfPosted, animated: true)
    }
    
    
     //Delegate管理したアクション（投稿ピンの削除）
    func allPinRemove() {
        self.currentMapView.removeAnnotations(pinsOfPosted)
    }
    
    
    //PostedPinOnCurrentViewControllerクラスのインスタンスを作り、そのプロパティ（delegate）にselfを代入
    //※且つそれをSegueの中で定義するとうまくいった！（viewDidLoadに書くとうまくいかなかった）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let postedPinOCVC = segue.destination as? PostedPinOnCurrentViewController {
            postedPinOCVC.delegate = self
        }
    }
    
    
    //PinAnnotationViewを使う
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        //投稿者自身の場所を表す青い丸には適応しない。
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinView = MKPinAnnotationView()
            pinView.canShowCallout = true
            
            //アノテーションビューに色を設定する。
            if let color = annotation as? ColorMKPointAnnotation {
                pinView.pinTintColor = color.pinColor
                pinView.canShowCallout = true
                
                //右ボタンをアノテーションビューに追加する。
                let buttonRight = UIButton()
                buttonRight.frame = CGRect(x:0, y:0, width:40, height:40)
                buttonRight.setImage(UIImage(named: "投稿"), for: UIControlState.normal)
                pinView.rightCalloutAccessoryView = buttonRight
            }
        else {
            pinView.annotation = annotation
        }
        return pinView
    }
    
    
    //吹き出しアクササリー押下時の呼び出しメソッド
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if(control == view.rightCalloutAccessoryView) {
            //右のボタンが押された場合のアクション
            if view is MKPinAnnotationView {
                
                userDefaults.set(view.annotation?.title!, forKey: "buttonRightTitle")
                userDefaults.set(view.annotation?.subtitle!, forKey: "buttonRightSubtitle")
                userDefaults.synchronize()
                
                let tabBarController = parent as! ESTabBarController
                tabBarController.setSelectedIndex(3, animated: false)
                for viewController in tabBarController.childViewControllers {
                    if viewController is PostedDataViewController {
                        let postedViewContoller = viewController as! PostedDataViewController
                        postedViewContoller.buttonRightSelection()
                        break
                    }
                }
            }
        }
    }
    
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        // 他の画面から segue を使って戻ってきた時に呼ばれる
    }
    
}
