[English](README.md) | **Português** | [Español](README.es.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md)

O README em inglês é a referência e prevalece se houver diferença.

# tern-omp-usage

[![check](https://github.com/joaodutra88/tern-omp-usage/actions/workflows/check.yml/badge.svg)](https://github.com/joaodutra88/tern-omp-usage/actions/workflows/check.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/joaodutra88/tern-omp-usage?style=flat)](https://github.com/joaodutra88/tern-omp-usage/stargazers)

Um plugin de barra de status do [Tern](https://stencil.so/tern) para usuários do [omp](https://omp.sh). Ele mantém na tela, em uma única linha, os limites de assinatura do Claude e do Codex, o orçamento de gastos da semana e os tokens e o custo de hoje, sem nenhum painel para abrir.

![Uso do Claude e do Codex na barra de status do Tern](assets/statusline.png)

## O que ele responde

Tudo fica na barra de status, então as respostas estão na tela enquanto você trabalha:

- **Dá pra encarar uma execução pesada hoje?** Um orçamento da semana de trabalho: cada dia útil libera 20% da cota semanal, e a parte de um feriado fica guardada.
- **Quanto custou hoje?** Tokens e custo ao preço da API desde a meia-noite, em todos os provedores que o omp acompanha.
- **Tenho um reset guardado?** Resets salvos de limite de uso para Claude e Codex.
- **Claude e Codex lado a lado**, ambos lidos pelo omp, sem nenhum login novo.

## O que cada parte significa

| Aparência | Significado |
|---|---|
| <img src="assets/seg-window.png" height="28" alt="janela de 5h"> | Uso de uma janela: 5h, semana (`wk`) e Fable, quando o seu plano tem. Cada ponto mantém sua própria cor, do verde ao vermelho, e a porcentagem assume a cor do último ponto alcançado. Em 80%, a porcentagem vira um selo vermelho pulsante. |
| <img src="assets/seg-reset.png" height="28" alt="contagem até o reset"> | Tempo até a janela de 5h do Claude ser redefinida. Fica verde quando faltam menos de 30 min e a janela de 5h está em 80% ou mais, o que significa que o alívio está perto. |
| <img src="assets/seg-credits.png" height="28" alt="resets salvos"> | Resets de limite de uso que você tem guardados. |
| <img src="assets/seg-budget.png" height="28" alt="orçamento da semana de trabalho"> | Orçamento da semana de trabalho. Cada dia de segunda a sexta da janela atual de 7 dias libera 20% da cota semanal. `left` é a cota liberada e ainda não gasta. `over` (vermelho pulsante) significa que você está gastando à frente da semana. |
| <img src="assets/seg-codex.png" height="28" alt="Codex"> | Codex. `×2` é o número de contas vinculadas, e as janelas mostram a parte das contas que já foi esgotada. |
| <img src="assets/seg-today.png" height="28" alt="tokens e custo de hoje"> | Tokens e custo ao preço da API desde a meia-noite local, todos os provedores, a partir de `omp stats`. Leituras de cache contam como tokens, então a maior parte desse número é cache. |
| <img src="assets/seg-refresh.png" height="28" alt="atualizar"> | Atualizar agora. Clicar em qualquer segmento de uso faz o mesmo. |

## Como fica ao longo da semana

Estes exemplos foram renderizados a partir de respostas fixas do `omp`, então você pode ver estados que não acontecem todos os dias.

**Manhã tranquila.** Tudo verde, bastante orçamento.

![calmo](assets/state-calm.png)

**Uso subindo.** Um `↑` aparece quando uma janela subiu 3 pontos ou mais desde a última leitura, 5 minutos antes.

![subindo](assets/state-rising.png)

**Janela de 5h quente.** Em 86%, a porcentagem vira um selo vermelho, e o reset fica verde porque o alívio está a 21 minutos.

![quente](assets/state-hot.png)

**À frente da semana.** 65% da semana usados com apenas 40% liberados: `over 25%` pulsa até o próximo dia útil alcançar.

![acima do orçamento](assets/state-over.png)

**Bloqueado.** Uma janela em 100% mostra um selo pulsante com o tempo até ser liberada e os seus resets salvos.

![bloqueado](assets/state-locked.gif)

## Instalação

```sh
tern plugin install https://github.com/joaodutra88/tern-omp-usage
```

Você precisa do `omp` logado na Anthropic e/ou no OpenAI Codex, de forma que `omp usage` funcione em um terminal. O plugin usa o omp que o Tern gerencia (`%LOCALAPPDATA%\Tern\omp\bin\omp.exe`) e recorre ao `omp` no `PATH`. Se o daemon do Tern não encontrar o executável, defina `OMP_USAGE_BIN` com o caminho completo.

### Instalar com o seu agente de IA

Cole isto no omp, no Claude Code, no Codex ou em qualquer agente que consiga executar comandos:

```text
Install the Tern plugin https://github.com/joaodutra88/tern-omp-usage for me.
1. Check `omp usage --json -p anthropic` (or `-p openai-codex`) works. If it doesn't, help me sign in with omp first.
2. Run `tern plugin install https://github.com/joaodutra88/tern-omp-usage`.
3. Run `tern plugin list --json` and confirm `omp-usage` has status "ready".
4. If it isn't ready, read the lines containing `omp-usage` in Tern's log
   (`%LOCALAPPDATA%\Tern\Logs\tern.log` on Windows) and the repo's AGENTS.md, then tell me what is wrong.
5. Explain what each part of the status line means, using the README.
```

## O que ele executa e o que toca

O plugin não faz requisições de rede e não lê credenciais. Ele apenas executa o omp:

| Comando | Quando |
|---|---|
| `omp usage --json -p anthropic` | A cada 5 min. O endpoint de uso da Anthropic responde 429 abaixo de cerca de 5 min. |
| `omp usage --json -p openai-codex` | A cada 5 min |
| `omp stats --json` | A cada 5 min |
| `omp usage invalidate` | Quando você clica em um segmento, para pular o cache do omp |

Ele não grava nada em disco. O formatador da barra só lê os valores em cache dessas chamadas, porque o Tern dá 4 ms para um formatador.

## Configuração

| Onde | Nome | Padrão |
|---|---|---|
| `usage.luau` | `DAILY` | `0.20`, cota liberada por dia útil |
| `usage.luau` | `TREND_STEP` | `0.03`, subida que ganha o `↑` |
| `usage.luau` | `M.labels` | As palavras que a barra mostra (`left`, `over`, `LOCKED`, `tokens`) |
| `window.luau` | `FETCH_MS` | 5 min |
| ambiente | `OMP_USAGE_BIN` | Caminho do `omp` quando o Tern não o encontra |

As cores são CSS simples no final de `window.luau`. Cada segmento é `#statusline .sl-plugin[title="plugin.omp-usage.<name>"]`.

### No seu idioma

Cada palavra que a barra mostra fica em `M.labels`, no topo de `usage.luau`, então traduzir é uma mudança de uma linha. Pull requests que adicionem um idioma são bem-vindos.

### Seus próprios segmentos

Se existir um arquivo `extras.luau` ao lado de `window.luau`, o plugin o carrega. O Git o ignora, então segmentos pessoais nunca chegam ao repositório:

```luau
local M = {}
function M.init(hidden, every) end -- register commands, timers, CSS
function M.segments(out, pane) end -- insert segments before the usage ones
return M
```

## Contribuindo

Este projeto é open source sob MIT: use, faça fork, altere, publique. Issues e pull requests são abertos a todos.

- `python scripts/check.py` valida sintaxe, testes, CSS e o manifesto. O CI executa a mesma coisa. Adicione `--tern` para também recarregar o plugin no seu Tern e ler o log dele.
- Usando um agente de IA? Aponte para [AGENTS.md](AGENTS.md). Ele explica as regras que são fáceis de quebrar e como abrir um relatório de bug limpo para você.
- Mais em [CONTRIBUTING.md](CONTRIBUTING.md).

## Histórico de estrelas

[![Gráfico de histórico de estrelas](https://api.star-history.com/svg?repos=joaodutra88/tern-omp-usage&type=Date)](https://star-history.com/#joaodutra88/tern-omp-usage&Date)
