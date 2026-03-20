package {
	
	import com.fluocode.ane.webview.WebViewANE;
	import com.fluocode.ane.webview.WebViewEvent;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * Test project for `WebViewANE`.
	 * Demonstrates how to use the modern WebView on iOS and Android.
	 */
	public class Main extends Sprite {
		
		private var webView:WebViewANE;
		private var statusText:TextField;
		private var urlInput:TextField;
		
		public function Main() {
			if (stage) {
				init();
			} else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// Create UI
			createUI();
			
			// Initialize WebView
			initWebView();
		}
		
		private function createUI():void {
			// Background
			graphics.beginFill(0xCCCCCC);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill();
			
			// Title
			var title:TextField = new TextField();
			title.text = "WebViewANE Test";
			title.setTextFormat(new TextFormat("Arial", 24, 0x000000, true));
			title.width = stage.stageWidth;
			title.height = 40;
			title.y = 10;
			addChild(title);
			
			// URL input field
			var urlLabel:TextField = new TextField();
			urlLabel.text = "URL:";
			urlLabel.setTextFormat(new TextFormat("Arial", 14, 0x000000));
			urlLabel.width = 50;
			urlLabel.height = 25;
			urlLabel.x = 10;
			urlLabel.y = 60;
			addChild(urlLabel);
			
			urlInput = new TextField();
			urlInput.text = "https://www.google.com";
			urlInput.setTextFormat(new TextFormat("Arial", 14, 0x000000));
			urlInput.width = stage.stageWidth - 200;
			urlInput.height = 25;
			urlInput.x = 70;
			urlInput.y = 60;
			urlInput.border = true;
			urlInput.background = true;
			urlInput.backgroundColor = 0xFFFFFF;
			urlInput.type = "input";
			addChild(urlInput);
			
			// Load button
			var loadButton:Sprite = createButton("Cargar", 0x4CAF50);
			loadButton.x = stage.stageWidth - 120;
			loadButton.y = 60;
			loadButton.addEventListener(MouseEvent.CLICK, onLoadClick);
			addChild(loadButton);
			
			// Navigation controls
			var backButton:Sprite = createButton("←", 0x2196F3);
			backButton.x = 10;
			backButton.y = 100;
			backButton.addEventListener(MouseEvent.CLICK, onBackClick);
			addChild(backButton);
			
			var forwardButton:Sprite = createButton("→", 0x2196F3);
			forwardButton.x = 80;
			forwardButton.y = 100;
			forwardButton.addEventListener(MouseEvent.CLICK, onForwardClick);
			addChild(forwardButton);
			
			var reloadButton:Sprite = createButton("↻", 0xFF9800);
			reloadButton.x = 150;
			reloadButton.y = 100;
			reloadButton.addEventListener(MouseEvent.CLICK, onReloadClick);
			addChild(reloadButton);
			
			var stopButton:Sprite = createButton("■", 0xF44336);
			stopButton.x = 220;
			stopButton.y = 100;
			stopButton.addEventListener(MouseEvent.CLICK, onStopClick);
			addChild(stopButton);
			
			// Test HTML button
			var htmlButton:Sprite = createButton("HTML Test", 0x9C27B0);
			htmlButton.x = 290;
			htmlButton.y = 100;
			htmlButton.addEventListener(MouseEvent.CLICK, onHTMLTestClick);
			addChild(htmlButton);
			
			// Status text
			statusText = new TextField();
			statusText.text = "Inicializando...";
			statusText.setTextFormat(new TextFormat("Arial", 12, 0x000000));
			statusText.width = stage.stageWidth - 20;
			statusText.height = 30;
			statusText.x = 10;
			statusText.y = 140;
			statusText.multiline = true;
			statusText.wordWrap = true;
			addChild(statusText);
		}
		
		private function createButton(label:String, color:uint):Sprite {
			var button:Sprite = new Sprite();
			button.graphics.beginFill(color);
			button.graphics.drawRoundRect(0, 0, 60, 30, 5, 5);
			button.graphics.endFill();
			
			var text:TextField = new TextField();
			text.text = label;
			text.setTextFormat(new TextFormat("Arial", 14, 0xFFFFFF, true));
			text.width = 60;
			text.height = 30;
			text.selectable = false;
			text.mouseEnabled = false;
			button.addChild(text);
			
			button.buttonMode = true;
			button.useHandCursor = true;
			
			return button;
		}
		
		private function initWebView():void {
			webView = new WebViewANE();
			
			if (!webView.isAvailable) {
				updateStatus("ERROR: WebViewANE no está disponible. Verifica que el ANE esté correctamente incluido.");
				return;
		 }
			
			// Initialize WebView (leave space for the UI)
			var webViewY:Number = 180;
			var webViewHeight:Number = stage.stageHeight - webViewY - 10;
			
			if (webView.init(10, webViewY, stage.stageWidth - 20, webViewHeight)) {
				updateStatus("WebView inicializado correctamente");
				
				// Listen for events
				webView.addEventListener(WebViewEvent.PAGE_LOADED, onPageLoaded);
				webView.addEventListener(WebViewEvent.PAGE_ERROR, onPageError);
				webView.addEventListener(WebViewEvent.URL_CHANGED, onURLChanged);
				webView.addEventListener(WebViewEvent.JAVASCRIPT_MESSAGE, onJavaScriptMessage);
				webView.addEventListener(WebViewEvent.CUSTOM_SCHEME, onCustomScheme);
				
				// Load the initial URL
				webView.loadURL("https://www.google.com");
			} else {
				updateStatus("ERROR: No se pudo inicializar el WebView");
			}
		}
		
		private function onLoadClick(e:MouseEvent):void {
			var url:String = urlInput.text;
			if (url && url.length > 0) {
				if (!url.match(/^https?:\/\//)) {
					url = "https://" + url;
				}
				updateStatus("Cargando: " + url);
				webView.loadURL(url);
			}
		}
		
		private function onBackClick(e:MouseEvent):void {
			if (webView.canGoBack()) {
				webView.goBack();
			}
		}
		
		private function onForwardClick(e:MouseEvent):void {
			if (webView.canGoForward()) {
				webView.goForward();
			}
		}
		
		private function onReloadClick(e:MouseEvent):void {
			webView.reload();
		}
		
		private function onStopClick(e:MouseEvent):void {
			webView.stop();
		}
		
		private function onHTMLTestClick(e:MouseEvent):void {
			var html:String = '<!DOCTYPE html>' +
				'<html>' +
				'<head>' +
				'<meta charset="UTF-8">' +
				'<meta name="viewport" content="width=device-width, initial-scale=1.0">' +
				'<title>WebViewANE Test</title>' +
				'<style>' +
				'body { font-family: Arial, sans-serif; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; }' +
				'h1 { text-align: center; }' +
				'.container { max-width: 600px; margin: 0 auto; background: rgba(255,255,255,0.1); padding: 20px; border-radius: 10px; }' +
				'button { background: #4CAF50; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; margin: 5px; }' +
				'button:hover { background: #45a049; }' +
				'</style>' +
				'</head>' +
				'<body>' +
				'<div class="container">' +
				'<h1>WebViewANE HTML5 Test</h1>' +
				'<p>Este es un ejemplo de HTML5 moderno cargado en el WebView.</p>' +
				'<button onclick="testJavaScript()">Probar JavaScript</button>' +
				'<button onclick="testCanvas()">Probar Canvas</button>' +
				'<div id="result"></div>' +
				'<canvas id="canvas" width="300" height="200" style="border: 2px solid white; margin-top: 20px;"></canvas>' +
				'</div>' +
				'<script>' +
				'function testJavaScript() {' +
				'  var result = document.getElementById("result");' +
				'  result.innerHTML = "<p>JavaScript funciona correctamente! Hora: " + new Date() + "</p>";' +
				'  if (window.webViewANE) {' +
				'    window.webViewANE.sendMessage("Mensaje desde JavaScript: " + new Date());' +
				'  }' +
				'}' +
				'function testCanvas() {' +
				'  var canvas = document.getElementById("canvas");' +
				'  var ctx = canvas.getContext("2d");' +
				'  ctx.fillStyle = "#FF6B6B";' +
				'  ctx.fillRect(0, 0, 150, 200);' +
				'  ctx.fillStyle = "#4ECDC4";' +
				'  ctx.fillRect(150, 0, 150, 200);' +
				'  ctx.fillStyle = "white";' +
				'  ctx.font = "20px Arial";' +
				'  ctx.fillText("Canvas Works!", 50, 100);' +
				'}' +
				'</script>' +
				'</body>' +
				'</html>';
			
			webView.loadHTML(html);
			updateStatus("Cargando HTML de prueba...");
		}
		
		private function onPageLoaded(e:WebViewEvent):void {
			updateStatus("Página cargada: " + e.data);
			urlInput.text = e.data;
		}
		
		private function onPageError(e:WebViewEvent):void {
			// Filter common non-critical errors
			var errorMsg:String = e.data;
			if (errorMsg.indexOf("net::ERR_UNKNOWN_URL_SCHEME") >= 0) {
				// This error is handled via CUSTOM_SCHEME; don't show it as an error.
				return;
			}
			updateStatus("ERROR: " + errorMsg);
		}
		
		private function onURLChanged(e:WebViewEvent):void {
			updateStatus("URL cambiada: " + e.data);
		}
		
		private function onJavaScriptMessage(e:WebViewEvent):void {
			updateStatus("JavaScript: " + e.data);
		}
		
		private function onCustomScheme(e:WebViewEvent):void {
			updateStatus("Esquema personalizado detectado: " + e.data);
			trace("Esquema personalizado: " + e.data);
			// Here you can handle the custom scheme (for example: jukeboxhub://).
			// For example, open an external URL or execute custom logic.
		}
		
		private function updateStatus(message:String):void {
			statusText.text = message;
			trace(message);
		}
	}
}

