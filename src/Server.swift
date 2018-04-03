import Foundation
import CoreFoundation

class Server: Thread {
    let QUEUE_SIZE: Int32 = 5
    let port = "4444"
    let UNKNOWN_ERROR = "Unknown error."
    
    /* NOTE: The archaic types, functions and their error-codes
     * are documented in the BSD System Calls Manual. */
    
    var _addrinfo: addrinfo?
    var _sockaddr: UnsafeMutablePointer<addrinfo>?
    var socket_fd: Int32? = -1
    var request_fd: Int32? = -1

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
                let prefix = "Failed to prepare for a network connection: "
                let errorMessage = status == EAI_SYSTEM
                    ? String(validatingUTF8: strerror(errno))
                    : String(validatingUTF8: gai_strerror(status))
                throw NetworkError.getaddrinfo(errorMessage: prefix + (errorMessage ?? UNKNOWN_ERROR))
            }
        }
        
        func getSocketFileDescriptor() throws {
            self.socket_fd = socket(
                self._sockaddr!.pointee.ai_family,
                self._sockaddr!.pointee.ai_socktype,
                self._sockaddr!.pointee.ai_protocol)
            
            guard self.socket_fd != -1 else {
                var errorMessage = "Failed to create a socket file descriptor. Error: "
                errorMessage.append(String(utf8String: strerror(errno)) ?? UNKNOWN_ERROR)
                freeaddrinfo(self._sockaddr)
                throw NetworkError.socket(errorMessage: errorMessage)
            }
        }
        
        func bindSocketFileDescriptorToPort() throws {
            let status = Darwin.bind(
                self.socket_fd!,
                self._sockaddr!.pointee.ai_addr,
                self._sockaddr!.pointee.ai_addrlen)
            
            guard status == 0 else {
                defer {
                    freeaddrinfo(self._sockaddr)
                    close(self.socket_fd!)
                }
                
                var errorMessage = "Failed to bind a socket file descriptor to a port. Error: "
                errorMessage.append(String(utf8String: strerror(errno)) ?? UNKNOWN_ERROR)
                
                switch errno {
                                    /** Recoverable errors: **/
                case EADDRINUSE,    /* The specified address is already in use. */
                     EINVAL:        /* socket is already bound or it has been shut down. */
                    throw NetworkError.bind(recoverable: true, errorMessage: errorMessage)
                    
                                    /** Non-recoverable errors: **/
                case EACCES,        /* The current user has inadequate permission to access the requested address. */
                     EADDRNOTAVAIL, /* The specified address is not available from the local machine. */
                     EAFNOSUPPORT,  /* socket is not of a type that can be bound to an address. */
                     EBADF,         /* socket is not a valid file descriptor. */
                     EDESTADDRREQ,  /* socket is a null pointer. */
                     EFAULT,        /* the address parameter is not in a valid part of the user address space. */
                     ENOTSOCK:      /* socket does not refer to a socket */
                    break
                default:            /* Non-documented errors are non-recoverable. */
                    break
                }
                throw NetworkError.bind(recoverable: false, errorMessage: errorMessage)
            }
            freeaddrinfo(self._sockaddr)
        }
        
        func listenForACall() throws {
            let status = listen(
                self.socket_fd!,
                QUEUE_SIZE)
            
            guard status == 0 else {
                defer {
                    close(socket_fd!)
                }
                
                var errorMessage = "Failed to listen on a socket. Error: "
                errorMessage.append(String(utf8String: strerror(errno)) ?? UNKNOWN_ERROR)
                
                switch errno {
                                    /** Recoverable errors: **/
                case EDESTADDRREQ,  /* The socket is not bound to a local address and the protocol
                                     * does not support listening to an unbound socket. */
                     EINVAL:        /* Socket is already connected. */
                    throw NetworkError.listen(recoverable: true, errorMessage: errorMessage)
                    
                                    /** Non-recoverable errors: **/
                case EACCES,        /* The current process has insufficient privileges. */
                     EBADF,         /* The argument socket is not a valid file descriptor. */
                     EINVAL,        /* Socket is already connected. */
                     ENOTSOCK,      /* The argument socket does not reference a socket. */
                     EOPNOTSUPP:    /* The socket is not of a type that supports the operation listen(). */
                    break
                default:            /* Non-documented errors are non-recoverable. */
                    break
                }
                throw NetworkError.listen(recoverable: false, errorMessage: errorMessage)
            }
        }
        
        func acceptCall() {
            var connectedAddrInfo = sockaddr(sa_len: 0, sa_family: 0, sa_data: (0,0,0,0,0,0,0,0,0,0,0,0,0,0))
            var connectedAddrInfoLength = socklen_t(MemoryLayout.size(ofValue: sockaddr.self))
            self.request_fd = accept(self.socket_fd!,
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
                    read(self.request_fd!,
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
            try bindSocketFileDescriptorToPort()
            try listenForACall()
            dispatchForExecutionWhenChannelIsOpened()
            acceptCall()
            receiveAndProcessData()
            // TODO free up resources.
        } catch  {
            print("todo error handling.")
        }
    }
}
