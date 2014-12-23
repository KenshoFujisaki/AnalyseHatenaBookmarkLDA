AnalyseHatenaBookmarkLDA
========================
[はてブ記事を用いた興味分析](http://d.hatena.ne.jp/ni66ling/20141223/1419323806 "はてブ記事を用いた興味分析")の[LDAによるトピック解析](http://d.hatena.ne.jp/ni66ling/20141223/1419350700 "LDAによるトピック解析")のためのスクリプトです．  
事前に[データの準備](https://github.com/KenshoFujisaki/CreateHatenaBookmarkLogDB "データ準備")が完了していることを前提とします．

本スクリプトにより，はてブ記事のトピック解析結果を下のようなワードクラウドに出力できます．
![LDAによるはてブのトピック解析結果](http://cdn-ak.f.st-hatena.com/images/fotolife/n/ni66ling/20141223/20141223233507.png)  
またこの図の見方は下のとおりです．
![ワードクラウドの見方](http://cdn-ak.f.st-hatena.com/images/fotolife/n/ni66ling/20141223/20141223233511.png)

# 事前準備
MacOSX環境を前提に説明します．
##### 1. 解析対象のはてブ記事群のデータ準備
[データの準備](https://github.com/KenshoFujisaki/CreateHatenaBookmarkLogDB "データ準備")に従って，はてブ記事群をMySQLに登録します．
##### 2. LDAのインストール
[lda, a Latent Dirichlet Allocation package.](http://chasen.org/~daiti-m/dist/lda/ "lda, a Latent Dirichlet Allocation package.")の"C version"をダウンロードし，バイナリを「./LDA/lda」に配置します．
具体的には次のような手順を行います．
```
$ cd ./LDA
$ wget http://chasen.org/~daiti-m/dist/lda/lda-0.2.tar.gz
$ tar xvf lda-0.2.tar.gz 
$ cd lda-0.2
$ make
$ cp lda ../lda
$ rm -Rf lda-0.2*
```
##### 3. [d3-cloud](https://github.com/jasondavies/d3-cloud "d3-cloud")のインストール
```
$ cd ./LDA
$ git clone https://github.com/jasondavies/d3-cloud.git wordcloud
```
##### 4. wkhtmltoimageのインストール
[wkhtmltopdf](http://wkhtmltopdf.org/ "wkhtmltopdf")の「Download」からダウンロードし，インストールします．  
インストール後`$ wkhtmltoimage`が実行できれば完了です．

# 使い方
##### 1. LDAの入力ファイルの作成
```
$ cd ./LDA
$ ./mkldainput.sh > lda_input.dat
```
##### 2. LDAの実行
```
$ cd ./LDA
$ ./lda -N [number_of_topics] lda_input.dat lda_output
```
[number_of_topics]にはトピック数を指定します．例えば30など．
##### 3. LDAの実行結果（β：トピックごとの単語の分布）の可視化（ワードクラウド化）
```
$ cd ./LDA
$ ./parseBeta lda_output.beta [number_of_topics] [number_of_rankings]
```
[number_of_topics]にはトピック数を指定します．これは2.の値と一致する必要があります．  
[number_of_rankings]には出力する単語数を指定します．これはワードクラウドに表示するおおよその単語数です．例えば1000など．
##### 4. 結果の確認
結果は「./LDA/wordcloud/visualize_csv/lda_output/topic[トピック番号].png」に出力されます．  
これが上図のワードクラウドです．
