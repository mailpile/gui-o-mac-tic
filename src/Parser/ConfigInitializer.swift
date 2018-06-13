import AppKit

extension Config {
    convenience init?(json: [String: Any]) throws {
        let app_name = json[Keyword.app_name.rawValue] as? String
        let app_icon = json[Keyword.app_icon.rawValue] as? String
        let require_gui = json[Keyword.require_gui.rawValue] as? String
        let main_windowJSON = json[Keyword.main_window.rawValue] as? [String: Any]
        
        guard let indicatorJSON = json[Keyword.indicator.rawValue] as? [String: Any] else {
            throw ParsingError.nonCompliantInput
        }
        let indicator: Indicator! = Indicator(json: indicatorJSON)
        
        let fontStylesJSON = json[Keyword.font_styles.rawValue] as? [String: Any]
        let fontStyles: FontStyles? = fontStylesJSON != nil ? FontStyles(json: fontStylesJSON!) : nil
        
        let imagesJSON = json[Keyword.images.rawValue] as? [String: String]
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
        if let http_cookiesJSON = json[Keyword.http_cookies.rawValue] as? [String: Any] {
            for cookieJSON in http_cookiesJSON {
                if let host = cookieJSON.key.split(separator: ":").first
                 , let portString = cookieJSON.key.split(separator: ":").last
                 , let port = UInt16(portString)
                 , let value = cookieJSON.value as? [String: Any] {
                    let cookie = MPHTTPCookie(hostname: String(host), port: port, json: value)
                    http_cookies.append(cookie)
                }
            }
        }
        
        let never_run_from_dmg = json[Keyword.never_run_from_dmg.rawValue] as? Bool
        
        let status_bar_popover_message = json[Keyword.status_bar_popover_message.rawValue] as? String
        
        self.init(app_name: app_name!,
                  app_icon: app_icon!,
                  require_gui: require_gui,
                  main_window: main_window,
                  indicators: indicator,
                  icons: images,
                  fontStyles: fontStyles,
                  http_cookies: http_cookies,
                  never_run_from_dmg: never_run_from_dmg,
                  status_bar_popover_message: status_bar_popover_message)
    }
}

extension Indicator {
    init?(json: [String: Any]) {
        self.initialStatus = json[Keyword.initial_status.rawValue] as? String
        let menuJSON = json[Keyword.menu_items.rawValue] as? [[String: Any]]
        
        self.menu = []
        for action:[String: Any] in menuJSON! {
            let menu = ActionItem(json: action)
            self.menu.append(menu!)
        }
    }
}

extension ActionItem {
    init?(json: [String: Any]) {
        self.id = json[Keyword.id.rawValue] as? String
        self.label = json[Keyword.label.rawValue] as? String
        self.sensitive = json[Keyword.sensitive.rawValue] as? Bool
        self.separator = json[Keyword.separator.rawValue] as? Bool
        
        if let args = json[Keyword.args.rawValue] {
            self.args = Args(string: args as? String,
                             list: args as? [String],
                             dictionary: args as? [String: Any])
        } else {
            args = nil
        }

        if let type = json[Keyword.type.rawValue] as? String {
            self.type = ActionItemType(rawValue: type)!
        } else {
            self.type = ActionItemType.button
        }
        
        if let opString = json[Keyword.op.rawValue] as? String {
           self.op = StringToOperationMapper.Map(operation: opString)
        } else {
            self.op = nil
        }
        
        if let positionString = json[Keyword.position.rawValue] as? String {
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
        
        self.show = json[Keyword.show.rawValue] as! Bool
        self.message = json[Keyword.message.rawValue] as? String
        self.close_quits = json[Keyword.close_quits.rawValue] as! Bool
        self.width = json[Keyword.width.rawValue] as! Int
        self.height = json[Keyword.height.rawValue] as! Int
        
        self.image = json[Keyword.background.rawValue] as? String
        
        self.initial_notification = json[Keyword.initial_notification.rawValue] as? String ?? ""
        
        
        let statusJSON = json[Keyword.status_displays.rawValue] as? [[String: String]]
        self.status_displays = statusParser(statusJSON: statusJSON)
        
        self.action_items = []
        if let actionItemsJSON = json[Keyword.action_items.rawValue] as? [[String: Any]] {
            for action: [String: Any] in actionItemsJSON {
                let menu = ActionItem(json: action)
                self.action_items.append(menu!)
            }
        }
    }
}

extension StatusDisplay {
    convenience init?(json: [String: String], statusDisplayIconFinder: (String?) -> NSImage?) {
        let icon: String? = json[Keyword.icon.rawValue]
        assert(icon?.hasPrefix(Keyword.imagePrefix.rawValue) ?? true)
        var iconImage: NSImage?
        if icon != nil {
            let iconName = String(icon!.dropFirst(Keyword.imagePrefix.rawValue.count))
            iconImage = statusDisplayIconFinder(iconName)
        }
        
        self.init(item: json[Keyword.id.rawValue]!,
                  title: json[Keyword.title.rawValue]!,
                  details: json[Keyword.details.rawValue],
                  icon: iconImage)
    }
}

extension FontStyles {
    init?(json: [String: Any]) {
        if let detailsJSON = json[Keyword.details.rawValue] as? [String: Any] {
            self.details = FontStyle(json: detailsJSON)
        } else {
            self.details = nil
        }
        
        if let notificationJSON = json[Keyword.notification.rawValue] as? [String: Any] {
            self.notification = FontStyle(json: notificationJSON)
        } else {
            self.notification = nil
        }
        
        if let splashJSON = json[Keyword.splash.rawValue] as? [String: Any] {
            self.splash = FontStyle(json: splashJSON)
        } else {
            self.splash = nil
        }
        
        if let statusJSON = json[Keyword.title.rawValue] as? [String: Any] {
            self.title = FontStyle(json: statusJSON)
        } else {
            self.title = nil
        }
        
        if let buttonsJSON = json[Keyword.buttons.rawValue] as? [String: Any] {
            self.buttons = FontStyle(json: buttonsJSON)
        } else {
            self.buttons = nil
        }
    }
}

extension FontStyles.FontStyle {
    init?(json: [String: Any]) {
        self.bold = json[Keyword.bold.rawValue] as? Bool
        self.italic = json[Keyword.italic.rawValue] as? Bool
        self.family = json[Keyword.family.rawValue] as? String
        self.points = json[Keyword.points.rawValue] as? Int
    }
}
