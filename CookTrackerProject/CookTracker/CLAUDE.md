# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
## Gemini CLI 連携ガイド

### 目的
ユーザーが **「Geminiと相談しながら進めて」** （または同義語）と指示した場合、Claude は以降のタスクを **Gemini CLI** と協調しながら進める。
Gemini から得た回答はそのまま提示し、Claude 自身の解説・統合も付け加えることで、両エージェントの知見を融合する。

---

### トリガー
- 正規表現: `/Gemini.*相談しながら/`
- 例:
- 「Geminiと相談しながら進めて」
- 「この件、Geminiと話しつつやりましょう」

---

### 基本フロー
1. **PROMPT 生成**
Claude はユーザーの要件を 1 つのテキストにまとめ、環境変数 `$PROMPT` に格納する。

2. **Gemini CLI 呼び出し**
```bash
gemini <<EOF
$PROMPT
EOF
# cooktracker - 料理管理アプリ 要件定義書 & 開発ガイド

## 1. プロジェクト概要

### 1.1 アプリ概要
**プロジェクト名:** cooktracker  
**コンセプト:** ゲーミフィケーション要素で料理初心者の自炊を楽しくサポートするiOSアプリ

### 1.2 開発目的
20代一人暮らしの料理初心者が継続的に自炊に取り組めるよう、レシピ管理と調理記録をゲーム感覚で楽しめるアプリを提供する。

### 1.3 開発アプローチ
- **開発方針:** プロトタイプ重視
- **リリース戦略:** 段階的リリース
- **開発手法:** Claude Codeによるペアプログラミング

## 2. ターゲットユーザー

### 2.1 メインターゲット
- **年齢層:** 20代男女
- **居住形態:** 一人暮らし
- **料理レベル:** 自炊に興味を持ち始めた初心者
- **利用シーン:** 日常的な自炊での継続的な利用

## 3. 機能要件

### 3.1 レシピ管理機能

#### 3.1.1 URL登録機能
- YouTube/WebサイトのURL貼り付けによるレシピ登録
- タイトル手動入力（自動取得は将来実装）
- リンク先への遷移機能

#### 3.1.2 手動入力機能
- **必須項目:** タイトル、材料
- **任意項目:** 手順、調理時間、メモ
- **難易度設定:** 星5段階（ユーザー主観）

#### 3.1.3 分類・検索機能
- カテゴリ分け機能（初期設定：食事）
- レシピ一覧表示・検索機能

### 3.2 調理・記録機能

#### 3.2.1 調理タイマー機能
- メインタイマー：ワンボタンスタート/ストップ
- サブタイマー：複数同時実行可能（将来実装）
- バックグラウンド継続動作
- 調理時間の自動記録

#### 3.2.2 料理完了記録
- 料理写真撮影機能（最大20枚/レシピ）
- 改善メモ入力機能
- 完了時の経験値付与

#### 3.2.3 履歴管理
- 同一レシピの複数回調理履歴
- カレンダー表示での料理履歴確認
- 過去の記録詳細表示

### 3.3 ゲーミフィケーション機能

#### 3.3.1 経験値・レベルシステム
- 料理完了時に経験値付与（現段階では一律）
- レベルアップシステム
- Duolingo級のリッチなレベルアップアニメーション演出

#### 3.3.2 バッジシステム
- 連続調理バッジ
- 初回完了バッジ
- バッジ獲得時の演出

### 3.4 ユーザー管理機能

#### 3.4.1 アカウント機能
- ユーザー登録・ログイン機能（任意・初期実装では不要）
- プロフィール管理（登録時のみ）
- Supabase認証システム連携（将来対応）

#### 3.4.2 データ管理
- **未登録ユーザー:** ローカルデータ保存
- **登録ユーザー:** Supabaseデータベース連携
- データ移行機能（ローカル→クラウド）

### 3.5 通知機能

#### 3.5.1 プッシュ通知
- 調理リマインダー（前日調理時間に「今日も調理をしましょう」）
- レベルアップ・バッジ獲得通知

## 4. 非機能要件

### 4.1 技術要件

#### 4.1.1 プラットフォーム
- **対象OS:** iOS
- **最低対応バージョン:** iOS 15.0以上
- **開発言語:** Swift/SwiftUI

#### 4.1.2 バックエンド
- **データベース:** Core Data（ローカル）、Supabase（将来のクラウド同期用）
- **認証:** Supabase Auth（任意機能）
- **ストレージ:** ローカルストレージ（写真保存）、Supabase Storage（将来対応）

#### 4.1.3 パフォーマンス
- リッチアニメーション対応
- 写真最大20枚/レシピの容量管理
- バックグラウンドタイマー動作

### 4.2 デザイン要件

#### 4.2.1 デザインテイスト
- **全体テイスト:** ポップ
- **メインカラー:** パステルブラウン（美味しそうな色調）
- **アプリアイコン:** フォーク・ナイフ・お皿モチーフ

#### 4.2.2 ユーザビリティ
- 料理初心者向けの直感的なUI
- ワンボタンで簡単操作
- 継続しやすいUX設計

## 5. 画面構成・機能一覧

### 5.1 メイン画面
- **ホーム画面**
  - 現在のレベル・経験値表示
  - 最近の料理履歴
  - 今日の調理提案
  - クイックアクセスボタン

### 5.2 レシピ関連画面
- **レシピ一覧画面**
  - カテゴリ別表示
  - 検索機能
  - お気に入り表示
- **レシピ詳細画面**
  - 材料・手順表示
  - 調理開始ボタン
  - 過去の調理履歴
- **レシピ登録画面**
  - URL入力/手動入力切り替え
  - 基本情報入力フォーム

### 5.3 調理関連画面
- **調理画面**
  - メインタイマー表示
  - サブタイマー管理
  - 手順ナビゲーション
- **完了記録画面**
  - 写真撮影
  - メモ入力
  - 経験値獲得演出

### 5.4 履歴・統計画面
- **カレンダー画面**
  - 月間調理履歴
  - 連続記録表示
- **統計画面**
  - レベル・バッジ表示
  - 調理回数統計

### 5.5 設定・プロフィール画面
- **プロフィール画面**（登録ユーザーのみ）
  - ユーザー情報
  - 実績表示
- **設定画面**
  - 通知設定
  - アカウント管理（登録・ログイン）
  - データ移行オプション

## 6. データベース設計

### 6.1 主要データ構成

#### Core Data（ローカル）
**Users（ユーザー）**
```swift
- id (UUID, Primary Key)
- username (String, optional)
- level (Integer)
- experience_points (Integer)
- is_registered (Boolean)
- created_at (Date)
- updated_at (Date)
```

**Recipes（レシピ）**
```swift
- id (UUID, Primary Key)
- title (String)
- ingredients (String)
- instructions (String, optional)
- url (String, optional)
- thumbnail_url (String, optional)
- category (String)
- difficulty (Integer, 1-5)
- created_at (Date)
- updated_at (Date)
```

**CookingRecords（調理記録）**
```swift
- id (UUID, Primary Key)
- recipe_id (UUID, Foreign Key)
- cooking_time (Integer, minutes)
- photo_paths (Array of String)
- notes (String, optional)
- experience_gained (Integer)
- cooked_at (Date)
```

**Badges（バッジ）**
```swift
- id (UUID, Primary Key)
- badge_type (String)
- earned_at (Date)
```

#### Supabase（将来のクラウド同期用）
上記と同様の構造でクラウド保存対応

## 7. 将来的拡張予定

### 7.1 フェーズ2以降の機能
- サブタイマー機能（複数同時実行）
- URL自動取得機能（サムネイル・タイトル）
- ゲーミフィケーション機能拡張
- ソーシャル機能（友達との共有等）
- 難易度別経験値システム
- バッジシステム拡張
- 効果音・バイブレーション演出
- 予定管理機能
- 栄養情報表示
- 買い物リスト機能

### 7.2 運用面
- **アプリ名:** cooktracker
- **アプリアイコン:** フォーク・ナイフ・お皿モチーフ
- **分析機能:** 初期実装では不要

## 8. 開発計画

### 8.1 フェーズ1（MVP）
#### 優先度1：レシピ管理機能
- レシピ一覧画面
- レシピ詳細・編集画面
- Core Data基本実装
- URLリンク貼り付け（手動タイトル）

#### 優先度2：調理タイマー機能
- 基本タイマー画面
- メインタイマーのみ
- バックグラウンド動作

### 8.2 フェーズ2以降
- ゲーミフィケーション機能
- 履歴・統計機能
- サブタイマー機能
- URL自動取得機能
- その他将来機能

### 8.3 開発環境
- **フロントエンド:** iOS（Swift/SwiftUI）
- **ローカルデータベース:** Core Data
- **バックエンド:** Supabase（将来のクラウド同期用）
- **バージョン管理:** Git（GitHubリポジトリ作成予定）
- **開発手法:** Claude Codeによるペアプログラミング

## 9. 技術的考慮事項

### 9.1 セキュリティ
- Supabase認証による安全なユーザー管理
- 画像アップロードのセキュリティ対策
- APIアクセスの適切な権限管理

### 9.2 パフォーマンス
- 画像の適切な圧縮・リサイズ
- バックグラウンドタスクの効率的な管理
- アニメーションの最適化

### 9.3 ユーザビリティ
- 未登録ユーザーでもフル機能利用可能
- ユーザー登録への自然な導線設計
- ローカル→クラウドデータ移行の安全性
- アクセシビリティ対応

---

**要件定義完了日:** 2025年6月13日  
**承認者:** [ユーザー名]  
**作成者:** Claude (Anthropic)

この要件定義書でClaude Codeでの開発開始が可能です。追加・修正があればお知らせください。

---

# 開発ガイド (Development Guide)

## 開発環境とビルド

### プロジェクト構成
- **プロジェクト名:** CookTracker
- **開発環境:** Xcode (iOS 15.0+)
- **言語:** Swift/SwiftUI
- **データベース:** Core Data (ローカル)
- **主要フレームワーク:** SwiftUI, CoreData, UserNotifications

### ビルドとテスト
```bash
# Xcodeでプロジェクトを開く
open CookTracker.xcodeproj

