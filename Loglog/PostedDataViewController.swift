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
import ESTabBarController


class PostedDataViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textSearchBar: UISearchBar!
    
    var postArray: [PostData] = []
    var postArrayBySearch: [PostData] = []
    var postArrayAll: [PostData] = []
    var postArrayOnHome1: [PostData] = []
    var postArrayOnHome2: [PostData] = []
    var postArrayOnHome3: [PostData] = []
    
    // DatabaseのobserveEventの登録状態を表す
    var observing = false
    
    //user defaultsを使う準備
    let userDefaults:UserDefaults = UserDefaults.standard
    
    //投稿画像の拡大Viewの初期設定
    var backImage: UIImageView? = nil
    var setImage: UIImageView? = nil
    // 画像の拡大率
    var currentScale:CGFloat = 1.0
    //「CLOSEボタン」の初期設定
    var closeButton = UIButton()
    //投稿画像のタップ判別Flag
    var imageTappedFlag = 0
    
    
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
        textSearchBar.placeholder = "※投稿内容は長押しでコピー可能"
        //何も入力されていなくてもReturnキーを押せるようにする。
        textSearchBar.enablesReturnKeyAutomatically = false
        //* tableView.tableHeaderView = textSearchBar
        
        let nib = UINib(nibName: "PostedDataViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        // テーブル行の高さをAutoLayoutで自動調整する
        tableView.rowHeight = UITableViewAutomaticDimension
        // テーブル行の高さの概算値を設定しておく
        tableView.estimatedRowHeight = 400
        
        // TableViewを再表示する
        self.tableView.reloadData()
        
        //setImageのタップを有効にする（※画像のピンチイン・アウトを実装する際のために設定）
        self.setImage?.isUserInteractionEnabled = true
    }
    
    
    // Returnボタンを押した際にキーボードを消す
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる
        self.view.endEditing(true)
    }
    
    
    // テキスト以外の場所をタッチした際にキーボードを消す（←機能していない・・・）
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textSearchBar.resignFirstResponder()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        // TableViewを再表示する（※superの前に入れておくのが大事！！）
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
        super.viewWillAppear(animated)
        
        if Auth.auth().currentUser != nil {
            if self.observing == false {
                // 要素が【追加】されたらpostArrayに追加してTableViewを再表示する
                let postsRef = Database.database().reference().child(Const.PostPath)
                postsRef.observe(.childAdded, with: { snapshot in
                    
                    // PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid {
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        
                        // 始めのinsertの段階でuidと異なるmyMap(ID)の投稿データを除いておく
                        if postData.myMap == [] || postData.myMap.contains(uid) {
                            
                            self.postArray.insert(postData, at: 0)
                            // 念のため同じデータをpostArrayAllに入れておく
                            self.postArrayAll.insert(postData, at: 0)
                        }
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                // 要素が【変更】されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
                postsRef.observe(.childChanged, with: { snapshot in
                    
                    if let uid = Auth.auth().currentUser?.uid {
                        // PostDataクラスを生成して受け取ったデータを設定する
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        
                    // 検索バーのテキスト有無で場合分け
                    if self.textSearchBar.text == "" {
                        // 保持している配列からidが同じものを探す
                        var index: Int = 0
                        for post in self.postArray {
                            if post.id == postData.id {
                                index = self.postArray.index(of: post)!
                                break
                            }
                        }
                        
                        // 保持している配列からidが同じものを探す（※postArrayAll用）
                        var indexAll: Int = 0
                        for post in self.postArrayAll {
                            if post.id == postData.id {
                                indexAll = self.postArrayAll.index(of: post)!
                                break
                            }
                        }
                        
                        // 差し替えるため一度削除する
                        self.postArray.remove(at: index)
                        self.postArrayAll.remove(at: indexAll)
                        
                        // 削除したところに更新済みのデータを追加する
                        self.postArray.insert(postData, at: index)
                        self.postArrayAll.insert(postData, at: indexAll)
                        
                        // TableViewを再表示する
                        self.tableView.reloadData()
                        }
                        
                    //HomeViewControllerで対象のボタンを押した場合①
                    else if self.textSearchBar.text == "【※貴方の全投稿を抽出中】" {
                        // 保持している配列からidが同じものを探す
                        var indexOnHome1: Int = 0
                        for post in self.postArrayOnHome1 {
                            if post.id == postData.id {
                                indexOnHome1 = self.postArrayOnHome1.index(of: post)!
                                break
                            }
                        }
                        
                        // 保持している配列からidが同じものを探す（※postArray用）
                        var index: Int = 0
                        for post in self.postArray {
                            if post.id == postData.id {
                                index = self.postArray.index(of: post)!
                                break
                            }
                        }
                        
                        // 保持している配列からidが同じものを探す（※postArrayAll用）
                        var indexAll: Int = 0
                        for post in self.postArrayAll {
                            if post.id == postData.id {
                                indexAll = self.postArrayAll.index(of: post)!
                                break
                            }
                        }
                        
                        // 差し替えるため一度削除する
                        self.postArrayOnHome1.remove(at: indexOnHome1)
                        self.postArray.remove(at: index)
                        self.postArrayAll.remove(at: indexAll)
                        
                        // 削除したところに更新済みのデータを追加する
                        self.postArrayOnHome1.insert(postData, at: indexOnHome1)
                        self.postArray.insert(postData, at: index)
                        self.postArrayAll.insert(postData, at: indexAll)
                        
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                        
                    //HomeViewControllerで対象のボタンを押した場合②
                    else if self.textSearchBar.text == "【※貴方が「いいね」した投稿を抽出中】" {
                        // 保持している配列からidが同じものを探す
                        var indexOnHome2: Int = 0
                        for post in self.postArrayOnHome2 {
                            if post.id == postData.id {
                                indexOnHome2 = self.postArrayOnHome2.index(of: post)!
                                break
                            }
                        }
                        
                        // 保持している配列からidが同じものを探す（※postArray用）
                        var index: Int = 0
                        for post in self.postArray {
                            if post.id == postData.id {
                                index = self.postArray.index(of: post)!
                                break
                            }
                        }
                        
                        // 保持している配列からidが同じものを探す（※postArrayAll用）
                        var indexAll: Int = 0
                        for post in self.postArrayAll {
                            if post.id == postData.id {
                                indexAll = self.postArrayAll.index(of: post)!
                                break
                            }
                        }
                        
                        // 差し替えるため一度削除する
                        self.postArrayOnHome2.remove(at: indexOnHome2)
                        self.postArray.remove(at: index)
                        self.postArrayAll.remove(at: indexAll)
                        
                        // 削除したところに更新済みのデータを追加する
                        self.postArrayOnHome2.insert(postData, at: indexOnHome2)
                        self.postArray.insert(postData, at: index)
                        self.postArrayAll.insert(postData, at: indexAll)
                        
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                    
                        //HomeViewControllerで対象のボタンを押した場合③
                    else if self.textSearchBar.text == "【※貴方の「自分専用」を抽出中】" {
                        // 保持している配列からidが同じものを探す
                        var indexOnHome3: Int = 0
                        for post in self.postArrayOnHome3 {
                            if post.id == postData.id {
                                indexOnHome3 = self.postArrayOnHome3.index(of: post)!
                                break
                            }
                        }
                        
                        // 保持している配列からidが同じものを探す（※postArray用）
                        var index: Int = 0
                        for post in self.postArray {
                            if post.id == postData.id {
                                index = self.postArray.index(of: post)!
                                break
                            }
                        }
                        
                        // 保持している配列からidが同じものを探す（※postArrayAll用）
                        var indexAll: Int = 0
                        for post in self.postArrayAll {
                            if post.id == postData.id {
                                indexAll = self.postArrayAll.index(of: post)!
                                break
                            }
                        }
                        
                        // 差し替えるため一度削除する
                        self.postArrayOnHome3.remove(at: indexOnHome3)
                        self.postArray.remove(at: index)
                        self.postArrayAll.remove(at: indexAll)
                        
                        // 削除したところに更新済みのデータを追加する
                        self.postArrayOnHome3.insert(postData, at: indexOnHome3)
                        self.postArray.insert(postData, at: index)
                        self.postArrayAll.insert(postData, at: indexAll)
                        
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                    
                    else {
                        // 保持している配列からidが同じものを探す
                        var indexBySearch: Int = 0
                        for post in self.postArrayBySearch {
                            if post.id == postData.id {
                                indexBySearch = self.postArrayBySearch.index(of: post)!
                                break
                            }
                        }
                        
                        // 保持している配列からidが同じものを探す（※postArray用）
                        var index: Int = 0
                        for post in self.postArray {
                            if post.id == postData.id {
                                index = self.postArray.index(of: post)!
                                break
                            }
                        }
                        
                        // 保持している配列からidが同じものを探す（※postArrayAll用）
                        var indexAll: Int = 0
                        for post in self.postArrayAll {
                            if post.id == postData.id {
                                indexAll = self.postArrayAll.index(of: post)!
                                break
                            }
                        }
                            
                        // 差し替えるため一度削除する
                        self.postArrayBySearch.remove(at: indexBySearch)
                        self.postArray.remove(at: index)
                        self.postArrayAll.remove(at: indexAll)
                        
                        // 削除したところに更新済みのデータを追加する
                        self.postArrayBySearch.insert(postData, at: indexBySearch)
                        self.postArray.insert(postData, at: index)
                        self.postArrayAll.insert(postData, at: indexAll)
                            
                        // TableViewを再表示する
                        self.tableView.reloadData()
                        }
                    }
                })
                
                // 要素が【削除】されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
                postsRef.observe(.childRemoved, with: { snapshot in
                    
                    if let uid = Auth.auth().currentUser?.uid {
                        // PostDataクラスを生成して受け取ったデータを設定する
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        
                        // 検索バーのテキスト有無で場合分け
                        if self.textSearchBar.text == "" {
                            // 保持している配列からidが同じものを探す
                            var index: Int = 0
                            for post in self.postArray {
                                if post.id == postData.id {
                                    index = self.postArray.index(of: post)!
                                    break
                                }
                            }
                            
                            // 保持している配列からidが同じものを探す（※postArrayAll用）
                            var indexAll: Int = 0
                            for post in self.postArrayAll {
                                if post.id == postData.id {
                                    indexAll = self.postArrayAll.index(of: post)!
                                    break
                                }
                            }
                            
                            // 削除する
                            self.postArray.remove(at: index)
                            self.postArrayAll.remove(at: indexAll)
                            
                            // TableViewを再表示する
                            self.tableView.reloadData()
                        }
                        
                            //HomeViewControllerで対象のボタンを押した場合①
                        else if self.textSearchBar.text == "【※貴方の全投稿を抽出中】" {
                            // 保持している配列からidが同じものを探す
                            var indexOnHome1: Int = 0
                            for post in self.postArrayOnHome1 {
                                if post.id == postData.id {
                                    indexOnHome1 = self.postArrayOnHome1.index(of: post)!
                                    break
                                }
                            }
                            
                            // 保持している配列からidが同じものを探す（※postArray用）
                            var index: Int = 0
                            for post in self.postArray {
                                if post.id == postData.id {
                                    index = self.postArray.index(of: post)!
                                    break
                                }
                            }
                            
                            // 保持している配列からidが同じものを探す（※postArrayAll用）
                            var indexAll: Int = 0
                            for post in self.postArrayAll {
                                if post.id == postData.id {
                                    indexAll = self.postArrayAll.index(of: post)!
                                    break
                                }
                            }
                            
                            // 削除する
                            self.postArrayOnHome1.remove(at: indexOnHome1)
                            self.postArray.remove(at: index)
                            self.postArrayAll.remove(at: indexAll)
                            
                            // TableViewを再表示する
                            self.tableView.reloadData()
                        }
                        
                            //HomeViewControllerで対象のボタンを押した場合②
                        else if self.textSearchBar.text == "【※貴方が「いいね」した投稿を抽出中】" {
                            // 保持している配列からidが同じものを探す
                            var indexOnHome2: Int = 0
                            for post in self.postArrayOnHome2 {
                                if post.id == postData.id {
                                    indexOnHome2 = self.postArrayOnHome2.index(of: post)!
                                    break
                                }
                            }
                            
                            // 保持している配列からidが同じものを探す（※postArray用）
                            var index: Int = 0
                            for post in self.postArray {
                                if post.id == postData.id {
                                    index = self.postArray.index(of: post)!
                                    break
                                }
                            }
                            
                            // 保持している配列からidが同じものを探す（※postArrayAll用）
                            var indexAll: Int = 0
                            for post in self.postArrayAll {
                                if post.id == postData.id {
                                    indexAll = self.postArrayAll.index(of: post)!
                                    break
                                }
                            }
                            
                            // 削除する
                            self.postArrayOnHome2.remove(at: indexOnHome2)
                            self.postArray.remove(at: index)
                            self.postArrayAll.remove(at: indexAll)
                            
                            // TableViewを再表示する
                            self.tableView.reloadData()
                        }
                            
                            //HomeViewControllerで対象のボタンを押した場合③
                        else if self.textSearchBar.text == "【※貴方の「自分専用」を抽出中】" {
                            // 保持している配列からidが同じものを探す
                            var indexOnHome3: Int = 0
                            for post in self.postArrayOnHome3 {
                                if post.id == postData.id {
                                    indexOnHome3 = self.postArrayOnHome3.index(of: post)!
                                    break
                                }
                            }
                            
                            // 保持している配列からidが同じものを探す（※postArray用）
                            var index: Int = 0
                            for post in self.postArray {
                                if post.id == postData.id {
                                    index = self.postArray.index(of: post)!
                                    break
                                }
                            }
                            
                            // 保持している配列からidが同じものを探す（※postArrayAll用）
                            var indexAll: Int = 0
                            for post in self.postArrayAll {
                                if post.id == postData.id {
                                    indexAll = self.postArrayAll.index(of: post)!
                                    break
                                }
                            }
                            
                            // 削除する
                            self.postArrayOnHome3.remove(at: indexOnHome3)
                            self.postArray.remove(at: index)
                            self.postArrayAll.remove(at: indexAll)
                            
                            // TableViewを再表示する
                            self.tableView.reloadData()
                        }
                        else {
                          
                            // 保持している配列からidが同じものを探す
                            var indexBySearch: Int = 0
                            for post in self.postArrayBySearch {
                                if post.id == postData.id {
                                    indexBySearch = self.postArrayBySearch.index(of: post)!
                                    break
                                }
                            }
                            
                            // 保持している配列からidが同じものを探す（※postArray用）
                            var index: Int = 0
                            for post in self.postArray {
                                if post.id == postData.id {
                                    index = self.postArray.index(of: post)!
                                    break
                                }
                            }
                            
                            // 保持している配列からidが同じものを探す（※postArrayAll用）
                            var indexAll: Int = 0
                            for post in self.postArrayAll {
                                if post.id == postData.id {
                                    indexAll = self.postArrayAll.index(of: post)!
                                    break
                                }
                            }
                            
                            // 削除する
                            self.postArrayBySearch.remove(at: indexBySearch)
                            self.postArray.remove(at: index)
                            self.postArrayAll.remove(at: indexAll)
                            
                            // TableViewを再表示する
                            self.tableView.reloadData()
                        }
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
                postArrayAll = []
                postArrayBySearch = []
                postArrayOnHome1 = []
                postArrayOnHome2 = []
                postArrayOnHome3 = []
                tableView.reloadData()
                // オブザーバーを削除する
                Database.database().reference().removeAllObservers()
                
                // DatabaseのobserveEventが上記コードにより解除されたため
                // falseとする
                observing = false
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.tableView.dataSource = self
        // TableViewを再表示する
        self.tableView.reloadData()
    }
        
    
    //検索バーでテキストが空白時 or HomeViewControllerで対象のボタンを押印 or テキスト入力時の呼び出しメソッド
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
     
        if textSearchBar.text == "" {
            self.tableView.reloadData()
        }
        
        //HomeViewControllerで対象のボタンを押印①
        else if textSearchBar.text == "【※貴方の全投稿を抽出中】" {
            let uid = Auth.auth().currentUser?.uid
            
            let array = uid?.components(separatedBy: NSCharacterSet.whitespaces)
            var tempFilteredArray = postArrayAll
            for n in array! {
                tempFilteredArray = tempFilteredArray.filter{($0.userID?.contains(n))!}
            }
            postArrayOnHome1 = tempFilteredArray
            
            self.tableView.reloadData()
        }
        
        //HomeViewControllerで対象のボタンを押印②
        else if textSearchBar.text == "【※貴方が「いいね」した投稿を抽出中】" {
            let uid = Auth.auth().currentUser?.uid
            
            let array = uid?.components(separatedBy: NSCharacterSet.whitespaces)
            var tempFilteredArray = postArrayAll
            for n in array! {
                tempFilteredArray = tempFilteredArray.filter{($0.likes.contains(n))}
            }
            postArrayOnHome2 = tempFilteredArray
            
            self.tableView.reloadData()
        }
        
        //HomeViewControllerで対象のボタンを押印③
        else if textSearchBar.text == "【※貴方の「自分専用」を抽出中】" {
            let uid = Auth.auth().currentUser?.uid
            
            let array = uid?.components(separatedBy: NSCharacterSet.whitespaces)
            var tempFilteredArray = postArrayAll
            for n in array! {
                tempFilteredArray = tempFilteredArray.filter{($0.myMap.contains(n))}
            }
            postArrayOnHome3 = tempFilteredArray
            
            self.tableView.reloadData()
        }
            
        else {
            // 検索バーに入力された単語をスペースで分けて配列に入れる
            let searchWords = textSearchBar.text!
            let array = searchWords.components(separatedBy: NSCharacterSet.whitespaces)
            // 検索バーのテキストを一部でも含むものをAND検索する！
            var tempFilteredArray = postArrayAll
            for n in array {
                tempFilteredArray = tempFilteredArray.filter({ ($0.category?.localizedCaseInsensitiveContains(n))! || ($0.contents?.localizedCaseInsensitiveContains(n))! || ($0.relatedURL?.localizedCaseInsensitiveContains(n))! || ($0.secretpass?.localizedCaseInsensitiveContains(n))! || ($0.id?.localizedCaseInsensitiveContains(n))! || ($0.pinAddress?.localizedCaseInsensitiveContains(n))! || ($0.name?.localizedCaseInsensitiveContains(n))!})
            }
            postArrayBySearch = tempFilteredArray
            
            self.tableView.reloadData()
        }
    }

    
    // tableviewの行数をカウント
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if textSearchBar.text == "" {
            return postArray.count
        }
        else if textSearchBar.text == "【※貴方の全投稿を抽出中】" {
            
            return postArrayOnHome1.count
        }
        else if textSearchBar.text == "【※貴方が「いいね」した投稿を抽出中】" {
            
            return postArrayOnHome2.count
        }
        else if textSearchBar.text == "【※貴方の「自分専用」を抽出中】" {
            
            return postArrayOnHome3.count
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
            
                // セル内のreviseボタンを追加で管理
                cell.reviseButton.addTarget(self, action:#selector(handleReviseButton(_:forEvent:)), for: .touchUpInside)
            
                // セル内のcreateMapPinボタンを追加で管理
                cell.createMapPinButton.addTarget(self, action:#selector(handleCreateMapPinButton(_:forEvent:)), for: .touchUpInside)
            
                // セル内のimageViewボタンを追加で管理
                cell.imageViewButton.addTarget(self, action:#selector(handleImageViewButton(_:forEvent:)), for: .touchUpInside)
            
                return cell
            }
        
        else if textSearchBar.text == "【※貴方の全投稿を抽出中】" {
            
            // セルを取得してデータを設定する
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostedDataViewCell
            cell.setPostData(postArrayOnHome1[indexPath.row])
            
            // セル内のボタンのアクションをソースコードで設定する
            cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
            
            // セル内のmyMapボタンを追加で管理
            cell.myMapButton.addTarget(self, action:#selector(handleMyMapButton(_:forEvent:)), for: .touchUpInside)
            
            // セル内のreviseボタンを追加で管理
            cell.reviseButton.addTarget(self, action:#selector(handleReviseButton(_:forEvent:)), for: .touchUpInside)
            
            // セル内のcreateMapPinボタンを追加で管理
            cell.createMapPinButton.addTarget(self, action:#selector(handleCreateMapPinButton(_:forEvent:)), for: .touchUpInside)
            
            // セル内のimageViewボタンを追加で管理
            cell.imageViewButton.addTarget(self, action:#selector(handleImageViewButton(_:forEvent:)), for: .touchUpInside)
            
            return cell
            }
        
        else if textSearchBar.text == "【※貴方が「いいね」した投稿を抽出中】" {
            
            // セルを取得してデータを設定する
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostedDataViewCell
            cell.setPostData(postArrayOnHome2[indexPath.row])
            
            // セル内のボタンのアクションをソースコードで設定する
            cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
            
            // セル内のmyMapボタンを追加で管理
            cell.myMapButton.addTarget(self, action:#selector(handleMyMapButton(_:forEvent:)), for: .touchUpInside)
            
            // セル内のreviseボタンを追加で管理
            cell.reviseButton.addTarget(self, action:#selector(handleReviseButton(_:forEvent:)), for: .touchUpInside)
            
            // セル内のcreateMapPinボタンを追加で管理
            cell.createMapPinButton.addTarget(self, action:#selector(handleCreateMapPinButton(_:forEvent:)), for: .touchUpInside)
            
            // セル内のimageViewボタンを追加で管理
            cell.imageViewButton.addTarget(self, action:#selector(handleImageViewButton(_:forEvent:)), for: .touchUpInside)
            
            return cell
        }
        else if textSearchBar.text == "【※貴方の「自分専用」を抽出中】" {
            
            // セルを取得してデータを設定する
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostedDataViewCell
            cell.setPostData(postArrayOnHome3[indexPath.row])
            
            // セル内のボタンのアクションをソースコードで設定する
            cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
            
            // セル内のmyMapボタンを追加で管理
            cell.myMapButton.addTarget(self, action:#selector(handleMyMapButton(_:forEvent:)), for: .touchUpInside)
            
            // セル内のreviseボタンを追加で管理
            cell.reviseButton.addTarget(self, action:#selector(handleReviseButton(_:forEvent:)), for: .touchUpInside)
            
            // セル内のcreateMapPinボタンを追加で管理
            cell.createMapPinButton.addTarget(self, action:#selector(handleCreateMapPinButton(_:forEvent:)), for: .touchUpInside)
            
            // セル内のimageViewボタンを追加で管理
            cell.imageViewButton.addTarget(self, action:#selector(handleImageViewButton(_:forEvent:)), for: .touchUpInside)
            
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
            
                // セル内のreviseボタンを追加で管理
                cell.reviseButton.addTarget(self, action:#selector(handleReviseButton(_:forEvent:)), for: .touchUpInside)
            
                // セル内のcreateMapPinボタンを追加で管理
                cell.createMapPinButton.addTarget(self, action:#selector(handleCreateMapPinButton(_:forEvent:)), for: .touchUpInside)
            
                // セル内のimageViewボタンを追加で管理
                cell.imageViewButton.addTarget(self, action:#selector(handleImageViewButton(_:forEvent:)), for: .touchUpInside)
                
                return cell
            }
        
        }
    
    
    // セル内のlikeボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let postData : PostData
        
        if textSearchBar.text == "" {
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArray[indexPath!.row]
        }
        
        else if textSearchBar.text == "【※貴方の全投稿を抽出中】" {
            
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArrayOnHome1[indexPath!.row]
        }
            
        else if textSearchBar.text == "【※貴方が「いいね」した投稿を抽出中】" {
            
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArrayOnHome2[indexPath!.row]
        }
            
        else if textSearchBar.text == "【※貴方の「自分専用」を抽出中】" {
            
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArrayOnHome3[indexPath!.row]
        }
        
        else {
            // 検索バーに入力された単語をスペースで分けて配列に入れる
            let searchWords = textSearchBar.text!
            let array = searchWords.components(separatedBy: NSCharacterSet.whitespaces)
            // 検索バーのテキストを一部でも含むものをAND検索する！
            var tempFilteredArray = postArrayAll
            for n in array {
                tempFilteredArray = tempFilteredArray.filter({ ($0.category?.localizedCaseInsensitiveContains(n))! || ($0.contents?.localizedCaseInsensitiveContains(n))! || ($0.relatedURL?.localizedCaseInsensitiveContains(n))! || ($0.secretpass?.localizedCaseInsensitiveContains(n))! || ($0.id?.localizedCaseInsensitiveContains(n))! || ($0.pinAddress?.localizedCaseInsensitiveContains(n))! || ($0.name?.localizedCaseInsensitiveContains(n))!})
            }
            postArrayBySearch = tempFilteredArray
            postData = postArrayBySearch[indexPath!.row]
        }
        
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
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let postData : PostData

        if textSearchBar.text == "" {
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArray[indexPath!.row]
        }
        
        else if textSearchBar.text == "【※貴方の全投稿を抽出中】" {
            
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArrayOnHome1[indexPath!.row]
        }
            
        else if textSearchBar.text == "【※貴方が「いいね」した投稿を抽出中】" {
            
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArrayOnHome2[indexPath!.row]
        }
            
        else if textSearchBar.text == "【※貴方の「自分専用」を抽出中】" {
            
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArrayOnHome3[indexPath!.row]
        }
            
        else {
            // 検索バーに入力された単語をスペースで分けて配列に入れる
            let searchWords = textSearchBar.text!
            let array = searchWords.components(separatedBy: NSCharacterSet.whitespaces)
            // 検索バーのテキストを一部でも含むものをAND検索する！
            var tempFilteredArray = postArrayAll
            for n in array {
                tempFilteredArray = tempFilteredArray.filter({ ($0.category?.localizedCaseInsensitiveContains(n))! || ($0.contents?.localizedCaseInsensitiveContains(n))! || ($0.relatedURL?.localizedCaseInsensitiveContains(n))! || ($0.secretpass?.localizedCaseInsensitiveContains(n))! || ($0.id?.localizedCaseInsensitiveContains(n))! || ($0.pinAddress?.localizedCaseInsensitiveContains(n))! || ($0.name?.localizedCaseInsensitiveContains(n))!})
            }
            postArrayBySearch = tempFilteredArray
            postData = postArrayBySearch[indexPath!.row]
        }
        
        // Firebaseに保存するデータの準備
        if let uid = Auth.auth().currentUser?.uid {
            if postData.myMapSelected {
            // すでにタップをしていた場合
            for myMapId in postData.myMap {
                if myMapId == uid {
                    postData.myMap.removeAll()
                    SVProgressHUD.showSuccess(withStatus: "「自分専用」を解除しました\n\n※この投稿は他のユーザーにも表示されます")
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
                    SVProgressHUD.showSuccess(withStatus: "「自分専用」に設定しました\n\n※この投稿は他のユーザーからは見えなくなります")
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
    
    
    //セル内のReviseボタンが押された時に呼ばれるメソッド
    @objc func handleReviseButton(_ sender: UIButton, forEvent event: UIEvent) {
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let postData : PostData
        
        if textSearchBar.text == "" {
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArray[indexPath!.row]
        }
        else if textSearchBar.text == "【※貴方の全投稿を抽出中】" {
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArrayOnHome1[indexPath!.row]
        }
        else if textSearchBar.text == "【※貴方が「いいね」した投稿を抽出中】" {
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArrayOnHome2[indexPath!.row]
        }
        else if textSearchBar.text == "【※貴方の「自分専用」を抽出中】" {
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArrayOnHome3[indexPath!.row]
        }
        else {
            // 検索バーに入力された単語をスペースで分けて配列に入れる
            let searchWords = textSearchBar.text!
            let array = searchWords.components(separatedBy: NSCharacterSet.whitespaces)
            // 検索バーのテキストを一部でも含むものをAND検索する！
            var tempFilteredArray = postArrayAll
            for n in array {
                tempFilteredArray = tempFilteredArray.filter({ ($0.category?.localizedCaseInsensitiveContains(n))! || ($0.contents?.localizedCaseInsensitiveContains(n))! || ($0.relatedURL?.localizedCaseInsensitiveContains(n))! || ($0.secretpass?.localizedCaseInsensitiveContains(n))! || ($0.id?.localizedCaseInsensitiveContains(n))! || ($0.pinAddress?.localizedCaseInsensitiveContains(n))! || ($0.name?.localizedCaseInsensitiveContains(n))!})
            }
            postArrayBySearch = tempFilteredArray
            postData = postArrayBySearch[indexPath!.row]
        }
        
        //タップを検知されたpostDataから投稿ナンバーを抽出する
        let reviseDataId = postData.id
        
        //Reviseボタンを押したユーザーが投稿者本人かどうかの判断
        let uid = Auth.auth().currentUser?.uid
        let userID = postData.userID
        if userID == uid {
            userDefaults.set(reviseDataId, forKey: "reviseDataId")
            userDefaults.synchronize()
            self.performSegue(withIdentifier: "toRevised", sender: nil)
        }
        else {
            SVProgressHUD.showError(withStatus: "投稿者ご本人ではない為、投稿内容の修正・削除はできません")
            return
        }
    }
    
    
    //セル内のcreateMapPinボタンが押された時に呼ばれるメソッド
    @objc func handleCreateMapPinButton(_ sender: UIButton, forEvent event: UIEvent) {
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let postData : PostData
        
        if textSearchBar.text == "" {
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArray[indexPath!.row]
        }
        else if textSearchBar.text == "【※貴方の全投稿を抽出中】" {
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArrayOnHome1[indexPath!.row]
        }
        else if textSearchBar.text == "【※貴方が「いいね」した投稿を抽出中】" {
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArrayOnHome2[indexPath!.row]
        }
        else if textSearchBar.text == "【※貴方の「自分専用」を抽出中】" {
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArrayOnHome3[indexPath!.row]
        }
        else {
            // 検索バーに入力された単語をスペースで分けて配列に入れる
            let searchWords = textSearchBar.text!
            let array = searchWords.components(separatedBy: NSCharacterSet.whitespaces)
            // 検索バーのテキストを一部でも含むものをAND検索する！
            var tempFilteredArray = postArrayAll
            for n in array {
                tempFilteredArray = tempFilteredArray.filter({ ($0.category?.localizedCaseInsensitiveContains(n))! || ($0.contents?.localizedCaseInsensitiveContains(n))! || ($0.relatedURL?.localizedCaseInsensitiveContains(n))! || ($0.secretpass?.localizedCaseInsensitiveContains(n))! || ($0.id?.localizedCaseInsensitiveContains(n))! || ($0.pinAddress?.localizedCaseInsensitiveContains(n))! || ($0.name?.localizedCaseInsensitiveContains(n))!})
            }
            postArrayBySearch = tempFilteredArray
            postData = postArrayBySearch[indexPath!.row]
        }
        
        //タップを検知されたpostDataから投稿ナンバーを抽出する
        let createMapPinId = postData.id
        
        userDefaults.set(createMapPinId, forKey: "createMapPinId")
        userDefaults.synchronize()
        
        let tabBarController = self.parent as! ESTabBarController
        tabBarController.setSelectedIndex(2, animated: false)
        for viewController in tabBarController.childViewControllers {
            if viewController is SearchMapViewController {
                let searchMapViewController = viewController as! SearchMapViewController
                searchMapViewController.createMapPin()
            }
        }
    }
    
    
    //セル内のimageViewボタンが押された時に呼ばれるメソッド
    @objc func handleImageViewButton(_ sender: UIButton, forEvent event: UIEvent) {
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let postData : PostData
        
        if textSearchBar.text == "" {
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArray[indexPath!.row]
        }
        else if textSearchBar.text == "【※貴方の全投稿を抽出中】" {
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArrayOnHome1[indexPath!.row]
        }
        else if textSearchBar.text == "【※貴方が「いいね」した投稿を抽出中】" {
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArrayOnHome2[indexPath!.row]
        }
        else if textSearchBar.text == "【※貴方の「自分専用」を抽出中】" {
            // 配列からタップされたインデックスのデータを取り出す
            postData = postArrayOnHome3[indexPath!.row]
        }
        else {
            // 検索バーに入力された単語をスペースで分けて配列に入れる
            let searchWords = textSearchBar.text!
            let array = searchWords.components(separatedBy: NSCharacterSet.whitespaces)
            // 検索バーのテキストを一部でも含むものをAND検索する！
            var tempFilteredArray = postArrayAll
            for n in array {
                tempFilteredArray = tempFilteredArray.filter({ ($0.category?.localizedCaseInsensitiveContains(n))! || ($0.contents?.localizedCaseInsensitiveContains(n))! || ($0.relatedURL?.localizedCaseInsensitiveContains(n))! || ($0.secretpass?.localizedCaseInsensitiveContains(n))! || ($0.id?.localizedCaseInsensitiveContains(n))! || ($0.pinAddress?.localizedCaseInsensitiveContains(n))! || ($0.name?.localizedCaseInsensitiveContains(n))!})
            }
            postArrayBySearch = tempFilteredArray
            postData = postArrayBySearch[indexPath!.row]
        }
        
        //タップを検知されたpostDataから投稿ナンバー／写真コードを抽出する
        let imageViewId = postData.id
        print("タップされたインデックスのid by imageViewボタン＝\(imageViewId!)")
        let imageCode = postData.image
        print("タップされたインデックスのid by imageViewボタン＝\(imageCode!)")
        
        //投稿画像のタップを検知
        imageTappedFlag = imageTappedFlag + 1
        print("imageTappedFlag = \(imageTappedFlag)")
        
        if imageTappedFlag == 1 {
        //投稿写真をタップされた際の拡大画像の設定
        backImage = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        backImage?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.addSubview(backImage!)
        
        setImage = UIImageView(frame: CGRect(x: 20, y: 90, width: self.view.frame.size.width - 40, height: self.view.frame.size.height - 130))
        setImage?.image = postData.image
        setImage?.contentMode = UIViewContentMode.scaleAspectFit
        self.view.addSubview(setImage!)
        
        //「CLOSEボタン」のインスタンス生成＆各種設定
        closeButton.frame = CGRect(x: 20, y: 70, width: 80, height: 20)
        // ボタンのタイトルを設定
        closeButton.setTitle("CLOSE", for:UIControlState.normal)
        // タイトルの色
        closeButton.setTitleColor(UIColor.white, for: .normal)
        // ボタンのフォントサイズ
        closeButton.titleLabel?.font =  UIFont.systemFont(ofSize: 20)
        // タップされたときのaction
        closeButton.addTarget(self, action:#selector(handleCloseButton(_:forEvent:)), for: .touchUpInside)
        // Viewにボタンを追加
        self.view.addSubview(closeButton)
        }
        
    }
    
    
    //「CLOSEボタン」が押された時に呼ばれるメソッド
    @objc func handleCloseButton(_ sender: UIButton, forEvent event: UIEvent) {
        backImage?.removeFromSuperview()
        setImage?.removeFromSuperview()
        closeButton.removeFromSuperview()
        //投稿画像タップFlagの初期化
        imageTappedFlag = 0
    }
    
    
    //HomeViewControllerで「allPostedSelectButton」を押された際の処理
    func allPostedSelection() {
        self.tableView.reloadData()
        self.textSearchBar.text = "【※貴方の全投稿を抽出中】"
        
        let uid = Auth.auth().currentUser?.uid
        
        let array = uid?.components(separatedBy: NSCharacterSet.whitespaces)
        var tempFilteredArray = postArrayAll
        for n in array! {
            tempFilteredArray = tempFilteredArray.filter{($0.userID?.contains(n))!}
        }
        postArrayOnHome1 = tempFilteredArray
        
        self.tableView.reloadData()
    }
    
    
    //HomeViewControllerで「likeSelectButton」を押された際の処理
    func likeSelection() {
        self.tableView.reloadData()
        self.textSearchBar.text = "【※貴方が「いいね」した投稿を抽出中】"
        
        let uid = Auth.auth().currentUser?.uid
        
        let array = uid?.components(separatedBy: NSCharacterSet.whitespaces)
        var tempFilteredArray = postArrayAll
        for n in array! {
            tempFilteredArray = tempFilteredArray.filter{($0.likes.contains(n))}
        }
        postArrayOnHome2 = tempFilteredArray
        
        self.tableView.reloadData()
    }
    
    
    //HomeViewControllerで「myMapSelectButton」を押された際の処理
    func myMapSelection() {
        self.tableView.reloadData()
        self.textSearchBar.text = "【※貴方の「自分専用」を抽出中】"
        
        let uid = Auth.auth().currentUser?.uid
        
        let array = uid?.components(separatedBy: NSCharacterSet.whitespaces)
        var tempFilteredArray = postArrayAll
        for n in array! {
            tempFilteredArray = tempFilteredArray.filter{($0.myMap.contains(n))}
        }
        postArrayOnHome3 = tempFilteredArray
        
        self.tableView.reloadData()
    }
    
    
    //地図上で「吹き出し内の右のボタン」を押された際の処理
    func buttonRightSelection() {
        
        let buttonRightTitle = userDefaults.string(forKey: "buttonRightTitle")!
        let buttonRightSubtitle = userDefaults.string(forKey: "buttonRightSubtitle")!
        
        self.textSearchBar.text = "\(buttonRightTitle) \(buttonRightSubtitle)"
        
        // 検索バーに入力された単語をスペースで分けて配列に入れる
        let searchWords = textSearchBar.text!
        let array = searchWords.components(separatedBy: NSCharacterSet.whitespaces)
        // 検索バーのテキストを一部でも含むものをAND検索する！
        var tempFilteredArray = postArrayAll
        for n in array {
            tempFilteredArray = tempFilteredArray.filter({ ($0.category?.localizedCaseInsensitiveContains(n))! || ($0.contents?.localizedCaseInsensitiveContains(n))! || ($0.relatedURL?.localizedCaseInsensitiveContains(n))! || ($0.secretpass?.localizedCaseInsensitiveContains(n))! || ($0.id?.localizedCaseInsensitiveContains(n))! || ($0.pinAddress?.localizedCaseInsensitiveContains(n))! || ($0.name?.localizedCaseInsensitiveContains(n))!})
        }
        postArrayBySearch = tempFilteredArray
        
        self.tableView.reloadData()
    }
    
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        // 他の画面から segue を使って戻ってきた時に呼ばれる
    }
    
}

