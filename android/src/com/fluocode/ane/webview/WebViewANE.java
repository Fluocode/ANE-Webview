package com.fluocode.ane.webview;

import android.app.Activity;
import android.graphics.Color;
import android.os.Handler;
import android.os.Looper;
import android.view.Gravity;
import android.view.ViewGroup;
import android.webkit.ConsoleMessage;
import android.webkit.JavascriptInterface;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

import java.util.HashMap;
import java.util.Map;

public class WebViewANE implements com.adobe.fre.FREExtension {
    
    private static final String TAG = "WebViewANE";
    
    // Helper method to sanitize messages
    private static String sanitizeMessage(String message) {
        if (message == null) {
            return null;
        }
        
        // Remove control characters (except for \n, \r, \t)
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < message.length(); i++) {
            char c = message.charAt(i);
            // Allow printable characters and some common control characters
            if (Character.isISOControl(c) && c != '\n' && c != '\r' && c != '\t') {
                continue; // Skip unwanted control characters
            }
            // Validate that the character is a valid Unicode code point
            if (Character.isValidCodePoint(c)) {
                sb.append(c);
            }
        }
        
        return sb.toString();
    }
    
    // Helper method to dispatch status events safely
    private static void safeDispatchStatusEvent(FREContext ctx, String code, String level) {
        try {
            if (ctx == null || code == null || level == null) {
                return;
            }
            
            // Validate that code and level are valid strings
            if (code.isEmpty() || level.isEmpty()) {
                return;
            }
            
            // Ensure both strings are valid UTF-8
            // Verify they do not contain null characters
            if (code.indexOf('\0') >= 0 || level.indexOf('\0') >= 0) {
                return;
            }
            
            ctx.dispatchStatusEventAsync(code, level);
        } catch (IllegalArgumentException e) {
            // Ignore invalid argument errors
            e.printStackTrace();
        } catch (Exception e) {
            // Ignore any other error
            e.printStackTrace();
        }
    }
    
    @Override
    public void initialize() {
        // Extension initialization
    }
    
    @Override
    public FREContext createContext(String extId) {
        return new WebViewANEContext();
    }
    
    @Override
    public void dispose() {
        // Extension cleanup
    }
    
    // Context class
    static class WebViewANEContext extends FREContext {
        
        private WebView webView;
        private Activity activity;
        private FrameLayout container;
        private Handler mainHandler;
        
        public WebViewANEContext() {
            mainHandler = new Handler(Looper.getMainLooper());
        }
        
        @Override
        public Map<String, FREFunction> getFunctions() {
            Map<String, FREFunction> functionMap = new HashMap<String, FREFunction>();
            
            functionMap.put("init", new InitFunction());
            functionMap.put("loadURL", new LoadURLFunction());
            functionMap.put("loadHTML", new LoadHTMLFunction());
            functionMap.put("evaluateJavaScript", new EvaluateJavaScriptFunction());
            functionMap.put("goBack", new GoBackFunction());
            functionMap.put("goForward", new GoForwardFunction());
            functionMap.put("reload", new ReloadFunction());
            functionMap.put("stop", new StopFunction());
            functionMap.put("setVisible", new SetVisibleFunction());
            functionMap.put("setBounds", new SetBoundsFunction());
            functionMap.put("setBackgroundColor", new SetBackgroundColorFunction());
            functionMap.put("getCurrentURL", new GetCurrentURLFunction());
            functionMap.put("canGoBack", new CanGoBackFunction());
            functionMap.put("canGoForward", new CanGoForwardFunction());
            functionMap.put("clearCache", new ClearCacheFunction());
            functionMap.put("dispose", new DisposeFunction());
            
            return functionMap;
        }
        
        @Override
        public void dispose() {
            if (webView != null) {
                mainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (container != null && webView != null) {
                            container.removeView(webView);
                        }
                        if (webView != null) {
                            webView.destroy();
                            webView = null;
                        }
                        container = null;
                    }
                });
            }
        }
        
        // Init Function
        class InitFunction implements FREFunction {
            @Override
            public FREObject call(FREContext ctx, FREObject[] args) {
                try {
                    double x = args[0].getAsDouble();
                    double y = args[1].getAsDouble();
                    double width = args[2].getAsDouble();
                    double height = args[3].getAsDouble();
                    
                    final int xInt = (int)x;
                    final int yInt = (int)y;
                    final int widthInt = (int)width;
                    final int heightInt = (int)height;
                    
                    Activity activity = (Activity)ctx.getActivity();
                    if (activity == null) {
                        return FREObject.newObject(false);
                    }
                    
                    WebViewANEContext.this.activity = activity;
                    
                    mainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            // Create container
                            container = new FrameLayout(activity);
                            FrameLayout.LayoutParams containerParams = new FrameLayout.LayoutParams(
                                ViewGroup.LayoutParams.MATCH_PARENT,
                                ViewGroup.LayoutParams.MATCH_PARENT
                            );
                            activity.addContentView(container, containerParams);
                            
                            // Create WebView
                            webView = new WebView(activity);
                            
                            // Configure WebView
                            WebSettings settings = webView.getSettings();
                            settings.setJavaScriptEnabled(true);
                            settings.setDomStorageEnabled(true);
                            settings.setDatabaseEnabled(true);
                            // setAppCacheEnabled was removed in Android API 33+
                            // settings.setAppCacheEnabled(true);
                            settings.setLoadWithOverviewMode(true);
                            settings.setUseWideViewPort(true);
                            settings.setBuiltInZoomControls(false);
                            settings.setDisplayZoomControls(false);
                            settings.setSupportZoom(true);
                            settings.setDefaultTextEncodingName("utf-8");
                            
                            // Enable modern HTML5 and JavaScript
                            settings.setJavaScriptCanOpenWindowsAutomatically(true);
                            settings.setAllowFileAccess(true);
                            settings.setAllowContentAccess(true);
                            settings.setAllowFileAccessFromFileURLs(true);
                            settings.setAllowUniversalAccessFromFileURLs(true);
                            settings.setMediaPlaybackRequiresUserGesture(false);
                            
                            // Additional settings for better compatibility
                            settings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW); // Allow mixed content (HTTP in HTTPS)
                            settings.setBlockNetworkLoads(false); // Allow network loads
                            settings.setBlockNetworkImage(false); // Allow network images
                            
                            // WebViewClient to handle events
                            webView.setWebViewClient(new WebViewClient() {
                                @Override
                                public void onPageFinished(WebView view, String url) {
                                    super.onPageFinished(view, url);
                                    if (url != null) {
                                        safeDispatchStatusEvent(ctx, "PAGE_LOADED", url);
                                    }
                                }
                                
                                @Override
                                public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
                                    super.onReceivedError(view, request, error);
                                    
                                    String url = request.getUrl().toString();
                                    
                                    // Ignore custom-scheme errors (handled in shouldOverrideUrlLoading)
                                    if (url != null && !url.startsWith("http://") && !url.startsWith("https://") && !url.startsWith("file://")) {
                                        // It's a custom scheme; not a real error
                                        return;
                                    }
                                    
                                    // Ignore subresource errors (images, CSS, etc.) that don't affect the main page
                                    if (request.isForMainFrame()) {
                                        String errorDescription = error != null ? error.getDescription().toString() : "Unknown error";
                                        String errorMsg = "Error: " + errorDescription;
                                        if (errorMsg.length() > 4096) {
                                            errorMsg = errorMsg.substring(0, 4096) + "... [truncated]";
                                        }
                                        errorMsg = sanitizeMessage(errorMsg);
                                        if (errorMsg != null && !errorMsg.isEmpty()) {
                                            safeDispatchStatusEvent(ctx, "PAGE_ERROR", errorMsg);
                                        }
                                    }
                                    // Subresource errors are ignored silently
                                }
                                
                                @Override
                                public void onReceivedHttpError(WebView view, WebResourceRequest request, android.webkit.WebResourceResponse errorResponse) {
                                    super.onReceivedHttpError(view, request, errorResponse);
                                    // Report HTTP errors only in the main frame
                                    if (request.isForMainFrame() && errorResponse != null && errorResponse.getStatusCode() >= 400) {
                                        String url = request.getUrl() != null ? request.getUrl().toString() : "unknown";
                                        String errorMsg = "HTTP Error " + errorResponse.getStatusCode() + ": " + url;
                                        if (errorMsg.length() > 4096) {
                                            errorMsg = errorMsg.substring(0, 4096) + "... [truncated]";
                                        }
                                        errorMsg = sanitizeMessage(errorMsg);
                                        if (errorMsg != null && !errorMsg.isEmpty()) {
                                            safeDispatchStatusEvent(ctx, "PAGE_ERROR", errorMsg);
                                        }
                                    }
                                }
                                
                                @Override
                                public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                                    try {
                                        String url = request.getUrl() != null ? request.getUrl().toString() : null;
                                        if (url == null || url.trim().isEmpty()) {
                                            return false;
                                        }
                                        
                                        // Limit URL length
                                        if (url.length() > 8192) {
                                            url = url.substring(0, 8192) + "... [truncated]";
                                        }
                                        
                                        // Sanitize URL
                                        url = sanitizeMessage(url);
                                        if (url == null || url.isEmpty()) {
                                            return false;
                                        }
                                        
                                        // Handle custom schemes (not http/https/file)
                                        if (!url.startsWith("http://") && !url.startsWith("https://") && !url.startsWith("file://") && !url.startsWith("javascript:")) {
                                            // Custom scheme; dispatch event and don't load
                                            safeDispatchStatusEvent(ctx, "URL_CHANGED", url);
                                            safeDispatchStatusEvent(ctx, "CUSTOM_SCHEME", url);
                                            return true; // Indicate that we handled the URL
                                        }
                                        
                                        // Normal URLs
                                        safeDispatchStatusEvent(ctx, "URL_CHANGED", url);
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    }
                                    return false; // Allow the WebView to load the URL
                                }
                            });
                            
                            // JavaScript Interface for two-way communication
                            // Exposes window.webViewANE.sendMessage() in JavaScript
                            webView.addJavascriptInterface(new WebAppInterface(ctx), "webViewANE");
                            
                            // WebChromeClient for JavaScript console and interface verification
                            webView.setWebChromeClient(new WebChromeClient() {
                                @Override
                                public void onProgressChanged(WebView view, int newProgress) {
                                    super.onProgressChanged(view, newProgress);
                                    // Inject a script while the page is loading to verify the interface
                                    if (newProgress > 0 && newProgress < 100) {
                                        view.evaluateJavascript(
                                            "if (typeof window.webViewANE === 'undefined') {" +
                                            "  console.warn('webViewANE interface not available');" +
                                            "} else {" +
                                            "  console.log('webViewANE interface ready');" +
                                            "}", null);
                                    }
                                }
                                
                                @Override
                                public boolean onConsoleMessage(ConsoleMessage consoleMessage) {
                                    try {
                                        if (consoleMessage == null) {
                                            return true;
                                        }
                                        
                                        String message = consoleMessage.message();
                                        
                                        // Validate message
                                        if (message == null || message.trim().isEmpty()) {
                                            return true;
                                        }
                                        
                                        // Limit message length (max 4096 characters to avoid FRE issues)
                                        if (message.length() > 4096) {
                                            message = message.substring(0, 4096) + "... [truncated]";
                                        }
                                        
                                        // Sanitize the message: remove control characters and ensure valid encoding
                                        message = sanitizeMessage(message);
                                        
                                        if (message == null || message.isEmpty()) {
                                            return true;
                                        }
                                        
                                        // Detect whether the message looks like a custom scheme or an error callback
                                        // Common patterns: "scheme://path" or "path?params"
                                        if (message.contains("://") || message.matches("^[a-zA-Z][a-zA-Z0-9+.-]*:.*")) {
                                            // Looks like a custom scheme; verify
                                            if (!message.startsWith("http://") && !message.startsWith("https://") && 
                                                !message.startsWith("file://") && !message.startsWith("javascript:") &&
                                                !message.startsWith("data:") && !message.startsWith("about:")) {
                                                // Custom scheme; dispatch as CUSTOM_SCHEME
                                                safeDispatchStatusEvent(ctx, "CUSTOM_SCHEME", message);
                                                return true; // Don't also dispatch as JAVASCRIPT_MESSAGE
                                            }
                                        }
                                        
                                        // Also detect payment-error patterns that arrive as messages
                                        if (message.contains("payment-method-error")) {
                                            // Convert to a custom scheme if it doesn't already have one
                                            String customScheme = message;
                                            if (!message.contains("://")) {
                                                // Add a default scheme if missing
                                                customScheme = "jukeboxhub://" + message;
                                            }
                                            safeDispatchStatusEvent(ctx, "CUSTOM_SCHEME", customScheme);
                                            return true; // Don't also dispatch as JAVASCRIPT_MESSAGE
                                        }
                                        
                                        safeDispatchStatusEvent(ctx, "JAVASCRIPT_MESSAGE", message);
                                    } catch (Exception e) {
                                        // Silence errors when sending console messages to avoid crashes
                                        // Console messages are not critical
                                        e.printStackTrace();
                                    }
                                    return true;
                                }
                                
                            });
                            
                            // Configure layout
                            FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                                widthInt, heightInt
                            );
                            params.leftMargin = xInt;
                            params.topMargin = yInt;
                            params.gravity = Gravity.TOP | Gravity.LEFT;
                            
                            webView.setLayoutParams(params);
                            webView.setBackgroundColor(Color.WHITE);
                            
                            container.addView(webView);
                        }
                    });
                    
                    return FREObject.newObject(true);
                } catch (Exception e) {
                    e.printStackTrace();
                    try {
                        return FREObject.newObject(false);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                        return null;
                    }
                }
            }
        }
        
        // JavaScript Interface
        class WebAppInterface {
            FREContext context;
            
            WebAppInterface(FREContext ctx) {
                context = ctx;
            }
            
            @JavascriptInterface
            public void sendMessage(String message) {
                try {
                    if (message == null || message.trim().isEmpty()) {
                        return;
                    }
                    
                    // Limit message length (max 4096 characters to avoid FRE issues)
                    if (message.length() > 4096) {
                        message = message.substring(0, 4096) + "... [truncated]";
                    }
                    
                    // Sanitize the message
                    message = sanitizeMessage(message);
                    if (message == null || message.isEmpty()) {
                        return;
                    }
                    
                    // Detect whether the message looks like a custom scheme or an error callback
                    // Common patterns: "scheme://path" or "path?params"
                    if (message.contains("://") || message.matches("^[a-zA-Z][a-zA-Z0-9+.-]*:.*")) {
                        // Looks like a custom scheme; verify
                        if (!message.startsWith("http://") && !message.startsWith("https://") && 
                            !message.startsWith("file://") && !message.startsWith("javascript:") &&
                            !message.startsWith("data:") && !message.startsWith("about:")) {
                            // Custom scheme; dispatch as CUSTOM_SCHEME
                            safeDispatchStatusEvent(context, "CUSTOM_SCHEME", message);
                            return; // Don't dispatch also as JAVASCRIPT_MESSAGE
                        }
                    }
                    
                    // Also detect payment-error patterns that arrive as messages
                    if (message.contains("payment-method-error")) {
                        // Convert to a custom scheme if it doesn't already have one
                        String customScheme = message;
                        if (!message.contains("://")) {
                            // Add a default scheme if missing
                            customScheme = "jukeboxhub://" + message;
                        }
                        safeDispatchStatusEvent(context, "CUSTOM_SCHEME", customScheme);
                        return; // Don't dispatch also as JAVASCRIPT_MESSAGE
                    }
                    
                    safeDispatchStatusEvent(context, "JAVASCRIPT_MESSAGE", message);
                } catch (Exception e) {
                    // Silence errors when sending messages to avoid crashes
                    e.printStackTrace();
                }
            }
        }
        
        // LoadURL Function
        class LoadURLFunction implements FREFunction {
            @Override
            public FREObject call(FREContext ctx, FREObject[] args) {
                try {
                    final String url = args[0].getAsString();
                    
                    mainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            if (webView != null) {
                                webView.loadUrl(url);
                            }
                        }
                    });
                    
                    return null;
                } catch (Exception e) {
                    e.printStackTrace();
                    return null;
                }
            }
        }
        
        // LoadHTML Function
        class LoadHTMLFunction implements FREFunction {
            @Override
            public FREObject call(FREContext ctx, FREObject[] args) {
                try {
                    final String html = args[0].getAsString();
                    String baseURL = args.length > 1 ? args[1].getAsString() : null;
                    final String baseURLFinal = baseURL != null ? baseURL : "file:///android_asset/";
                    
                    mainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            if (webView != null) {
                                webView.loadDataWithBaseURL(baseURLFinal, html, "text/html", "UTF-8", null);
                            }
                        }
                    });
                    
                    return null;
                } catch (Exception e) {
                    e.printStackTrace();
                    return null;
                }
            }
        }
        
        // EvaluateJavaScript Function
        class EvaluateJavaScriptFunction implements FREFunction {
            @Override
            public FREObject call(FREContext ctx, FREObject[] args) {
                try {
                    final String script = args[0].getAsString();
                    
                    mainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            if (webView != null) {
                                webView.evaluateJavascript(script, null);
                            }
                        }
                    });
                    
                    return null;
                } catch (Exception e) {
                    e.printStackTrace();
                    return null;
                }
            }
        }
        
        // GoBack Function
        class GoBackFunction implements FREFunction {
            @Override
            public FREObject call(FREContext ctx, FREObject[] args) {
                mainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (webView != null && webView.canGoBack()) {
                            webView.goBack();
                        }
                    }
                });
                return null;
            }
        }
        
        // GoForward Function
        class GoForwardFunction implements FREFunction {
            @Override
            public FREObject call(FREContext ctx, FREObject[] args) {
                mainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (webView != null && webView.canGoForward()) {
                            webView.goForward();
                        }
                    }
                });
                return null;
            }
        }
        
        // Reload Function
        class ReloadFunction implements FREFunction {
            @Override
            public FREObject call(FREContext ctx, FREObject[] args) {
                mainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (webView != null) {
                            webView.reload();
                        }
                    }
                });
                return null;
            }
        }
        
        // Stop Function
        class StopFunction implements FREFunction {
            @Override
            public FREObject call(FREContext ctx, FREObject[] args) {
                mainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (webView != null) {
                            webView.stopLoading();
                        }
                    }
                });
                return null;
            }
        }
        
        // SetVisible Function
        class SetVisibleFunction implements FREFunction {
            @Override
            public FREObject call(FREContext ctx, FREObject[] args) {
                try {
                    final boolean visible = args[0].getAsBool();
                    
                    mainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            if (webView != null) {
                                webView.setVisibility(visible ? WebView.VISIBLE : WebView.INVISIBLE);
                            }
                        }
                    });
                    
                    return null;
                } catch (Exception e) {
                    e.printStackTrace();
                    return null;
                }
            }
        }
        
        // SetBounds Function
        class SetBoundsFunction implements FREFunction {
            @Override
            public FREObject call(FREContext ctx, FREObject[] args) {
                try {
                    final int x = (int)args[0].getAsDouble();
                    final int y = (int)args[1].getAsDouble();
                    final int width = (int)args[2].getAsDouble();
                    final int height = (int)args[3].getAsDouble();
                    
                    mainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            if (webView != null) {
                                FrameLayout.LayoutParams params = (FrameLayout.LayoutParams)webView.getLayoutParams();
                                params.width = width;
                                params.height = height;
                                params.leftMargin = x;
                                params.topMargin = y;
                                webView.setLayoutParams(params);
                            }
                        }
                    });
                    
                    return null;
                } catch (Exception e) {
                    e.printStackTrace();
                    return null;
                }
            }
        }
        
        // SetBackgroundColor Function
        class SetBackgroundColorFunction implements FREFunction {
            @Override
            public FREObject call(FREContext ctx, FREObject[] args) {
                try {
                    // Color format: ARGB as integer (0xAARRGGBB)
                    final int color = (int)args[0].getAsDouble();
                    
                    mainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            if (webView != null) {
                                webView.setBackgroundColor(color);
                            }
                        }
                    });
                    
                    return null;
                } catch (Exception e) {
                    e.printStackTrace();
                    return null;
                }
            }
        }
        
        // GetCurrentURL Function
        class GetCurrentURLFunction implements FREFunction {
            @Override
            public FREObject call(FREContext ctx, FREObject[] args) {
                try {
                    final String[] url = new String[1];
                    
                    mainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            if (webView != null) {
                                url[0] = webView.getUrl();
                            } else {
                                url[0] = "";
                            }
                        }
                    });
                    
                    // Wait a bit so it runs on the main thread
                    try {
                        Thread.sleep(50);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    
                    return FREObject.newObject(url[0] != null ? url[0] : "");
                } catch (Exception e) {
                    e.printStackTrace();
                    try {
                        return FREObject.newObject("");
                    } catch (Exception ex) {
                        ex.printStackTrace();
                        return null;
                    }
                }
            }
        }
        
        // CanGoBack Function
        class CanGoBackFunction implements FREFunction {
            @Override
            public FREObject call(FREContext ctx, FREObject[] args) {
                try {
                    final boolean[] canGoBack = new boolean[1];
                    
                    mainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            canGoBack[0] = webView != null && webView.canGoBack();
                        }
                    });
                    
                    try {
                        Thread.sleep(50);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    
                    return FREObject.newObject(canGoBack[0]);
                } catch (Exception e) {
                    e.printStackTrace();
                    try {
                        return FREObject.newObject(false);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                        return null;
                    }
                }
            }
        }
        
        // CanGoForward Function
        class CanGoForwardFunction implements FREFunction {
            @Override
            public FREObject call(FREContext ctx, FREObject[] args) {
                try {
                    final boolean[] canGoForward = new boolean[1];
                    
                    mainHandler.post(new Runnable() {
                        @Override
                        public void run() {
                            canGoForward[0] = webView != null && webView.canGoForward();
                        }
                    });
                    
                    try {
                        Thread.sleep(50);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    
                    return FREObject.newObject(canGoForward[0]);
                } catch (Exception e) {
                    e.printStackTrace();
                    try {
                        return FREObject.newObject(false);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                        return null;
                    }
                }
            }
        }
        
        // ClearCache Function
        class ClearCacheFunction implements FREFunction {
            @Override
            public FREObject call(FREContext ctx, FREObject[] args) {
                mainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (webView != null) {
                            webView.clearCache(true);
                            webView.clearHistory();
                        }
                    }
                });
                return null;
            }
        }
        
        // Dispose Function
        class DisposeFunction implements FREFunction {
            @Override
            public FREObject call(FREContext ctx, FREObject[] args) {
                mainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (container != null && webView != null) {
                            container.removeView(webView);
                        }
                        if (webView != null) {
                            webView.destroy();
                            webView = null;
                        }
                        container = null;
                    }
                });
                return null;
            }
        }
    }
}

