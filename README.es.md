[English](README.md) | [Português](README.pt-BR.md) | **Español** | [简体中文](README.zh-CN.md) | [日本語](README.ja.md)

El README en inglés es la referencia y prevalece si hay diferencias.

# tern-omp-usage

[![check](https://github.com/joaodutra88/tern-omp-usage/actions/workflows/check.yml/badge.svg)](https://github.com/joaodutra88/tern-omp-usage/actions/workflows/check.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/joaodutra88/tern-omp-usage?style=flat)](https://github.com/joaodutra88/tern-omp-usage/stargazers)

Un plugin de barra de estado de [Tern](https://stencil.so/tern) para usuarios de [omp](https://omp.sh). Mantiene en pantalla los límites de suscripción de Claude y Codex, el presupuesto de gasto de esta semana y los tokens y el costo de hoy, en una sola línea, sin tener que abrir ningún panel.

![Uso de Claude y Codex en la barra de estado de Tern](assets/statusline.png)

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

![tranquila](assets/state-calm.png)

**El uso sube.** Aparece una `↑` cuando una ventana subió 3 puntos o más desde la última lectura, 5 minutos antes.

![subiendo](assets/state-rising.png)

**Ventana de 5h caliente.** Al 86% el porcentaje se convierte en una insignia roja, y el reinicio se pone verde porque el alivio está a 21 minutos.

![caliente](assets/state-hot.png)

**Por delante de la semana.** Se ha usado el 65% de la semana con solo el 40% desbloqueado: `over 25%` pulsa hasta que el siguiente día hábil se ponga al día.

![sobre presupuesto](assets/state-over.png)

**Bloqueada.** Una ventana al 100% muestra una insignia pulsante con el tiempo hasta que se libere y tus reinicios guardados.

![bloqueada](assets/state-locked.gif)

## Instalación

```sh
tern plugin install https://github.com/joaodutra88/tern-omp-usage
```

Necesitas `omp` con sesión iniciada en Anthropic y/o OpenAI Codex, para que `omp usage` funcione en una terminal. El plugin usa el omp que gestiona Tern (`%LOCALAPPDATA%\Tern\omp\bin\omp.exe`) y recurre a `omp` en el `PATH`. Si el demonio de Tern no lo encuentra, define `OMP_USAGE_BIN` con la ruta completa.

### Instalar con tu agente de IA

Pega esto en omp, Claude Code, Codex o cualquier agente que pueda ejecutar comandos:

```text
Instala el plugin de Tern https://github.com/joaodutra88/tern-omp-usage por mí.
1. Comprueba que `omp usage --json -p anthropic` (o `-p openai-codex`) funciona. Si no funciona, ayúdame a iniciar sesión en omp primero.
2. Ejecuta `tern plugin install https://github.com/joaodutra88/tern-omp-usage`.
3. Ejecuta `tern plugin list --json` y confirma que `omp-usage` tiene el estado "ready".
4. Si no está listo, lee las líneas que contienen `omp-usage` en el log de Tern
   (`%LOCALAPPDATA%\Tern\Logs\tern.log` en Windows) y el AGENTS.md del repositorio, y luego dime qué está mal.
5. Explica qué significa cada parte de la barra de estado, usando el README.
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

## Contribuir

Es código abierto bajo MIT: úsalo, haz un fork, cámbialo, publícalo. Los issues y los pull requests están abiertos para todos.

- `python scripts/check.py` valida la sintaxis, las pruebas, el CSS y el manifiesto. CI ejecuta lo mismo. Añade `--tern` para además recargar el plugin en tu Tern y leer su log.
- ¿Usas un agente de IA? Apúntalo a [AGENTS.md](AGENTS.md). Explica las reglas que se rompen fácilmente y cómo presentar un reporte de bug limpio para ti.
- Más en [CONTRIBUTING.md](CONTRIBUTING.md).

## Historial de estrellas

[![Star History Chart](https://api.star-history.com/svg?repos=joaodutra88/tern-omp-usage&type=Date)](https://star-history.com/#joaodutra88/tern-omp-usage&Date)
