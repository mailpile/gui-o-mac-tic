import Foundation
import CoreFoundation

/* NOTE: The archaic functions used in this file are documented in the online-manual pages (man command). */

class Server: Thread {
    let QUEUE_SIZE: Int32 = 5
    let port = "4444"
    let UNKNOWN_ERROR = "Unknown error."
    
    var _addrinfo: addrinfo?
    var _sockaddr: UnsafeMutablePointer<addrinfo>?
    var socket_fd: Int32 = -1
    var request_fd: Int32 = -1

    func serve(dispatchForExecutionWhenChannelIsOpened: () -> Void) {
        func setupDataStructures() throws {
            self._addrinfo = addrinfo(
                ai_flags: AI_PASSIVE,
                ai_family: AF_INET,         // Use either IPv4 or IPv6.
                ai_socktype: SOCK_STREAM,   // Force TCP.
                ai_protocol: 0,             // Do not prefer IPv4 or IPv6 over the other.
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
                let prefix = "The following error occured while preparing for a network connection: "
                let errorMessage = status == EAI_SYSTEM
                    ? String(validatingUTF8: strerror(errno))
                    : String(validatingUTF8: gai_strerror(status))
                throw NetworkError.getaddrinfo(reason: prefix + (errorMessage ?? UNKNOWN_ERROR))
            }
        }
        
        func getSocketFileDescriptor() throws {
            self.socket_fd = socket(
                self._sockaddr!.pointee.ai_family,
                self._sockaddr!.pointee.ai_socktype,
                self._sockaddr!.pointee.ai_protocol)
            
            guard self.socket_fd != -1 else {
                var errorMessage = "The following error occured while attempting to create a socket file descriptor: "
                errorMessage.append(String(utf8String: strerror(errno)) ?? UNKNOWN_ERROR)
                freeaddrinfo(self._sockaddr)
                throw NetworkError.socket(reason: errorMessage)
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
        
        do {
            try setupDataStructures()
            try getSocketFileDescriptor()
            bindSocketFileDescriptorToPort()
            listenForACall()
            dispatchForExecutionWhenChannelIsOpened()
            acceptCall()
            receiveAndProcessData()
            // TODO free up resources.
        } catch  {
            print("todo error handling.")
        }
    }
}
