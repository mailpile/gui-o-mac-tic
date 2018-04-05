import AppKit

extension Config {
    convenience init?(json: [String: Any]) {
        let app_name = json["app_name"] as? String
        let app_icon = json["app_icon"] as? String
        let require_gui = json["require_gui"] as? String
        let main_windowJSON = json["main_window"] as? [String: Any]
        
        let indicatorJSON = json["indicator"] as? [String: Any]
        let indicator: Indicator! = Indicator(json: indicatorJSON!)
        
        let fontStylesJSON = json["font_styles"] as? [String: Any]
        let fontStyles: FontStyles? = fontStylesJSON != nil ? FontStyles(json: fontStylesJSON!) : nil
        
        let imagesJSON = json["images"] as? [String: String]
        var images = [String: NSImage]()
        imagesJSON!.forEach({ title, path in
            let image = NSImage(withTemplatedIconPath: path)
            images[title] = image
        })
        
        func imageForIcon(name: String!) -> NSImage? {
            return images[name]
        }
        let main_window:MainWindow? = MainWindow(json: main_windowJSON!, statusDisplayIconFinder: imageForIcon)
        
        var http_cookies = [MPHTTPCookie]()
        if let http_cookiesJSON = json["http_cookies"] as? [String: Any] {
            for cookieJSON in http_cookiesJSON {
                let value = cookieJSON.value as! [String: Any]
                let cookie = MPHTTPCookie(hostname: cookieJSON.key, json: value)
                http_cookies.append(cookie)
            }
        }
        
        self.init(app_name: app_name!,
                  app_icon: app_icon!,
                  require_gui: require_gui,
                  main_window: main_window,
                  indicators: indicator,
                  icons: images,
                  fontStyles: fontStyles,
                  http_cookies: http_cookies)
    }
}

extension Indicator {
    init?(json: [String: Any]) {
        self.initialStatus = json["initial_status"] as? String
        let menuJSON = json["menu_items"] as? [[String: Any]]
        
        self.menu = []
        for action:[String: Any] in menuJSON! {
            let menu = ActionItem(json: action)
            self.menu.append(menu!)
        }
    }
}

extension ActionItem {
    init?(json: [String: Any]) {
        self.id = json["id"] as? String
        self.label = json["label"] as? String
        self.sensitive = json["sensitive"] as? Bool
        self.separator = json["separator"] as? Bool
        
        if let args = json["args"] {
            self.args = Args(string: args as? String,
                             list: args as? [String],
                             dictionary: args as? [String: Any])
        } else {
            args = nil
        }

        if let type = json["type"] as? String {
            self.type = ActionItemType(rawValue: type)
        } else {
            self.type = nil
        }
        
        if let opString = json["op"] as? String {
           self.op = StringToOperationMapper.Map(operation: opString)
        } else {
            self.op = nil
        }
        
        if let positionString = json["position"] as? String {
            if let position = Position(rawValue: positionString) {
                self.position = position
            } else {
                self.position = nil
            }
        } else {
            self.position = nil
        }
    }
}

extension MainWindow {
    init?(json: [String: Any], statusDisplayIconFinder: @escaping (String?) -> NSImage?) {
        func statusParser(statusJSON: [[String: String]]?) -> [StatusDisplay]? {
            var statuses: [StatusDisplay] = []
            if (statusJSON != nil) {
                for oneStatusJSON in statusJSON! {
                    guard let status: StatusDisplay = StatusDisplay(json: oneStatusJSON, statusDisplayIconFinder: statusDisplayIconFinder) else {
                        continue
                    }
                    statuses.append(status)
                }
            }
            return statuses.isEmpty ? nil : statuses
        }
        
        self.show = json["show"] as! Bool
        self.message = json["message"] as? String
        self.close_quits = json["close_quits"] as! Bool
        self.width = json["width"] as! Int
        self.height = json["height"] as! Int
        
        if let imageFileName = json["background"] as? String {
            self.image = NSImage(withTemplatedIconPath: imageFileName)
        } else {
            self.image = nil
        }
        
        
        let statusJSON = json["status_displays"] as? [[String: String]]
        self.status = statusParser(statusJSON: statusJSON)
        
        self.actions = []
        if let actionItemsJSON = json["actions"] as? [[String: Any]] {
            for action: [String: Any] in actionItemsJSON {
                let menu = ActionItem(json: action)
                self.actions.append(menu!)
            }
        }
    }
}

extension StatusDisplay {
    convenience init?(json: [String: String], statusDisplayIconFinder: (String?) -> NSImage?) {
        let icon: String? = json["icon"]
        let prefix = "image:"
        assert(icon?.hasPrefix(prefix) ?? true)
        let iconName = String(icon!.dropFirst(prefix.count))
        let iconImage: NSImage? = statusDisplayIconFinder(iconName)
        
        self.init(item: json["id"]!, title: json["title"]!, details: json["details"], icon: iconImage)
    }
}

extension FontStyles {
    init?(json: [String: Any]) {
        
        if let detailsJSON = json["details"] as? [String: Any] {
            self.details = FontStyle(json: detailsJSON)
        } else {
            self.details = nil
        }
        
        if let notificationJSON = json["notification"] as? [String: Any] {
            self.notification = FontStyle(json: notificationJSON)
        } else {
            self.notification = nil
        }
        
        if let splashJSON = json["splash"] as? [String: Any] {
            self.splash = FontStyle(json: splashJSON)
        } else {
            self.splash = nil
        }
        
        if let statusJSON = json["title"] as? [String: Any] {
            self.title = FontStyle(json: statusJSON)
        } else {
            self.title = nil
        }
    }
}

extension FontStyles.FontStyle {
    init?(json: [String: Any]) {
        self.bold = json["bold"] as? Bool
        self.italic = json["italic"] as? Bool
        self.family = json["family"] as? String
        self.points = json["points"] as? Int
    }
}
