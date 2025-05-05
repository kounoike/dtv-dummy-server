# dtv-dummy-server

recpt1 などのコマンドの代わりに [TSDuck](https://tsduck.io/) を使用して、TS ファイルを mirakurun or mirakcに食わせる設定を自動生成する Docker イメージです。

## 使い方

```yaml:compose.yaml
services:
  mirakurun:
    image: ghcr.io/kounoike/dtv-dummy-server/mirakurun:latest
    volumes:
      - ./data:/data
    ports:
      - "40772:40772"
    env_file: .env
    environment:
      - UPLINK_URL=http://uplink-mirakurun-server.local:40772
      - TZ=Asia/Tokyo

  mirakc:
    image: ghcr.io/kounoike/dtv-dummy-server/mirakc:latest
    volumes:
      - ./data:/data
    ports:
      - "41772:40772"
    env_file: .env
    environment:
      - UPLINK_URL=http://uplink-mirakurun-server.local:40772
      - RUST_LOG=info
      - TZ=Asia/Tokyo
```

のように、適当なディレクトリを `/data` としてマウントします。

## 上流設定

環境変数 `UPLINK_URL` としてを mirakurun or mirakc サーバ指定すると、そのサーバと HTTP で取得する設定を自動的に生成します。
後述のファイル出力のためにチャンネルタイプ SKY を空けるため、GR のチャンネルのみを取得します。
環境変数を設定しない場合は生成しません。

## ファイル読み込み

`/data` 直下に `*.ts` ファイルを置くと仮想的なチャンネルを生成します。

- ファイル名の `.ts` を除いた部分がチャンネル名となります
- チューナーを開くとファイルの最初から読み込みます
- 番組表データは `/data/eit.xml` から読み込みます

## TS ファイル生成

`ts_gen.sh` を実行すると ffmpeg を使ってプログレッシブ・インターレース・テレシネのサンプル映像を生成します。
詳しくはシェルスクリプトを読んでください。

## eit.xml 生成

`python event_gen.py > data/eit.xml` で適当な番組表を生成します。
スクリプトは今のところ適当なので、必要に応じて修正してください。

`eit.xml` の書き方は[この辺](https://github.com/tsduck/tsduck/blob/master/src/libtsduck/dtv/tables/dvb/tsEIT.xml)を参考にしてください。

## TODO

- 番組表生成スクリプトをもっと便利にする
    - 現在の日付から何日分生成、みたいにする
    - 生成する番組データをテンプレートで設定出来るようにする
    - 必要なチャンネル数分生成する
        - （生成しすぎるとエラーになったりするため）
    - 番組生成方法を設定可能にする（例: 設定ファイルで何分番組を繰り返すかとか設定できるように）
- 再生ループに対応する
    - TSDuck の読み込み時は無限ループするようにしているが、PCR などが整合取れていないため再生出来なくなる
