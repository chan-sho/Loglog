//
//  RevisePhotoViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/11/07.
//  Copyright © 2018 高野翔. All rights reserved.
//

import UIKit
import CLImageEditor


class RevisePhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate {
    
    
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    //user defaultsを使う準備
    let userDefaults:UserDefaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Flagの初期化
        self.userDefaults.set("NO", forKey: "reviseImageButtonFlag")
        self.userDefaults.synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func libraryButton(_ sender: Any) {
        // ライブラリ（カメラロール）を指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func cameraButton(_ sender: Any) {
        // カメラを指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    
    // 写真を撮影or選択したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if info[UIImagePickerControllerOriginalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            // あとでCLImageEditorライブラリで加工する
            print("DEBUG_PRINT: image = \(image)")
            // CLImageEditorにimageを渡して、加工画面を起動する。
            let editor = CLImageEditor(image: image)!
            editor.delegate = self
            picker.pushViewController(editor, animated: true)
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // CLImageEditorで加工が終わったときに呼ばれるメソッド
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        //userDefaultsに投稿画像を修正した事のFlagを保存
        self.userDefaults.set("YES", forKey: "reviseImageButtonFlag")
        self.userDefaults.synchronize()
        
        // 投稿の画面を開く
        let reviseDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "ReviseDetail") as! ReviseDetailViewController
        
        //*postFinalizeViewController.image = image!
        
        // ImageViewから画像を取得する
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)
        
        self.userDefaults.set("\(imageString)", forKey: "reviseImage")
        
        editor.present(reviseDetailViewController, animated: true, completion: nil)
    }
   
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        // 他の画面から segue を使って戻ってきた時に呼ばれる
        //Flagの初期化
        self.userDefaults.set("NO", forKey: "reviseImageButtonFlag")
        self.userDefaults.synchronize()
    }

}
