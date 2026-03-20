package com.fluocode.ane.webview {
	
	import flash.events.Event;
	
	/**
	 * Custom event dispatched by `WebViewANE`.
	 */
	public class WebViewEvent extends Event {
		
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
		
		private var _data:String;
		
		/**
		 * Creates a new `WebViewEvent`.
		 * @param type The event type (for example: `PAGE_LOADED`).
		 * @param data A string payload associated with the event (for example: URL or error message).
		 * @param bubbles Whether the event bubbles.
		 * @param cancelable Whether the event is cancelable.
		 */
		public function WebViewEvent(type:String, data:String = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			_data = data;
		}
		
		/**
		 * Returns the payload string associated with this event.
		 * @return The event payload, or `null` if no payload was provided.
		 */
		public function get data():String {
			return _data;
		}
		
		/**
		 * Clones this event.
		 * @return A copy of this event instance.
		 */
		override public function clone():Event {
			return new WebViewEvent(type, _data, bubbles, cancelable);
		}
	}
}

