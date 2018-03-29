import AppKit

class Config {
    static private var _shared: Config?
    static public var shared: Config! {
        return Config._shared!
    }
    
    /* TODO Refactor to a Blackboard. Add this class and the two following group of variables as top level entities. */
    public var splashMessages = Queue<String>()
    public var mainWindowMessages = Queue<String>()
    public var nextErrorMessage: String?
    
    private(set) public var app_name: String
    private(set) public var app_icon: String
    private(set) public var require_gui: String?
    private(set) public var main_window: MainWindow?
    private(set) public var indicator: Indicator!
    private(set) public var icons: [String: Images]
    private(set) public var fontStyles: FontStyles?
    private(set) public var http_cookies: [MPHTTPCookie]?
    
    init(app_name: String,
         app_icon: String,
         require_gui: String?,
         main_window: MainWindow?,
         indicators: Indicator!,
         icons: [String: Images],
         fontStyles: FontStyles?,
         http_cookies: [MPHTTPCookie]?) {
        self.app_name = app_name
        self.app_icon = app_icon
        self.main_window = main_window
        self.indicator = indicators
        self.icons = icons
        self.fontStyles = fontStyles
        self.http_cookies = http_cookies
        Config._shared = self
    }
}
