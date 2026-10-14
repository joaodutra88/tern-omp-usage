<div align="center">

<img src="assets/banner.png" width="760" alt="tern-omp-usage: límites de Claude y Codex desde omp, directamente en la barra de estado de Tern">

[![check](https://github.com/joaodutra88/tern-omp-usage/actions/workflows/check.yml/badge.svg)](https://github.com/joaodutra88/tern-omp-usage/actions/workflows/check.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/joaodutra88/tern-omp-usage?style=flat)](https://github.com/joaodutra88/tern-omp-usage/stargazers)
[![Latest release](https://img.shields.io/github/v/release/joaodutra88/tern-omp-usage)](https://github.com/joaodutra88/tern-omp-usage/releases/latest)

Un plugin de barra de estado de [Tern](https://stencil.so/tern) para usuarios de [omp](https://omp.sh). Mantiene en pantalla los límites de suscripción de Claude y Codex, el presupuesto de gasto de esta semana y los tokens y el costo de hoy, en una sola línea, sin tener que abrir ningún panel.

**[Instalación](#instalación)** · **[Qué significa cada parte](#qué-significa-cada-parte)** · **[Configuración](#configuración)** · **[FAQ](#faq)** · **[Contribuir](#contribuir)**

[English](README.md) | [Português](README.pt-BR.md) | **Español** | [简体中文](README.zh-CN.md) | [日本語](README.ja.md)

El README en inglés es la referencia y prevalece si hay diferencias.

<img src="assets/statusline.png" alt="Uso de Claude y Codex en la barra de estado de Tern">

</div>

## Qué responde

Todo queda en la barra de estado, así que las respuestas están en pantalla mientras trabajas:

- **¿Puedo permitirme una ejecución pesada hoy?** Un presupuesto de la semana laboral: cada día hábil desbloquea el 20% de la cuota semanal, y la parte de un feriado se traslada.
- **¿Cuánto costó hoy?** Tokens y costo a precio de API desde medianoche, de todos los proveedores que omp registra.
- **¿Tengo un reinicio guardado?** Reinicios guardados de límites de uso para Claude y Codex.
- **Claude y Codex lado a lado**, ambos leídos a través de omp, sin nada nuevo que iniciar sesión.

## Qué significa cada parte

| Se ve así | Significado |
|---|---|
| <img src="assets/seg-window.png" height="28" alt="ventana de 5h"> | Uso de una ventana: 5h, semana (`wk`) y Fable cuando tu plan lo incluye. Cada punto conserva su propio color, de verde a rojo, y el porcentaje toma el color del último punto alcanzado. Al 80% el porcentaje se convierte en una insignia roja pulsante. |
| <img src="assets/seg-reset.png" height="28" alt="cuenta regresiva del reinicio"> | Tiempo hasta que se reinicia la ventana de 5h de Claude. Se pone verde cuando faltan menos de 30 min y la ventana de 5h está al 80% o más, lo que indica que el alivio está cerca. |
| <img src="assets/seg-credits.png" height="28" alt="reinicios guardados"> | Reinicios de límite de uso que tienes guardados. |
| <img src="assets/seg-budget.png" height="28" alt="presupuesto de la semana laboral"> | Presupuesto de la semana laboral. Cada día de lunes a viernes de la ventana actual de 7 días desbloquea el 20% de la cuota semanal. `left` es la cuota desbloqueada y aún no gastada. `over` (rojo pulsante) significa que estás gastando por delante de la semana. |
| <img src="assets/seg-codex.png" height="28" alt="Codex"> | Codex. `×2` es el número de cuentas vinculadas, y las ventanas muestran la proporción de cuentas agotadas. |
| <img src="assets/seg-today.png" height="28" alt="tokens y costo de hoy"> | Tokens y costo a precio de API desde la medianoche local, todos los proveedores, desde `omp stats`. Las lecturas de caché cuentan como tokens, así que la mayor parte de este número es caché. |
| <img src="assets/seg-refresh.png" height="28" alt="actualizar"> | Actualizar ahora. Hacer clic en cualquier segmento de uso hace lo mismo. |

## Cómo se ve a lo largo de la semana

Estas imágenes se generaron a partir de respuestas fijas de `omp`, así que puedes ver estados que no ocurren todos los días.

**Mañana tranquila.** Todo en verde, mucho presupuesto.

<p align="center"><img src="assets/state-calm.png" alt="tranquila"></p>

**El uso sube.** Aparece una `↑` cuando una ventana subió 3 puntos o más desde la última lectura, 5 minutos antes.

<p align="center"><img src="assets/state-rising.png" alt="subiendo"></p>

**Ventana de 5h caliente.** Al 86% el porcentaje se convierte en una insignia roja, y el reinicio se pone verde porque el alivio está a 21 minutos.

<p align="center"><img src="assets/state-hot.png" alt="caliente"></p>

**Por delante de la semana.** Se ha usado el 65% de la semana con solo el 40% desbloqueado: `over 25%` pulsa hasta que el siguiente día hábil se ponga al día.

<p align="center"><img src="assets/state-over.png" alt="sobre presupuesto"></p>

**Bloqueada.** Una ventana al 100% muestra una insignia pulsante con el tiempo hasta que se libere y tus reinicios guardados.

<p align="center"><img src="assets/state-locked.gif" alt="bloqueada"></p>

## Instalación

```sh
tern plugin install https://github.com/joaodutra88/tern-omp-usage
```

Necesitas `omp` con sesión iniciada en Anthropic y/o OpenAI Codex, para que `omp usage` funcione en una terminal. El plugin usa el omp que gestiona Tern (`%LOCALAPPDATA%\Tern\omp\bin\omp.exe`) y recurre a `omp` en el `PATH`. Si el demonio de Tern no lo encuentra, define `OMP_USAGE_BIN` con la ruta completa.

### Instalar con tu agente de IA

Pega esto en omp, Claude Code, Codex o cualquier agente que pueda ejecutar comandos:

```text
Install the Tern plugin https://github.com/joaodutra88/tern-omp-usage for me.
1. Check `omp usage --json -p anthropic` (or `-p openai-codex`) works. If it doesn't, help me sign in with omp first.
2. Run `tern plugin install https://github.com/joaodutra88/tern-omp-usage`.
3. Run `tern plugin list --json` and confirm `omp-usage` has status "ready".
4. If it isn't ready, read the lines containing `omp-usage` in Tern's log
   (`%LOCALAPPDATA%\Tern\Logs\tern.log` on Windows) and the repo's AGENTS.md, then tell me what is wrong.
5. Explain what each part of the status line means, using the README.
```

## Qué ejecuta y qué toca

El plugin no hace peticiones de red ni lee credenciales. Solo ejecuta omp:

| Comando | Cuándo |
|---|---|
| `omp usage --json -p anthropic` | Cada 5 min. El endpoint de uso de Anthropic responde 429 por debajo de unos 5 min. |
| `omp usage --json -p openai-codex` | Cada 5 min |
| `omp stats --json` | Cada 5 min |
| `omp usage invalidate` | Al hacer clic en un segmento, para saltarse la caché de omp |

No escribe nada en disco. El formateador de la barra solo lee los valores en caché que dejan esas llamadas, porque Tern le da a un formateador 4 ms.

## Configuración

| Dónde | Nombre | Valor por defecto |
|---|---|---|
| `usage.luau` | `DAILY` | `0.20`, cuota desbloqueada por día hábil |
| `usage.luau` | `TREND_STEP` | `0.03`, subida que gana la `↑` |
| `usage.luau` | `M.labels` | Las palabras que muestra la barra (`left`, `over`, `LOCKED`, `tokens`) |
| `window.luau` | `FETCH_MS` | 5 min |
| entorno | `OMP_USAGE_BIN` | Ruta a `omp` cuando Tern no la encuentra |

Los colores son CSS simple al final de `window.luau`. Cada segmento es `#statusline .sl-plugin[title="plugin.omp-usage.<name>"]`.

### En tu idioma

Cada palabra que muestra la barra vive en `M.labels`, al inicio de `usage.luau`, así que traducirla es un cambio de una línea. Se agradecen los pull requests que añadan un idioma.

### Tus propios segmentos

Si existe un archivo `extras.luau` junto a `window.luau`, el plugin lo carga. Git lo ignora, así que tus segmentos personales nunca llegan al repositorio:

```luau
local M = {}
function M.init(hidden, every) end -- registrar comandos, temporizadores, CSS
function M.segments(out, pane) end -- insertar segmentos antes de los de uso
return M
```

## FAQ

**`tern plugin list` muestra el plugin como `disabled`.**
Tern desactiva un plugin que produce errores o cuyo formateador de estado supera su presupuesto de tiempo. Ejecuta `tern plugin reload`, luego busca las líneas con `omp-usage` en el log de Tern (`%LOCALAPPDATA%\Tern\Logs\tern.log` en Windows) y abre un issue con ellas.

**La barra muestra `✻ Claude ?` o `⬢ Codex ?`.**
La última llamada a `omp usage` falló. Comprueba que `omp usage --json -p anthropic` (o `-p openai-codex`) funciona en una terminal, e inicia sesión con omp si no funciona. Haz clic en cualquier segmento para reintentar.

**No aparece nada.**
Asegúrate de que la barra de estado esté activada (`"status_bar": true` en la configuración de Tern). Si lo está, es posible que el demonio de Tern no encuentre `omp`: define `OMP_USAGE_BIN` con su ruta completa y reinicia Tern.

**Los números van por detrás de claude.ai.**
Vienen del mismo endpoint de uso a través de omp, cada 5 minutos, porque Anthropic limita la frecuencia de las consultas más rápidas. Haz clic en un segmento para forzar una lectura nueva.

**¿Por qué el conteo de tokens de hoy es tan alto?**
Incluye las lecturas de caché, que son la mayor parte de la entrada de un agente. El costo es lo que esos tokens costarían a precio de API, no lo que cobra tu suscripción.

**¿Cómo lo desinstalo?**
`tern plugin remove omp-usage`.

## Contribuir

Es código abierto bajo MIT: úsalo, haz un fork, cámbialo, publícalo. Los issues y los pull requests están abiertos para todos.

- `python scripts/check.py` valida la sintaxis, las pruebas, el CSS y el manifiesto. CI ejecuta lo mismo. Añade `--tern` para además recargar el plugin en tu Tern y leer su log.
- ¿Usas un agente de IA? Apúntalo a [AGENTS.md](AGENTS.md). Explica las reglas que se rompen fácilmente y cómo presentar un reporte de bug limpio para ti.
- Más en [CONTRIBUTING.md](CONTRIBUTING.md). Todos los participantes siguen el [Código de conducta](CODE_OF_CONDUCT.md); los problemas de seguridad se tratan según [SECURITY.md](SECURITY.md).

## Historial de estrellas

[![Star History Chart](https://api.star-history.com/svg?repos=joaodutra88/tern-omp-usage&type=Date)](https://star-history.com/#joaodutra88/tern-omp-usage&Date)
