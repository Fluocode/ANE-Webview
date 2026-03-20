🌐 WebViewANE (Adobe AIR ANE for a Modern WebView)

WebViewANE is an Adobe Native Extension (ANE) that embeds a modern WebView in your Adobe AIR app. It supports HTML5 content and allows you to execute JavaScript from ActionScript, while also receiving messages/events back from JavaScript.

✨ Key Features

- Modern HTML5 + JavaScript support (iOS uses `WKWebView`, Android uses `WebView`)
- Two-way communication between JavaScript and ActionScript
- Navigation helpers (back/forward/history)
- Page lifecycle events (loaded/error/url changes)
- Custom scheme support (handled via events)
- Optional auto-close/hide behavior triggered from JavaScript

🧰 What You Need

- Adobe AIR 33.1+ (required to use ANEs)
- iOS: iOS 9.0+
- Android: Android 5.0 (API 21)+

🔌 Add the Extension to Your AIR App

In your `*-app.xml` (or the AIR descriptor file you already use), add the extension ID:

```xml
<extensions>
  <extensionID>com.fluocode.ane.Webview</extensionID>
</extensions>
```

🛡️ Descriptor XML Permissions (Only If Needed)

WebViewANE loads web content, so your app must have network permission and (on iOS) an explanation string. If you only load HTTPS content, you may not need relaxed iOS transport security settings; however, keep the “local network usage” description.

🍎 iOS (`-app.xml`)

Add the network usage description:

```xml
<iPhone>
  <InfoAdditions>
    <![CDATA[
      <key>NSLocalNetworkUsageDescription</key>
      <string>This app needs network access to load web content.</string>
    ]]>
  </InfoAdditions>
</iPhone>
```

If you also load `http://` (non-HTTPS) or mixed content, you may need ATS configuration. Example (use production-appropriate ATS settings when deploying):

```xml
<iPhone>
  <InfoAdditions>
    <![CDATA[
      <key>NSAppTransportSecurity</key>
      <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
      </dict>
    ]]>
  </InfoAdditions>
</iPhone>
```

🤖 Android (`-app.xml`)

At minimum, add permissions:

```xml
<manifestAdditions>
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
</manifestAdditions>
```

If you load `http://` content, you may need cleartext traffic support:

```xml
<manifestAdditions>
  <application android:usesCleartextTraffic="true">
  </application>
</manifestAdditions>
```

📚 ActionScript API (ActionScript 3)

🚀 Minimal Setup

```actionscript
import com.fluocode.ane.webview.WebViewANE;
import com.fluocode.ane.webview.WebViewEvent;

var webView:WebViewANE = new WebViewANE();

if (!webView.isAvailable) {
    trace("WebViewANE is not available.");
    return;
}

webView.init(0, 0, stage.stageWidth, stage.stageHeight);

webView.addEventListener(WebViewEvent.PAGE_LOADED, function(e:WebViewEvent):void {
    trace("PAGE_LOADED: " + e.data);
});
webView.addEventListener(WebViewEvent.PAGE_ERROR, function(e:WebViewEvent):void {
    trace("PAGE_ERROR: " + e.data);
});
```

### 1. `isAvailable` (getter)

```actionscript
if (webView.isAvailable) {
    trace("ANE context is ready.");
}
```

### 2. `init(x:Number, y:Number, width:Number, height:Number):Boolean`

```actionscript
var ok:Boolean = webView.init(0, 0, stage.stageWidth, stage.stageHeight);
if (!ok) trace("init() failed.");
```

### 3. `loadURL(url:String):void`

```actionscript
webView.loadURL("https://example.com");
```

### 4. `loadHTML(html:String, baseURL:String = null):void`

```actionscript
var html:String = "<html><body><h1>Hello</h1></body></html>";
webView.loadHTML(html);
```

### 5. `evaluateJavaScript(script:String):void`

```actionscript
webView.evaluateJavaScript("console.log('Hello from AIR');");
```

### 6. `goBack():void`

```actionscript
if (webView.canGoBack()) webView.goBack();
```

### 7. `goForward():void`

```actionscript
if (webView.canGoForward()) webView.goForward();
```

### 8. `reload():void`

```actionscript
webView.reload();
```

### 9. `stop():void`

```actionscript
webView.stop();
```

### 10. `setVisible(visible:Boolean):void`

```actionscript
webView.setVisible(true);   // show
webView.setVisible(false);  // hide
```

### 11. `setBounds(x:Number, y:Number, width:Number, height:Number):void`

```actionscript
webView.setBounds(10, 180, 800, 600);
```

### 12. `setBackgroundColor(color:uint):void`

Color format:
- `0xAARRGGBB` (ARGB) or
- `0xRRGGBB` (RGB; alpha is treated as 255/opaque)

