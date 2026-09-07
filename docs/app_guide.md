# Kakeibo アプリ コード解説ガイド

> **この文書の対象読者**  
> JavaとPythonの基本文法は知っているが、Flutter/Dart/Riverpod/Driftは初めての方。  
> 「エラーが起きたとき、どのファイルを見ればよいか」が分かるようになることを目標とします。

---

## 目次

- [第0章　複式簿記の基礎知識](#第0章　複式簿記の基礎知識)
- [第1章　はじめに・技術スタック](#第1章　はじめに技術スタック)
- [第2章　Dart文法早見表](#第2章　dart文法早見表)
- [第3章　フォルダ構成](#第3章　フォルダ構成)
- [第4章　アプリの全体的な流れ](#第4章　アプリの全体的な流れ)
- [第5章　Widgetの仕組み](#第5章　widgetの仕組み)
- [第6章　data層の説明](#第6章　data層の説明)
- [第7章　domain層の説明](#第7章　domain層の説明)
- [第8章　presentation層 — Providers](#第8章　presentation層--providers)
- [第9章　presentation層 — 各画面](#第9章　presentation層--各画面)
- [第10章　エラー対処法](#第10章　エラー対処法)

---

# 第0章　複式簿記の基礎知識

コードを読む前に、このアプリが扱う「複式簿記」の概念を理解しておく必要があります。  
ここを飛ばすと、変数名の意味が全く分からなくなります。

## 0.1 複式簿記とは

家計の取引を「お金の出どころ（貸方）」と「お金の行き先（借方）」の**2箇所に同時に記録**する仕組みです。  
普通の家計簿（単式簿記）が「食費 -1,000円」と1箇所に書くのに対し、  
複式簿記は「食費 +1,000円 ／ 現金 -1,000円」と2箇所に書きます。

これにより、**何にいくら使ったか**（損益）と**今いくら持っているか**（残高）を同時に把握できます。

## 0.2 借方・貸方（Debit・Credit）

| 用語 | 英語 | 仕訳上の位置 | 意味 |
|------|------|-------------|------|
| 借方 | Debit  | 左側 | お金の「行き先」 |
| 貸方 | Credit | 右側 | お金の「出どころ」 |

**例：スーパーで1,000円の食料品を現金で買った**

| 借方（左）      | 貸方（右）  |
|----------------|------------|
| 食費 1,000円   | 現金 1,000円 |

コード上では `entryTypeIndex: 0` が借方、`entryTypeIndex: 1` が貸方です。

## 0.3 勘定科目グループ（AccountGroup）

このアプリでは勘定科目を5つのグループに分類しています。

| グループ | 英語 | コード上の値 | 増える方向 | どちらの表に出るか |
|---------|------|------------|----------|-----------------|
| 資産 | asset | 0 | 借方（左） | 貸借対照表（B/S） |
| 負債 | liability | 1 | 貸方（右） | 貸借対照表（B/S） |
| 純資産 | equity | 2 | 貸方（右） | 貸借対照表（B/S） |
| 費用 | expense | 3 | 借方（左） | 損益計算書（P/L） |
| 収益 | revenue | 4 | 貸方（右） | 損益計算書（P/L） |

**`normallyDebit`（借方正常）という概念**  
「資産」と「費用」は借方に記録すると残高が増える → `normallyDebit = true`  
「負債」「純資産」「収益」は貸方に記録すると残高が増える → `normallyDebit = false`

これがコード中に頻出する `g.normallyDebit ? raw : -raw` の意味です。  
DBには「借方合計 - 貸方合計」が生の値（`raw`）として入っていますが、  
負債・収益は貸方が増加方向なので、符号を反転（`-raw`）することで「残高」に変換しています。

## 0.4 貸借対照表（B/S）と損益計算書（P/L）

**貸借対照表（Balance Sheet）**：ある時点での財産状況  
```
資産 = 負債 + 純資産 + 当期純利益
```

**損益計算書（Profit & Loss）**：ある期間の収支  
```
当期純利益 = 収益 - 費用
```

---

# 第1章　はじめに・技術スタック

## 1.1 使用している技術

| 技術 | 役割 | Pythonで例えると |
|------|------|----------------|
| **Dart** | プログラミング言語 | Python自体 |
| **Flutter** | UI フレームワーク | Tkinter / PyQtのようなもの |
| **Riverpod** | 状態管理ライブラリ | グローバル変数を安全に管理するしくみ |
| **Drift** | データベースライブラリ | SQLAlchemy（ORM）のようなもの |

## 1.2 pubspec.yaml のパッケージ一覧

`pubspec.yaml` はPythonの `requirements.txt` に相当します。使用中のパッケージの役割：

```yaml
dependencies:
  flutter_riverpod: ^2.6.1   # 状態管理。画面とデータをつなぐ
  riverpod_annotation: ^2.6.1 # Riverpodのコード生成用アノテーション

  drift: ^2.23.1              # SQLite ORM。テーブル定義・クエリを書く
  drift_flutter: ^0.2.4       # FlutterでDriftを使うためのアダプター
  sqlite3_flutter_libs: ^0.5.31 # SQLiteのネイティブライブラリ

  intl: ^0.20.2               # 日付・数値のフォーマット（例: "2024年1月"）
  uuid: ^4.5.1                # ユニークID生成（仕訳IDに使用）
  path: ^1.9.0                # ファイルパス操作
  path_provider: ^2.1.5       # スマホのファイル保存場所を取得

  fl_chart: ^0.70.2           # グラフ描画（棒グラフ・円グラフ）
  share_plus: ^10.1.4         # ファイル共有（CSVエクスポート）
  csv: ^6.0.0                 # CSV形式への変換

dev_dependencies:
  build_runner: ^2.4.14       # コード自動生成ツール（.g.dartを生成する）
  drift_dev: ^2.23.1          # Drift用コード生成
  riverpod_generator: ^2.6.4  # Riverpod用コード生成
```

> **`dev_dependencies` とは**  
> 開発時にのみ必要なパッケージ（実際のアプリには含まれない）。  
> Pythonで言うと `pytest` や `mypy` のようなもの。

---

# 第2章　Dart文法早見表

JavaとPythonと比べながらDartの文法を説明します。

## 2.1 変数・型宣言

```dart
// Dart
int age = 25;            // 型を明示（Javaと同じ）
var name = 'Taro';       // 型推論（Pythonと同じ感覚）
final score = 100;       // 再代入不可（Javaのfinalに近い）
const PI = 3.14;         // コンパイル時定数（値がビルド前に決まる）
```

```java
// Java との比較
int age = 25;
String name = "Taro";
final int score = 100;
static final double PI = 3.14;
```

```python
# Python との比較
age: int = 25
name = "Taro"
score = 100        # Pythonにはfinal相当なし
PI = 3.14
```

**`final` と `const` の違い（重要）**
- `final`：実行時に一度だけ代入される。アプリ起動後に決まる値に使う
- `const`：コンパイル時（ビルド時）に決まる定数。`const SizedBox()` のようにWidgetでよく使う

## 2.2 null安全（Dart特有の重要機能）

Dartは変数が `null` を持てるかどうかを型で区別します。

```dart
String name = 'Taro';    // nullを持てない（nullを代入するとコンパイルエラー）
String? name = null;     // ?をつけるとnullを持てる

// null合体演算子（Pythonの "or" に近い）
String display = name ?? '名前なし';  // nameがnullなら'名前なし'を使う

// null条件演算子
int? length = name?.length;  // nameがnullならlengthもnull（エラーにならない）

// nullチェック後の強制アクセス
if (name != null) {
  print(name.length);  // このブロック内ではnullでないと保証される
}

// !（強制アンラップ）: nullでないと確信があるとき
print(name!.length);  // nameがnullだとクラッシュ。多用は危険
```

## 2.3 関数・アロー関数

```dart
// 通常の関数（Javaと同じ形式）
int add(int a, int b) {
  return a + b;
}

// アロー関数（1行で書ける省略形）
int add(int a, int b) => a + b;

// 名前付き引数（Pythonのキーワード引数に近い）
void greet({required String name, int age = 0}) {
  print('$name, $age歳');
}
greet(name: 'Taro', age: 25);  // 呼び出し時も名前をつける

// 無名関数（ラムダ）
final double Function(double) square = (x) => x * x;
```

**このアプリでの頻出パターン**
```dart
// Providerに渡す関数（引数なしの非同期関数）
final deleteAccountProvider = Provider<Future<void> Function(Account)>((ref) {
  //                                    ↑この型が「Accountを受け取りFutureを返す関数」
  final db = ref.watch(databaseProvider);
  return (account) async {   // ← これが実際の関数
    await db.accountsDao.deleteAccount(account.id);
  };
});
```

## 2.4 クラス・継承・ミックスイン

```dart
// 基本的なクラス（Javaとほぼ同じ）
class Person {
  final String name;  // フィールド
  int age;

  Person({required this.name, this.age = 0});  // コンストラクタ
}

// 継承
class Student extends Person {
  String school;
  Student({required super.name, required this.school});
}

// ミックスイン（with）: Javaのinterfaceのdefaultメソッドに近い
// 複数のクラスに同じ機能を追加する仕組み
mixin Flyable {
  void fly() => print('飛ぶ');
}
class Bird extends Animal with Flyable {}

// このアプリでの例
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
//   ↑ DatabaseAccessorを継承   ↑ 自動生成コードのミックスインを組み込む
```

## 2.5 非同期処理（async / await / Future / Stream）

```dart
// Future: 「将来完了する処理の結果」（Pythonのasyncio.coroutineに近い）
Future<String> fetchData() async {
  await Future.delayed(Duration(seconds: 1));  // 1秒待つ
  return 'データ';
}

// 使う側
void main() async {
  String result = await fetchData();  // 完了まで待つ
  print(result);
}

// Stream: 「継続的に流れてくるデータ」（Pythonのgeneratorに近い）
Stream<int> countUp() async* {
  for (int i = 0; i < 3; i++) {
    yield i;  // データを1つずつ流す
    await Future.delayed(Duration(seconds: 1));
  }
}
```

**このアプリでの使い方**
- `Future` → DBへの書き込み・読み取り（一度だけ実行）
- `Stream` → DBの変更を監視（データが変わるたびに自動更新）

```dart
// StreamProvider: DBが更新されるたびに画面が自動更新される
final accountsStreamProvider = StreamProvider<List<Account>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.accountsDao.watchAllAccounts();  // watchが「監視」の意味
});
```

## 2.6 コレクション操作

```dart
final numbers = [1, 2, 3, 4, 5];

// where（Pythonのfilterに相当）
final evens = numbers.where((n) => n % 2 == 0).toList(); // [2, 4]

// map（Pythonのmapに相当）
final doubled = numbers.map((n) => n * 2).toList(); // [2, 4, 6, 8, 10]

// fold（Pythonのreduceに相当）
final sum = numbers.fold(0.0, (acc, n) => acc + n); // 15.0
//                       ↑初期値  ↑accが累積値, nが現在の要素

// firstOrNull（Pythonのnextにtry/catchをかけたもの）
final first = numbers.where((n) => n > 3).firstOrNull; // 4 (なければnull)

// スプレッド演算子（リストの展開）
final a = [1, 2];
final b = [0, ...a, 3]; // [0, 1, 2, 3]

// スプレッドをifで条件付きに使う（FlutterのWidget列挙でよく使う）
final items = [
  'りんご',
  if (isLoggedIn) 'マイページ',  // 条件が真のときだけ追加
  ...extraItems,                 // リストを展開して追加
];
```

## 2.7 Flutterならではの書き方

```dart
// Widgetのネスト（UIの入れ子構造）
// HTMLのタグのネストと同じ考え方
Widget build(BuildContext context) {
  return Scaffold(          // 画面の骨格
    appBar: AppBar(         // 上部バー
      title: Text('タイトル'),
    ),
    body: Column(           // 縦並びのコンテナ
      children: [
        Text('テキスト1'),
        const SizedBox(height: 8),  // 余白
        Text('テキスト2'),
      ],
    ),
  );
}

// constコンストラクタ: 値が変わらないWidgetに付ける（パフォーマンス最適化）
const Text('固定テキスト')  // ← constOK（文字列が変わらない）
Text(variableText)         // ← constNG（変数を使っている）
```

## 2.8 part / part of（.g.dartファイルの仕組み）

```dart
// app_database.dart の先頭
part 'app_database.g.dart';  // このファイルの「一部」として .g.dart を取り込む

// app_database.g.dart の先頭（自動生成ファイル）
part of 'app_database.dart'; // 「app_database.dartの一部」であることを宣言
```

`part` / `part of` は「1つのファイルを複数のファイルに分割して書く」仕組みです。  
`.g.dart` ファイルは `build_runner` が自動生成します。  

> ⚠️ **`.g.dart` ファイルは絶対に手動編集してはいけません**  
> 次回 `build_runner` を実行すると上書きされて変更が消えます。

**`build_runner` を実行するタイミング**
- テーブル定義（`app_database.dart`）を変更したとき
- 新しいDAOを追加したとき
- Riverpodのコード生成（`@riverpod`アノテーション）を使ったとき

実行コマンド：
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

# 第3章　フォルダ構成

## 3.1 全体マップ

```
Kakeibo/
├── lib/                        ← アプリのソースコード（ここがメイン）
│   ├── main.dart               ← アプリの起動点
│   ├── app.dart                ← アプリの設定（テーマ・言語）
│   │
│   ├── data/                   ← 【data層】DBの定義・操作
│   │   └── database/
│   │       ├── app_database.dart    ← テーブル定義・DB設定
│   │       ├── app_database.g.dart  ← 自動生成（触らない）
│   │       └── daos/               ← Data Access Objects（DB操作クラス）
│   │           ├── accounts_dao.dart
│   │           ├── accounts_dao.g.dart    ← 自動生成
│   │           ├── transactions_dao.dart
│   │           ├── transactions_dao.g.dart ← 自動生成
│   │           ├── recurring_dao.dart
│   │           └── recurring_dao.g.dart   ← 自動生成
│   │
│   ├── domain/                 ← 【domain層】ビジネスロジック
│   │   ├── enums/
│   │   │   ├── account_group.dart  ← 勘定科目グループの列挙型
│   │   │   └── entry_type.dart     ← 借方・貸方の列挙型
│   │   └── services/
│   │       ├── ledger_service.dart     ← 複式簿記の変換ロジック
│   │       ├── csv_export_service.dart ← CSVエクスポート
│   │       └── recurring_service.dart  ← 定期取引の自動処理
│   │
│   └── presentation/           ← 【presentation層】UI関連
│       ├── providers/          ← データの状態管理（Riverpod）
│       │   ├── database_provider.dart
│       │   ├── accounts_provider.dart
│       │   ├── transactions_provider.dart
│       │   ├── reports_provider.dart
│       │   └── recurring_provider.dart
│       │
│       ├── screens/            ← 各画面
│       │   ├── main_scaffold.dart       ← アプリ全体の骨格画面
│       │   ├── home/
│       │   │   └── home_screen.dart     ← ホーム画面
│       │   ├── input/
│       │   │   └── input_screen.dart    ← 仕訳入力画面
│       │   ├── reports/
│       │   │   └── reports_screen.dart  ← 決算レポート画面
│       │   ├── accounts/
│       │   │   └── accounts_screen.dart ← 勘定科目管理画面
│       │   ├── search/
│       │   │   └── search_screen.dart   ← 検索画面
│       │   ├── recurring/
│       │   │   └── recurring_rules_screen.dart ← 定期取引管理
│       │   └── setup/
│       │       └── initial_balance_screen.dart ← 初期残高設定
│       │
│       └── widgets/            ← 複数の画面で使い回す部品
│           ├── amount_text.dart         ← 金額表示ウィジェット
│           └── transaction_list_tile.dart ← 仕訳一覧の1行
│
├── android/                    ← Android固有の設定（基本触らない）
├── docs/                       ← このドキュメント
└── pubspec.yaml                ← パッケージ管理ファイル
```

## 3.2 3層構造の意味

このアプリは **data / domain / presentation** の3層に分けています。  
これは「関心の分離」という設計思想です。

```
presentation（UI）
    ↕ データを要求・受け取る
domain（ビジネスロジック）
    ↕ データを変換・計算する
data（DB）
    ↕ データを保存・取得する
```

**なぜ分けるか**：画面の見た目を変えたいときにDBのコードを触らなくて済む。  
逆に、DBの構造を変えても画面のコードへの影響を最小限にできる。

**エラー発生時の当たりのつけ方**：
- 画面が崩れる → `presentation/screens/` を見る
- データが保存されない → `data/daos/` を見る
- 計算結果がおかしい → `domain/services/` または `presentation/providers/` を見る

---

# 第4章　アプリの全体的な流れ

## 4.1 アプリ起動から画面表示まで

```
main.dart
  └─ ProviderScope  ← Riverpodの全Providerを管理するルートWidget
       └─ SimpleLedgerApp (app.dart)
            └─ MaterialApp  ← Flutterアプリの設定（テーマ・言語など）
                 └─ MainScaffold (main_scaffold.dart)
                      └─ Scaffold  ← 画面の骨格（AppBar + body + BottomNav）
                           ├─ HomeScreen     ← タブ0
                           ├─ ReportsScreen  ← タブ1
                           └─ AccountsScreen ← タブ2
```

**`main.dart` の全文**
```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Flutterエンジンの初期化
  runApp(
    const ProviderScope(   // Riverpodのルート。全Providerはここで管理される
      child: SimpleLedgerApp(),
    ),
  );
}
```

`ProviderScope` がないとRiverpodのProviderが使えません。  
エラー「ProviderContainer was not found」が出たらここを疑います。

## 4.2 データの流れ（画面表示時）

```
1. 画面（Screen）が ref.watch(xxxProvider) でProviderを監視
      ↓
2. Provider が databaseProvider（DBの参照）を取得
      ↓
3. Provider が DAO のメソッド（watchAllAccounts など）を呼ぶ
      ↓
4. DAO が Drift（SQLiteライブラリ）を使ってDBにクエリを発行
      ↓
5. DBからデータが返ってくる
      ↓
6. Providerがデータを整形して画面に渡す
      ↓
7. 画面がデータを表示する
```

**具体例（勘定科目一覧の表示）**
```dart
// accounts_screen.dart（画面）
final accountsAsync = ref.watch(accountsStreamProvider);
// ↑ このStreamProviderを監視。データが変わると自動で画面が再描画される

// accounts_provider.dart（Provider）
final accountsStreamProvider = StreamProvider<List<Account>>((ref) {
  final db = ref.watch(databaseProvider);  // DBの参照を取得
  return db.accountsDao.watchAllAccounts(); // DAOのメソッドを呼ぶ
});

// accounts_dao.dart（DAO）
Stream<List<Account>> watchAllAccounts() {
  return (select(accounts)           // accountsテーブルを選択
        ..orderBy([...]))            // 並び順を指定
      .watch();                      // 監視モード（変化があるたびにStreamに流す）
}
```

## 4.3 ユーザー操作の流れ（データ書き込み時）

```
1. ユーザーが画面でボタンを押す
      ↓
2. 画面が ref.read(xxxProvider) でProviderの「関数」を取得して実行
      ↓
3. Provider内の関数がDAOのメソッド（insert, update, deleteなど）を呼ぶ
      ↓
4. DAOがDBに書き込む
      ↓
5. StreamProviderが変化を検知して自動的に画面を更新
```

> **`ref.watch` と `ref.read` の違い**  
> - `ref.watch`: Providerの変化を「監視」する。値が変わると画面が再描画される。`build()` メソッド内で使う  
> - `ref.read`: Providerを一度だけ「読む」。再描画は起きない。ボタン押下などのイベント内で使う

## 4.4 画面遷移（Navigator）

Flutterでは画面遷移を「スタック（積み重ね）」で管理します。  
Webブラウザの「戻る」ボタンと同じ考え方です。

```dart
// 新しい画面を開く（「プッシュ」= スタックに積む）
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const InputScreen()),
);
// → InputScreenが前面に表示される

// 現在の画面を閉じて戻る（「ポップ」= スタックから取り出す）
Navigator.pop(context);

// ダイアログを開いて結果を受け取る
final result = await showDialog<bool>(
  context: context,
  builder: (ctx) => AlertDialog(...),
);
// resultにはダイアログで選んだ値（true/false）が入る
```

**`context` について**  
`BuildContext`（通称 `context`）は「今この画面がアプリのどこにいるか」の位置情報です。  
`Navigator.push(context, ...)` では「この`context`の位置から新しい画面を開く」という意味になります。

---

# 第5章　Widgetの仕組み

## 5.1 Widgetとは

Flutterでは画面上のあらゆる要素が「Widget」です。  
テキスト、ボタン、余白、行、列……すべてWidgetです。  
WidgetをHTMLのタグのように入れ子にして画面を作ります。

```dart
Column(              // 縦に並べるWidget（HTMLの<div style="flex-direction:column">に近い）
  children: [
    Text('タイトル'),         // テキストWidget
    SizedBox(height: 8),     // 余白Widget
    ElevatedButton(          // ボタンWidget
      onPressed: () {},
      child: Text('押して'),
    ),
  ],
)
```

## 5.2 4種類のWidget（このアプリで使われているもの）

### ① StatelessWidget（状態を持たないWidget）

```dart
class MyText extends StatelessWidget {
  final String text;          // 外から受け取る値
  const MyText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text);        // 毎回同じものを表示するだけ
  }
}
```

**使いどころ**：表示だけで、内部に変化する状態がないWidget。  
このアプリでは `_AccountRow`、`_SectionHeader`、`AmountText` などが該当。

### ② StatefulWidget（状態を持つWidget）

```dart
class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
  // ↑ 「状態」を管理するStateクラスを生成する
}

class _CounterState extends State<Counter> {
  int _count = 0;  // ← これが「状態」。変化するデータ

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$_count'),
        ElevatedButton(
          onPressed: () {
            setState(() {       // setState内で状態を変えると画面が再描画される
              _count++;
            });
          },
          child: Text('増やす'),
        ),
      ],
    );
  }
}
```

**使いどころ**：`TextField` のテキストや、ドロップダウンの選択値など、  
「この画面の中だけで変化する状態」を持つWidget。

### ③ ConsumerWidget（Riverpodを使えるStatelessWidget）

```dart
class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //                                        ↑ refが追加される（Providerにアクセスするため）
    final accounts = ref.watch(accountsStreamProvider);
    return ListView(...);
  }
}
```

**使いどころ**：DBのデータを表示するだけで、独自の状態を持たない画面。

### ④ ConsumerStatefulWidget（Riverpodを使えるStatefulWidget）

```dart
class InputFormScreen extends ConsumerStatefulWidget {
  const InputFormScreen({super.key});

  @override
  ConsumerState<InputFormScreen> createState() => _InputFormScreenState();
}

class _InputFormScreenState extends ConsumerState<InputFormScreen> {
  // refも使えて、かつ自分の状態（_count など）も持てる
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsStreamProvider); // refが使える
    return Stepper(...);
  }
}
```

**使いどころ**：DBのデータも必要で、かつ独自の状態も必要な画面。  
このアプリでは `MainScaffold`、`InputScreen`、`AccountsScreen` などが該当。

## 5.3 Widgetのライフサイクル（重要：エラーの多くはここで起きる）

StatefulWidget / ConsumerStatefulWidget には「ライフサイクル」があります。

```
StatefulWidget が作られる
      ↓
initState() ← ここで初期化処理を行う（TextEditingController の作成など）
      ↓
build()     ← 画面を描画する（StateやProviderの値が変わるたびに呼ばれる）
      ↓
      ↓ ユーザーが画面を閉じる
      ↓
dispose()   ← ここで後片付けを行う（TextEditingController の破棄など）
```

**`TextEditingController` のよくあるエラー**

```dart
class _FormState extends ConsumerState<FormScreen> {
  final _nameCtrl = TextEditingController();  // テキストフィールドの制御オブジェクト

  @override
  void initState() {
    super.initState();
    // ここで初期値を設定することが多い
    _nameCtrl.text = '初期値';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();  // ← 必ず破棄する。忘れるとメモリリーク
    super.dispose();
  }
}
```

過去にこのアプリで起きたエラー：「TextEditingControllerが破棄済みなのにアクセス」  
→ `dispose()` の後に `_nameCtrl.text = ...` を呼ぼうとしたことが原因。  
→ `mounted` チェック（後述）で防げる。

**`mounted` チェック**

```dart
// 非同期処理の後に画面の状態を変えようとすると、
// その間に画面が閉じられている可能性がある
Future<void> _save() async {
  await db.insertSomething();          // DBへの書き込みを待つ
  if (!mounted) return;                // ← 画面がまだ存在するかチェック
  Navigator.pop(context);             // ← mountedを確認してから使う
}
```

**`setState` を呼ぶタイミング**

```dart
// 正しい使い方: build()の外で、setState内で状態を変える
setState(() {
  _currentStep = 1;  // この代入が終わると build() が再実行される
});

// 誤った使い方: build()の中でsetStateを呼ぶ（無限ループになる）
Widget build(BuildContext context) {
  setState(() { ... }); // ← NG! build中にsetStateを呼ぶと再帰的にbuildが呼ばれる
  return ...;
}
```

## 5.4 BuildContext

`BuildContext`（略して `context`）は「このWidgetがWidget treeのどこにあるか」を示すオブジェクトです。

```dart
// context を必要とする主な操作
Navigator.push(context, ...);        // 画面遷移
showDialog(context: context, ...);   // ダイアログ表示
ScaffoldMessenger.of(context).showSnackBar(...); // スナックバー表示
Theme.of(context).colorScheme.primary;           // テーマ色の取得
```

**非同期処理と context の注意点**

```dart
Future<void> _doSomething() async {
  // contextをasyncの前に保存しておく
  final messenger = ScaffoldMessenger.of(context);  // ← async前にキャプチャ

  await someAsyncOperation();  // ここで時間がかかる

  if (!mounted) return;        // 画面が生きているか確認
  messenger.showSnackBar(...); // 保存したmessengerを使う（contextは直接使わない）
}
```

---

# 第6章　data層の説明

## 6.1 app_database.dart

### このファイルの役割

SQLiteデータベースの**テーブル定義**と**マイグレーション（バージョン管理）**を担当します。  
Driftというライブラリを使い、Dartのクラスとしてテーブルを定義します。

### テーブル定義（Tableクラス）

```dart
// 勘定科目テーブル（accounts）
class Accounts extends Table {
  // 各フィールド（カラム）を定義する

  IntColumn get id => integer().autoIncrement()();
  // ↑ id: 整数型、自動採番（1, 2, 3...と自動で増える）

  TextColumn get name => text().withLength(min: 1, max: 100)();
  // ↑ name: テキスト型、1〜100文字

  IntColumn get groupIndex => integer()();
  // ↑ groupIndex: 整数型（0=資産, 1=負債, 2=純資産, 3=費用, 4=収益）

  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
  // ↑ displayOrder: 表示順。デフォルトは0

  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  // ↑ isDefault: デフォルト科目かどうか。デフォルトはfalse
}
```

```dart
// 仕訳（取引）テーブル（financial_transactions）
class FinancialTransactions extends Table {
  TextColumn get id => text()();
  // ↑ id: テキスト型（UUIDを使うためStringになっている）

  DateTimeColumn get date => dateTime()();
  // ↑ date: 日時型（取引日）

  TextColumn get description => text().withLength(min: 1, max: 200)();
  // ↑ description: 摘要（例：「スーパーで食料品購入」）

  TextColumn get memo => text().withLength(max: 500).withDefault(const Constant(''))();
  // ↑ memo: メモ。デフォルトは空文字列

  @override
  Set<Column> get primaryKey => {id};
  // ↑ idを主キーとして指定（autoIncrementがないのでこちらで設定）
}
```

```dart
// 仕訳明細（借方・貸方の各エントリ）テーブル（journal_entries）
class JournalEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get transactionId => text().references(FinancialTransactions, #id)();
  // ↑ transactionId: どの取引（FinancialTransaction）に属するか。外部キー

  IntColumn get accountId => integer().references(Accounts, #id)();
  // ↑ accountId: どの勘定科目か。外部キー

  IntColumn get entryTypeIndex => integer()();
  // ↑ entryTypeIndex: 0=借方, 1=貸方

  RealColumn get amount => real()();
  // ↑ amount: 金額（小数点あり浮動小数点）
}
```

```dart
// 定期取引ルールテーブル（recurring_rules）
class RecurringRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  // ↑ name: ルール名（例：「家賃」「Netflix」）

  IntColumn get debitAccountId => integer().references(Accounts, #id)();
  // ↑ debitAccountId: 借方勘定科目のID（費用・資産側）

  IntColumn get creditAccountId => integer().references(Accounts, #id)();
  // ↑ creditAccountId: 貸方勘定科目のID（支払い元）

  RealColumn get amount => real().nullable()();
  // ↑ amount: 金額（nullなら「変動費」として毎月手動入力）

  IntColumn get dayOfMonth => integer()();
  // ↑ dayOfMonth: 毎月何日に処理するか（31は月末のセンチネル値）

  TextColumn get memo => text().withDefault(const Constant(''))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  // ↑ isActive: 有効フラグ（falseにすると処理をスキップ）
}
```

```dart
// 定期取引処理ログテーブル（recurring_logs）
class RecurringLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ruleId => integer().references(RecurringRules, #id)();
  // ↑ ruleId: どのルール（RecurringRule）の処理結果か

  TextColumn get generatedFor => text()();
  // ↑ generatedFor: "2024-07" のような「YYYY-MM」形式。同じ月に二重処理しないため

  TextColumn get transactionId => text().nullable()();
  // ↑ transactionId: 生成した仕訳のID。nullなら「入力待ち（変動費）」の状態
}
```

### マイグレーション（DBのバージョン管理）

```dart
@override
int get schemaVersion => 5;
// ↑ DBの「バージョン番号」。テーブルを追加・変更するたびに増やす

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async {
    await m.createAll();         // 初回インストール時: 全テーブルを作成
    await _seedDefaultAccounts(); // 初回インストール時: デフォルト科目を追加
  },
  onUpgrade: (m, from, to) async {
    // from: アップグレード前のバージョン番号
    // to: アップグレード後のバージョン番号

    if (from < 2) {
      // バージョン1→2のときの処理（勘定科目の追加）
      await _insertAccountIfNotExists('PayPay', 0, 5);
    }
    if (from < 5) {
      // バージョン4→5のときの処理（定期取引テーブルの追加）
      await m.createTable(recurringRules);
      await m.createTable(recurringLogs);
    }
  },
);
```

**エラーの原因になりやすいポイント**：  
テーブルを追加したのに `schemaVersion` を増やし忘れると、  
既存ユーザーの端末で新しいテーブルが作成されずクラッシュします。

## 6.2 transactions_dao.dart

### このファイルの役割

仕訳（取引）データの**読み書き**を担当します。  
「1つの取引 + 複数の仕訳エントリ」をまとめて操作します。

### 重要なデータ構造

```dart
// 仕訳エントリ（1行分）と、その科目情報をまとめたクラス
class JournalEntryWithAccount {
  final JournalEntry entry;    // entry: 仕訳エントリ（金額・借方貸方など）
  final Account account;       // account: その科目の詳細（名前・グループなど）
  JournalEntryWithAccount({required this.entry, required this.account});
}

// 1つの取引 + その全エントリをまとめたクラス
class TransactionWithEntries {
  final FinancialTransaction transaction; // transaction: 取引本体（日付・摘要）
  final List<JournalEntryWithAccount> entries; // entries: 借方・貸方のエントリ一覧
  TransactionWithEntries({required this.transaction, required this.entries});
}
```

### 主要なメソッド

```dart
// 指定月の取引をStreamで監視（画面に表示する用）
Stream<List<FinancialTransaction>> watchTransactionsInMonth(int year, int month) {
  final start = DateTime(year, month, 1);    // その月の1日
  final end = DateTime(year, month + 1, 1);  // 翌月の1日（終端は含まない）
  return (select(financialTransactions)
        ..where((t) => t.date.isBetweenValues(start, end))
        ..orderBy([(t) => OrderingTerm.desc(t.date)]))  // 新しい日付順
      .watch();
}

// 取引を作成（仕訳エントリと一緒に）
Future<void> insertTransactionWithEntries({
  required FinancialTransactionsCompanion transaction, // 取引本体のデータ
  required List<JournalEntriesCompanion> entries,      // エントリのリスト
}) async {
  await db.transaction(() async {
    // db.transaction: ここ内部の処理をまとめて「1つの操作」として実行
    // どちらかが失敗したら両方ロールバック（中途半端な状態にならない）
    await into(financialTransactions).insert(transaction);
    for (final e in entries) {
      await into(journalEntries).insert(e);
    }
  });
}

// 残高を集計する（B/SやP/Lの計算に使う）
Future<Map<int, double>> getAccountBalances({
  DateTime? from,  // from: 集計開始日（nullなら全期間の始まりから）
  DateTime? to,    // to: 集計終了日（nullなら全期間の終わりまで）
}) async {
  // 戻り値: { 科目ID: 残高（借方合計 - 貸方合計）} のMap

  final balances = <int, double>{};  // 結果を入れるMap（科目ID → 残高）
  for (final tx in allTx) {
    final entries = await ...;
    for (final e in entries) {
      final current = balances[e.accountId] ?? 0.0;  // 現在の累計（なければ0）
      balances[e.accountId] =
          e.entryTypeIndex == 0
              ? current + e.amount   // 借方エントリ: 加算
              : current - e.amount;  // 貸方エントリ: 減算
    }
  }
  return balances;
}
```

**`getAccountBalances` の戻り値の意味**

```
balances[食費のID]    = +5000.0   → 食費に5000円の借方記録がある
balances[現金のID]    = -5000.0   → 現金に5000円の貸方記録がある（支出した）
balances[給与収入のID] = -80000.0  → 給与収入に80000円の貸方記録がある
```

資産・費用は「借方 = プラス方向」なので `raw` をそのまま使う。  
収益・負債は「貸方 = プラス方向」なので `-raw` で符号反転して残高にする。

## 6.3 accounts_dao.dart

```dart
@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<AppDatabase>
    with _$AccountsDaoMixin {

  // 全勘定科目をStreamで監視（表示順 → グループ順に並べる）
  Stream<List<Account>> watchAllAccounts() {
    return (select(accounts)
          ..orderBy([
            (a) => OrderingTerm.asc(a.displayOrder),  // 表示順で昇順
            (a) => OrderingTerm.asc(a.groupIndex),    // 次にグループ順で昇順
          ]))
        .watch();
  }

  // 科目を追加
  Future<int> insertAccount(AccountsCompanion account) =>
      into(accounts).insert(account);
  // 戻り値のintは新しく作られた行のid

  // 科目を削除（IDで指定）
  Future<int> deleteAccount(int id) =>
      (delete(accounts)..where((a) => a.id.equals(id))).go();
  // 戻り値のintは削除された行数
}
```

## 6.4 recurring_dao.dart

```dart
@DriftAccessor(tables: [RecurringRules, RecurringLogs, Accounts])
class RecurringDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringDaoMixin {

  // 全ルールを「処理日の昇順」で監視
  Stream<List<RecurringRule>> watchAllRules() => ...

  // 有効なルールのみを取得（アプリ起動時の処理用）
  Future<List<RecurringRule>> getActiveRules() => ...

  // 当月のログを取得（二重処理防止）
  Future<List<RecurringLog>> getLogsForMonth(String yyyyMm) =>
  // yyyyMm: "2024-07" のような文字列

  // 当月の「入力待ち（変動費）」ログを取得
  Future<List<RecurringLog>> getPendingLogsForMonth(String yyyyMm) =>
  // transactionId が null のものだけを返す

  // ログの transactionId を更新（変動費入力完了時）
  Future<void> markLogComplete(int logId, String transactionId) =>
  // logId: 更新するログのID
  // transactionId: 新しく作成した取引のID
}
```

---

# 第7章　domain層の説明

## 7.1 account_group.dart

```dart
// 列挙型（enum）：決まった値の集合を定義する
// Javaのenumとほぼ同じ
enum AccountGroup {
  asset,      // 0: 資産
  liability,  // 1: 負債
  equity,     // 2: 純資産
  expense,    // 3: 費用
  revenue,    // 4: 収益
}
```

> **コード上での対応**  
> `Account.groupIndex` には 0〜4 の数値が入っています。  
> `AccountGroup.values[acc.groupIndex]` で数値からenumに変換します。

```dart
// extension: 既存のクラス/enumにメソッドを追加する仕組み（Javaにはない）
extension AccountGroupExtension on AccountGroup {

  // 表示名を返す（switch文を使っている）
  String get displayName { ... }
  // get をつけると「メソッド」ではなく「プロパティ」として使える
  // group.displayName() ではなく group.displayName で呼ぶ

  // B/Sに属する科目か
  bool get isBalanceSheet =>
      this == AccountGroup.asset ||
      this == AccountGroup.liability ||
      this == AccountGroup.equity;

  // 借方が増加方向か（資産と費用のみtrue）
  bool get normallyDebit =>
      this == AccountGroup.asset || this == AccountGroup.expense;
  // これがtrueなら: 残高 = raw（借方合計 - 貸方合計）
  // これがfalseなら: 残高 = -raw（符号を反転）
}
```

## 7.2 entry_type.dart

```dart
enum EntryType {
  debit,  // 0: 借方（= DB上の entryTypeIndex == 0）
  credit, // 1: 貸方（= DB上の entryTypeIndex == 1）
}
```

コード中で `EntryType.debit.index` と書くと `0` が返ります。  
DBの `entryTypeIndex` との照合に使います。

## 7.3 ledger_service.dart

```dart
// 家計簿UIからの入力種別
enum InputType {
  expense,  // 支出: 費用科目に借方、資産科目に貸方
  income,   // 収入: 資産科目に借方、収益科目に貸方
  transfer, // 振替: 資産科目に借方、別の資産科目に貸方（例：現金→銀行）
}

// UIから受け取るシンプルな入力データ
class SimpleEntry {
  final InputType type;         // type: 支出/収入/振替のどれか
  final int debitAccountId;     // debitAccountId: 借方科目のID
  final int creditAccountId;    // creditAccountId: 貸方科目のID
  final double amount;          // amount: 金額（常に正の値）
  final DateTime date;          // date: 取引日
  final String description;     // description: 摘要
  final String memo;            // memo: メモ（空でもOK）
}

class LedgerService {
  // SimpleEntry → DBに保存できる形式（Companion）に変換する
  buildTransaction(SimpleEntry input) {
    final txId = _uuid.v4();
    // _uuid.v4(): ランダムなUUID（例: "550e8400-e29b-41d4-a716-446655440000"）を生成

    // 借方エントリ（借方科目が「受け取る側」）
    final debit = JournalEntriesCompanion.insert(
      transactionId: txId,
      accountId: input.debitAccountId,
      entryTypeIndex: 0,         // 0 = 借方
      amount: input.amount,
    );

    // 貸方エントリ（貸方科目が「渡す側」）
    final credit = JournalEntriesCompanion.insert(
      transactionId: txId,
      accountId: input.creditAccountId,
      entryTypeIndex: 1,         // 1 = 貸方
      amount: input.amount,
    );

    return (transaction: transaction, entries: [debit, credit]);
    // ↑ 名前付きレコード（Dart 3の機能）。タプルに名前をつけたもの
  }
}
```

## 7.4 recurring_service.dart

```dart
class RecurringService {
  final AppDatabase db;  // db: 操作するDBの参照

  // "2024-07" のような文字列を生成するstaticメソッド
  static String monthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';
  // padLeft(2, '0'): 1桁の月を "01" のように0埋めする

  // dayOfMonth == 31 は「月末」を意味するセンチネル値
  static bool _isDue(RecurringRule rule, DateTime now) {
    if (rule.dayOfMonth == 31) {
      // DateTime(year, month + 1, 0): 翌月の「0日目」= 当月の最終日
      final lastDay = DateTime(now.year, now.month + 1, 0).day;
      return now.day == lastDay;  // 今日が月末かどうか
    }
    return now.day >= rule.dayOfMonth;  // 今日が処理日以降かどうか
  }

  // メイン処理: アプリ起動時に呼ばれる
  Future<RecurringProcessResult> processToday() async {
    final now = DateTime.now();
    final key = monthKey(now);            // 当月のキー（例: "2024-07"）
    final rules = await db.recurringDao.getActiveRules();  // 有効なルール一覧
    final logs = await db.recurringDao.getLogsForMonth(key); // 当月の処理済みログ
    final done = logs.map((l) => l.ruleId).toSet();
    // done: 当月に既に処理済みのruleIdのSet（重複処理を防ぐ）

    int autoGenerated = 0;  // 自動生成した件数
    int pendingCount = 0;   // 入力待ち件数

    for (final rule in rules) {
      if (done.contains(rule.id)) continue;  // 既に処理済みならスキップ
      if (!_isDue(rule, now)) continue;       // 処理日未満ならスキップ

      if (rule.amount != null) {
        // 固定費: 自動で取引を生成
        ...
        autoGenerated++;
      } else {
        // 変動費: 入力待ちとしてログだけ記録
        await db.recurringDao.insertLog(...);
        pendingCount++;
      }
    }

    return RecurringProcessResult(
      autoGenerated: autoGenerated,
      pendingCount: pendingCount,
    );
  }
}
```

---

# 第8章　presentation層 — Providers

## 8.1 Riverpodとは

Riverpodは「アプリ全体でデータを共有・管理する」ライブラリです。  
グローバル変数を安全に使えるようにしたもの、と考えると分かりやすいです。

**なぜProviderが必要か**：  
画面A（ホーム）と画面B（レポート）が同じDBデータを使う場合、  
Providerがなければ両方の画面でDBクエリを重複して書く必要があります。  
Providerを使うと「データを1箇所で管理し、どの画面からでも参照できる」状態になります。

## 8.2 Providerの種類（このアプリで使われているもの）

| 種類 | 役割 | 返り値 |
|------|------|--------|
| `Provider` | 値や関数を提供する（変化しない） | 任意の型 |
| `StateProvider` | 変更可能な単純な値を管理する | `StateController<T>` |
| `FutureProvider` | 非同期処理の結果を提供する | `AsyncValue<T>` |
| `StreamProvider` | Streamのデータを提供する（自動更新） | `AsyncValue<T>` |

```dart
// StateProvider の使い方
final selectedHomeMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();  // 初期値: 今月
});

// 読む（監視）
final month = ref.watch(selectedHomeMonthProvider);

// 変更する
ref.read(selectedHomeMonthProvider.notifier).state = DateTime(2024, 6);
//                                    ↑ .notifier で変更用オブジェクトを取得
```

```dart
// FutureProvider の AsyncValue の扱い方
final summaryAsync = ref.watch(homeSummaryProvider);
summaryAsync.when(
  data: (summary) => Text('${summary.netAssets}'),  // データ取得成功時
  loading: () => CircularProgressIndicator(),         // 読み込み中
  error: (e, _) => Text('エラー: $e'),               // エラー時
);
```

## 8.3 database_provider.dart

```dart
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();  // DBのインスタンスを作成
  ref.onDispose(db.close);   // Providerが破棄されるときDBを閉じる
  return db;
});
```

これが「DBへの入口」です。全てのDAOはこのProviderを通してDBにアクセスします。  
`ref.watch(databaseProvider)` で取得した `db` から `db.accountsDao` などにアクセスします。

## 8.4 accounts_provider.dart

```dart
// 全勘定科目をStreamで監視
final accountsStreamProvider = StreamProvider<List<Account>>((ref) {
  final db = ref.watch(databaseProvider);  // DBを取得
  return db.accountsDao.watchAllAccounts(); // DAOのStreamを返す
});

// 科目追加関数を提供するProvider
final addAccountProvider =
    Provider<Future<void> Function(String name, AccountGroup group)>((ref) {
  // 戻り値の型: 「String と AccountGroup を受け取り Future<void> を返す関数」
  final db = ref.watch(databaseProvider);
  return (name, group) async {
    await db.accountsDao.insertAccount(
      AccountsCompanion.insert(name: name, groupIndex: group.index),
    );
  };
});
```

## 8.5 transactions_provider.dart

このProviderファイルには多くのProviderが含まれています。主要なものを説明します。

```dart
// 選択中の月（ホーム画面のナビゲーション用）
final selectedHomeMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// 選択月の仕訳一覧（ホーム画面の取引リスト）
final monthTransactionsProvider =
    FutureProvider.autoDispose<List<TransactionWithEntries>>((ref) async {
  // autoDispose: 誰も監視していないときにProviderを自動で破棄する
  final month = ref.watch(selectedHomeMonthProvider);  // 選択月を監視
  ...
});

// 検索関連のProvider群
final searchQueryProvider = StateProvider<String>((ref) => '');
// searchQueryProvider: 検索キーワードを保持

final searchStartDateProvider = StateProvider<DateTime?>((ref) => null);
// searchStartDateProvider: 検索期間の開始日

final searchEndDateProvider = StateProvider<DateTime?>((ref) => null);
// searchEndDateProvider: 検索期間の終了日

enum SearchSort { dateDesc, dateAsc, amountDesc, amountAsc }
// SearchSort: 検索結果の並び順を表すenum

final searchSortProvider = StateProvider<SearchSort>((ref) => SearchSort.dateDesc);
// searchSortProvider: 現在選択中の並び順

final searchResultsProvider = FutureProvider.autoDispose<...>((ref) async {
  final query = ref.watch(searchQueryProvider);     // キーワード
  final startDate = ref.watch(searchStartDateProvider); // 開始日
  final endDate = ref.watch(searchEndDateProvider);     // 終了日
  final sort = ref.watch(searchSortProvider);           // 並び順
  // これらを組み合わせてフィルタリング・ソートした結果を返す
});
```

## 8.6 reports_provider.dart

決算レポートのデータを計算する最も複雑なProviderです。

```dart
// レポートの対象期間を管理
class ReportPeriod {
  final int year;       // year: 対象年
  final int? month;     // month: 対象月（nullなら年次レポート）

  DateTime get from =>  // from: 期間の開始日時
      month != null ? DateTime(year, month!, 1) : DateTime(year, 1, 1);

  DateTime get to =>    // to: 期間の終了日時（翌月1日 = 終端を含まない）
      month != null ? DateTime(year, month! + 1, 1) : DateTime(year + 1, 1, 1);
}

// 全期間の残高を取得（B/S用: 累計データが必要）
final allTimeRawBalancesProvider =
    FutureProvider.autoDispose<Map<int, double>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.transactionsDao.getAccountBalances();  // 引数なし = 全期間
});

// 貸借対照表データ
final balanceSheetProvider =
    FutureProvider.autoDispose<BalanceSheetData>((ref) async {
  final allAccounts = await ref.watch(accountsStreamProvider.future);
  final balances = await ref.watch(allTimeRawBalancesProvider.future);
  // balances: { 科目ID: 借方合計-貸方合計 } のMap（全期間）

  // B/Sの3グループ（資産・負債・純資産）の残高リストを作成
  for (final g in bsGroups) {
    items[g] = allAccounts
        .where((a) => a.groupIndex == g.index)  // このグループの科目だけ
        .map((a) {
          final raw = balances[a.id] ?? 0.0;     // 生の残高（なければ0）
          final balance = g.normallyDebit ? raw : -raw;  // 符号調整
          return (account: a, balance: balance);
        })
        .where((e) => e.balance > 0)  // 残高ゼロ以下は表示しない
        .toList();
  }

  // 累計当期純利益（収益の累計 - 費用の累計）
  final netIncome = allAccounts.fold(0.0, (s, a) {
    final g = AccountGroup.values[a.groupIndex];
    final raw = balances[a.id] ?? 0.0;
    if (g == AccountGroup.revenue) return s + (-raw);  // 収益: -rawで正にする
    if (g == AccountGroup.expense) return s - raw;     // 費用: rawで正なので引く
    return s;
  });
});
```

**`BalanceSheetData` の構造**

```dart
class BalanceSheetData {
  final Map<AccountGroup, List<...>> items;  // items: グループ別の残高リスト
  final double totalAssets;                  // 資産合計
  final double totalLiabilities;             // 負債合計
  final double totalEquity;                  // 純資産合計（元入金のみ）
  final double netIncome;                    // 当期純利益（累計）
  final double netAssets;                    // 純資産（資産-負債）

  // 純資産の部合計（元入金 + 当期純利益）
  double get totalEquityWithIncome => totalEquity + netIncome;
}
```

## 8.7 recurring_provider.dart

```dart
// セッション中に自動生成した件数（アプリを再起動するとリセット）
final recurringSessionCountProvider = StateProvider<int>((ref) => 0);

// 当月の「入力待ち変動費」リスト
final pendingRecurringProvider =
    FutureProvider<List<PendingRecurringItem>>((ref) async {
  ...
});

// PendingRecurringItem: 入力待ち情報をまとめたクラス
class PendingRecurringItem {
  final RecurringRule rule;      // rule: 対象の定期取引ルール
  final RecurringLog log;        // log: 当月の処理ログ（transactionId=null）
  final Account debitAccount;    // debitAccount: 借方科目
  final Account creditAccount;   // creditAccount: 貸方科目
}

// 変動費の金額を入力して取引を完成させる
final completeRecurringProvider =
    Provider<Future<void> Function(PendingRecurringItem, double)>((ref) {
  final db = ref.watch(databaseProvider);
  return (item, amount) async {
    // item: 完了させる変動費の情報
    // amount: ユーザーが入力した金額
    ...
    ref.invalidate(pendingRecurringProvider);
    // invalidate: pendingRecurringProviderを「無効化」して再取得させる
  };
});
```

---

# 第9章　presentation層 — 各画面

## 9.1 main_scaffold.dart

アプリ全体の骨格を担当する画面です。  
ボトムナビゲーションバーと、3つのFAB（右下ボタン）を管理します。

```dart
class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _selectedIndex = 0;   // _selectedIndex: 現在選択中のタブ（0=ホーム, 1=決算, 2=科目）
  bool _fabVisible = true;  // _fabVisible: FABの表示/非表示
  double _lastScrollOffset = 0; // _lastScrollOffset: 前回のスクロール位置（スクロール方向を検知するため）

  @override
  void initState() {
    super.initState();
    // アプリ起動時（画面描画の直後）に定期取引の処理を実行
    WidgetsBinding.instance.addPostFrameCallback((_) => _runRecurring());
    // addPostFrameCallback: build()が完了した直後に実行されるコールバック
  }

  // スクロールを検知してFABを表示/非表示にする
  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    // axis != Axis.vertical: 水平スクロール（タブ切り替え）は無視

    if (notification is ScrollStartNotification) {
      _lastScrollOffset = notification.metrics.pixels; // スクロール開始位置を記録
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      final delta = notification.metrics.pixels - _lastScrollOffset;
      // delta: スクロール量（正=下スクロール, 負=上スクロール）
      _lastScrollOffset = notification.metrics.pixels;

      if (notification.metrics.pixels <= 0) {
        // ページ最上部: 必ず表示
        if (!_fabVisible) setState(() => _fabVisible = true);
      } else if (delta > 4 && _fabVisible) {
        // 4px以上下スクロール: 非表示
        setState(() => _fabVisible = false);
      } else if (delta < -4 && !_fabVisible) {
        // 4px以上上スクロール: 再表示
        setState(() => _fabVisible = true);
      }
    }
    return false; // falseを返すとScrollNotificationが親にも伝搬する
  }
}
```

## 9.2 home_screen.dart

月次の収支サマリーと取引一覧を表示します。

```dart
class HomeScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedHomeMonthProvider);
    // selectedMonth: 表示中の月（ナビゲーションで変更される）

    final summaryAsync = ref.watch(selectedMonthSummaryProvider);
    // summaryAsync: 月次サマリー（収入・支出・純資産）

    final txAsync = ref.watch(monthTransactionsProvider);
    // txAsync: 選択月の仕訳一覧

    // CustomScrollView: AppBarが縮むスクロール効果を実現するWidget
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar: スクロールに合わせて縮む/固定するAppBar
          SliverAppBar(
            expandedHeight: 210,  // 展開時の高さ
            pinned: true,         // スクロールしても上部に固定
            ...
          ),
          // const _RecurringBanner(): 定期取引バナー
          // SliverToBoxAdapter: 通常のWidgetをSliver（スクロール対応）に変換するラッパー
          const _RecurringBanner(),
          SliverToBoxAdapter(...), // ヘッダー「◯月の取引」
          // SliverList: 効率的なリスト表示（画面外のアイテムを描画しない）
          SliverList(...),
        ],
      ),
    );
  }
}
```

**`HomeSummary` クラスの変数**

```dart
class HomeSummary {
  final double monthlyIncome;   // monthlyIncome: 選択月の収入合計
  final double monthlyExpense;  // monthlyExpense: 選択月の支出合計
  final double netAssets;       // netAssets: 全期間の純資産（資産-負債）

  double get monthlyBalance => monthlyIncome - monthlyExpense;
  // monthlyBalance: 月次収支（収入-支出）
}
```

## 9.3 input_screen.dart

仕訳入力のステップフォームです。5つのステップに分かれています。

**ステップ構成**

| ステップ | 内容 | 主な変数 |
|---------|------|---------|
| Step 0 | 日付選択 | `_selectedDate` |
| Step 1 | 借方科目選択 | `_debitAccountId` |
| Step 2 | 貸方科目選択 | `_creditAccountId` |
| Step 3 | 金額入力 | `_amountCtrl`（TextEditingController） |
| Step 4 | 摘要・メモ入力 | `_descCtrl`、`_memoCtrl` |

```dart
class _JournalStepFormState extends ConsumerState<_JournalStepForm> {
  int _currentStep = 0;  // _currentStep: 現在アクティブなステップ（0〜4）
  int _maxStep = 0;      // _maxStep: ユーザーが到達した最大ステップ（「戻って編集」の制御に使う）

  DateTime _selectedDate = DateTime.now();  // 選択した取引日
  int? _debitAccountId;                     // 選択した借方科目ID（未選択ならnull）
  int? _creditAccountId;                    // 選択した貸方科目ID
  final _amountCtrl = TextEditingController();   // 金額入力欄の制御
  final _descCtrl = TextEditingController();     // 摘要入力欄の制御
  final _memoCtrl = TextEditingController();     // メモ入力欄の制御

  @override
  void dispose() {
    // Controllerは必ずdisposeする（メモリリーク防止）
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  // _maxStep パターン: 一度進んだステップには戻れる
  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
      if (step > _maxStep) _maxStep = step;  // 最大到達ステップを更新
    });
  }
}
```

## 9.4 reports_screen.dart

3つのタブ（グラフ / P/L / B/S）を持つ決算レポート画面です。

```dart
class ReportsScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,       // タブの数
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: 'グラフ'),
              Tab(text: 'P/L 損益'),
              Tab(text: 'B/S 貸借'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ChartTab(),  // タブ0: 棒グラフ・円グラフ
            _PLTab(),     // タブ1: 損益計算書
            _BSTab(),     // タブ2: 貸借対照表
          ],
        ),
      ),
    );
  }
}
```

**B/S表示の計算ロジック**（`_BSBody`内）

```dart
// isBalanced: 資産合計と（負債+純資産合計）が一致しているか
final isBalanced =
    (data.totalAssets - data.totalLiabilities - data.totalEquityWithIncome).abs() < 0.01;
// abs(): 絶対値（符号を無視した差）
// < 0.01: 浮動小数点の誤差を許容するための閾値
```

## 9.5 accounts_screen.dart

勘定科目の一覧表示・追加・削除を行います。

スクロールに連動したFAB表示切り替えのロジックが `main_scaffold.dart` と共通です（同じ `_onScroll` メソッドを持つ）。

## 9.6 search_screen.dart

仕訳の全文検索と絞り込みを行います。

```dart
// 検索を実行する条件（いずれかがあれば検索実行）
final shouldSearch =
    query.trim().isNotEmpty || startDate != null || endDate != null;
// trim(): 前後の空白を除去
// isNotEmpty: 空文字列でないか
```

## 9.7 recurring_rules_screen.dart

定期取引ルールの管理（一覧・追加・編集・削除）を行います。

```dart
// _RecurringRuleFormScreenState の主要変数
int _dayOfMonth = 1;         // _dayOfMonth: 処理日（1〜28 または 31=月末）
int? _debitAccountId;        // _debitAccountId: 借方科目ID
int? _creditAccountId;       // _creditAccountId: 貸方科目ID
bool _isActive = true;       // _isActive: ルールの有効/無効フラグ
// amountCtrl: 金額（空欄なら変動費として扱う）
```

## 9.8 共通ウィジェット

### amount_text.dart

金額を「¥1,234」形式で表示します。マイナスなら赤字表示などの判定をここで行います。

### transaction_list_tile.dart

仕訳一覧の1行を表示する再利用可能なWidgetです。

```dart
class TransactionListTile extends StatelessWidget {
  final TransactionWithEntries data;   // data: 表示する仕訳データ
  final VoidCallback? onDelete;         // onDelete: 削除時のコールバック
  // VoidCallback: 「引数なし・戻り値なし」の関数型（() => void に相当）
}
```

**表示の判定ロジック**

```dart
// 費用 or 収益のエントリを「代表エントリ」として色・アイコンを決める
final primaryEntry = entries.firstWhere(
  (e) {
    final g = AccountGroup.values[e.account.groupIndex];
    return g == AccountGroup.expense || g == AccountGroup.revenue;
  },
  orElse: () => entries.first,  // 費用・収益がなければ最初のエントリを使う
);

// isExpense: 支出取引か（赤で表示）
// isRevenue: 収入取引か（緑で表示）
// どちらでもない（振替）: 青で表示
```

---

# 第10章　エラー対処法

## 10.1 エラーの種類と原因レイヤー

| エラーの症状 | 疑うべきファイル |
|------------|---------------|
| 画面が真っ赤になる（赤いエラー画面） | エラーメッセージを読む。スタックトレースの一番上が原因 |
| データが表示されない（ローディングのまま） | 該当Providerと、その中で呼ぶDAOメソッドを確認 |
| データが保存されない | DAOのinsert/updateメソッドと、app_database.dartのテーブル定義を確認 |
| アプリがクラッシュする | スタックトレースを確認。多くはnull参照かdisposed Controllerへのアクセス |
| 「Target of URI hasn't been generated」エラー | `build_runner` を実行する |
| DBスキーマエラー | `schemaVersion` を増やして `onUpgrade` を追加したか確認 |

## 10.2 よくあるエラーパターン

### パターン1: FlutterError — disposed controller

```
FlutterError: A TextEditingController was used after being disposed.
```

**原因**：`dispose()` の後に `controller.text = ...` を呼んでいる。  
**対処**：`if (!mounted) return;` を追加して、画面が存在するか確認してから操作する。

---

### パターン2: LateInitializationError

```
LateInitializationError: Field '_xxx' has not been initialized.
```

**原因**：`late` キーワードで宣言した変数を `initState()` で初期化し忘れた。  
**対処**：`initState()` に初期化コードを追加する。

---

### パターン3: ProviderException — ref.watch in async

```
Bad state: Tried to use ref.watch inside an async context.
```

**原因**：`await` の後で `ref.watch()` を使っている。  
**対処**：`await` の前に `ref.watch()` の結果を変数に保存する。

```dart
// NG
final db = ref.watch(databaseProvider);
await someAsyncOperation();
final data = ref.watch(otherProvider); // ← awaitの後でNG

// OK
final db = ref.watch(databaseProvider);
final data = ref.watch(otherProvider); // ← awaitの前に全て取得
await someAsyncOperation();
```

---

### パターン4: build_runner が必要な場面

以下の変更をした後は必ず実行する：

```bash
dart run build_runner build --delete-conflicting-outputs
```

- `app_database.dart` のテーブル定義を変更した
- 新しい `@DriftAccessor` DAO を追加した
- `schemaVersion` を変更した
- 「Target of URI hasn't been generated」エラーが出た

---

### パターン5: null チェック漏れ

```
Null check operator used on a null value
```

**原因**：`!`（強制アンラップ）を使った変数が `null` だった。  
**対処**：`?.`（null条件演算子）か `??`（null合体演算子）に変える。

```dart
// NG
print(user!.name);  // userがnullだとクラッシュ

// OK
print(user?.name ?? '不明');  // nullなら'不明'を使う
```

## 10.3 `build_runner` が必要なタイミングまとめ

| 操作 | build_runner が必要か |
|------|---------------------|
| `app_database.dart` のテーブルを追加・変更 | **必要** |
| DAOファイルを新規作成 | **必要** |
| DAOのメソッドを変更 | 不要（`.g.dart` はクラス定義の変更に対してのみ必要） |
| Providerを追加（`@riverpod` アノテーションなし） | **不要** |
| 画面（Widget）を追加・変更 | **不要** |
| `pubspec.yaml` にパッケージを追加 | 不要（`flutter pub get` のみ必要） |

---

## まとめ：ファイルと役割の早見表

| ファイル | 一言説明 | エラーが起きたら疑う症状 |
|---------|---------|----------------------|
| `app_database.dart` | テーブル定義・マイグレーション | DBスキーマエラー、新しいテーブルが使えない |
| `*_dao.dart` | DBの読み書きメソッド | データが取得・保存できない |
| `account_group.dart` | 勘定科目グループのenum | グループ判定がおかしい |
| `ledger_service.dart` | 借方・貸方の仕訳データ生成 | 仕訳の生成ロジックがおかしい |
| `recurring_service.dart` | 定期取引の自動処理 | 定期取引が実行されない・重複する |
| `*_provider.dart` | データ状態管理 | 画面のデータが更新されない・おかしい |
| `main_scaffold.dart` | アプリ骨格・FAB・タブ切り替え | タブが切り替わらない、FABが消えない |
| `home_screen.dart` | ホーム画面 | ホームの表示がおかしい |
| `input_screen.dart` | 仕訳入力フォーム | 仕訳が保存できない、ステップがおかしい |
| `reports_screen.dart` | 決算レポート表示 | グラフ・P/L・B/Sの表示がおかしい |
| `accounts_screen.dart` | 勘定科目管理 | 科目の追加・削除ができない |
| `recurring_rules_screen.dart` | 定期取引管理 | 定期取引ルールの設定ができない |
| `transaction_list_tile.dart` | 仕訳一覧の1行 | 仕訳リストの表示がおかしい |

---

*このドキュメントは `docs/app_guide.md` に保存されています。*  
*アプリに変更を加えた際は、対応する章を更新することをお勧めします。*
