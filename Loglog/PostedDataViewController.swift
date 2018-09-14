//
//  PostedDataViewController.swift
//  Loglog
//
//  Created by 高野翔 on 2018/09/01.
//  Copyright © 2018年 高野翔. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class PostedDataViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textSearchBar: UISearchBar!
    
    var postArray: [PostData] = []
    var postArrayNoSearch: [PostData] = []
    var postArrayBySearch: [PostData] = []
    
    // DatabaseのobserveEventの登録状態を表す
    var observing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // HUDで投稿完了を表示する
        SVProgressHUD.show(withStatus: "データ読み込み中です")
        SVProgressHUD.dismiss(withDelay: 4.0)

        tableView.delegate = self
        tableView.dataSource = self
        
        // テーブルセルのタップを【無効】にする
        tableView.allowsSelection = false
        
        //separatorを左端始まりにして、黒色にする
        tableView.separatorColor = UIColor.black
        tableView.separatorInset = .zero
        
        textSearchBar.delegate = self
        textSearchBar.placeholder = "カテゴリー／内容などで検索"
        //何も入力されていなくてもReturnキーを押せるようにする。
        textSearchBar.enablesReturnKeyAutomatically = false
        //* tableView.tableHeaderView = textSearchBar
        
        let nib = UINib(nibName: "PostedDataViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        // テーブル行の高さをAutoLayoutで自動調整する
        tableView.rowHeight = UITableViewAutomaticDimension
        // テーブル行の高さの概算値を設定しておく
        tableView.estimatedRowHeight = UIScreen.main.bounds.width + 400
        
        //検索バーの初期設定
        textSearchBar.text = ""
        
        // TableViewを再表示する
        self.tableView.reloadData()
    }
    
    // Returnボタンを押した際にキーボードを消す
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる
        self.view.endEditing(true)
    }
    
    // テキスト以外の場所をタッチした際にキーボードを消す
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textSearchBar.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if Auth.auth().currentUser != nil {
            if self.observing == false {
                // 要素が追加されたらpostArrayに追加してTableViewを再表示する
                let postsRef = Database.database().reference().child(Const.PostPath)
                postsRef.observe(.childAdded, with: { snapshot in
                    print("DEBUG_PRINT: .childAddedイベントが発生しました。")
                    
                    // PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid {
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        self.postArray.insert(postData, at: 0)
                        
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
                postsRef.observe(.childChanged, with: { snapshot in
                    print("DEBUG_PRINT: .childChangedイベントが発生しました。")
                    
                    if let uid = Auth.auth().currentUser?.uid {
                        // PostDataクラスを生成して受け取ったデータを設定する
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        
                        
                        // 保持している配列からidが同じものを探す
                        var index: Int = 0
                        for post in self.postArray {
                            if post.id == postData.id {
                                index = self.postArray.index(of: post)!
                                break
                            }
                        }
                        
                        // 差し替えるため一度削除する
                        self.postArray.remove(at: index)
                        
                        // 削除したところに更新済みのデータを追加する
                        self.postArray.insert(postData, at: index)
                        
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                
                // DatabaseのobserveEventが上記コードにより登録されたため
                // trueとする
                observing = true
            }
        } else {
            if observing == true {
                // ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する。
                // テーブルをクリアする
                postArray = []
                tableView.reloadData()
                // オブザーバーを削除する
                Database.database().reference().removeAllObservers()
                
                // DatabaseのobserveEventが上記コードにより解除されたため
                // falseとする
                observing = false
            }
        }
        
    }
    
    
    //検索バーでテキストが空白or全て消された時 / テキスト入力された時の呼び出しメソッド
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let uid = Auth.auth().currentUser?.uid
        
        if textSearchBar.text == "" {
            // myMapが空 or 自身のuidと同じ
            postArray = postArray.filter( { $0.myMap == [] || ($0.myMap.contains(uid!))} )
        }
        else {
            // 検索バーのテキストを一部でも含む　もしくは　myMapが空 or 自身のuidと同じ
            postArrayBySearch = postArray.filter({ ($0.category?.contains(textSearchBar.text!))! || ($0.contents?.contains(textSearchBar.text!))! || ($0.relatedURL?.contains(textSearchBar.text!))! || ($0.secretpass?.contains(textSearchBar.text!))! || $0.myMap == [] || ($0.myMap.contains(uid!))})
        }
        
        tableView.reloadData()
    }
    
    // tableviewの行数をカウント
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
             if textSearchBar.text == "" {
                return postArray.count
            }
             else {
                return postArrayBySearch.count
            }
        }
    
    // tablewviewのcellにデータを受け渡すfunc
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if textSearchBar.text == "" {
                // セルを取得してデータを設定する
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostedDataViewCell
                cell.setPostData(postArray[indexPath.row])
                
                // セル内のボタンのアクションをソースコードで設定する
                cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
                
                // セル内のmyMapボタンを追加で管理
                cell.myMapButton.addTarget(self, action:#selector(handleMyMapButton(_:forEvent:)), for: .touchUpInside)
                
                return cell
            }
        else {
                // セルを取得してデータを設定する
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostedDataViewCell
                cell.setPostData(postArrayBySearch[indexPath.row])
                
                // セル内のボタンのアクションをソースコードで設定する
                cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
                
                // セル内のmyMapボタンを追加で管理
                cell.myMapButton.addTarget(self, action:#selector(handleMyMapButton(_:forEvent:)), for: .touchUpInside)
                
                return cell
            }
        }
    
    
    // セル内のlikeボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // タップされたインデックスのデータを確認
        print("タップされたインデックスのデータ by likeボタン＝\(postData)")
        
        // Firebaseに保存するデータの準備
        if let uid = Auth.auth().currentUser?.uid {
            if postData.isLiked {
                // すでにいいねをしていた場合はいいねを解除するためIDを取り除く
                var index = -1
                for likeId in postData.likes {
                    if likeId == uid {
                        // 削除するためにインデックスを保持しておく
                        index = postData.likes.index(of: likeId)!
                        break
                    }
                }
                postData.likes.remove(at: index)
            } else {
                postData.likes.append(uid)
            }
            
            // 増えたlikesをFirebaseに保存する
            let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
            let likes = ["likes": postData.likes]
            postRef.updateChildValues(likes)
            
        }
    }
    
    
    // セル内のMyMapボタンがタップされた時に呼ばれるメソッド
    @objc func handleMyMapButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: MyMapボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // タップされたインデックスのデータを確認
        print("タップされたインデックスのデータ by MyMapボタン＝\(postData)")
        
        // Firebaseに保存するデータの準備
        if let uid = Auth.auth().currentUser?.uid {
            if postData.myMapSelected {
            // すでにタップをしていた場合
            for myMapId in postData.myMap {
                if myMapId == uid {
                    postData.myMap.removeAll()
                    SVProgressHUD.showSuccess(withStatus: "「自分専用」を解除しました\n※この投稿は他のユーザーにも表示されます")
                    SVProgressHUD.dismiss(withDelay: 3.0)
                    break
                }
                if myMapId != uid {
                    break
                    }
                }
            // まだタップされていない場合
            }
            else {
                if postData.userID == uid {
                    postData.myMap.append(uid)
                    SVProgressHUD.showSuccess(withStatus: "「自分専用」に設定しました\n※この投稿は他のユーザーからは見えなくなります")
                    SVProgressHUD.dismiss(withDelay: 3.0)
                    }
                    else {
                    return
                    }
            }
            
            // 増えたmyMapをFirebaseに保存する
            let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
            let myMap = ["myMap": postData.myMap]
            postRef.updateChildValues(myMap)
            
        }
        
    }
    
}