```actionscript
webView.setBackgroundColor(0xFF000000); // opaque black (ARGB)
webView.setBackgroundColor(0x000000);   // black RGB (alpha assumed)
```

### 13. `getCurrentURL():String`

```actionscript
var url:String = webView.getCurrentURL();
trace("Current URL: " + url);
```

### 14. `canGoBack():Boolean`

```actionscript
if (webView.canGoBack()) trace("Back is available.");
```

### 15. `canGoForward():Boolean`

```actionscript
if (webView.canGoForward()) trace("Forward is available.");
```

### 16. `clearCache():void`

```actionscript
webView.clearCache();
```

### 17. `dispose():void`

```actionscript
webView.dispose();
```

### 18. `enableAutoCloseOnMessage(message:String = "close_webview", disposeOnClose:Boolean = false):void`

Use this when you want a web page button to hide/close the WebView by sending a message from JavaScript.

```actionscript
webView.enableAutoCloseOnMessage("close_webview", false);
```

📡 Events

You receive `WebViewEvent` with `e.data` as the payload (URL, error message, or JS message).

```actionscript
webView.addEventListener(WebViewEvent.URL_CHANGED, function(e:WebViewEvent):void {
    trace("URL_CHANGED: " + e.data);
});

webView.addEventListener(WebViewEvent.JAVASCRIPT_MESSAGE, function(e:WebViewEvent):void {
    trace("JAVASCRIPT_MESSAGE: " + e.data);
});

webView.addEventListener(WebViewEvent.CUSTOM_SCHEME, function(e:WebViewEvent):void {
    trace("CUSTOM_SCHEME: " + e.data);
});
```

Event list:

- `WebViewEvent.PAGE_LOADED`: fired when the page finishes loading (payload is the URL)
- `WebViewEvent.PAGE_ERROR`: fired on navigation/load errors (payload is an error string)
- `WebViewEvent.URL_CHANGED`: fired when the URL changes (payload is the current URL)
- `WebViewEvent.JAVASCRIPT_MESSAGE`: fired when JavaScript sends a message (payload is the message string)
- `WebViewEvent.CUSTOM_SCHEME`: fired when a custom URL scheme is detected (payload is the detected value, e.g. `jukeboxhub://...`)

💬 JavaScript Integration

From your web page:

```html
<script>
  if (window.webViewANE) {
    window.webViewANE.sendMessage("Hello from JavaScript!");
  }
</script>
```

Auto-close/hide example:

```html
<button onclick="onCancel()">Cancel</button>
<script>
  function onCancel() {
    if (window.webViewANE) {
      window.webViewANE.sendMessage("close_webview");
    }
  }
</script>
```

🔑 API Keys / Credentials

No API keys are required for using this ANE. The ANE does not call external services; it only renders web content and forwards navigation/JavaScript messages back to your AIR app.

🌐 WebViewANE (Adobe AIR ANE for a Modern WebView)

WebViewANE is an Adobe Native Extension (ANE) that embeds a modern WebView in your Adobe AIR app. It supports HTML5 content and allows you to execute JavaScript from ActionScript, while also receiving messages/events back from JavaScript.

✨ Key Features

- Modern HTML5 + JavaScript support (iOS uses `WKWebView`, Android uses `WebView`)
- Two-way communication between JavaScript and ActionScript
- Navigation helpers (back/forward/history)
- Page lifecycle events (loaded/error/url changes)
- Custom scheme support (handled via events)
- Optional auto-close/hide behavior triggered from JavaScript

🧰 What You Need

- Adobe AIR 33.1+ (required to use ANEs)
- iOS: iOS 9.0+
- Android: Android 5.0 (API 21)+

🔌 Add the Extension to Your AIR App

In your `*-app.xml` (or the AIR descriptor file you already use), add the extension ID:

```xml
<extensions>
  <extensionID>com.fluocode.ane.Webview</extensionID>
</extensions>
```

🛡️ Descriptor XML Permissions (Only If Needed)

WebViewANE loads web content, so your app must have network permission and (on iOS) an explanation string. If you only load HTTPS content, you may not need relaxed iOS transport security settings; however, keep the “local network usage” description.

🍎 iOS (`-app.xml`)

Add the network usage description:

```xml
<iPhone>
  <InfoAdditions>
    <![CDATA[
      <key>NSLocalNetworkUsageDescription</key>
      <string>This app needs network access to load web content.</string>
    ]]>
  </InfoAdditions>
</iPhone>
```

If you also load `http://` (non-HTTPS) or mixed content, you may need ATS configuration. Example (use production-appropriate ATS settings when deploying):