# iOS Simulatorでのビルド・実行
# Xcode内で Product > Run (⌘R)

# クリーンビルド
# Xcode内で Product > Clean Build Folder (⌘⇧K)
```

### 主要ディレクトリ構成
```
CookTracker/
├── CookTrackerApp.swift          # メインアプリエントリーポイント
├── ContentView.swift             # タブビューのルート画面
├── Persistence.swift             # Core Data設定・サンプルデータ
├── CookTrackerDataModel.xcdatamodeld/ # Core Dataモデル定義
├── Models/
│   └── CookingTimer.swift        # タイマー機能のロジック
└── Views/
    ├── RecipeListView.swift      # レシピ一覧画面
    ├── RecipeDetailView.swift    # レシピ詳細画面
    ├── AddRecipeView.swift       # レシピ追加画面
    ├── EditRecipeView.swift      # レシピ編集画面
    ├── CookingTimerView.swift    # 調理タイマー画面
    ├── CookingCompletionView.swift # 調理完了記録画面
    └── RecipeSelectorView.swift  # レシピ選択画面
```

## アーキテクチャとデザインパターン

### Core Data構成
4つのメインエンティティで構成:
- **User:** ユーザー情報（レベル、経験値）
- **Recipe:** レシピ情報（タイトル、材料、手順、難易度）
- **CookingRecord:** 調理記録（時間、写真、メモ、獲得経験値）
- **Badge:** バッジ情報（種類、取得日時）

### SwiftUIアーキテクチャ
- **@StateObject/@ObservedObject:** CookingTimerクラスでタイマー状態管理
- **@FetchRequest:** Core Dataからのリアルタイムデータ取得
- **@Environment(\.managedObjectContext):** Core Data操作
- **Sheet Navigation:** モーダル画面遷移（レシピ追加・編集・完了記録）

### 重要な実装パターン

#### Core Data操作
```swift
// データ取得
@FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.updatedAt, ascending: false)],
    animation: .default)
