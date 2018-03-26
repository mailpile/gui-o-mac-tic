import AppKit

extension Config {
    convenience init?(json: [String: Any]) {
        let app_name = json["app_name"] as? String
        let app_icon = json["app_icon"] as? String
        let require_gui = json["require_gui"] as? String
        let main_windowJSON = json["main_window"] as? [String: Any]
        let indicatorJSON = json["indicator"] as? [String: Any]
        let iconsJSON = json["icons"] as? [String: String]
        let fontStylesJSON = json["font-styles"] as? [String: Any]
        let indicator:Indicator! = Indicator(json: indicatorJSON!)
        let fontStyles:FontStyles? = FontStyles(json: fontStylesJSON!)
        // TODO Cookies are to be parsed as well.
        func getImageForIconAt(path: String!, ofType: String!) -> NSImage? {
            let iconUrl = URL(fileURLWithPath: path)
            let actualIconUrl = iconUrl.appendingToLastPathComponent(string: ofType)
            return NSImage(contentsOf: actualIconUrl)
        }
        var icons = [String: Icon]()
        iconsJSON!.forEach({ title, path in
            let statusBarIcon: NSImage? = getImageForIconAt(path: path, ofType: Constants.STATUSBAR)
            let substatusIcon: NSImage? = getImageForIconAt(path: path, ofType: Constants.SUBSTATUS)
            let icon = Icon(statusBar: statusBarIcon,
                            substatus: substatusIcon)
            icons[title] = icon
        })
        
        func imageForSubstatusIconNamed(name: String!) -> NSImage? {
            return icons[name]?.substatus
        }
        let main_window:MainWindow? = MainWindow(json: main_windowJSON!, substatusIconFinder: imageForSubstatusIconNamed)
        
        self.init(app_name: app_name!, app_icon: app_icon!, require_gui: require_gui, main_window: main_window, indicators: indicator, icons: icons, fontStyles: fontStyles)
    }
}

extension Indicator {
    init?(json: [String: Any]) {
        self.initialStatus = json["initial_status"] as? String
        let menuJSON = json["menu"] as? [[String: Any]]
        
        self.menu = []
        for action:[String: Any] in menuJSON! {
            let menu = Action(json: action)
            self.menu.append(menu!)
        }
    }
}

extension Action {
    init?(json: [String: Any]) {
        self.label = json["label"] as? String
        self.item = json["item"] as? String ?? nil
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
            self.type = ActionType(rawValue: type)
        } else {
            self.type = nil
        }
        
        if let opString = json["op"] as? String {
            switch opString {
            case "show_url":
                self.op = .show_url
            case "terminal":
                self.op = .terminal
            case "shell":
                self.op = .shell
            case "quit":
                self.op = .quit
            case "show_main_window":
                self.op = .show_main_window
            case "get_url":
                self.op = .get_url
            case "post_url":
                self.op = .post_url
            case "show_splash_screen":
                self.op = .show_splash_screen
                
            default:
                preconditionFailure("Invalid configuration: \(opString) is not a known op.")
            }
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
    init?(json: [String: Any], substatusIconFinder: @escaping (String!) -> NSImage?) {
        
        func statusParser(statusJSON: [[String: String]]?) -> [Status]? {
            var statuses: [Status] = []
            if (statusJSON != nil) {
                for oneStatusJSON in statusJSON! {
                    guard let status: Status = Status(json: oneStatusJSON, substatusIconFinder: substatusIconFinder) else {
                        continue
                    }
                    statuses.append(status)
                }
            }
            return statuses.isEmpty ? nil : statuses
        }
        
        self.show = json["show"] as! Bool!
        self.message = json["message"] as? String
        self.close_quits = json["close_quits"] as! Bool
        self.width = json["width"] as! Int
        self.height = json["height"] as! Int
        
        if let imageFileName = json["image"] as? String {
            let imageFileNameWithExtension = imageFileName.components(separatedBy: .init(charactersIn: "/")).last
            let imageFileNameWithoutExtension = imageFileNameWithExtension!.components(separatedBy: .init(charactersIn: ".")).first!
            guard let image = NSImage(named: NSImage.Name(rawValue: imageFileNameWithoutExtension)) else {
                // TODO Alert the user.
                fatalError("Bad configuration. Image by the name \(imageFileNameWithoutExtension) does not exist")
            }
            self.image = image
        } else {
            self.image = nil
        }
        
        let actionsJSON = json["actions"] as! [[String: Any]]

        let statusJSON = json["status"] as? [[String: String]]
        self.status = statusParser(statusJSON: statusJSON)
        
        let substatusJSON = json["substatus"] as? [[String: String]]
        self.substatus = statusParser(statusJSON: substatusJSON)
        
        self.actions = []
        for action:[String: Any] in actionsJSON {
            let menu = Action(json: action)
            self.actions.append(menu!)
        }
    }
}

extension Status {
    convenience init?(json: [String: String], substatusIconFinder: (String!) -> NSImage?) {
        
        let icon: String? = json["icon"]
        let prefix = "icon:"
        assert(icon?.hasPrefix(prefix) ?? true)
        let iconName = String(icon!.dropFirst(prefix.count))
        let iconImage: NSImage? = substatusIconFinder(iconName)
        
        self.init(item: json["item"]!, label: json["label"]!, hint: json["hint"]!, icon: iconImage)
    }
}

extension FontStyles {
    init?(json: [String: Any]) {
        let labelJSON = json["label"] as! [String: Any]
        let hintJSON = json["hint"] as! [String: Any]
        let splashJSON = json["splash"] as! [String: Any]
        let statusJSON = json["status"] as! [String: Any]
        
        self.label = FontStyle(json: labelJSON)
        self.hint = FontStyle(json: hintJSON)
        self.splash = FontStyle(json: splashJSON)
        self.status = FontStyle(json: statusJSON)
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