```xml
<iPhone>
  <InfoAdditions>
    <![CDATA[
      <key>NSAppTransportSecurity</key>
      <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
      </dict>
    ]]>
  </InfoAdditions>
</iPhone>
```

🤖 Android (`-app.xml`)

At minimum, add permissions:

```xml
<manifestAdditions>
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
</manifestAdditions>
```

If you load `http://` content, you may need cleartext traffic support:

```xml
<manifestAdditions>
  <application android:usesCleartextTraffic="true">
  </application>
</manifestAdditions>
```

📚 ActionScript API (ActionScript 3)

🚀 Minimal Setup

```actionscript
import com.fluocode.ane.webview.WebViewANE;
import com.fluocode.ane.webview.WebViewEvent;

var webView:WebViewANE = new WebViewANE();

if (!webView.isAvailable) {
    trace("WebViewANE is not available.");
    return;
}

webView.init(0, 0, stage.stageWidth, stage.stageHeight);

webView.addEventListener(WebViewEvent.PAGE_LOADED, function(e:WebViewEvent):void {
    trace("PAGE_LOADED: " + e.data);
});
webView.addEventListener(WebViewEvent.PAGE_ERROR, function(e:WebViewEvent):void {
    trace("PAGE_ERROR: " + e.data);
});
```

### 1. `isAvailable` (getter)

```actionscript
if (webView.isAvailable) {
    trace("ANE context is ready.");
}
```

### 2. `init(x:Number, y:Number, width:Number, height:Number):Boolean`

```actionscript
var ok:Boolean = webView.init(0, 0, stage.stageWidth, stage.stageHeight);
if (!ok) trace("init() failed.");
```

### 3. `loadURL(url:String):void`

```actionscript
webView.loadURL("https://example.com");
```

### 4. `loadHTML(html:String, baseURL:String = null):void`

```actionscript
var html:String = "<html><body><h1>Hello</h1></body></html>";
webView.loadHTML(html);
```

### 5. `evaluateJavaScript(script:String):void`

```actionscript
webView.evaluateJavaScript("console.log('Hello from AIR');");
```

### 6. `goBack():void`

```actionscript
if (webView.canGoBack()) webView.goBack();
```

### 7. `goForward():void`

```actionscript
if (webView.canGoForward()) webView.goForward();
```

### 8. `reload():void`

```actionscript
webView.reload();
```

### 9. `stop():void`

```actionscript
webView.stop();
```

### 10. `setVisible(visible:Boolean):void`

```actionscript
webView.setVisible(true);   // show
webView.setVisible(false);  // hide
```

### 11. `setBounds(x:Number, y:Number, width:Number, height:Number):void`

```actionscript
webView.setBounds(10, 180, 800, 600);
```

### 12. `setBackgroundColor(color:uint):void`

Color format:
- `0xAARRGGBB` (ARGB) or
- `0xRRGGBB` (RGB; alpha is treated as 255/opaque)

```actionscript
webView.setBackgroundColor(0xFF000000); // opaque black (ARGB)
webView.setBackgroundColor(0x000000);   // black RGB (alpha assumed)
```

### 13. `getCurrentURL():String`

```actionscript
var url:String = webView.getCurrentURL();
trace("Current URL: " + url);
```

### 14. `canGoBack():Boolean`

```actionscript
if (webView.canGoBack()) trace("Back is available.");
```

### 15. `canGoForward():Boolean`

```actionscript
if (webView.canGoForward()) trace("Forward is available.");
```

### 16. `clearCache():void`

```actionscript
webView.clearCache();
```

### 17. `dispose():void`

```actionscript
webView.dispose();
```

### 18. `enableAutoCloseOnMessage(message:String = "close_webview", disposeOnClose:Boolean = false):void`

Use this when you want a web page button to hide/close the WebView by sending a message from JavaScript.

```actionscript
webView.enableAutoCloseOnMessage("close_webview", false);
```

📡 Events

You receive `WebViewEvent` with `e.data` as the payload (URL, error message, or JS message).

```actionscript
webView.addEventListener(WebViewEvent.URL_CHANGED, function(e:WebViewEvent):void {
    trace("URL_CHANGED: " + e.data);
});

webView.addEventListener(WebViewEvent.JAVASCRIPT_MESSAGE, function(e:WebViewEvent):void {
    trace("JAVASCRIPT_MESSAGE: " + e.data);
});

webView.addEventListener(WebViewEvent.CUSTOM_SCHEME, function(e:WebViewEvent):void {
    trace("CUSTOM_SCHEME: " + e.data);
});
```

Event list:

- `WebViewEvent.PAGE_LOADED`: fired when the page finishes loading (payload is the URL)
- `WebViewEvent.PAGE_ERROR`: fired on navigation/load errors (payload is an error string)
- `WebViewEvent.URL_CHANGED`: fired when the URL changes (payload is the current URL)
- `WebViewEvent.JAVASCRIPT_MESSAGE`: fired when JavaScript sends a message (payload is the message string)
- `WebViewEvent.CUSTOM_SCHEME`: fired when a custom URL scheme is detected (payload is the detected value, e.g. `jukeboxhub://...`)

💬 JavaScript Integration

From your web page:

```html
<script>
  if (window.webViewANE) {
    window.webViewANE.sendMessage("Hello from JavaScript!");
  }
</script>
```

Auto-close/hide example:

```html
<button onclick="onCancel()">Cancel</button>
<script>
  function onCancel() {
    if (window.webViewANE) {
      window.webViewANE.sendMessage("close_webview");
    }
  }
</script>
```

🔑 API Keys / Credentials

No API keys are required for using this ANE. The ANE does not call external services; it only renders web content and forwards navigation/JavaScript messages back to your AIR app.

🌐 WebViewANE (Adobe AIR ANE for a Modern WebView)

WebViewANE is an Adobe Native Extension (ANE) that embeds a modern WebView in your Adobe AIR app. It supports HTML5 content and allows you to execute JavaScript from ActionScript, while also receiving messages/events back from JavaScript.

✨ Key Features

- Modern HTML5 + JavaScript support (iOS uses `WKWebView`, Android uses `WebView`)
- Two-way communication between JavaScript and ActionScript
- Navigation helpers (back/forward/history)
- Page lifecycle events (loaded/error/url changes)
- Custom scheme support (handled via events)
- Optional auto-close/hide behavior triggered from JavaScript

🧰 What You Need

- Adobe AIR 33.1+ (required to use ANEs)
- iOS: iOS 9.0+
- Android: Android 5.0 (API 21)+

🔌 Add the Extension to Your AIR App

In your `*-app.xml` (or the AIR descriptor file you already use), add the extension ID:

```xml
<extensions>
  <extensionID>com.fluocode.ane.Webview</extensionID>
</extensions>
```

🛡️ Descriptor XML Permissions (Only If Needed)

WebViewANE loads web content, so your app must have network permission and (on iOS) an explanation string. If you only load HTTPS content, you may not need relaxed iOS transport security settings; however, keep the “local network usage” description.

🍎 iOS (`-app.xml`)

Add the network usage description:

```xml
<iPhone>
  <InfoAdditions>
    <![CDATA[
      <key>NSLocalNetworkUsageDescription</key>
      <string>This app needs network access to load web content.</string>
    ]]>
  </InfoAdditions>
</iPhone>
```

If you also load `http://` (non-HTTPS) or mixed content, you may need ATS configuration. Example (use production-appropriate ATS settings when deploying):

```xml
<iPhone>
  <InfoAdditions>
    <![CDATA[
      <key>NSAppTransportSecurity</key>
      <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
      </dict>
    ]]>
  </InfoAdditions>
</iPhone>
```

🤖 Android (`-app.xml`)

At minimum, add permissions:

```xml
<manifestAdditions>
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
</manifestAdditions>
```

If you load `http://` content, you may need cleartext traffic support:

```xml
<manifestAdditions>
  <application android:usesCleartextTraffic="true">
  </application>
</manifestAdditions>
```

📚 ActionScript API (ActionScript 3)

🚀 Minimal Setup

```actionscript
import com.fluocode.ane.webview.WebViewANE;
import com.fluocode.ane.webview.WebViewEvent;

var webView:WebViewANE = new WebViewANE();

if (!webView.isAvailable) {
    trace("WebViewANE is not available.");
    return;
}

webView.init(0, 0, stage.stageWidth, stage.stageHeight);

webView.addEventListener(WebViewEvent.PAGE_LOADED, function(e:WebViewEvent):void {
    trace("PAGE_LOADED: " + e.data);
});
webView.addEventListener(WebViewEvent.PAGE_ERROR, function(e:WebViewEvent):void {
    trace("PAGE_ERROR: " + e.data);
});
```

### 1. `isAvailable` (getter)

```actionscript
if (webView.isAvailable) {
    trace("ANE context is ready.");
}
```

### 2. `init(x:Number, y:Number, width:Number, height:Number):Boolean`

```actionscript
var ok:Boolean = webView.init(0, 0, stage.stageWidth, stage.stageHeight);
if (!ok) trace("init() failed.");
```

### 3. `loadURL(url:String):void`

```actionscript
webView.loadURL("https://example.com");
```

### 4. `loadHTML(html:String, baseURL:String = null):void`

```actionscript
var html:String = "<html><body><h1>Hello</h1></body></html>";
webView.loadHTML(html);
```

