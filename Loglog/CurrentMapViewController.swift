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

class CurrentMapViewController: UIViewController, CLLocationManagerDelegate  {
    
    @IBOutlet weak var currentMapView: MKMapView!
    @IBOutlet weak var postFromCurrent: UIButton!
    
    let pin = MKPointAnnotation()
    
    //user defaultsを使う準備
    let userDefaults:UserDefaults = UserDefaults.standard
    
    var currentMapManager:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                alertMessage(message: "位置情報サービスの利用が制限されている利用できません。「設定」⇒「一般」⇒「機能制限」")
                
            //「許可しない」に設定されている場合
            case CLAuthorizationStatus.denied:
                alertMessage(message: "位置情報の利用が許可されていないため利用できません。「設定」⇒「プライバシー」⇒「位置情報サービス」⇒「アプリ名」")
                
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
            alertMessage(message: "位置情報サービスがONになっていないため利用できません。「設定」⇒「プライバシー」⇒「位置情報サービス」")
        }
    }
    
    //メッセージ出力メソッド
    func alertMessage(message:String) {
        let aleartController = UIAlertController(title: "注意", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title:"OK", style: .default, handler:nil)
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
        currentMapView.removeAnnotations(currentMapView.annotations)
        //ピンを置く場所を指定
        pin.coordinate = tappedPoint
        //ピンのタイトルを設定
        pin.title = "この場所で良いですか？"
        //ピンのサブタイトルの設定
        pin.subtitle = "OKなら「準備投稿」をクリック"
        //ピンをdisplayMapの上に置く
        self.currentMapView.addAnnotation(pin)
        
        //座標確認
        print("\(pin.coordinate)")
        print("\(pin.coordinate.latitude)")
        print("\(pin.coordinate.longitude)")
        
    }
    
    //最後に表示されているpinの座標値を緯度と経度に分ける

    @IBAction func postFromCurrent(_ sender: Any) {

        userDefaults.set(pin.coordinate.latitude, forKey: "pincoodinateLatitude")
        userDefaults.set(pin.coordinate.longitude, forKey: "pincoodinateLongitude")
        userDefaults.synchronize()
        
        //座標値の最終確認
        print("Lati座標確認＝\(pin.coordinate.latitude)")
        print("Long座標確認＝\(pin.coordinate.longitude)")
        
    }

    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        // 他の画面から segue を使って戻ってきた時に呼ばれる
    }
    
}
