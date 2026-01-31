#!/bin/bash

# Obsidian Local REST API - 開発サーバー起動スクリプト

cd "$(dirname "$0")"

# 依存関係がインストールされていなければインストール
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

# 開発モードで起動
echo "Starting development mode..."
npm run dev
