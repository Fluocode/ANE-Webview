# Debugging: "WebView no inicializado o contexto inválido"

## El problema

Estás viendo este error:
```
[WebViewANE] loadURL: WebView no inicializado o contexto inválido
```

Esto significa que **`loadURL` se está llamando antes de que el WebView se inicialice**, o **`initWebView` nunca se está llamando**.

## Posibles causas

1. **No estás llamando a `init()` antes de `loadURL()`** en tu código ActionScript
2. **Hay un problema de sincronización**: `init()` es asíncrono y retorna inmediatamente, pero el WebView tarda un momento en crearse
3. **`init()` está fallando silenciosamente**

## Cómo verificar

Después de recompilar, cuando ejecutes jukeboxhub, deberías ver estos logs en orden:

1. `[WebViewANE] ExtInitializer: WebViewANE extension inicializada`
2. `[WebViewANE] ContextInitializer: Inicializando contexto WebViewANE`
3. **`[WebViewANE] initWebView: Llamada recibida...`** ← **DEBES VER ESTO**
4. `[WebViewANE] initWebView: Parámetros recibidos: x=..., y=..., width=..., height=...`
5. `[WebViewANE] initWebView: Ejecutando en main queue...`
6. `[WebViewANE] initWebView: window=YES, rootViewController=YES`
7. `[WebViewANE] WebView creado: frame=...`
8. `[WebViewANE] WebView inicializado exitosamente: ...`

**Si NO ves el paso 3**, significa que **no estás llamando a `init()`** en tu código ActionScript.

## Solución en ActionScript

Asegúrate de llamar a `init()` ANTES de `loadURL()`:

```actionscript
var webView:WebViewANE = new WebViewANE();

// 1. PRIMERO: Inicializar
if (webView.init(10, 100, stage.stageWidth - 20, 400)) {
    trace("WebView inicializado correctamente");
    
    // 2. ESPERAR un momento (opcional pero recomendado)
    setTimeout(function():void {
        // 3. DESPUÉS: Cargar URL
        webView.loadURL("https://www.google.com");
    }, 100); // Esperar 100ms para que el WebView se cree completamente
} else {
    trace("ERROR: No se pudo inicializar el WebView");
}
```

O mejor aún, espera al evento de inicialización completa (si está disponible) o usa un pequeño delay:

```actionscript
var webView:WebViewANE = new WebViewANE();

if (webView.init(10, 100, stage.stageWidth - 20, 400)) {
    trace("WebView inicializado, esperando a que esté listo...");
    
    // Esperar a que el WebView esté completamente inicializado
    var initTimer:Timer = new Timer(200, 1); // 200ms
    initTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
        webView.loadURL("https://www.google.com");
    });
    initTimer.start();
}
```

## Verificar los logs

Ejecuta:
```bash
./ver-logs-jukeboxhub.sh
```

Y busca si ves `[WebViewANE] initWebView: Llamada recibida...` cuando ejecutas tu app.