### 5. `evaluateJavaScript(script:String):void`

```actionscript
webView.evaluateJavaScript("console.log('Hello from AIR');");
```

### 6. `goBack():void`

```actionscript
if (webView.canGoBack()) webView.goBack();
```

### 7. `goForward():void`

```actionscript
if (webView.canGoForward()) webView.goForward();
```

### 8. `reload():void`

```actionscript
webView.reload();
```

### 9. `stop():void`

```actionscript
webView.stop();
```

### 10. `setVisible(visible:Boolean):void`

```actionscript
webView.setVisible(true);   // show
webView.setVisible(false);  // hide
```

### 11. `setBounds(x:Number, y:Number, width:Number, height:Number):void`

```actionscript
webView.setBounds(10, 180, 800, 600);
```

### 12. `setBackgroundColor(color:uint):void`

Color format:
- `0xAARRGGBB` (ARGB) or
- `0xRRGGBB` (RGB; alpha is treated as 255/opaque)

```actionscript
webView.setBackgroundColor(0xFF000000); // opaque black (ARGB)
webView.setBackgroundColor(0x000000);   // black RGB (alpha assumed)
```

### 13. `getCurrentURL():String`

```actionscript
var url:String = webView.getCurrentURL();
trace("Current URL: " + url);
```

### 14. `canGoBack():Boolean`

```actionscript
if (webView.canGoBack()) trace("Back is available.");
```

### 15. `canGoForward():Boolean`

```actionscript
if (webView.canGoForward()) trace("Forward is available.");
```

### 16. `clearCache():void`

```actionscript
webView.clearCache();
```

### 17. `dispose():void`

```actionscript
webView.dispose();
```

### 18. `enableAutoCloseOnMessage(message:String = "close_webview", disposeOnClose:Boolean = false):void`

Use this when you want a web page button to hide/close the WebView by sending a message from JavaScript.

```actionscript
webView.enableAutoCloseOnMessage("close_webview", false);
```

📡 Events

You receive `WebViewEvent` with `e.data` as the payload (URL, error message, or JS message).

```actionscript
webView.addEventListener(WebViewEvent.URL_CHANGED, function(e:WebViewEvent):void {
    trace("URL_CHANGED: " + e.data);
});

webView.addEventListener(WebViewEvent.JAVASCRIPT_MESSAGE, function(e:WebViewEvent):void {
    trace("JAVASCRIPT_MESSAGE: " + e.data);
});

webView.addEventListener(WebViewEvent.CUSTOM_SCHEME, function(e:WebViewEvent):void {
    trace("CUSTOM_SCHEME: " + e.data);
});
```

Event list:

- `WebViewEvent.PAGE_LOADED`: fired when the page finishes loading (payload is the URL)
- `WebViewEvent.PAGE_ERROR`: fired on navigation/load errors (payload is an error string)
- `WebViewEvent.URL_CHANGED`: fired when the URL changes (payload is the current URL)
- `WebViewEvent.JAVASCRIPT_MESSAGE`: fired when JavaScript sends a message (payload is the message string)
- `WebViewEvent.CUSTOM_SCHEME`: fired when a custom URL scheme is detected (payload is the detected value, e.g. `jukeboxhub://...`)

💬 JavaScript Integration

From your web page:

```html
<script>
  if (window.webViewANE) {
    window.webViewANE.sendMessage("Hello from JavaScript!");
  }
</script>
```

Auto-close/hide example:

```html
<button onclick="onCancel()">Cancel</button>
<script>
  function onCancel() {
    if (window.webViewANE) {
      window.webViewANE.sendMessage("close_webview");
    }
  }
</script>
```

🔑 API Keys / Credentials

No API keys are required for using this ANE. The ANE does not call external services; it only renders web content and forwards navigation/JavaScript messages back to your AIR app.

🌐 WebViewANE (Adobe AIR ANE for a Modern WebView)

WebViewANE is an Adobe Native Extension (ANE) that embeds a modern WebView in your Adobe AIR app. It supports HTML5 content and allows you to execute JavaScript from ActionScript, while also receiving messages/events back from JavaScript.

✨ Key Features

- Modern HTML5 + JavaScript support (iOS uses `WKWebView`, Android uses `WebView`)
- Two-way communication between JavaScript and ActionScript
- Navigation helpers (back/forward/history)
- Page lifecycle events (loaded/error/url changes)
- Custom scheme support (handled via events)
- Optional auto-close/hide behavior triggered from JavaScript

🧰 What You Need

- Adobe AIR 33.1+ (required to use ANEs)
- iOS: iOS 9.0+
- Android: Android 5.0 (API 21)+

🔌 Add the Extension to Your AIR App

