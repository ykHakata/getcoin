# NAME

getcoin - ビットコイン獲得ゲーム

# SYNOPSIS

## URL

- <http://example> - example

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

```
(リポジトリ展開用のディレクトリから作成の場合)
(例: ホームディレクト配下に github 用のディレクトリ作成)
$ mkdir ~/github

(github ディレクトリ配下に example リポジトリ展開)
$ cd ~/github
$ git clone git@github.com:ykHakata/example.git

(Perl バージョンを確認)
$ cd ~/github/example/
$ cat .perl-version
5.**.*

(cpanfile に必要なモジュール情報が記載)
$ cd ~/github/example/
$ cat cpanfile
requires 'Mojolicious' ...

(carton を使いインストール実行)
$ carton install
```

## START APP

### LOCAL

1. リポジトリの存在するディレクトリへ移動
1. mojo コマンドでアプリケーションサーバー起動
1. web ブラウザ確認
1. アプリケーションサーバー終了

事前に SETUP を参考に準備をすませてください

```
$ cd ~/github/example/

(WEBフレームワークを起動 development モード)
$ carton exec -- morbo script/example

(終了時は control + c で終了)
```

コマンドラインで morbo サーバー実行後、web ブラウザ `http://localhost:3000/` で確認

## TEST

必ずテストコードが通過するように実装してください。

```
(通常のテストコード実行)
(自動でモードが testing になるように設定している)
$ carton exec -- script/example test

(実行 mode を明示的に切り替え)
$ carton exec -- script/example test --mode testing

(テスト結果を詳細に出力)
$ carton exec -- script/example test -v --mode testing

(テスト結果を詳細かつ個別に出力)
$ carton exec -- script/example test -v --mode testing t/example.t
```

## WORK

1. ソースコード更新 github へ push
1. サーバーへ接続 github より pull
1. app サーバーを再起動

サーバーの設定詳細は `doc/deploy.md` を参考にしてください

```
(ソースコード更新後)
(全ての更新を対象)
$ git add .

(コミット内容は簡潔に)
$ git commit -m 'add auth'

(github へ反映)
$ git push origin master

(サーバーへ接続)
(ローカル環境から各自のアカウントでログイン)
$ ssh name@example.com

(もしくは)
$ ssh name@***.**.***.**

(アプリケーションユーザーに)
$ sudo su - example

(移動後 github より pull 更新)
$ cd ~/example/
$ git pull origin master

(app サーバーを再起動)
$ carton exec -- hypnotoad script/example
```

# TODO

# SEE ALSO

- <https://github.com/ykHakata/example> - github
- <https://github.com/ykHakata/summary/blob/master/perl5_install.md> - perl5_install / perl5 ローカル環境での設定手順
- <https://github.com/ykHakata/summary/blob/master/mojo_setup.md> - mojo_setup - Mojolicious の基本的なセットアップ
- <http://example> - example
- <http://example> - example
- <http://example> - example
