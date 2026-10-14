<div align="center">

<img src="assets/banner.png" width="760" alt="tern-omp-usage: omp 経由の Claude と Codex の上限を Tern のステータスラインに表示">

[![check](https://github.com/joaodutra88/tern-omp-usage/actions/workflows/check.yml/badge.svg)](https://github.com/joaodutra88/tern-omp-usage/actions/workflows/check.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/joaodutra88/tern-omp-usage?style=flat)](https://github.com/joaodutra88/tern-omp-usage/stargazers)
[![Latest release](https://img.shields.io/github/v/release/joaodutra88/tern-omp-usage)](https://github.com/joaodutra88/tern-omp-usage/releases/latest)

[omp](https://omp.sh) ユーザー向けの [Tern](https://stencil.so/tern) ステータスラインプラグインです。Claude と Codex のサブスクリプション上限、今週の支出予算、今日のトークン数とコストを、パネルを開かずに 1 行で画面に表示し続けます。

**[インストール](#インストール)** · **[各表示の意味](#各表示の意味)** · **[設定](#設定)** · **[FAQ](#faq)** · **[コントリビュート](#コントリビュート)**

[English](README.md) | [Português](README.pt-BR.md) | [Español](README.es.md) | [简体中文](README.zh-CN.md) | **日本語**

> この日本語版は参考訳です。英語版 README.md が正であり、内容が異なる場合は英語版が優先されます。

<img src="assets/statusline.png" alt="Tern ステータスラインの Claude と Codex の使用量">

</div>

## わかること

すべてステータスラインに表示されるので、作業しながら答えを確認できます。

- **今日、重い処理を実行する余裕はあるか?** 週の作業日予算です。平日ごとに週間クォータの 20% が解放され、祝日分の枠は繰り越されます。
- **今日はいくらかかったか?** 深夜 0 時以降のトークン数と API 価格ベースのコストです。omp が追跡するすべてのプロバイダーが対象です。
- **保存済みのリセットはあるか?** Claude と Codex の保存済み使用量上限リセットを表示します。
- **Claude と Codex を並べて表示。** どちらも omp 経由で読み取るため、新たにサインインする必要はありません。

## 各表示の意味

| 見た目 | 意味 |
|---|---|
| <img src="assets/seg-window.png" height="28" alt="5h window"> | 1 つのウィンドウの使用量: 5h、週 (`wk`)、そしてプランに含まれる場合は Fable。各ドットは緑から赤までの独自の色を持ち、パーセンテージは最後に到達したドットの色になります。80% に達すると、パーセンテージは点滅する赤いバッジに変わります。 |
| <img src="assets/seg-reset.png" height="28" alt="reset countdown"> | Claude の 5h ウィンドウがリセットされるまでの時間。30 分未満で、かつ 5h ウィンドウが 80% 以上のとき緑になります。救済が近いことを示します。 |
| <img src="assets/seg-credits.png" height="28" alt="saved resets"> | 保存済みの使用量上限リセット。 |
| <img src="assets/seg-budget.png" height="28" alt="work-week budget"> | 作業週の予算。現在の 7 日間ウィンドウのうち、月曜から金曜までの各日が週間クォータの 20% を解放します。`left` は解放済みでまだ使っていないクォータです。`over`(点滅する赤)は、週のペースより先に使いすぎていることを意味します。 |
| <img src="assets/seg-codex.png" height="28" alt="Codex"> | Codex。`×2` は連携済みアカウントの数で、ウィンドウは使い切られたアカウントの割合を示します。 |
| <img src="assets/seg-today.png" height="28" alt="today's tokens and cost"> | 深夜 0 時(ローカル時間)以降のトークン数と API 価格ベースのコスト。すべてのプロバイダーが対象で、`omp stats` から取得します。キャッシュ読み取りもトークンに含まれるため、この数値の大部分はキャッシュです。 |
| <img src="assets/seg-refresh.png" height="28" alt="refresh"> | 今すぐ更新。使用量のどのセグメントをクリックしても同じ動作になります。 |

## 週の経過に伴う表示の変化

これらは用意された `omp` の応答から描画したもので、毎日は起きない状態も確認できます。

**静かな朝。** すべて緑で、予算も十分にあります。

<p align="center"><img src="assets/state-calm.png" alt="calm"></p>

**使用量の上昇。** ウィンドウが 5 分前の読み取りから 3 ポイント以上上がると `↑` が表示されます。

<p align="center"><img src="assets/state-rising.png" alt="rising"></p>

**5h ウィンドウが高止まり。** 86% になるとパーセンテージは赤いバッジになり、救済まで 21 分なのでリセット表示が緑になります。

<p align="center"><img src="assets/state-hot.png" alt="hot"></p>

**週のペースより先行。** 週の 65% を使ったのに解放済みは 40% だけです。`over 25%` は次の平日が追いつくまで点滅します。

<p align="center"><img src="assets/state-over.png" alt="over budget"></p>

**ロック中。** 100% のウィンドウは、解放までの時間と保存済みリセットを示す点滅バッジを表示します。

<p align="center"><img src="assets/state-locked.gif" alt="locked"></p>

## インストール

```sh
tern plugin install https://github.com/joaodutra88/tern-omp-usage
```

Anthropic と / または OpenAI Codex に `omp` でサインインしておく必要があります。ターミナルで `omp usage` が動作することを確認してください。このプラグインは Tern が管理する omp (`%LOCALAPPDATA%\Tern\omp\bin\omp.exe`) を使用し、見つからない場合は `PATH` 上の `omp` にフォールバックします。Tern のデーモンが見つけられない場合は、`OMP_USAGE_BIN` にフルパスを設定してください。

### AI エージェントでインストールする

omp、Claude Code、Codex、またはコマンドを実行できる任意のエージェントに、次を貼り付けます:

```text
Install the Tern plugin https://github.com/joaodutra88/tern-omp-usage for me.
1. Check `omp usage --json -p anthropic` (or `-p openai-codex`) works. If it doesn't, help me sign in with omp first.
2. Run `tern plugin install https://github.com/joaodutra88/tern-omp-usage`.
3. Run `tern plugin list --json` and confirm `omp-usage` has status "ready".
4. If it isn't ready, read the lines containing `omp-usage` in Tern's log
   (`%LOCALAPPDATA%\Tern\Logs\tern.log` on Windows) and the repo's AGENTS.md, then tell me what is wrong.
5. Explain what each part of the status line means, using the README.
```

## 実行するもの、触れるもの

このプラグインはネットワークリクエストを行わず、認証情報も読み取りません。omp を実行するだけです:

| コマンド | 実行タイミング |
|---|---|
| `omp usage --json -p anthropic` | 5 分ごと。Anthropic の使用量エンドポイントは約 5 分未満だと 429 を返します。 |
| `omp usage --json -p openai-codex` | 5 分ごと |
| `omp stats --json` | 5 分ごと |
| `omp usage invalidate` | セグメントをクリックしたとき。omp のキャッシュを回避するため |

ディスクへの書き込みは行いません。Tern はフォーマッタに 4 ms しか与えないため、ステータス表示のフォーマッタは上記の呼び出しでキャッシュされた値を読み取るだけです。

## 設定

| 場所 | 名前 | 既定値 |
|---|---|---|
| `usage.luau` | `DAILY` | `0.20`、平日ごとに解放されるクォータ |
| `usage.luau` | `TREND_STEP` | `0.03`、`↑` が付く上昇幅 |
| `usage.luau` | `M.labels` | バーに表示される語(`left`、`over`、`LOCKED`、`tokens`) |
| `window.luau` | `FETCH_MS` | 5 分 |
| 環境変数 | `OMP_USAGE_BIN` | Tern が見つけられない場合の `omp` のパス |

色は `window.luau` の末尾にある通常の CSS で設定します。各セグメントは `#statusline .sl-plugin[title="plugin.omp-usage.<name>"]` です。

### 言語を変更する

バーに表示されるすべての語は `usage.luau` の先頭にある `M.labels` に定義されているため、翻訳は 1 行の変更で済みます。言語を追加するプルリクエストを歓迎します。

### 独自のセグメント

`window.luau` と同じフォルダに `extras.luau` ファイルがあれば、プラグインはそれを読み込みます。Git はこのファイルを無視するため、個人用のセグメントがリポジトリに入ることはありません:

```luau
local M = {}
function M.init(hidden, every) end -- register commands, timers, CSS
function M.segments(out, pane) end -- insert segments before the usage ones
return M
```

## FAQ

**`tern plugin list` でプラグインが `disabled` と表示される。**
Tern は、エラーを起こした、またはステータスフォーマッタが時間予算を超えたプラグインを無効にします。`tern plugin reload` を実行してから、Tern のログ(Windows では `%LOCALAPPDATA%\Tern\Logs\tern.log`)で `omp-usage` を含む行を探し、その行を添えて Issue を開いてください。

**バーに `✻ Claude ?` または `⬢ Codex ?` と表示される。**
直前の `omp usage` 呼び出しが失敗しています。ターミナルで `omp usage --json -p anthropic`(または `-p openai-codex`)が動作するか確認し、動作しなければ omp でサインインしてください。どのセグメントをクリックしても再試行されます。

**何も表示されない。**
ステータスラインがオンになっているか確認してください(Tern の設定で `"status_bar": true`)。オンなのに表示されない場合、Tern のデーモンが `omp` を見つけられていない可能性があります。`OMP_USAGE_BIN` にフルパスを設定し、Tern を再起動してください。

**数値が claude.ai より遅れている。**
同じ使用量エンドポイントから omp 経由で、5 分ごとに取得しているためです。Anthropic は頻繁なポーリングにレート制限をかけるため、この間隔にしています。セグメントをクリックすると、最新の値を強制的に読み取ります。

**今日のトークン数がなぜこんなに多いのか?**
エージェントの入力の大部分を占めるキャッシュ読み取りが含まれているためです。コストは、それらのトークンを API 価格で計算した金額であり、サブスクリプションの請求額ではありません。

**アンインストールするには?**
`tern plugin remove omp-usage` を実行してください。

## コントリビュート

このプロジェクトは MIT ライセンスのオープンソースです。使う、フォークする、変更する、配布する、いずれも自由です。Issue とプルリクエストは誰に対しても開かれています。

- `python scripts/check.py` は構文、テスト、CSS、マニフェストを検証します。CI も同じものを実行します。`--tern` を付けると、お使いの Tern でプラグインを再読み込みし、そのログも確認します。
- AI エージェントを使っていますか? [AGENTS.md](AGENTS.md) を指定してください。間違えやすいルールと、適切なバグ報告の書き方を説明しています。
- 詳細は [CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。参加者は全員 [行動規範](CODE_OF_CONDUCT.md) に従います。セキュリティの問題は [SECURITY.md](SECURITY.md) から報告してください。

## スター履歴

[![Star History Chart](https://api.star-history.com/svg?repos=joaodutra88/tern-omp-usage&type=Date)](https://star-history.com/#joaodutra88/tern-omp-usage&Date)
