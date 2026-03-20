package com.fluocode.ane.webview {
	
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;
	import flash.utils.Timer;
	
	/**
	 * WebViewANE - Adobe Native Extension for the modern WebView.
	 * Supports iOS and Android with modern HTML5 and JavaScript capabilities.
	 */
	public class WebViewANE extends EventDispatcher {
		
		private static const EXTENSION_ID:String = "com.fluocode.ane.Webview";
		private var _context:ExtensionContext;
		private var _isInitialized:Boolean = false;
		private var _webViewReady:Boolean = false;
		private var _isIOS:Boolean = false;
		private var _pendingLoadURL:String = null;
		private var _autoCloseOnMessage:String = null;
		private var _autoCloseDisposes:Boolean = false;
		
		// Events
		/**
		 * Dispatched when a page finishes loading.
		 */
		public static const PAGE_LOADED:String = "pageLoaded";
		/**
		 * Dispatched when the native side reports a page loading error.
		 */
		public static const PAGE_ERROR:String = "pageError";
		/**
		 * Dispatched when the current URL changes.
		 */
		public static const URL_CHANGED:String = "urlChanged";
		/**
		 * Dispatched when the WebView sends a message to the native side via JavaScript.
		 */
		public static const JAVASCRIPT_MESSAGE:String = "javascriptMessage";
		
		/**
		 * Creates a new `WebViewANE` instance and initializes the underlying ANE context.
		 */
		public function WebViewANE() {
			try {
				// Detect whether we are running on iOS.
				_isIOS = Capabilities.os.toLowerCase().indexOf("iphone") != -1 || 
				         Capabilities.os.toLowerCase().indexOf("ipad") != -1 ||
				         Capabilities.os.toLowerCase().indexOf("ipod") != -1;
				
				_context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
				if (_context) {
					_context.addEventListener(StatusEvent.STATUS, onStatus);
					_isInitialized = true;
				} else {
					trace("Error: No se pudo crear el contexto de extensión");
				}
			} catch (e:Error) {
				trace("Error al inicializar WebViewANE: " + e.message);
			}
		}
		
		/**
		 * Initializes the WebView with the specified bounds.
		 * @param x The X coordinate.
		 * @param y The Y coordinate.
		 * @param width The desired width.
		 * @param height The desired height.
		 * @return `true` if the native initialization succeeded; otherwise `false`.
		 */
		public function init(x:Number, y:Number, width:Number, height:Number):Boolean {
			if (!_isInitialized || !_context) {
				trace("WebViewANE.init: ERROR - Contexto no inicializado");
				return false;
			}
			
			_webViewReady = false;
			
			try {
				trace("WebViewANE.init: Llamando init nativo con x=" + x + ", y=" + y + ", width=" + width + ", height=" + height);
				var result:Object = _context.call("init", x, y, width, height);
				var success:Boolean = result as Boolean;
				trace("WebViewANE.init: Resultado nativo = " + success);
				
				if (success) {
					if (_isIOS) {
						trace("WebViewANE.init: iOS detectado, esperando 200ms para que el WebView se cree...");
						// On iOS, the WebView is created asynchronously.
						// Wait 200ms for it to be fully created before allowing `loadURL`.
						var initTimer:Timer = new Timer(200, 1);
						initTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
							_webViewReady = true;
							trace("WebViewANE.init: WebView listo en iOS después de 200ms");
							initTimer.removeEventListener(TimerEvent.TIMER, arguments.callee);
							
							// If there is a pending URL, load it now.
							if (_pendingLoadURL) {
								var urlToLoad:String = _pendingLoadURL;
								_pendingLoadURL = null;
								trace("WebViewANE.init: Cargando URL pendiente: " + urlToLoad);
								loadURL(urlToLoad);
							}
						});
						initTimer.start();
					} else {
						// On Android, the WebView is ready immediately.
						_webViewReady = true;
						trace("WebViewANE.init: Android detectado, WebView listo inmediatamente");
					}
				} else {
					trace("WebViewANE.init: ERROR - init nativo retornó false");
				}
				
				return success;
			} catch (e:Error) {
				trace("WebViewANE.init: EXCEPCIÓN al inicializar WebView: " + e.message + " - " + e.getStackTrace());
				return false;
			}
		}
		
		/**
		 * Loads a URL in the WebView.
		 * @param url The URL to load.
		 */
		public function loadURL(url:String):void {
			if (!_isInitialized || !_context) return;
			
			// On iOS, wait until the WebView is ready.
			if (_isIOS && !_webViewReady) {
				// Store the URL and load it once the WebView is ready.
				_pendingLoadURL = url;
				trace("WebViewANE: WebView aún no está listo en iOS, guardando URL para cargar después: " + url);
				return;
			}
			
			try {
				_context.call("loadURL", url);
			} catch (e:Error) {
				trace("Error al cargar URL: " + e.message);
			}
		}
		
		/**
		 * Loads HTML directly into the WebView.
		 * @param html The HTML content to render.
		 * @param baseURL The base URL used to resolve relative resources.
		 */
		public function loadHTML(html:String, baseURL:String = null):void {
			if (!_isInitialized || !_context) return;
			
			try {
				_context.call("loadHTML", html, baseURL);
			} catch (e:Error) {
				trace("Error al cargar HTML: " + e.message);
			}
		}
		
		/**
		 * Executes JavaScript inside the WebView.
		 * @param script JavaScript code to execute.
		 */
		public function evaluateJavaScript(script:String):void {
			if (!_isInitialized || !_context) return;
			
			try {
				_context.call("evaluateJavaScript", script);
			} catch (e:Error) {
				trace("Error al ejecutar JavaScript: " + e.message);
			}
		}
		
		/**
		 * Navigates backward in the browser history.
		 */
		public function goBack():void {
			if (!_isInitialized || !_context) return;
			
			try {
				_context.call("goBack");
			} catch (e:Error) {
				trace("Error al retroceder: " + e.message);
			}
		}
		
		/**
		 * Navigates forward in the browser history.
		 */
		public function goForward():void {
			if (!_isInitialized || !_context) return;
			
			try {
				_context.call("goForward");
			} catch (e:Error) {
				trace("Error al avanzar: " + e.message);
			}
		}
		
		/**
		 * Reloads the current page.
		 */
		public function reload():void {
			if (!_isInitialized || !_context) return;
			
			try {
				_context.call("reload");
			} catch (e:Error) {
				trace("Error al recargar: " + e.message);
			}
		}
		
		/**
		 * Stops loading the current page.
		 */
		public function stop():void {
			if (!_isInitialized || !_context) return;
			
			try {
				_context.call("stop");
			} catch (e:Error) {
				trace("Error al detener: " + e.message);
			}
		}
		
		/**
		 * Sets the visibility of the WebView.
		 * @param visible `true` to show; `false` to hide.
		 */
		public function setVisible(visible:Boolean):void {
			if (!_isInitialized || !_context) return;
			
			// On iOS, wait for the WebView to be ready.
			if (_isIOS && !_webViewReady) {
				trace("WebViewANE.setVisible: WebView aún no está listo en iOS, esperando...");
				// Save the visibility state and apply it once it's ready.
				var visibleTimer:Timer = new Timer(100, 10); // Try every 100ms, maximum 10 times.
				var attempts:int = 0;
				visibleTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
					attempts++;
					if (_webViewReady) {
						visibleTimer.stop();
						visibleTimer.removeEventListener(TimerEvent.TIMER, arguments.callee);
						try {
							_context.call("setVisible", visible);
						} catch (err:Error) {
							trace("Error al establecer visibilidad: " + err.message);
						}
					} else if (attempts >= 10) {
						visibleTimer.stop();
						visibleTimer.removeEventListener(TimerEvent.TIMER, arguments.callee);
						trace("WebViewANE.setVisible: Timeout esperando WebView en iOS");
					}
				});
				visibleTimer.start();
				return;
			}
			
			try {
				_context.call("setVisible", visible);
			} catch (e:Error) {
				trace("Error al establecer visibilidad: " + e.message);
			}
		}
		
		/**
		 * Sets the position and size of the WebView.
		 * @param x The X coordinate.
		 * @param y The Y coordinate.
		 * @param width The desired width.
		 * @param height The desired height.
		 */
		public function setBounds(x:Number, y:Number, width:Number, height:Number):void {
			if (!_isInitialized || !_context) return;
			
			try {
				_context.call("setBounds", x, y, width, height);
			} catch (e:Error) {
				trace("Error al establecer bounds: " + e.message);
			}
		}
		
		/**
		 * Sets the background color of the WebView.
		 * @param color Color in ARGB format (`0xAARRGGBB`) or RGB (`0xRRGGBB`, assuming `alpha=255`).
		 * Example: `0xFF000000` (black), `0xFFFFFFFF` (white), `0xFF1a1a1a` (dark gray).
		 */
		public function setBackgroundColor(color:uint):void {
			if (!_isInitialized || !_context) return;
			
			try {
				// If the color has no alpha (RGB only), add alpha=255 (opaque).
				if ((color & 0xFF000000) == 0) {
					color = color | 0xFF000000;
				}
				_context.call("setBackgroundColor", color);
			} catch (e:Error) {
				trace("Error al establecer color de fondo: " + e.message);
			}
		}
		
		/**
		 * Returns the current URL.
		 * @return The current URL, or `null` if an error occurs.
		 */
		public function getCurrentURL():String {
			if (!_isInitialized || !_context) return null;
			
			try {
				return _context.call("getCurrentURL") as String;
			} catch (e:Error) {
				trace("Error al obtener URL: " + e.message);
				return null;
			}
		}
		
		/**
		 * Checks whether the WebView can navigate backward.
		 * @return `true` if it can go back; otherwise `false`.
		 */
		public function canGoBack():Boolean {
			if (!_isInitialized || !_context) return false;
			
			try {
				return _context.call("canGoBack") as Boolean;
			} catch (e:Error) {
				trace("Error al verificar canGoBack: " + e.message);
				return false;
			}
		}
		
		/**
		 * Checks whether the WebView can navigate forward.
		 * @return `true` if it can go forward; otherwise `false`.
		 */
		public function canGoForward():Boolean {
			if (!_isInitialized || !_context) return false;
			
			try {
				return _context.call("canGoForward") as Boolean;
			} catch (e:Error) {
				trace("Error al verificar canGoForward: " + e.message);
				return false;
			}
		}
		
		/**
		 * Clears the WebView cache.
		 */
		public function clearCache():void {
			if (!_isInitialized || !_context) return;
			
			try {
				_context.call("clearCache");
			} catch (e:Error) {
				trace("Error al limpiar caché: " + e.message);
			}
		}
		
		/**
		 * Disposes the underlying WebView resources and releases the ANE context.
		 */
		public function dispose():void {
			if (_context) {
				try {
					_context.call("dispose");
					_context.removeEventListener(StatusEvent.STATUS, onStatus);
					_context.dispose();
					_context = null;
					_isInitialized = false;
				} catch (e:Error) {
					trace("Error al liberar recursos: " + e.message);
				}
			}
		}
		
		/**
		 * Handles status events received from the native side.
		 */
		private function onStatus(event:StatusEvent):void {
			switch (event.code) {
				case "PAGE_LOADED":
					dispatchEvent(new WebViewEvent(WebViewEvent.PAGE_LOADED, event.level));
					break;
				case "PAGE_ERROR":
					dispatchEvent(new WebViewEvent(WebViewEvent.PAGE_ERROR, event.level));
					break;
				case "URL_CHANGED":
					dispatchEvent(new WebViewEvent(WebViewEvent.URL_CHANGED, event.level));
					break;
				case "JAVASCRIPT_MESSAGE":
					var jsEvent:WebViewEvent = new WebViewEvent(WebViewEvent.JAVASCRIPT_MESSAGE, event.level);
					dispatchEvent(jsEvent);
					
					if (_autoCloseOnMessage && event.level == _autoCloseOnMessage) {
						if (_autoCloseDisposes) {
							dispose();
						} else {
							setVisible(false);
						}
					}
					break;
			}
		}
		
		/**
		 * Configures an automatic message from JavaScript that will close or hide the WebView.
		 * @param message The message that must be received from JavaScript (defaults to `"close_webview"`).
		 * @param disposeOnClose If `true`, calls `dispose()`; if `false`, hides using `setVisible(false)`.
		 */
		public function enableAutoCloseOnMessage(message:String = "close_webview", disposeOnClose:Boolean = false):void {
			_autoCloseOnMessage = message;
			_autoCloseDisposes = disposeOnClose;
		}
		
		/**
		 * Indicates whether the ANE context is available and initialized.
		 * @return `true` if the ANE is initialized and ready; otherwise `false`.
		 */
		public function get isAvailable():Boolean {
			return _isInitialized && _context != null;
		}
	}
}