private var recipes: FetchedResults<Recipe>

// データ保存
do {
    try viewContext.save()
} catch {
    let nsError = error as NSError
    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
}
```

#### タイマー機能
- `CookingTimer`クラスが`ObservableObject`プロトコルを実装
- バックグラウンド動作対応（UserNotifications使用）
- リアルタイム進捗表示（1秒間隔の Timer）

## 開発時の注意事項

### データモデル変更
Core Data モデル（CookTrackerDataModel.xcdatamodeld）を変更する場合：
1. Xcodeでデータモデルファイルを開く
2. エンティティ・属性を編集
3. モデルバージョンの管理が必要な場合は新バージョンを作成

### 画像保存
- 現在は写真パスの保存のみ実装（photoPaths属性）
- 実際の画像保存機能は今後実装予定
- 最大20枚/レシピの制限を考慮

### パフォーマンス考慮
- レシピ検索: `localizedCaseInsensitiveContains`での部分一致検索
- タイマー: `objectWillChange.send()`での効率的な UI 更新
- アニメーション: `.animation(.easeInOut(duration: 1), value: timer.progress)`

### 多言語対応
- UI文字列は日本語で実装
- ハードコードされた文字列多数（将来的にLocalizable.stringsへの移行検討）

## 今後の実装予定機能

### フェーズ1（✅ 完了済み）
- [x] **基盤構築**: タブビュー・ホーム画面
- [x] **レシピCRUD機能**: 一覧・検索・追加・詳細表示
- [x] **基本タイマー機能**: バックグラウンド対応・通知機能

### フェーズ2（📋 実装予定）
- [ ] 調理完了記録機能（写真撮影・メモ）
- [ ] Core Data統合（データ永続化）
- [ ] 経験値・レベルシステム
- [ ] 履歴・統計画面

### フェーズ2以降
- サブタイマー機能
- URL自動取得機能
- ゲーミフィケーション機能拡張
- Supabase連携（クラウド同期）

## トラブルシューティング

### よくある問題
1. **Core Dataエラー:** Persistence.swiftのサンプルデータ作成時のエラー
2. **タイマーバックグラウンド動作:** UserNotifications権限が必要
3. **プレビュー表示:** PersistenceController.previewの利用

### デバッグヒント
- Core Dataデバッグ: `-com.apple.CoreData.SQLDebug 1` をスキーム引数に追加
- タイマー動作確認: シミュレーターでのバックグラウンド切り替えテスト
