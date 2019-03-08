# 第3回 開発合宿（機械学習やってみる）

## 目次
- はじめに
  - 機械学習の基礎知識
  - 合宿概要
- 強化学習編（難易度：中）
  - 概要
  - ツール
  - 実行方法
  - ソースについて
  - 今回のルール
  - 著作権保護について（念のため記載）
- 教師あり/教師なし学習編（難易度：高）
  - 概要
- 今回の順位決めについて

## はじめに
### <u>機械学習の基礎知識</u>
#### 機械学習とは
> 『機械学習（きかいがくしゅう、（英: machine learning）とは、  
人間が持つ学習にあたる仕組みを
  機械（特にコンピュータ）で実現する技術・手法の総称である。
> 
> 機械学習では、
  センサやデータベースなどに由来する**サンプルデータを入力して解析を行い、  
  そのデータから有用な規則、ルール、知識表現、判断基準などを抽出し、  
  アルゴリズムを発展させる**。 （ウィキペディア（Wikipedia））』  

つまり、機械学習の実装とは、  
データを読み込むことでアルゴリズムを作るようなプログラムを組むことであるといえる。

#### 機械学習の種類
機械学習は、データ処理の手法により、  
以下のように分類される。
- 教師あり学習　（ドワンゴ 競馬予測AI『まんば』 など）  
- 教師なし学習　（Amazon おすすめ商品 など）
- 強化学習　(Google AlphaGo など)

以下のブログがわかりやすく概要を説明している。（別配布資料にも記載）  
http://blog.brainpad.co.jp/entry/2017/02/24/121500

### <u>合宿概要</u>
今回は、  
- スーパーマリオ ワールド（実機）
    - 強化学習
- kaggle（Competitionという形で、お題と学習データがセットになってるやつ）
    - 教師あり学習
    - 教師なし学習

の２つを利用し、  
機械学習の実装を包括的に実践することで、  
AI・機械学習への理解を深めていく。

***

## 強化学習編（難易度：中）
### <u>概要</u>
SFC『スーパーマリオワールド』の実機を使って、  
強化学習で1面をクリアするロジックを作ろう。  
> 参考：スーパーマリオブラザーズを学習させてみた（1-1）  
https://www.nicovideo.jp/watch/sm18721450

### <u>ツール</u>
- 吸いだし器 (SFCのROMをカセットから吸いだす用)
- BizHawk 2.3 (エミュレータ(実行環境))
http://tasvideos.org/BizHawk/ReleaseHistory.html
- mySQL (使うか微妙)

### <u>実行方法</u>
1. 各自ROMをPCに吸い出し（詳細は取説に記載）   
    ※基盤むき出しなので接触注意
2. BizHawkを起動
3. File > Open ROMでゲームを実行
4. Tooles > Lue Console > Script > Open Scriptでmain.luaを選択
5. Toggle Scriptで実行(File選択時に自動で1回実行される)

### <u>ソースについて</u>
**main.lua**  
C言語に組み込まれることを想定したスクリプト言語**Lua**で書かれている。  
実装すべきは主にこいつのgenerateCommands()。  
デフォルトでは常にランダムな動きをするようになってる。  
頑張って可読性高くしたから、頑張って読んで。
```lua
function generateCommands(generation, number, seconds)
	marioCommand = {}
	marioCommand["A"] = math.random(0, 1) == 1
	marioCommand["B"] = math.random(0, 1) == 1
	marioCommand["X"] = math.random(0, 1) == 1
	marioCommand["Y"] = math.random(0, 1) == 1
	marioCommand["L"] = math.random(0, 1) == 1
	marioCommand["R"] = math.random(0, 1) == 1
	marioCommand["Up"] = math.random(0, 1) == 1
	marioCommand["Right"] = math.random(0, 1) == 1
	marioCommand["Down"] = math.random(0, 1) == 1
	marioCommand["Left"] = math.random(0, 1) == 1
	-- TODO ADD YOUR LOGIC
	db:insertCommands(generation,number,currentFrame/60,marioCommand)
	return marioCommand
end
```

**db.lua**  
DAO。必要あればカラムなりメソッドなり好きに足して。

**MarioTest.State**  
ゲームの状態を保存するステートセーブって機能を使う時の保存先。実態はJSONのzip。

### <u>今回のルール</u>
特に決めないが、同じ条件にするために以下のように制限を設ける。  
・memory.write禁止(read only)  
　 -> チーターは許されない。  
・MarioTest.State変更禁止  
　 -> スタートの条件はそろえよう。  
・marioCommand は math.random or db:hogehoge から得られたものだけが代入可  
　 -> 右マリオが早いに決まってんじゃん。

### <u>著作権保護について（念のため記載）</u>
今回共有するソースコードは、OSSであるBizHawkの実行時に生じるメモリ情報の一部と自作の実行ロジックのみである。  
また、ROMの吸いだしは私的な利用のみを目的として実施し、二次的な配布は一切行わない。  
この合宿は、**ネットワークサービスにおける任天堂の著作物の利用に関するガイドライン**を遵守しています。
https://www.nintendo.co.jp/networkservice_guideline/ja/index.html

***

## 教師あり/教師なし学習編（難易度：高）
### <u>概要</u>
kaggleで出題される課題のデータを使って、予測モデルを作ってみよう。  
> https://www.kaggle.com/c/titanic  

※参考資料を別途配布（あとは自力でやって）

***

## 今回の順位決めについて
今回はこれまで合宿のような対戦形式ではないため、順位付けは行わない。  
でも、**早くできた方がカッコいい**よね。
