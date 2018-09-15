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


class SearchMapViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var displayMap: MKMapView!
    @IBOutlet weak var postWithSearch: UIButton!
    
    let pin = MKPointAnnotation()
    var pinView:MKPinAnnotationView!
    
    //user defaultsを使う準備
    let userDefaults:UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputText.delegate = self
        
        postWithSearch.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        postWithSearch.layer.borderColor = UIColor.darkGray.cgColor
        postWithSearch.layer.borderWidth = 1.0
        postWithSearch.layer.cornerRadius = 10.0 //丸みを数値で変更できる
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        displayMap.removeAnnotations(displayMap.annotations)
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
    //アノテーションビューを返すメソッド
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        //アノテーションビューを作成する。
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        //アノテーションビューに座標、タイトル、サブタイトルを設定する。
        pinView.annotation = annotation
        //アノテーションビューに色を設定する。
        pinView.backgroundColor = UIColor.white
        //吹き出しを表示可能にする。
        pinView.canShowCallout = true
        
        return pinView
    }
    
    
    @IBAction func postWithSearch(_ sender: Any) {
        
        // ピンが立てられていない場合（＝場所を指定せずに投稿準備ボタンを押した場合）
        if pin.coordinate.latitude == 0.0 && pin.coordinate.longitude == 0.0  {
            SVProgressHUD.showError(withStatus: "場所が指定されていません！\n\n希望の場所を長押し&ピンを立てて投稿準備をしてください。\n\nこのままでも投稿可能ですが後程地図上に再表示できません。")
            SVProgressHUD.dismiss(withDelay: 7.0)
        }
        
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
