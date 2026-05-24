# cron humanizer

## 目的

5フィールドのcron式を入力すると、日本語の説明を表示するMVP。

## 対応範囲

- `*`
- 数値
- `*/15` のような間隔
- `1-5` のような範囲

## 画面

- `/` に入力フォームを置く
- GETパラメータ `expression` で変換する
- 成功時は説明、失敗時はエラーを表示する

## 実装

- controllerは入力を受け取り、service objectへ渡すだけにする
- 変換ロジックは `CronHumanizer` に置く
- JavaScriptは使わない

## 起動

```bash
docker-compose up
```

ブラウザで `http://localhost:3001` を開く。
