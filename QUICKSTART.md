# Guía Rápida - WebViewANE

## Instalación Rápida

### 1. Compilar el ANE

**En macOS/Linux:**
```bash
chmod +x build-ane.sh
./build-ane.sh
```

**En Windows:**
```cmd
build-ane.bat
```

### 2. Usar en tu Proyecto

1. Copia `WebViewANE.ane` a tu proyecto
2. Agrega el ANE en tu `*-app.xml`:
```xml
<extensions>
    <extensionID>com.fluocode.ane.Webview</extensionID>
</extensions>
```

3. Empaqueta tu app incluyendo el ANE:
```bash
adt -package -target apk ... -extdir . WebViewANE.ane
```

### 3. Código Mínimo

```actionscript
import com.fluocode.ane.webview.WebViewANE;

var webView:WebViewANE = new WebViewANE();
if (webView.isAvailable) {
    webView.init(0, 0, stage.stageWidth, stage.stageHeight);
    webView.loadURL("https://www.google.com");
}
```

## Probar el Proyecto de Ejemplo

1. Compila el proyecto de prueba:
```bash
amxmlc -output test-project/bin/Main.swf test-project/src/Main.as
```

2. Empaqueta para Android:
```bash
adt -package -target apk test-project/bin/WebViewANETest.apk \
    test-project/src/Main-app.xml test-project/bin/Main.swf \
    -extdir . WebViewANE.ane
```

3. Instala en tu dispositivo:
```bash
adb install test-project/bin/WebViewANETest.apk
```

## Solución Rápida de Problemas

**El WebView no aparece:**
- Verifica que `init()` fue llamado
- Verifica que `isAvailable` es `true`
- Revisa los logs: `adb logcat | grep WebViewANE`

**JavaScript no funciona:**
- Espera a que la página cargue antes de ejecutar JavaScript
- Usa el evento `PAGE_LOADED` para saber cuándo está lista

**El ANE no se carga:**
- Verifica que el `extensionID` coincida en `extension.xml` y tu app
- Asegúrate de incluir el ANE con `-extdir`

