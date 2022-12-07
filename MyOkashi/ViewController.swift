//
//  ViewController.swift
//  MyOkashi
//
//  Created by Daisuke Doi on 2022/12/04.
//

/*

 guard let asでキャストorアンラップ　はてなにかく
 
●● if let とguard let　の違い
 
 if let Huga = Hoge {
    func Hogehoge()
 }
 >>>>if let は　オプショナル型に値があったときだけ、指定の処理を行う。
 
 guard let Huga = Hoge  else {
    funco Hogehoge()
 }
 
 >>>>>>>guard letは、オプショナル型に値がなかったときだけ、指定の処理を行う。

 
 
●●構造体の書式
構造体の宣言、structキーワードを使う
struct 構造体名 {
  //構造体でまとめる変数やメソッドを宣言
}

構造体のインスタンス生成、初期化されて使える状態になる
let usedStruct = 構造体名()

 
 ●●do try catch構文の使い方
 メソッドの中には、エラー、例外を返してくれるものがある。そうしたメソッドは,下記のような形をしている。
 >>>>>>>>>>>>>>>>>>>>>>>>
 func methodHoge() throws {
    if 例外条件 {
        例外通知をおこなうスクリプト
    }
 }
 >>>>>>>>>>>>>>>>>>>>>>>>
メソッドの最後にあるthrowsは、例外やエラーを返す可能性がある　ということを指す。
throuwがついているメソッドを使う場合は、エラー、例外に備えて do try catch を使う必要がある。
⇨ do try catchが使えるのは、あらかじめエラー報告機能が備え付けられたメソッドだけ。家電のアース線みたいなもの

do-try-catch構文の書き方
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 func method() {
     do {
         try methodA()
     } catch {
         // エラー処理
     }
 }
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 2日でできるアプリの本を読むと、iOSではデフォルトでHTTPを使ってネット接続ができない。
 HTTPSでもAppleが推奨するセキュリティ要件を満たしていないと接続ができない。
 ATS(App Transport Security)とよばれる機能で、iOS側でブロックするようになっている。
 
タプル配列
データ型の一つ、1次元配列の中で変数を宣言することができ、後から変数の中に値をいれられる
For文とかと組み合わすと、繰り返し処理で任意のタプル配列を一気に出力することができる
タプルは値の追加、削除、データの個数を変更することができない。配列はできる
「(name:String , maker:String ,  link:URL, image:URL)」 がタプルになり、「name:Stringが変数名:データ型」を示す。
タプルを[](配列リテラル)で囲むことで、配列の要素として扱える。=[]は、配列として初期化(宣言)を行なっている。
タプルを配列の中に入れると、ほしい要素のみ過不足なく並んだデータの羅列を作成、表示できる。べんり
 
 
 present dismiss
 したからぴゅっと出てくる新規画面（モーダル遷移？）を呼び出せる。
 よびかた
 present (インスタンス化したViewController, animated: true, completion: nil))
 ->ViewControllerが定義する画面を出せる　animated はアニメーション処理の有無　completionは表示完了後の処理（クロージャで指定可能）
 
 */

import UIKit
import SafariServices


