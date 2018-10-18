//
//  AJAlertController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/10/17.
//  Copyright © 2018 高野翔. All rights reserved.
//

import UIKit
import Foundation
import SVProgressHUD
import Firebase
import FirebaseAuth


class AJAlertController: UIViewController {
    
    // MARK:- Private Properties
    // MARK:-
    
    private var strAlertTitle = "【同意確認】"
    private var strAlertText = String()
    private var btnCancelTitle:String?
    private var btnOtherTitle:String?
    
    private let btnOtherColor  = UIColor.blue
    private let btnCancelColor = UIColor.red
    
    // MARK:- Public Properties
    // MARK:-
    
    @IBOutlet var viewAlert: UIView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblAlertText: UILabel?
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var btnOther: UIButton!
    @IBOutlet var btnOK: UIButton!
    @IBOutlet var viewAlertBtns: UIView!
    @IBOutlet var alertWidthConstraint: NSLayoutConstraint!
    
    /// AlertController Completion handler
    typealias alertCompletionBlock = ((Int, String) -> Void)?
    private var block : alertCompletionBlock?
    
    // MARK:- AJAlertController Initialization
    // MARK:-
    
    /**
     Creates a instance for using AJAlertController
     - returns: AJAlertController
     */
    static func initialization() -> AJAlertController
    {
        let alertController = AJAlertController(nibName: "AJAlertController", bundle: nil)
        return alertController
    }
    
    //user defaultsを使う準備
    let userDefaults:UserDefaults = UserDefaults.standard
    
