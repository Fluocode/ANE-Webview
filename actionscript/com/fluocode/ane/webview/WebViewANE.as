package com.fluocode.ane.webview {
	
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	
	/**
	 * WebViewANE - Adobe Native Extension for the modern WebView.
	 * Supports iOS and Android with modern HTML5 and JavaScript capabilities.
	 */
	public class WebViewANE extends EventDispatcher {
		
		private static const EXTENSION_ID:String = "com.fluocode.ane.Webview";
		private var _context:ExtensionContext;
		private var _isInitialized:Boolean = false;
		
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
		 * Dispatched when a custom URL scheme is detected.
		 */
		public static const CUSTOM_SCHEME:String = "customScheme";
		
		/**
		 * Creates a new `WebViewANE` instance and initializes the underlying ANE context.
		 */
		public function WebViewANE() {
			try {
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
		 * @return `true` if initialization succeeded; otherwise `false`.
		 */
		public function init(x:Number, y:Number, width:Number, height:Number):Boolean {
			if (!_isInitialized || !_context) return false;
			
			try {
				var result:Object = _context.call("init", x, y, width, height);
				return result as Boolean;
			} catch (e:Error) {
				trace("Error al inicializar WebView: " + e.message);
				return false;
			}
		}
		
		/**
		 * Loads a URL in the WebView.
		 * @param url The URL to load.
		 */
		public function loadURL(url:String):void {
			if (!_isInitialized || !_context) return;
			
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
		 * Handles status events coming from the native side.
		 * @param event The received status event.
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
					dispatchEvent(new WebViewEvent(WebViewEvent.JAVASCRIPT_MESSAGE, event.level));
					break;
				case "CUSTOM_SCHEME":
					dispatchEvent(new WebViewEvent(WebViewEvent.CUSTOM_SCHEME, event.level));
					break;
			}
		}
		
		/**
		 * Indicates whether the ANE context is available.
		 * @return `true` if the ANE is initialized and ready; otherwise `false`.
		 */
		public function get isAvailable():Boolean {
			return _isInitialized && _context != null;
		}
	}
}

