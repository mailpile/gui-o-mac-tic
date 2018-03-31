import Foundation
import CoreFoundation

class Server: Thread {
    func go() {
        let ERROR = -1
        let sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
        if sock == ERROR {
            perror("Error creating a socket.")
            Thread.exit()
        }
        
        var sock_opt_on = Int32(1)
        setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &sock_opt_on, socklen_t(MemoryLayout.size(ofValue: sock_opt_on)))
        
        var socketAddress = sockaddr_in()
        let socketAddressSize = socklen_t(MemoryLayout.size(ofValue: socketAddress))
        socketAddress.sin_len = UInt8(socketAddressSize)
        socketAddress.sin_family = sa_family_t(AF_INET)
        
        socketAddress.sin_port = Blackboard.shared.tcp_port.bigEndian
        
        let bindServer = withUnsafePointer(to: &socketAddress) {
            Darwin.bind(sock, UnsafeRawPointer($0).assumingMemoryBound(to: sockaddr.self), socketAddressSize)
        }
        guard bindServer != ERROR else {
            perror("Binding error.")
            Thread.exit()
            return
        }
        guard listen(sock, 5) != ERROR else {
            perror("Listening error.")
            Thread.exit()
            return
        }
        
        var clientAddress = sockaddr_storage()
        var client_addr_len = socklen_t(MemoryLayout.size(ofValue: clientAddress))
        let client_fd = withUnsafeMutablePointer(to: &clientAddress) {
            accept(sock, UnsafeMutableRawPointer($0).assumingMemoryBound(to: sockaddr.self), &client_addr_len)
        }
        guard client_fd != ERROR else {
            perror("Failure: accepting connection")
            Thread.exit();
            return
        }
        
        while (true) {
            var line: String = ""
            var buff_rcvd = CChar()
            while line.last != "\n" {
                read(client_fd, &buff_rcvd, 1)
                line.append(NSString(format:"%c",buff_rcvd) as String)
            }
            let cmd = rawCommandToOperationAndArgs(rawCommand: line)
            let command = CommandFactory.build(forOperation: cmd.op, withArgs: cmd.args)
            
            DispatchQueue.main.async {
                command.execute(sender: self)
            }
        }
    }
}
