# Obsidian用ローカルREST API

インタラクティブなドキュメントはこちら: https://coddingtonbear.github.io/obsidian-local-rest-api/

ノートの操作を自動化したいと思ったことはありませんか？このプラグインはObsidianにREST APIを提供し、他のツールからノートを操作できるようにすることで、必要な自動化を実現できます。

このプラグインは、APIキー認証で保護された安全なHTTPSインターフェースを提供し、以下のことが可能です:

- 既存のノートの読み取り、作成、更新、削除。ノートの特定のセクションにコンテンツを挿入するための`PATCH` HTTPメソッドも用意されています。
- Vault内に保存されているノートの一覧表示。
- 定期ノート（デイリーノートなど）の作成と取得。
- コマンドの実行と利用可能なコマンドの一覧表示。

これは、[Obsidian Web](https://chrome.google.com/webstore/detail/obsidian-web/edoacekkjanmingkbkgjndndibhkegad)のようなブラウザ拡張機能からObsidianを操作する必要がある場合に特に便利です。

## インストール方法

### コミュニティプラグインからインストール

1. Obsidianを開き、**設定** → **コミュニティプラグイン** に移動
2. **閲覧** をクリックし、「Local REST API」を検索
3. **インストール** をクリックし、その後 **有効化** をクリック

### 手動インストール

1. [リリースページ](https://github.com/coddingtonbear/obsidian-local-rest-api/releases)から最新の`main.js`、`manifest.json`、`styles.css`をダウンロード
2. Vaultのプラグインフォルダにファイルをコピー（下記参照）
3. Obsidianを再起動し、**設定** → **コミュニティプラグイン** でプラグインを有効化

#### Vaultフォルダとは

**Vault（保管庫）** は、Obsidianでノートを保存しているフォルダのことです。Obsidianを初めて起動したときに選択または作成したフォルダがVaultです。

プラグインのインストール先は以下の場所になります:

```
[Vaultフォルダ]/.obsidian/plugins/obsidian-local-rest-api/
```

#### Vaultフォルダの場所を確認する方法

1. Obsidianを開く
2. 左下の **設定（歯車アイコン）** をクリック
3. **ファイルとリンク** を選択
4. 一番上に表示されている「保管庫のパス」がVaultフォルダの場所

#### 具体例

| OS | Vaultの場所の例 | プラグインのインストール先 |
|----|----------------|--------------------------|
| Windows | `D:\MyNotes` | `D:\MyNotes\.obsidian\plugins\obsidian-local-rest-api\` |
| macOS | `/Users/username/Documents/MyVault` | `/Users/username/Documents/MyVault/.obsidian/plugins/obsidian-local-rest-api/` |
| Linux | `/home/username/obsidian-vault` | `/home/username/obsidian-vault/.obsidian/plugins/obsidian-local-rest-api/` |

> **注意**: `.obsidian`フォルダは隠しフォルダです。Windowsではエクスプローラーの「表示」→「隠しファイル」を有効に、macOS/Linuxでは`Cmd+Shift+.`または`ls -a`コマンドで表示できます。

## 設定

プラグインを有効化したら、**設定** → **Local REST API** で以下の設定を確認できます:

| 設定項目 | デフォルト値 | 説明 |
|---------|-------------|------|
| HTTPSポート | 27124 | セキュアなHTTPS接続用ポート |
| HTTPポート | 27123 | 非セキュアなHTTP接続用ポート（デフォルトで無効） |
| APIキー | 自動生成 | API認証に使用するキー |

### APIキーの取得

1. **設定** → **Local REST API** を開く
2. 表示されている**APIキー**をコピー
3. このキーをAPIリクエストの`Authorization`ヘッダーに使用

## 使用方法

### 基本的なAPIリクエスト

```bash
# ノート一覧を取得
curl -k -H "Authorization: Bearer YOUR_API_KEY" \
  https://127.0.0.1:27124/vault/

# 特定のノートを取得
curl -k -H "Authorization: Bearer YOUR_API_KEY" \
  https://127.0.0.1:27124/vault/path/to/note.md

# 新しいノートを作成
curl -k -X PUT \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: text/markdown" \
  -d "# 新しいノート\n\nこれはテストです。" \
  https://127.0.0.1:27124/vault/new-note.md
```

### HTTPS証明書について

このプラグインは自己署名証明書を使用してHTTPS通信を行います。curlでは`-k`オプションを使用して証明書の検証をスキップできます。

証明書をシステムにインストールする場合は、プラグイン設定画面から証明書をダウンロードできます。

## Claude Desktopから接続する

Claude DesktopはMCP（Model Context Protocol）を使って外部ツールと連携できます。[obsidian-mcp](https://github.com/smithery-ai/obsidian-mcp)サーバーを使用することで、Claude DesktopからObsidianのノートを直接操作できるようになります。

### 前提条件

- Obsidianで**Local REST API**プラグインが有効化されていること
- **Node.js**がインストールされていること
- **Claude Desktop**がインストールされていること

### 設定手順

#### 1. APIキーを確認

Obsidianの**設定** → **Local REST API**でAPIキーを確認してください。

#### 2. Claude Desktopの設定ファイルを編集

設定ファイルの場所:

| OS | 設定ファイルのパス |
|----|-------------------|
| Windows | `%APPDATA%\Claude\claude_desktop_config.json` |
| macOS | `~/Library/Application Support/Claude/claude_desktop_config.json` |

#### 3. MCP設定を追加

`claude_desktop_config.json`に以下の設定を追加します:

```json
{
  "mcpServers": {
    "obsidian": {
      "command": "npx",
      "args": [
        "-y",
        "obsidian-mcp",
        "https://127.0.0.1:27124",
        "YOUR_API_KEY"
      ]
    }
  }
}
```

> **注意**: `YOUR_API_KEY`を実際のAPIキーに置き換えてください。

#### 4. Claude Desktopを再起動

設定を保存してClaude Desktopを再起動すると、Obsidianとの連携が有効になります。

### 使用例

Claude Desktopで以下のような指示ができるようになります:

- 「Obsidianのノート一覧を見せて」
- 「今日のデイリーノートを作成して」
- 「プロジェクトAのノートに新しいタスクを追加して」
- 「昨日のメモを要約して」

### トラブルシューティング

| 問題 | 解決方法 |
|------|---------|
| 接続できない | Obsidianが起動しているか確認 |
| 認証エラー | APIキーが正しいか確認 |
| MCPサーバーが見つからない | `npx obsidian-mcp --help`で動作確認 |
| 証明書エラー | 自己署名証明書の警告は正常（内部通信のため） |

## クレジット

このプラグインは[Vinzent03](https://github.com/Vinzent03)氏の[advanced-uriプラグイン](https://github.com/Vinzent03/obsidian-advanced-uri)に触発されて開発されました。カスタムURLスキームの制限を超えた自動化オプションの拡張を目指しています。
