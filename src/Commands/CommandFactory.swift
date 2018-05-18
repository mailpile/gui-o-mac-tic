import AppKit

class CommandFactory {
    
    static func build(forOperation operation: Operation, withArgs args: Args?) -> Command {
        switch operation {
        
        case .quit:
            return Quit()
        
        case .shell:
            precondition(args?.list != nil && args!.list!.count > 0, "No command was provided for execution.")
            return Shell(args!.list!)
            
        case .show_main_window:
            return ShowMainWindow()
            
        case .show_url:
            precondition(args != nil, "Did not receive a URL to open.")
            return ShowURL(url: args!.asURL() ?? URL(string: args!.dictionary!["url"] as! String)!)
            
        case .terminal:
            precondition(args?.dictionary != nil, "Expected a dictionary.")
            precondition(args!.dictionary!.count > 0, "Expected a non-empty dictionary.")
            precondition(args!.dictionary![Keyword.command.rawValue] != nil, "No command was provided for execution.")
            let command = args!.dictionary![Keyword.command.rawValue] as! String
            let title = args!.dictionary![Keyword.title.rawValue] as? String
            let icon = args!.dictionary![Keyword.icon.rawValue] as? String
            return Terminal(command, title, icon)
            
        case .get_url:
            precondition(args != nil, "Did not receive a URL to get.")
            guard let url = args!.asURL() else {
                preconditionFailure("Did not receive a URL to get.")
            }
            let cookies = CookieControl.cookiesForHost(url: url)
            return GetURL(url: url, cookies: cookies)
            
        case .post_url:
            precondition(args != nil, "Did not receive a URL to POST to.")
            guard let url = args!.asURL() else {
                preconditionFailure("Did not receive a payload to post.")
            }
            var swiftPayload = args!.dictionary
            swiftPayload?.removeValue(forKey: URL_KEY)
            
            do {
                let jsonPayload: Data? = try JSONSerialization.data(withJSONObject: swiftPayload!, options: [])
                let cookies = CookieControl.cookiesForHost(url: url)
                return PostURL(url: url, payload: jsonPayload, cookies: cookies)
            } catch {
                // TODO Error handling.
                print(error.localizedDescription)
                fatalError()
            }
        
        case .show_splash_screen:
            precondition(args != nil, "Did not receive arguments")
            let background = NSImage(contentsOfFile: args!.dictionary![Keyword.background.rawValue] as! String)
            let message = args!.dictionary![Keyword.message.rawValue] as? String ?? ""
            let showProgressBar = args!.dictionary![Keyword.progress_bar.rawValue] as? Bool == true
            
            precondition(background != nil, "A splash screen can not be created without a background.")
            return ShowSplashScreen(background: background, message: message, showProgressBar: showProgressBar)
            
        case .update_splash_screen:
            precondition(args == nil || args!.dictionary != nil, "Expected args to be a dictionary.")
            var progress = args!.dictionary![Keyword.progress.rawValue] as? Double
            if (progress != nil) {
                /* The Bar Progress Indicator requries a value on the range [0;100] but
                such values are on the range [0.0;1.0] in the config file. */
                progress! *= 100
            }
            let message = args!.dictionary![Keyword.message.rawValue] as? String ?? ""
            return UpdateSplashScreen(progress ?? 0, message)
            
        case .hide_splash_screen:
            return HideSplashScreen()
            
        case .hide_main_window:
            return HideMainWindow()
            
        case .set_status:
            let status = args?.dictionary?[Keyword.status.rawValue] as? String
            let badge = args?.dictionary?[Keyword.badge.rawValue] as? String
            return SetStatus(status, badge)
            
        case .set_status_display:
            guard let id: String = args?.dictionary?[Keyword.id.rawValue] as? String else {
                preconditionFailure("'set_status_display' must provide an \(Keyword.id.rawValue).")
            }
            let title = args!.dictionary![Keyword.title.rawValue] as? String
            let details = args!.dictionary![Keyword.details.rawValue] as? String
            
            let icon: NSImage?
            if let iconUrl = args!.dictionary![Keyword.icon.rawValue] as? String {
                if let iconFromFile = NSImage(contentsOfFile: iconUrl) {
                    icon = iconFromFile
                } else if let iconName = iconUrl.split(separator: ":").last {
                    icon = Blackboard.shared.config?.icons[String(iconName)]
                } else {
                    icon = nil
                }
            } else {
                icon = nil
            }
            
            var colour: NSColor?
            if let hexColour = args!.dictionary![Keyword.color.rawValue] as? String {
                colour = NSColor(hexColour: hexColour)
            }
            
            return SetStatusDisplay(id, title, details, icon, colour)
            
        case .set_item:
            precondition(args?.dictionary?[Keyword.id.rawValue] as? String != nil,
                         "'set_item' must provide an \(Keyword.id.rawValue).")
            let id = args!.dictionary![Keyword.id.rawValue] as! String
            let label = args!.dictionary![Keyword.label.rawValue] as? String
            let sensitive = args!.dictionary![Keyword.sensitive.rawValue] as? Bool ?? true
            return SetItem(id, label, sensitive)
            
        case .set_next_error_message:
            let message = args?.dictionary?[Keyword.message.rawValue] as? String
            return SetNextErrorMessage(message)
            
        case .notify_user:
            let message = args?.dictionary?[Keyword.message.rawValue] as? String
            precondition(message != nil, "'notify_user' must provide a \(Keyword.message.rawValue).")
            
            let popup = args?.dictionary?[Keyword.popup.rawValue] as? Bool ?? false
            let alert = args?.dictionary?[Keyword.alert.rawValue] as? Bool ?? false
            
            let actions: [ActionItem]?
            if let jsonActionItems = args?.dictionary?[Keyword.action_items.rawValue] as? [[String: Any]] {
                actions = Parser.parse(actions: jsonActionItems)
            } else {
                actions = nil
            }
            return NotifyUser(messageToSend: message!,
                              popup: popup,
                              alert: alert,
                              actions: actions)
            
        case .set_http_cookie:
            guard let domain = args!.dictionary![Keyword.domain.rawValue] as? String else {
                preconditionFailure("'set_http_cookie' must provide a \(Keyword.domain.rawValue).")
            }
            
            guard let key = args!.dictionary![Keyword.key.rawValue] as? String else {
                preconditionFailure("'set_http_cookie' must provide a \(Keyword.key.rawValue).")
            }
            
            let value = args!.dictionary![Keyword.value.rawValue] as? String
            let remove = args!.dictionary![Keyword.remove.rawValue] as? Bool
            return SetHTTPCookie(domain, key, value, remove)
        }
    }
}
