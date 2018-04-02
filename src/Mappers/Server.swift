import Foundation
import CoreFoundation

class Server: Thread {
    let QUEUE_SIZE: Int32 = 5
    let port = "4444"
    
    var _addrinfo: addrinfo?
    var _sockaddr: UnsafeMutablePointer<addrinfo>?
    var socket_fd: Int32 = -1
    var request_fd: Int32 = -1
    
    func serve(dispatchForExecutionWhenChannelIsOpened: () -> Void) {
        func setupDataStructures() {
            self._addrinfo = addrinfo(
                ai_flags: AI_PASSIVE,       // Localhost
                ai_family: AF_INET,         // Use either IPv4 or IPv6
                ai_socktype: SOCK_STREAM,   // Force TCP
                ai_protocol: 0,             // Any
                ai_addrlen: 0,
                ai_canonname: nil,
                ai_addr: nil,
                ai_next: nil)
            
            let status = getaddrinfo(
                nil,
                port,
                &(self._addrinfo!),
                &(self._sockaddr))
            
            guard status == 0 else {
                // todo error handling
                return
            }
        }
        
        func getSocketFileDescriptor() {
            self.socket_fd = socket(
                self._sockaddr!.pointee.ai_family,
                self._sockaddr!.pointee.ai_socktype,
                self._sockaddr!.pointee.ai_protocol)
            
            guard self.socket_fd != -1 else {
                // todo error handling.
                freeaddrinfo(_sockaddr)
                return
            }
        }
        
        func bindSocketFileDescriptorToPort() {
            let status = Darwin.bind(
                self.socket_fd,
                self._sockaddr!.pointee.ai_addr,
                self._sockaddr!.pointee.ai_addrlen)
            
            guard status == 0 else {
                // Handle errors
                freeaddrinfo(self._sockaddr)
                close(self.socket_fd)
                return
            }
        }
        
        func listenForACall() {
            let status = listen(
                self.socket_fd,
                QUEUE_SIZE)
            
            guard status == 0 else {
                // TODO error handling.
                close(self.socket_fd)
                return
            }
        }
        
        func acceptCall() {
            var connectedAddrInfo = sockaddr(sa_len: 0, sa_family: 0, sa_data: (0,0,0,0,0,0,0,0,0,0,0,0,0,0))
            var connectedAddrInfoLength = socklen_t(MemoryLayout.size(ofValue: sockaddr.self))
            self.request_fd = accept(self.socket_fd,
                                     &connectedAddrInfo,
                                     &connectedAddrInfoLength) // TODO free?
            
            guard request_fd != -1 else {
                let error = String(utf8String: strerror(errno)) ?? "Unknown error" // TODO Handle errors.
                print(error)
                Thread.exit()
                return
            }
        }
        
        func receiveAndProcessData() {
            while (true) {
                var line: String = ""
                var buff_rcvd = CChar()
                while line.last != "\n" {
                    read(self.request_fd,
                         &buff_rcvd,
                         1)
                    line.append(NSString(format:"%c",buff_rcvd) as String)
                }
                let cmd = rawCommandToOperationAndArgs(rawCommand: line)
                let command = CommandFactory.build(forOperation: cmd.op, withArgs: cmd.args)
                
                DispatchQueue.main.async {
                    command.execute(sender: self)
                }
            }
        }
        
        setupDataStructures()
        getSocketFileDescriptor()
        bindSocketFileDescriptorToPort()
        listenForACall()
        dispatchForExecutionWhenChannelIsOpened()
        acceptCall()
        receiveAndProcessData()
        // TODO free up resources.
    }
}
