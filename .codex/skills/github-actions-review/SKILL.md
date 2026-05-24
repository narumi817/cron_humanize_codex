---
name: github-actions-review
description: （開発中）Gitアクションの内容をMVP観点でレビューする。Gitアクションのレビューを依頼されたときに使用する。
---

# GitHub ActionsレビューSkill

MVP（最小実用製品）向けプロジェクトのGitHub Actions workflowをレビューしてください。

以下の観点を重視してください:

- 不要なworkflowが存在しないか
- 過剰設計になっていないか
- CIの実行時間が遅すぎないか
- 重複したjobがないか
- 不要なmatrix buildを行っていないか
- 不要なデプロイ自動化が含まれていないか

以下を重視して最適化してください:

- フィードバックが速いこと
- シンプルであること
- 保守しやすいこと
- GitHub Actionsの利用を必要最小限に抑えること