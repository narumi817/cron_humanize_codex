---
name: docker-review
description: （開発中）DockerfileやDocker Composeの構成をMVP観点でレビューする。Dockerのレビューを依頼されたときに使用する。
---

# DockerレビューSkill

Dockerの構成をMVP（最小実用製品）の観点からレビューしてください。

以下の観点を重視してください:

- MVPに対して過剰な構成になっていないか
- docker-compose.yml が冗長ではないか
- 開発環境として最低限か
- Rails 8 + Dockerとして一般的か
- 不要な service / volume / package がないか
- build時間が長くなりすぎていないか
- 開発用途に対して過剰な本番構成になっていないか
- Rails標準やDocker標準から逸脱しすぎていないか
- 個人開発MVPとして不要な複雑化がないか
- volume構成がシンプルか

改善案を以下に分類してください:

1. must
2. should
3. nice to have

必要に応じて、よりシンプルな構成案を提案してください。

以下を重視して最適化してください:

- 保守しやすいこと
- シンプルであること
- buildが速いこと
- 個人開発で扱いやすいこと
