# Cómo ver los logs de WebViewANE con jukeboxhub

## Opción 1: Console.app (Más fácil)

1. **Conecta tu dispositivo iOS** al Mac
2. Abre **Console.app** (Aplicaciones → Utilidades → Consola)
3. En la barra lateral izquierda, selecciona tu **dispositivo iOS**
4. En la barra de búsqueda superior, escribe: `WebViewANE`
5. **Ejecuta tu app jukeboxhub** en el dispositivo
6. Los logs aparecerán en tiempo real con el prefijo `[WebViewANE]`

## Opción 2: Script en línea de comandos

```bash
cd /Users/fluocode/Documents/GitHub/ANE-Webview
./ver-logs-jukeboxhub.sh
```

Luego ejecuta tu app jukeboxhub en el dispositivo y verás los logs en tiempo real.

## Opción 3: Xcode

1. Conecta tu dispositivo
2. Abre Xcode
3. **Window → Devices and Simulators** (⇧⌘2)
4. Selecciona tu dispositivo
5. Haz clic en **Open Console**
6. Los logs aparecerán en tiempo real

## Qué buscar en los logs

Cuando ejecutes tu app, deberías ver:

1. **`[WebViewANE] ExtInitializer: WebViewANE extension inicializada`** - Cuando se carga el ANE
2. **`[WebViewANE] ContextInitializer: Inicializando contexto WebViewANE`** - Cuando se crea el contexto
3. **`[WebViewANE] initWebView: window=YES, rootViewController=YES`** - Cuando se inicializa el WebView
4. **`[WebViewANE] WebView creado: frame=...`** - Cuando se crea el WebView
5. **`[WebViewANE] loadURL: Cargando URL: ...`** - Cuando cargas una URL
6. **`[WebViewANE] Página cargada: ...`** - Cuando la página termina de cargar

## Si no ves logs

- Asegúrate de que la app jukeboxhub esté corriendo
- Verifica que el dispositivo esté conectado
- Intenta buscar solo "WebViewANE" sin las llaves en Console.app

