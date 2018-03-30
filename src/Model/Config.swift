import AppKit

class Config {
    var app_name: String
    var app_icon: String
    var require_gui: String?
    var main_window: MainWindow?
    var indicator: Indicator!
    var icons: [String: NSImage]
    var fontStyles: FontStyles?
    var http_cookies: [MPHTTPCookie]?
    
    init(app_name: String,
         app_icon: String,
         require_gui: String?,
         main_window: MainWindow?,
         indicators: Indicator!,
         icons: [String: NSImage],
         fontStyles: FontStyles?,
         http_cookies: [MPHTTPCookie]?) {
        self.app_name = app_name
        self.app_icon = app_icon
        self.main_window = main_window
        self.indicator = indicators
        self.icons = icons
        self.fontStyles = fontStyles
        self.http_cookies = http_cookies
    }
}