In your `*-app.xml` (or the AIR descriptor file you already use), add the extension ID:

```xml
<extensions>
  <extensionID>com.fluocode.ane.Webview</extensionID>
</extensions>
```

🛡️ Descriptor XML Permissions (Only If Needed)

WebViewANE loads web content, so your app must have network permission and (on iOS) an explanation string. If you only load HTTPS content, you may not need the relaxed iOS transport security settings; however, keep the “local network usage” description.

🍎 iOS (`-app.xml`)

Add the network usage description:

```xml
<iPhone>
  <InfoAdditions>
    <![CDATA[
      <key>NSLocalNetworkUsageDescription</key>
      <string>This app needs network access to load web content.</string>
    ]]>
  </InfoAdditions>
</iPhone>
```

If you also load `http://` (non-HTTPS) or mixed content, you may need ATS configuration. Example (use production-appropriate ATS settings when deploying):

```xml
<iPhone>
  <InfoAdditions>
    <![CDATA[
      <key>NSAppTransportSecurity</key>
      <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
      </dict>
    ]]>
  </InfoAdditions>
</iPhone>
```

🤖 Android (`-app.xml`)

At minimum, add permissions:

```xml
<manifestAdditions>
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
</manifestAdditions>
```

If you load `http://` content, you may need cleartext traffic support:

```xml
<manifestAdditions>
  <application android:usesCleartextTraffic="true">
  </application>
</manifestAdditions>
```

📚 ActionScript API (ActionScript 3)

🚀 Minimal Setup

```actionscript
import com.fluocode.ane.webview.WebViewANE;
import com.fluocode.ane.webview.WebViewEvent;

var webView:WebViewANE = new WebViewANE();

if (!webView.isAvailable) {
    trace("WebViewANE is not available.");
    return;
}

webView.init(0, 0, stage.stageWidth, stage.stageHeight);

webView.addEventListener(WebViewEvent.PAGE_LOADED, function(e:WebViewEvent):void {
    trace("PAGE_LOADED: " + e.data);
});
webView.addEventListener(WebViewEvent.PAGE_ERROR, function(e:WebViewEvent):void {
    trace("PAGE_ERROR: " + e.data);
});
```

### 1. `isAvailable` (getter)

```actionscript
if (webView.isAvailable) {
    trace("ANE context is ready.");
}
```

### 2. `init(x:Number, y:Number, width:Number, height:Number):Boolean`

```actionscript
var ok:Boolean = webView.init(0, 0, stage.stageWidth, stage.stageHeight);
if (!ok) trace("init() failed.");
```

### 3. `loadURL(url:String):void`

```actionscript
webView.loadURL("https://example.com");
```

### 4. `loadHTML(html:String, baseURL:String = null):void`

```actionscript
var html:String = "<html><body><h1>Hello</h1></body></html>";
webView.loadHTML(html);
```

### 5. `evaluateJavaScript(script:String):void`

```actionscript
webView.evaluateJavaScript("console.log('Hello from AIR');");
```

### 6. `goBack():void`

```actionscript
if (webView.canGoBack()) webView.goBack();
```

### 7. `goForward():void`

```actionscript
if (webView.canGoForward()) webView.goForward();
```

### 8. `reload():void`

```actionscript
webView.reload();
```

### 9. `stop():void`

```actionscript
webView.stop();
```

### 10. `setVisible(visible:Boolean):void`

```actionscript
webView.setVisible(true);   // show
webView.setVisible(false);  // hide
```

### 11. `setBounds(x:Number, y:Number, width:Number, height:Number):void`

```actionscript
webView.setBounds(10, 180, 800, 600);
```

### 12. `setBackgroundColor(color:uint):void`

Color format:
- `0xAARRGGBB` (ARGB) or
- `0xRRGGBB` (RGB; alpha is treated as 255/opaque)

```actionscript
webView.setBackgroundColor(0xFF000000); // opaque black (ARGB)
webView.setBackgroundColor(0x000000);   // black RGB (alpha assumed)
```

### 13. `getCurrentURL():String`

```actionscript
var url:String = webView.getCurrentURL();
trace("Current URL: " + url);
```

### 14. `canGoBack():Boolean`

```actionscript
if (webView.canGoBack()) trace("Back is available.");
```

### 15. `canGoForward():Boolean`

```actionscript
if (webView.canGoForward()) trace("Forward is available.");
```

### 16. `clearCache():void`

```actionscript
webView.clearCache();
```

### 17. `dispose():void`

```actionscript
webView.dispose();
```

### 18. `enableAutoCloseOnMessage(message:String = "close_webview", disposeOnClose:Boolean = false):void`

Use this when you want a web page button to hide/close the WebView by sending a message from JavaScript.

