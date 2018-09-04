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

class SearchMapViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var displayMap: MKMapView!
    
    var pinView:MKPinAnnotationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputText.delegate = self
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        let searchKeyword = textField.text
        
        print(searchKeyword!)
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(searchKeyword!, completionHandler: { (placemarks:[CLPlacemark]?, error:Error?) in
            
            if let placemark = placemarks?[0] {
                if let targetCoordinate = placemark.location?.coordinate {
                    print(targetCoordinate)
                    
                    let pin = MKPointAnnotation()
                    pin.coordinate = targetCoordinate
                    pin.title = searchKeyword
                    pin.subtitle = "OKなら「投稿」をクリック"
                    
                    self.displayMap.addAnnotation(pin)
                    self.displayMap.region = MKCoordinateRegionMakeWithDistance(targetCoordinate,500.0,500.0)
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
        //ピンの生成
        let pin = MKPointAnnotation()
        //ピンを置く場所を指定
        pin.coordinate = tappedPoint
        //ピンのタイトルを設定
        pin.title = "この場所で良いですか？"
        //ピンのサブタイトルの設定
        pin.subtitle = "OKなら「投稿」をクリック"
        //ピンをdisplayMapの上に置く
        self.displayMap.addAnnotation(pin)
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
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        // 他の画面から segue を使って戻ってきた時に呼ばれる
    }

}
