# PexelsViewer

## APIキー

本プロジェクトでは、セキュリティと環境ごとの設定の柔軟性を確保するため、APIキーはxcconfigファイルで管理しています。

### 導入方法

以下のURLにアクセスし、Pexels APIキーを発行してください。

[https://www.pexels.com/api/](https://www.pexels.com/api/)

プロジェクトのConfigディレクトリ以下に、Config.xcconfigファイルを作成してください。

作成したファイルに、取得したAPIキーを以下の形式で記述してください。

```Plaintext
PEXELS_API_KEY = your_actual_api_key_here
```

## フォーマッター

本プロジェクトでは、コードの一貫性を保つため、Swiftformatを使用しています。

### 導入方法

以下のコマンドでインストールしてください。

```Bash
brew install swiftformat
```

### ルールについて

フォーマットルールは、Mirrativ社の**@fokotate**のスタイルガイドを参考にしています。

https://tech.mirrativ.stream/entry/2022/06/27/060850

💡 補足:
このルールは初期設定であり、チームの状況に応じて変更される可能性があります。