```actionscript
webView.enableAutoCloseOnMessage("close_webview", false);
```

📡 Events

You receive `WebViewEvent` with `e.data` as the payload (URL, error message, or JS message).

```actionscript
webView.addEventListener(WebViewEvent.URL_CHANGED, function(e:WebViewEvent):void {
    trace("URL_CHANGED: " + e.data);
});

webView.addEventListener(WebViewEvent.JAVASCRIPT_MESSAGE, function(e:WebViewEvent):void {
    trace("JAVASCRIPT_MESSAGE: " + e.data);
});

webView.addEventListener(WebViewEvent.CUSTOM_SCHEME, function(e:WebViewEvent):void {
    trace("CUSTOM_SCHEME: " + e.data);
});
```

Event list:

- `WebViewEvent.PAGE_LOADED`: fired when the page finishes loading (payload is the URL)
- `WebViewEvent.PAGE_ERROR`: fired on navigation/load errors (payload is an error string)
- `WebViewEvent.URL_CHANGED`: fired when the URL changes (payload is the current URL)
- `WebViewEvent.JAVASCRIPT_MESSAGE`: fired when JavaScript sends a message (payload is the message string)
- `WebViewEvent.CUSTOM_SCHEME`: fired when a custom URL scheme is detected (payload is the detected value, e.g. `jukeboxhub://...`)

💬 JavaScript Integration

From your web page:

```html
<script>
  if (window.webViewANE) {
    window.webViewANE.sendMessage("Hello from JavaScript!");
  }
</script>
```

Auto-close/hide example:

```html
<button onclick="onCancel()">Cancel</button>
<script>
  function onCancel() {
    if (window.webViewANE) {
      window.webViewANE.sendMessage("close_webview");
    }
  }
</script>
```

🔑 API Keys / Credentials

No API keys are required for using this ANE. The ANE does not call external services; it only renders web content and forwards navigation/JavaScript messages back to your AIR app.

🌐 WebViewANE (Adobe AIR ANE for a Modern WebView)

WebViewANE is an Adobe Native Extension (ANE) that embeds a modern WebView in your Adobe AIR app. It supports HTML5 content and allows you to execute JavaScript from ActionScript, while also receiving messages/events back from JavaScript.

✨ Key Features

- Modern HTML5 + JavaScript support (iOS uses `WKWebView`, Android uses `WebView`)
- Two-way communication between JavaScript and ActionScript
- Navigation helpers (back/forward/history)
- Page lifecycle events (loaded/error/url changes)
- Custom scheme support (handled via events)
- Optional auto-close/hide behavior triggered from JavaScript

🧰 What You Need

- Adobe AIR 33.1+ (required to use ANEs)
- iOS: iOS 9.0+
- Android: Android 5.0 (API 21)+

🔌 Add the Extension to Your AIR App

In your `*-app.xml` (or the AIR descriptor file you already use), add the extension ID:

```xml
<extensions>
  <extensionID>com.fluocode.ane.Webview</extensionID>
</extensions>
```

🛡️ Descriptor XML Permissions (Only If Needed)

WebViewANE loads web content, so your app must have network permission and (on iOS) an explanation string. If you only load HTTPS content, you may not need the relaxed iOS transport security settings; however, keep the “local network usage” description.

🍎 iOS (`-app.xml`)

Add the network usage description:

```xml
<iPhone>
  <InfoAdditions>
    <![CDATA[
      <key>NSLocalNetworkUsageDescription</key>
      <string>This app needs network access to load web content.</string>
    ]]>
  </InfoAdditions>
</iPhone>
```

If you also load `http://` (non-HTTPS) or mixed content, you may need ATS configuration. Example (use production-appropriate ATS settings when deploying):

```xml
<iPhone>
  <InfoAdditions>
    <![CDATA[
      <key>NSAppTransportSecurity</key>
      <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
      </dict>
    ]]>
  </InfoAdditions>
</iPhone>
```

🤖 Android (`-app.xml`)

At minimum, add permissions:

```xml
<manifestAdditions>
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
</manifestAdditions>
```

If you load `http://` content, you may need cleartext traffic support:

```xml
<manifestAdditions>
  <application android:usesCleartextTraffic="true">
  </application>
</manifestAdditions>
```

📚 ActionScript API (ActionScript 3)

🚀 Minimal Setup

```actionscript
import com.fluocode.ane.webview.WebViewANE;
import com.fluocode.ane.webview.WebViewEvent;

var webView:WebViewANE = new WebViewANE();

if (!webView.isAvailable) {
    trace("WebViewANE is not available.");
    return;
}

webView.init(0, 0, stage.stageWidth, stage.stageHeight);

webView.addEventListener(WebViewEvent.PAGE_LOADED, function(e:WebViewEvent):void {
    trace("PAGE_LOADED: " + e.data);
});
webView.addEventListener(WebViewEvent.PAGE_ERROR, function(e:WebViewEvent):void {
    trace("PAGE_ERROR: " + e.data);
});
```