class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //searchBarのdelegate通知先 これは依頼先クラスがどのswiftファイルに通知をするかを書いてる
        //今回はselfなのでVireContorller.swift内を対象
        searchText.delegate = self
        //プレースホルダー(検索バー　からの時に映る文字れる)を設定
        searchText.placeholder = "お菓子の名前を入力してください"
        //Table ViewのdataSourceを設定 ViewController内のそっかから引っ張ってtableViewにデータを入れてくれる
        tableView.dataSource = self
        //Table Viewのdelegateを設定
        tableView.delegate = self
        
    }
    
    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    //お菓子のリスト（タプル配列） タプルとは、複数の値を一つの変数として扱うことができる機能。

    var okashiList : [(name:String, maker:String , link:URL , image:URL)] = []
    
    //検索ボタンをクリック(タップ)時、下記Delegteメソッドが実行される
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる　IOSは自動で閉じてくれない
        view.endEditing(true)
        
        if let searchWord = searchBar.text{
            //デバッグエリアに出力
            print(searchWord)
            //入力されていたら、お菓子を検索
            searchOkashi(keyword: searchWord)
            
        }
    }
    
    //JSONのitem内のデータ構造　構造体の宣言
    //Codableは、取得したJSONを構造体に格納できるルールを持っているプロトコル
    struct ItemJson : Codable {
        //お菓子の名称
        let name: String?
        //メーカー
        let maker: String?
        //掲載URL
        let url: URL?
        //画像URL
        let image: URL?
    }
    //JSONのデータ構造
    struct ResultJson: Codable{
        let item:[ItemJson]?
    }
    //searchOkachiメソッド
    //第一引数；keyword 検索したいワード
    func searchOkashi(keyword : String){
        //お菓子の検索キーワードをURLエンコードする　引数でURLパラメーター用のエンコードを指定してる。
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        //リクエストURLの組み立て
        //リクエスト用のURLは文字列だが、URL(string- )構造体を指定して格納することで、後からプログラムでURL情報を使えるようにしている。
        //構造体はある目的を持ったデータやメソッドの集まり。URL(string-)は文字列からURL情報を分解整理して、URL構造体に格納している。
        guard let req_url = URL(string: "https://sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=r") else {
            return
        }
        print(req_url)
        
        //リクエストに必要な情報を生成
        let req = URLRequest(url: req_url)
        //データ転送を管理するためのセッションを生成 URLSessionには、バックグラウンド通信機能や、中断した通信を再開させる機能もある
        //引数　configuration: デフォルトのセッション構成を設定 delegate: nilを設定。今回はダウンロード後のデータ取り出しをクロージャで処理するため
        //delegateQueue delegateやクロージャで使うキューを指定。OperationQueue.mainとすることで、メインスレッドに対するキューを取得
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        //リクエストをタスク(実行しなければならない処理)として登録　引数　with: req リクエストを管理するオブジェクト、ダウンロード先や通信方法が指定
        //completionHandler:クロージャ。ダウンロードが完了したらクロージャが実行される。
        //クロージャの代わりにdelegateメソッドを置けば、よそのクラスで仕事させることもできる
        //completionHandlerの引数　data 取得後のデータが格納　response 通信の状態を示す状態が格納 error エラー内容が格納
        let task = session.dataTask(with: req, completionHandler: {
            (data , responce , error) in
            // セッションを終了
            session.finishTasksAndInvalidate()
            //do try catch エラーハンドリング do try catchだと、try以下の処理でエラー発生が発生するとcatch以下で例外処理を行うように切り替える
            
            do{
                //JSONDecoderのインスタンス取得
                let decoder = JSONDecoder()
                //受け取ったJSONデータをパース（解析）して格納　さっき作った構造体ResultJsonのデータ構造に合わせて、変数jsonに格納する。
                let json = try decoder.decode(ResultJson.self, from: data!)
                //print(json) tableView表示に書き換え
                //お菓子の情報が取得できているか確認
                if let items = json.item {
                    //お菓子のリストを初期化 これやらないと検索結果がテーブルの中にどんどん足されていく
                    self.okashiList.removeAll()
                    //取得しているお菓子の数だけ処理
                    for item in items {
                        if let name = item.name , let maker = item.maker, let link = item.url , let image = item.image {
                            //1つのお菓子をタプルでまとめて管理
                            let okashi = (name,maker,link,image)
                            //お菓子の配列へ追加　okashiListという配列にokashiというタプル配列が並べられてる
                            self.okashiList.append(okashi)
                            }
                    }
                    //Table Viewを更新する
                    self.tableView.reloadData()
                    
                    if let okashidbg = self.okashiList.first{
                        print("-----------------------")
                        print("okashiList[0] = \(okashidbg)")
                    }
                }
            } catch {
                //エラー処理
                print("エラーが発生しました")
            }
        })
        
        //ダウンロード開始 これがおわったらcompletionHandler内のクロージャが実行される
        task.resume()
    }
    
    //Cellの総数を返すdataSourceメソッド、必ず記述する必要がある。（Cellの個数を明示的に宣言する必要がある？）
    //tableView→dataSourceメソッド。Delegateと同じ動きでデータを引き渡せる？
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //お菓子リストの総数
        return okashiList.count
    }
    
    //Cellに値を設定するdataSourceメソッド。必ず記述する必要があります　第2引数 indexPath これから設定するセルの位置情報(行番号)などが格納されている
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //今回表示を行う、Cellオブジェクト　1行　を取得する。　dequeueReusableCellはセルを追加するdataSourceメソッド
        //withIdentifierでcell生成先のtableViewを指定、for: indexPathで位置を指定。
        //このdatasourceメソッドは、セルを生成するたびに繰り返し実行され、indexPathに都度位置情報を渡す。
        //その情報をもとにセルが設定されるので、この時点でcellは配列になっている
        let cell = tableView.dequeueReusableCell(withIdentifier: "okashiCell", for: indexPath)
        //お菓子のタイトルを設定　storyboard上 cellオブジェクト上のLabelにtextLabelプロパティが割り当てられているため、そこに名前が入る
        //indexPath.rowで、TableViewの先頭からの行番号を取得している。その数字をインデックスとしてokashiListからタプル配列を呼び出し、
        //タプル配列上　nameに相当する値を　さっき生成された配列cell.textLabelのtextプロパティに代入している。
        cell.textLabel?.text = okashiList[indexPath.row].name
        //お菓子画像を取得
        //元々のJSONに含まれるお菓子の画像はURLのみで、実際の画像ファイルはサーバー上にある。
        //そのため、Data(contentOf: okashiList[indexPath.tow].image)で画像のURLから画像ファイルをダウンロードしている
        //try？はエラーハンドリングの一つ。エラーが発生すると戻り値がnilになるオプショナル型変数。
        //正常に画像が取得できる前提で、try?とif letを使ったアンランプを組み合わせ、エラーとならないようにしている。
        //try? 以下のメソッドでエラーが起きると、戻り値nil → nil だとif let = により、try以下の処理自体をなかったことにできる。
        
        if let imageData = try? Data(contentsOf: okashiList[indexPath.row].image){
            //正常に取得できた場合は、UIImageで画像オブジェクトを生成して、Cellにお菓子画像を設定
            //Image Viewオブジェクトは、UIImageオブジェクトで設定すると画像を表示できる。
            //UIImage(data:imageData)では、画像のバイナリデータをUIImageクラスでUIImageオブジェクトに変換して、ImageView.imageに設定
            cell.imageView?.image = UIImage(data: imageData)
        }
        //設定済みのCellオブジェクトに画面を反映
        return cell
    }
    
    //Cellが選択されたときに呼び出されるdelegateメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //ハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        //SFSafariViewを開く
        let safariViewController = SFSafariViewController(url: okashiList[indexPath.row].link)
        //delegateの通知先を自分自身に設定
        safariViewController.delegate = self
        //SafariViewが開かれる
        present(safariViewController, animated: true, completion: nil)
    }
    
    
    //Safariが閉じられたときに呼ばれるDelegateメソッド
    //ちなみにこれ書かなくても普通に動いた　裏で走ってるViewControllerを閉じる？
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        //SafariViewを閉じる
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    
}

