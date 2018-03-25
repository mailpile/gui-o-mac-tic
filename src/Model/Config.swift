import AppKit

class Config {
    static private var _shared: Config?
    static public var shared: Config! {
        return Config._shared!
    }
    
    private(set) public var app_name: String
    private(set) public var app_icon: String
    private(set) public var require_gui: String?
    private(set) public var main_window: MainWindow?
    private(set) public var indicator: Indicator!
    private(set) public var icons: [String: Icon]
    private(set) public var fontStyles: FontStyles?
    
    init(app_name: String,
         app_icon: String,
         require_gui: String?,
         main_window: MainWindow?,
         indicators: Indicator!,
         icons: [String: Icon],
         fontStyles: FontStyles?) {
        self.app_name = app_name
        self.app_icon = app_icon
        self.main_window = main_window
        self.indicator = indicators
        self.icons = icons
        self.fontStyles = fontStyles
        
        Config._shared = self
    }
}