### 1. `isAvailable` (getter)

```actionscript
if (webView.isAvailable) {
    trace("ANE context is ready.");
}
```

### 2. `init(x:Number, y:Number, width:Number, height:Number):Boolean`

```actionscript
var ok:Boolean = webView.init(0, 0, stage.stageWidth, stage.stageHeight);
if (!ok) trace("init() failed.");
```

### 3. `loadURL(url:String):void`

```actionscript
webView.loadURL("https://example.com");
```

### 4. `loadHTML(html:String, baseURL:String = null):void`

```actionscript
var html:String = "<html><body><h1>Hello</h1></body></html>";
webView.loadHTML(html);
```

### 5. `evaluateJavaScript(script:String):void`

```actionscript
webView.evaluateJavaScript("console.log('Hello from AIR');");
```

### 6. `goBack():void`

```actionscript
if (webView.canGoBack()) webView.goBack();
```

### 7. `goForward():void`

```actionscript
if (webView.canGoForward()) webView.goForward();
```

### 8. `reload():void`

```actionscript
webView.reload();
```

### 9. `stop():void`

```actionscript
webView.stop();
```

### 10. `setVisible(visible:Boolean):void`

```actionscript
webView.setVisible(true);   // show
webView.setVisible(false);  // hide
```

### 11. `setBounds(x:Number, y:Number, width:Number, height:Number):void`

```actionscript
webView.setBounds(10, 180, 800, 600);
```

### 12. `setBackgroundColor(color:uint):void`

Color format:
- `0xAARRGGBB` (ARGB) or
- `0xRRGGBB` (RGB; alpha is treated as 255/opaque)

```actionscript
webView.setBackgroundColor(0xFF000000); // opaque black (ARGB)
webView.setBackgroundColor(0x000000);   // black RGB (alpha assumed)
```

### 13. `getCurrentURL():String`

```actionscript
var url:String = webView.getCurrentURL();
trace("Current URL: " + url);
```

### 14. `canGoBack():Boolean`

```actionscript
if (webView.canGoBack()) trace("Back is available.");
```

### 15. `canGoForward():Boolean`

```actionscript
if (webView.canGoForward()) trace("Forward is available.");
```

### 16. `clearCache():void`

```actionscript
webView.clearCache();
```

### 17. `dispose():void`

```actionscript
webView.dispose();
```

### 18. `enableAutoCloseOnMessage(message:String = "close_webview", disposeOnClose:Boolean = false):void`

Use this when you want a web page button to hide/close the WebView by sending a message from JavaScript.

```actionscript
webView.enableAutoCloseOnMessage("close_webview", false);
```

📡 Events

You receive `WebViewEvent` with `e.data` as the payload (URL, error message, or JS message).

```actionscript
webView.addEventListener(WebViewEvent.URL_CHANGED, function(e:WebViewEvent):void {
    trace("URL_CHANGED: " + e.data);
});

webView.addEventListener(WebViewEvent.JAVASCRIPT_MESSAGE, function(e:WebViewEvent):void {
    trace("JAVASCRIPT_MESSAGE: " + e.data);
});

webView.addEventListener(WebViewEvent.CUSTOM_SCHEME, function(e:WebViewEvent):void {
    trace("CUSTOM_SCHEME: " + e.data);
});
```

Event list:

- `WebViewEvent.PAGE_LOADED`: fired when the page finishes loading (payload is the URL)
- `WebViewEvent.PAGE_ERROR`: fired on navigation/load errors (payload is an error string)
- `WebViewEvent.URL_CHANGED`: fired when the URL changes (payload is the current URL)
- `WebViewEvent.JAVASCRIPT_MESSAGE`: fired when JavaScript sends a message (payload is the message string)
- `WebViewEvent.CUSTOM_SCHEME`: fired when a custom URL scheme is detected (payload is the detected value, e.g. `jukeboxhub://...`)

💬 JavaScript Integration

From your web page:

```html
<script>
  if (window.webViewANE) {
    window.webViewANE.sendMessage("Hello from JavaScript!");
  }
</script>
```

Auto-close/hide example:

```html
<button onclick="onCancel()">Cancel</button>
<script>
  function onCancel() {
    if (window.webViewANE) {
      window.webViewANE.sendMessage("close_webview");
    }
  }
</script>
```

🔑 API Keys / Credentials

No API keys are required for using this ANE. The ANE does not call external services; it only renders web content and forwards navigation/JavaScript messages back to your AIR app.
