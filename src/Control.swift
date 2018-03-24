import Cocoa

class Control: NSObject {
    let OK_GO = "OK GO"
    let OK_LISTEN = "OK LISTEN"
    let OK_LISTEN_TO = "OK LISTEN TO:"
    let OK_LISTEN_TCP = "OK LISTEN TCP:"
    let OK_LISTEN_HTTP = "OK LISTEN HTTP:"
    
    var daemon: Bool
    var config: Config?
    var gui: GUI?
    var sock: String? /* todo not string*/
    //var fd: String /* todo not string*/
    var child: String? /*todo not string*/
    var listening: String? /* todo not string*/
    
    init(/*fd: String/*todo not string*/,*/ config: Config?, gui_object: GUI?/*todo not string*/) {
        self.daemon = false
        self.config = config
        self.gui = gui_object
        self.sock = nil
        //self.fd = fd
        self.child = nil
        self.listening = nil
    }
    
    func shell_pivot(command: String) throws {
        // TODO
        print("shell_pivot: " + command)
    }
    
    private func listen() {
        // TODO
        print("listen")
    }
    
    private func accept() {
        // TODO
        print("accept")
    }
    
    func shell_tcp_pivot(command: String) throws {
        // TODO
        print("shell_tcp_pivot: " + command)
    }
    
    func http_tcp_pivot(url: NSURL) throws {
        // TODO
        print("http_tcp_pivot: " + url.absoluteString!)
    }
    
    func do_line_magic(line: String?, listen: Bool) throws -> (match: Bool, listen: Bool) {
        
        func getResource(ignoreCommand: String) -> String {
            return line!.dropFirst(ignoreCommand.count).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        do {
            if line == nil {
                return (match: false, listen: false)
            }
            
            if [self.OK_GO, self.OK_LISTEN].contains(line!.trimmingCharacters(in: .whitespacesAndNewlines)) {
                return (match: true, listen: line!.contains(self.OK_LISTEN))
            }
            
            if line!.starts(with: self.OK_LISTEN_TO) {
                let resource = getResource(ignoreCommand: self.OK_LISTEN_TO)
                try self.shell_pivot(command: resource)
                return (match: true, listen: true)
            }
            
            if line!.starts(with: self.OK_LISTEN_TCP) {
                let resource = getResource(ignoreCommand: self.OK_LISTEN_TCP)
                try self.shell_tcp_pivot(command: resource)
                return (match: true, listen: true)
            }
            
            if line!.starts(with: self.OK_LISTEN_HTTP) {
                let resource = getResource(ignoreCommand: self.OK_LISTEN_HTTP)
                try self.http_tcp_pivot(url: NSURL(string: resource)!)
                return (match: true, listen: true)
            }
        }
        catch {
            if let _ = self.gui {
                self.gui!.report_error(error: error.localizedDescription)
                /* todo "time.sleep(30)" */
                throw error
            }
        }
        return (match: false, listen: listen)
    }
    
    func bootstrap() {
        assert(self.config == nil)
        assert(self.gui == nil)
        do {
            var listen = false
            var config: [String] = []
            while true {
                let line: String? = readLine()
                
                let magic = try self.do_line_magic(line: line, listen: listen)
                listen = magic.listen
                if magic.match {
                    break;
                } else {
                    if let trimmedLine = line?.trimmingCharacters(in: .whitespaces) {
                        config.append(trimmedLine)
                    }
                }
            }
            
            
            /* TODO set config 'self.config = json.loads(''.join(config))'*/
            self.gui = GUI(config: self.config!)
            if listen {
                /*todo start this thread self.start()*/
                print("start thread")
            }
            self.gui!.run()
        } catch {
            /* todo crash */
        }
        
    }
    
    func `do`(command: String, kwargs: [String: String]) {
        // TODO
    }
    
    func run() {
        // TODO
    }
}