    //プライバシーポリシー・利用規約のページをきちんと開いた事を確認するFlag
    var CheckFlag :String = "NO"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAJAlertController()
    }
    
    // MARK:- AJAlertController Private Functions
    // MARK:-
    
    /// Inital View Setup
    private func setupAJAlertController(){
        
        let visualEffectView   = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.alpha = 0.8
        visualEffectView.frame = self.view.bounds
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(visualEffectView, at: 0)
        
        preferredAlertWidth()
        
        viewAlert.layer.cornerRadius  = 4.0
        viewAlert.layer.shadowOffset  = CGSize(width: 0.0, height: 0.0)
        viewAlert.layer.shadowColor   = UIColor(white: 0.0, alpha: 1.0).cgColor
        viewAlert.layer.shadowOpacity = 0.3
        viewAlert.layer.shadowRadius  = 3.0
        
        lblTitle.text   = strAlertTitle
        lblAlertText?.text   = strAlertText
        
        if let aCancelTitle = btnCancelTitle {
            btnCancel.setTitle(aCancelTitle, for: .normal)
            btnOK.setTitle(nil, for: .normal)
            btnCancel.setTitleColor(btnCancelColor, for: .normal)
        } else {
            btnCancel.isHidden  = true
        }
        
        if let aOtherTitle = btnOtherTitle {
            btnOther.setTitle(aOtherTitle, for: .normal)
            btnOK.setTitle(nil, for: .normal)
            btnOther.setTitleColor(btnOtherColor, for: .normal)
        } else {
            btnOther.isHidden  = true
        }
        
        if btnOK.title(for: .normal) != nil {
            btnOK.setTitleColor(btnOtherColor, for: .normal)
        } else {
            btnOK.isHidden  = true
        }
    }
    
    /// Setup different widths for iPad and iPhone
    private func preferredAlertWidth()
    {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            alertWidthConstraint.constant = 280.0
        case .pad:
            alertWidthConstraint.constant = 340.0
        case .unspecified: break
        case .tv: break
        case .carPlay: break
        }
    }
    
    /// Create and Configure Alert Controller
    private func configure(message:String, btnCancelTitle:String?, btnOtherTitle:String?)
    {
        self.strAlertText          = message
        self.btnCancelTitle     = btnCancelTitle
        self.btnOtherTitle    = btnOtherTitle
    }
    
    /// Show Alert Controller
    private func show()
    {
        if let appDelegate = UIApplication.shared.delegate, let window = appDelegate.window, let rootViewController = window?.rootViewController {
            
            var topViewController = rootViewController
            while topViewController.presentedViewController != nil {
                topViewController = topViewController.presentedViewController!
            }
            
            topViewController.addChildViewController(self)
            topViewController.view.addSubview(view)
            viewWillAppear(true)
            didMove(toParentViewController: topViewController)
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.alpha = 0.0
            view.frame = topViewController.view.bounds
            
            viewAlert.alpha     = 0.0
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.view.alpha = 1.0
            }, completion: nil)
            
            viewAlert.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            viewAlert.center    = CGPoint(x: (self.view.bounds.size.width/2.0), y: (self.view.bounds.size.height/2.0)-10)
            UIView.animate(withDuration: 0.2 , delay: 0.1, options: .curveEaseOut, animations: { () -> Void in
                self.viewAlert.alpha = 1.0
                self.viewAlert.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.viewAlert.center    = CGPoint(x: (self.view.bounds.size.width/2.0), y: (self.view.bounds.size.height/2.0))
            }, completion: nil)
        }
    }
    
    /// Hide Alert Controller
    private func hide()
    {
        self.view.endEditing(true)
        self.viewAlert.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
            self.viewAlert.alpha = 0.0
            self.viewAlert.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            self.viewAlert.center    = CGPoint(x: (self.view.bounds.size.width/2.0), y: (self.view.bounds.size.height/2.0)-5)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.25, delay: 0.05, options: .curveEaseIn, animations: { () -> Void in
            self.view.alpha = 0.0
            
        }) { (completed) -> Void in
            
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }
    }
    
    // MARK:- UIButton Clicks
    // MARK:-
    
    @IBAction func btnCancelTapped(sender: UIButton) {
        block!!(0,btnCancelTitle!)
        
        //アカウント削除ボタンを押された上で、「キャンセル」を選択した際のアクション
        let AccountDeleteFlag :String = userDefaults.string(forKey: "AccountDeleteFlag")!
        if AccountDeleteFlag == "YES" {
            //アカウント削除の2重チェックに使うFlagの再初期化
            userDefaults.set("NO", forKey: "AccountDeleteFlag")
            userDefaults.synchronize()
            print("再初期化：AccountDeleteFlag = 「NO」")
            hide()
            return
        }
        
        //プライバシーポリシー・利用規約のページをSafariで開くアクション
        let url = URL(string: "https://chan-sho.github.io/")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        //プライバシーポリシー・利用規約のページをSafariで開いた事をFlagに反映("No" → "YES")
        CheckFlag = "YES"
        
    }
    
    @IBAction func btnOtherTapped(sender: UIButton) {
        block!!(1,btnOtherTitle!)
        
        //アカウント削除ボタンを押された上で、「キャンセル」を選択した際のアクション
        let AccountDeleteFlag :String = userDefaults.string(forKey: "AccountDeleteFlag")!
        if AccountDeleteFlag == "YES" {
            print("残念ながら、アカウント削除が完了・・・")
            hide()
            let user = Auth.auth().currentUser
            user?.delete { error in
                if let error = error {
                    SVProgressHUD.showError(withStatus: "【エラーが発生しました】\n\nアカウント削除を希望される場合は、お手数ですが再度お試し下さい。\n\n何度もエラーが発生する場合には、お手数ですがHome画面の最下部にあるリンクよりご連絡をお願いします。")
                    return
                } else {
                    SVProgressHUD.showSuccess(withStatus: "【アカウント削除完了】\n\nLoglogをご愛顧頂き、\nありがとうございました！\n\nご希望・ご期待に添えず、\n大変申し訣ありませんでした。\n\nまたご利用頂ける際には、\n是非よろしくお願い致します。")
                    
                    // ログアウトする
                    try! Auth.auth().signOut()
                    self.navigationController?.popViewController(animated: true)
                    
                    print("アカウント削除後のログアウトCheck・・・")
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0) {
                    exit(1)
                    }
                }
            }
            return
        }
        
        if CheckFlag == "NO" {
            SVProgressHUD.showError(withStatus: "【ご注意・お願い】\n\nリンクから内容を必ずご確認頂いた上で、同意するかどうかご判断ください。\n\nユーザー様の大切な個人情報を扱わせて頂くアプリですので、ご理解をお願い致します！")
            return
        }
        else {
        //利用規約同意済みのYESをUserDefaultsに保存する
        userDefaults.set("YES", forKey: "EULAagreement")
        userDefaults.synchronize()
        hide()
        }
        
    }
    
    @IBAction func btnOkTapped(sender: UIButton)
    {
        block!!(0,"OK")
        hide()
    }
    
    /// Hide Alert Controller on background tap
    @objc func backgroundViewTapped(sender:AnyObject)
    {
        hide()
    }
    
    // MARK:- AJAlert Functions
    // MARK:-
    
    /**
     Display an Alert
     
     - parameter aStrMessage:    Message to display in Alert
     - parameter aCancelBtnTitle: Cancel button title
     - parameter aOtherBtnTitle: Other button title
     - parameter otherButtonArr: Array of other button title
     - parameter completion:     Completion block. Other Button Index - 1 and Cancel Button Index - 0
     */
    
    public func showAlert( aStrMessage:String,
                           aCancelBtnTitle:String?,
                           aOtherBtnTitle:String? ,
                           completion : alertCompletionBlock){
        configure( message: aStrMessage, btnCancelTitle: aCancelBtnTitle, btnOtherTitle: aOtherBtnTitle)
        show()
        block = completion
    }
    
    /**
     Display an Alert With "OK" Button
     
     - parameter aStrMessage: Message to display in Alert
     - parameter completion:  Completion block. OK Button Index - 0
     */
    
    public func showAlertWithOkButton( aStrMessage:String,
                                       completion : alertCompletionBlock){
        configure(message: aStrMessage, btnCancelTitle: nil, btnOtherTitle: nil)
        show()
        block = completion
    }
}

