<div align="center">

<img src="assets/banner.png" width="760" alt="tern-omp-usage：通过 omp 在 Tern 状态栏中显示 Claude 和 Codex 额度">

[![check](https://github.com/joaodutra88/tern-omp-usage/actions/workflows/check.yml/badge.svg)](https://github.com/joaodutra88/tern-omp-usage/actions/workflows/check.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/joaodutra88/tern-omp-usage?style=flat)](https://github.com/joaodutra88/tern-omp-usage/stargazers)
[![Latest release](https://img.shields.io/github/v/release/joaodutra88/tern-omp-usage)](https://github.com/joaodutra88/tern-omp-usage/releases/latest)

一个面向 [omp](https://omp.sh) 用户的 [Tern](https://stencil.so/tern) 状态栏插件。它在一行之内显示你的 Claude 和 Codex 订阅额度、本周的消费预算，以及今天的 token 用量和费用，无需打开任何面板。

**[安装](#安装)** · **[每一部分的含义](#每一部分的含义)** · **[配置](#配置)** · **[FAQ](#faq)** · **[贡献](#贡献)**

[English](README.md) | [Português](README.pt-BR.md) | [Español](README.es.md) | **简体中文** | [日本語](README.ja.md)

英文版 README.md 是参考版本，如两者有出入，以英文版为准。

<img src="assets/statusline.png" alt="Tern 状态栏中的 Claude 和 Codex 用量">

</div>

## 它能告诉你什么

所有信息都在状态栏里，工作时一眼就能看到：

- **今天能不能承受一次高负载运行？** 工作周预算：周一到周五每个工作日解锁每周额度的 20%，节假日的份额顺延到之后。
- **今天花了多少？** 自当地午夜起的 token 数和按 API 价格计算的费用，覆盖 omp 追踪的所有提供商。
- **有没有已保存的额度重置？** Claude 和 Codex 已保存的用量限制重置次数。
- **Claude 和 Codex 并排显示**，两者都通过 omp 读取，无需再登录任何新账户。

## 每一部分的含义

| 外观 | 含义 |
|---|---|
| <img src="assets/seg-window.png" height="28" alt="5h 窗口"> | 单个窗口的用量：5 小时（5h）、一周（`wk`），以及套餐包含时的 Fable。每个圆点保留自己的颜色，从绿色到红色，百分比采用最后一个被点亮的圆点的颜色。达到 80% 时，百分比变为闪烁的红色徽章。 |
| <img src="assets/seg-reset.png" height="28" alt="重置倒计时"> | 距离 Claude 5 小时窗口重置的时间。剩余不到 30 分钟且 5 小时窗口用量达到 80% 或以上时变为绿色，表示即将缓解。 |
| <img src="assets/seg-credits.png" height="28" alt="已保存的重置"> | 你已保存的用量限制重置次数。 |
| <img src="assets/seg-budget.png" height="28" alt="工作周预算"> | 工作周预算。当前 7 天窗口中，每个周一至周五解锁每周额度的 20%。`left` 表示已解锁但尚未花费的额度。`over`（闪烁红色）表示你的消费超前于本周进度。 |
| <img src="assets/seg-codex.png" height="28" alt="Codex"> | Codex。`×2` 表示已关联的账户数量，窗口显示已用完的账户所占的比例。 |
| <img src="assets/seg-today.png" height="28" alt="今日 token 和费用"> | 自当地午夜起的 token 数和 API 价格费用，覆盖所有提供商，数据来自 `omp stats`。缓存读取也计入 token，因此这个数字的大部分来自缓存。 |
| <img src="assets/seg-refresh.png" height="28" alt="刷新"> | 立即刷新。点击任意用量片段也会执行相同操作。 |

## 一周中的状态变化

以下画面由预设的 `omp` 回复渲染而成，因此可以看到并非每天都会出现的状态。

**平静的早晨。** 一切为绿色，预算充足。

<p align="center"><img src="assets/state-calm.png" alt="平静"></p>

**用量上升。** 当某个窗口相比 5 分钟前的读数上升了 3 个百分点或以上时，会出现 `↑`。

<p align="center"><img src="assets/state-rising.png" alt="上升"></p>

**5 小时窗口过热。** 达到 86% 时，百分比变为红色徽章，而重置倒计时变为绿色，因为距离缓解只剩 21 分钟。

<p align="center"><img src="assets/state-hot.png" alt="过热"></p>

**超前于本周进度。** 本周已用 65%，但只解锁了 40%：`over 25%` 会闪烁，直到下一个工作日赶上进度。

<p align="center"><img src="assets/state-over.png" alt="超出预算"></p>

**锁定。** 某个窗口达到 100% 时，会显示一个闪烁徽章，附带距离释放的时间以及你已保存的重置次数。

<p align="center"><img src="assets/state-locked.gif" alt="锁定"></p>

## 安装

```sh
tern plugin install https://github.com/joaodutra88/tern-omp-usage
```

你需要在 `omp` 中登录 Anthropic 和/或 OpenAI Codex，以便 `omp usage` 能在终端中正常运行。插件使用 Tern 管理的 omp（Windows 上为 `%LOCALAPPDATA%\Tern\omp\bin\omp.exe`，macOS 上为 `~/Library/Application Support/Tern/omp/bin/omp`），如果找不到，则回退到 `PATH` 中的 `omp`。如果 Tern 的守护进程找不到它，请将 `OMP_USAGE_BIN` 设置为完整路径。

### 使用 AI 代理安装

将以下内容粘贴到 omp、Claude Code、Codex 或任何能运行命令的代理中：

```text
Install the Tern plugin https://github.com/joaodutra88/tern-omp-usage for me.
1. Check `omp usage --json -p anthropic` (or `-p openai-codex`) works. If it doesn't, help me sign in with omp first.
2. Run `tern plugin install https://github.com/joaodutra88/tern-omp-usage`.
3. Run `tern plugin list --json` and confirm `omp-usage` has status "ready".
4. If it isn't ready, read the lines containing `omp-usage` in Tern's log
   (`%LOCALAPPDATA%\Tern\Logs\tern.log` on Windows) and the repo's AGENTS.md, then tell me what is wrong.
5. Explain what each part of the status line means, using the README.
```

## 它运行什么，会触及什么

该插件不发起任何网络请求，也不读取任何凭据。它只运行 omp：

| 命令 | 运行时机 |
|---|---|
| `omp usage --json -p anthropic` | 每 5 分钟。Anthropic 的用量接口在约 5 分钟以内会返回 429。 |
| `omp usage --json -p openai-codex` | 每 5 分钟 |
| `omp stats --json` | 每 5 分钟 |
| `omp usage invalidate` | 点击某个片段时，用于跳过 omp 的缓存 |

它不向磁盘写入任何内容。状态格式化器只读取上述调用缓存的值，因为 Tern 只给格式化器 4 毫秒的时间。

## 配置

| 位置 | 名称 | 默认值 |
|---|---|---|
| `usage.luau` | `DAILY` | `0.20`，每个工作日解锁的额度 |
| `usage.luau` | `TREND_STEP` | `0.03`，获得 `↑` 所需的上升幅度 |
| `usage.luau` | `M.labels` | 状态栏显示的文字（`left`、`over`、`LOCKED`、`tokens`） |
| `window.luau` | `FETCH_MS` | 5 分钟 |
| 环境变量 | `OMP_USAGE_BIN` | 当 Tern 找不到 `omp` 时使用的路径 |

颜色是 `window.luau` 底部的普通 CSS。每个片段对应 `#statusline .sl-plugin[title="plugin.omp-usage.<name>"]`。

### 使用你的语言

状态栏显示的每个文字都位于 `usage.luau` 顶部的 `M.labels` 中，因此翻译只需修改一行。欢迎提交添加新语言的 Pull Request。

### 你自己的片段

如果 `window.luau` 旁边存在 `extras.luau` 文件，插件会加载它。Git 会忽略该文件，因此个人片段不会进入代码仓库：

```luau
local M = {}
function M.init(hidden, every) end -- register commands, timers, CSS
function M.segments(out, pane) end -- insert segments before the usage ones
return M
```

## FAQ

**`tern plugin list` 将插件显示为 `disabled`。**
Tern 会禁用出错的插件，或状态格式化器超出时间预算的插件。运行 `tern plugin reload`，然后在 Tern 的日志（Windows 上为 `%LOCALAPPDATA%\Tern\Logs\tern.log`）中查找包含 `omp-usage` 的行，并附上这些行提交 Issue。

**状态栏显示 `✻ Claude ?` 或 `⬢ Codex ?`。**
上一次 `omp usage` 调用失败了。请在终端中检查 `omp usage --json -p anthropic`（或 `-p openai-codex`）是否能正常运行；如果不能，请先用 omp 登录。点击任意片段即可重试。

**完全没有显示任何内容。**
请确认状态栏已开启（Tern 设置中的 `"status_bar": true`）。如果已开启，Tern 的守护进程可能找不到 `omp`：请将 `OMP_USAGE_BIN` 设置为其完整路径，然后重启 Tern。

**数字比 claude.ai 慢。**
它们来自同一个用量接口，通过 omp 每 5 分钟读取一次，因为 Anthropic 会对更频繁的轮询进行限速。点击某个片段即可强制刷新。

**为什么今天的 token 数这么高？**
其中包含缓存读取，它们占了智能体输入的大部分。费用是这些 token 按 API 价格计算的结果，而不是你的订阅实际收取的金额。

**如何卸载？**
`tern plugin remove omp-usage`。

## 贡献

本项目采用 MIT 开源许可：可以使用、分叉、修改、发布。任何人都可以提交 Issue 和 Pull Request。

- `python scripts/check.py` 会验证语法、测试、CSS 和 manifest。CI 运行的也是同样的内容。添加 `--tern` 还会在你的 Tern 中重新加载插件并读取其日志。
- 使用 AI 代理？请让它参考 [AGENTS.md](AGENTS.md)。其中说明了容易出错的规则，以及如何为你提交规范的 Bug 报告。
- 更多内容见 [CONTRIBUTING.md](CONTRIBUTING.md)。参与者需遵守 [行为准则](CODE_OF_CONDUCT.md)；安全问题请通过 [SECURITY.md](SECURITY.md) 上报。

## Star 历史

[![Star History Chart](https://api.star-history.com/svg?repos=joaodutra88/tern-omp-usage&type=Date)](https://star-history.com/#joaodutra88/tern-omp-usage&Date)
