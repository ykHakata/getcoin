# NAME

getcoin - ビットコイン獲得ゲーム

## MEMO

- 2020/08/12: 開発再開の見通しがたたないため、公開サーバーの利用を中止
- 2020/10/08: google doc の資料を doc 内に追加、docker の起動を追加

## SYNOPSIS

## URL

- <http://getcoin.becom.work> - 開発用サーバー

## SETUP

### LOCAL

1. git clone
    - お手元の PC に任意のディレクトリを準備後、 github サイトよりリポジトリを取得
1. Perl
    - plenv を活用し、perl, cpanm, carton までのインストールを実行
1. Mojolicious
    - Mojolicious を始めとする必要なモジュール一式のインストール実行

事前に github の設定および SEE ALSO の `perl5_install` を参考に一連のインストールを実行してください

git リポジトリは任意のディレクトリに展開してください

```console
(リポジトリ展開用のディレクトリから作成の場合)
(例: ホームディレクト配下に github 用のディレクトリ作成)
$ mkdir ~/github

(github ディレクトリ配下に getcoin リポジトリ展開)
$ cd ~/github
$ git clone git@github.com:ykHakata/getcoin.git

(Perl バージョンを確認)
$ cd ~/github/getcoin/
$ cat .perl-version
5.**.*

(cpanfile に必要なモジュール情報が記載)
$ cd ~/github/getcoin/
$ cat cpanfile
requires 'Mojolicious' ...

(carton を使いインストール実行)
$ carton install
```

## START APP

### LOCAL_APP

1. リポジトリの存在するディレクトリへ移動
1. mojo コマンドでアプリケーションサーバー起動
1. web ブラウザ確認
1. アプリケーションサーバー終了

事前に SETUP を参考に準備をすませてください

```console
$ cd ~/github/getcoin/

(WEBフレームワークを起動 development モード)
$ carton exec -- morbo script/getcoin

(終了時は control + c で終了)
```

コマンドラインで morbo サーバー実行後、web ブラウザ `http://localhost:3000/` で確認

### DEVELOPMENT

web サーバー nginx 通常はつねに稼働中、サーバーの起動は root 権限

## TEST

必ずテストコードが通過するように実装してください。

```console
(通常のテストコード実行)
(自動でモードが testing になるように設定している)
$ carton exec -- script/getcoin test

(実行 mode を明示的に切り替え)
$ carton exec -- script/getcoin test --mode testing

(テスト結果を詳細に出力)
$ carton exec -- script/getcoin test -v --mode testing

(テスト結果を詳細かつ個別に出力)
$ carton exec -- script/getcoin test -v --mode testing t/getcoin.t
```

## WORK

1. ソースコード更新 github へ push
1. サーバーへ接続 github より pull
1. app サーバーを再起動

サーバーの設定詳細は `doc/deploy.md` を参考にしてください

```console
(ソースコード更新後)
(全ての更新を対象)
$ git add .

(コミット内容は簡潔に)
$ git commit -m 'add auth'

(github へ反映)
$ git push origin master

(サーバーへ接続)
(ローカル環境から各自のアカウントでログイン)
$ ssh kusakabe@becom.work

(もしくは)
$ ssh kusakabe@153.126.137.205

(アプリケーションユーザーに)
$ sudo su - getcoin

(移動後 github より pull 更新)
$ cd ~/getcoin/
$ git pull origin master

(app サーバーを再起動)
$ carton exec -- hypnotoad script/getcoin
```

## DOCKER

docker を使った起動について

```console
(初動のときはイメージ作成からおこなう)
docker-compose up --build

(web ブラウザで localhost:3000 で確認)

(コンテナの外からモジュールを追加したいとき Teng の場合)
echo "requires 'Teng', '0.31';" >> cpanfile
docker-compose exec web carton install

(コンテナの中に入って作業したいとき)
docker-compose exec web /bin/bash

(次回からの実行)
docker-compose up
```

docker file を作った時のメモ

```console
(docker 起動のために必要なファイル今回は ~/github/getcoin/ )
cd ~/github/getcoin/

(ファイルの中身は下記の記事参考)
touch Dockerfile docker-compose.yml compose_cmd.bash && \
chmod +x compose_cmd.bash
```

Dockerfile

```docker
FROM perl:5.26.1
RUN cpanm Carton && \
    apt-get update && \
    apt-get install -y sqlite3 && \
    mkdir -p /usr/src/app
WORKDIR /usr/src/app
```

docker-compose.yml

```docker
version: '3.7'
services:
  web:
    container_name: ctr_getcoin
    build:
      context: .
    image: img_getcoin
    volumes:
      - .:/usr/src/app
    ports:
      - '3000:3000'
    command: './compose_cmd.bash'
```

compose_cmd.bash

```bash
#!/usr/bin/env bash
carton install && \
carton exec -- morbo script/getcoin
```

## TODO

- ~~開発用の暫定確認用サーバーの準備~~
- 認証機能
  - 基本ログイン
  - 新規作成時紹介用トークンの受付
- 顧客管理機能
  - 基本管理(新規、編集、削除)
- ルーレット機能
  - ランダムな数字の出力機能
  - 数字の出力コントロール機能
  - 一定時間経過するとルーレットができる機能
- 所有コイン
  - ルーレットの出力に応じてコインを増やす、減らす
  - コインの払い出し
- 紹介用トークン発行機能
- メール送信機能
  - 新規登録時
  - パスワード変更時
  - コインの払い出し時
  - 登録解約時
- 管理画面機能
  - 管理者としての認証機能
  - 顧客管理機能
  - ルーレットの出力コントロール
  - 所有コインの管理
- 認証周りのつくりは顧客と管理者とわかれるので検討が必要
- https へ変更
- G スイート用意、gmail ドメインを貼り付け
- 公開用サーバーの準備

## SEE ALSO

- <https://github.com/ykHakata/example> - github
- <https://github.com/ykHakata/summary/blob/master/perl5_install.md> - perl5_install / perl5 ローカル環境での設定手順
- <https://github.com/ykHakata/summary/blob/master/mojo_setup.md> - mojo_setup - Mojolicious の基本的なセットアップ
- <http://example> - example
- <http://example> - example
- <http://example> - example
