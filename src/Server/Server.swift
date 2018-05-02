import Foundation
import CoreFoundation
import AppKit.NSAlert
import os.log

/*
 * NOTE:
 * This class contains low-evel code which is usually not
 * seen by Swift programmers. For those unfamiliar with network
 * programming, I suggest to read "Beej's Guide to Network Programming".
 * That guide is available at http://beej.us/guide/bgnet/.
 * (Note that Beej's Guide uses the C programming language).
 *
 * The code in the following class is laid out such that it's structure
 * corresponds to the structure of the aforementioned guide.
 */
class Server: Thread {
    let QUEUE_SIZE: Int32 = 5
    let UNKNOWN_ERROR = "Unknown error."
    
    let UNDEFINED_ERROR: Int32 = -1
    
    /* NOTE: The archaic types, functions and their error-codes
     * are documented in the BSD System Calls Manual and in the
     * BSD Library Functions Manual. */
    
    var _addrinfo: addrinfo?
    var _sockaddr: UnsafeMutablePointer<addrinfo>?
    private static let INVALID_FILE_DESCRIPTOR: Int32 = -1
    var socket_fd: Int32 = INVALID_FILE_DESCRIPTOR
    var request_fd: Int32 = INVALID_FILE_DESCRIPTOR

    func serve(dispatchForExecutionWhenChannelIsOpened: () -> Void) {
        func setupDataStructures(portToListenOn port: UInt16) throws {
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
                String(port),
                &(self._addrinfo!),
                &(self._sockaddr))
            
            guard status == 0 else {
                let prefix = "Failed to prepare for a network connection: "
                var errorMessage: String
                var errorCode: Int32
                switch status {
                                    /** Non-recoverable errors: **/
                case EAI_AGAIN,     /* temporary failure in name resolution */
                     EAI_BADFLAGS,  /* invalid value for ai_flags */
                     EAI_BADHINTS,  /* invalid value for hints */
                     EAI_FAIL,      /* on-recoverable failure in name resolution */
                     EAI_FAMILY,    /* ai_family not supported */
                     EAI_MEMORY,    /* memory allocation failure */
                     EAI_NONAME,    /* hostname or servname not provided, or not known */
                     EAI_OVERFLOW,  /* argument buffer overflow */
                     EAI_PROTOCOL,  /* resolved protocol is unknown */
                     EAI_SERVICE,   /* servname not supported for ai_socktype */
                     EAI_SOCKTYPE:  /* ai_socktype not supported */
                    errorMessage = String(validatingUTF8: gai_strerror(status)) ?? UNKNOWN_ERROR
                    errorCode = status
                case EAI_SYSTEM:    /* system error returned in errno */
                    errorMessage = String(validatingUTF8: strerror(errno)) ?? UNKNOWN_ERROR
                    errorCode = errno
                    break
                default:            /* Non-documented errors are non-recoverable. */
                    errorMessage = UNKNOWN_ERROR
                    errorCode = status
                    break
                }
                throw NetworkError.getaddrinfo(recoverable: false,
                                               errorMessage: prefix + errorMessage,
                                               errorCode: errorCode)
            }
        }
        
        func getSocketFileDescriptor() throws {
            self.socket_fd = socket(
                self._sockaddr!.pointee.ai_family,
                self._sockaddr!.pointee.ai_socktype,
                self._sockaddr!.pointee.ai_protocol)
            
            guard self.socket_fd != Server.INVALID_FILE_DESCRIPTOR else {
                switch errno {
                                /** Non-recoverable errors: **/
                case EACCES,    /* Permission to create a socket of the specified type and/or protocol is denied.*/
                EAFNOSUPPORT,   /* The specified address family is not supported. */
                EMFILE,         /* The per-process descriptor table is full. */
                ENOBUFS,        /* Insufficient buffer space is available.
                                 * The socket cannot be created until sufficient resources are freed. */
                ENOMEM,         /* Insufficient memory was available to fulfill the request. */
                EPROTONOSUPPORT,/* The protocol type or the specified protocol is not supported
                                 * within this domain. */
                EPROTOTYPE:     /* The socket type is not supported by the protocol. */
                    break
                default:        /* Non-documented errors are non-recoverable. */
                    break
                }
                var errorMessage = "Failed to create a socket file descriptor. Error: "
                errorMessage.append(String(utf8String: strerror(errno)) ?? UNKNOWN_ERROR)
                freeaddrinfo(self._sockaddr)
                throw NetworkError.socket(recoverable: false, errorMessage: errorMessage, errorCode: errno)
            }
        }
        
        func bindSocketFileDescriptorToPort() throws {
            let status = Darwin.bind(
                self.socket_fd,
                self._sockaddr!.pointee.ai_addr,
                self._sockaddr!.pointee.ai_addrlen)
            
            guard status == 0 else {
                defer {
                    freeaddrinfo(self._sockaddr)
                    close(self.socket_fd)
                }
                var errorMessage = "Failed to bind a socket file descriptor to a port. Error: "
                errorMessage.append(String(utf8String: strerror(errno)) ?? UNKNOWN_ERROR)
                
                switch errno {
                                    /** Recoverable errors: **/
                case EADDRINUSE,    /* The specified address is already in use. */
                     EINVAL:        /* socket is already bound or it has been shut down. */
                    throw NetworkError.bind(recoverable: true, errorMessage: errorMessage, errorCode: errno)
                    
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
                throw NetworkError.bind(recoverable: false, errorMessage: errorMessage, errorCode: errno)
            }
            freeaddrinfo(self._sockaddr)
        }
        
        func listenForACall() throws {
            let status = listen(
                self.socket_fd,
                QUEUE_SIZE)
            
            guard status == 0 else {
                defer {
                    close(socket_fd)
                }
                var errorMessage = "Failed to listen on a socket. Error: "
                errorMessage.append(String(utf8String: strerror(errno)) ?? UNKNOWN_ERROR)
                
                switch errno {
                                    /** Recoverable errors: **/
                case EDESTADDRREQ,  /* The socket is not bound to a local address and the protocol
                                     * does not support listening to an unbound socket. */
                     EINVAL:        /* Socket is already connected. */
                    throw NetworkError.listen(recoverable: true, errorMessage: errorMessage, errorCode: errno)
                    
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
                throw NetworkError.listen(recoverable: false, errorMessage: errorMessage, errorCode: errno)
            }
        }
        
        func acceptCall() throws {
            defer {
                close(self.socket_fd) // NOTE: Only a single connection shall be accepted.
            }
            var connectedAddrInfo = sockaddr(sa_len: 0, sa_family: 0, sa_data: (0,0,0,0,0,0,0,0,0,0,0,0,0,0))
            var connectedAddrInfoLength = socklen_t(MemoryLayout.size(ofValue: sockaddr.self))
            self.request_fd = accept(self.socket_fd,
                                     &connectedAddrInfo,
                                     &connectedAddrInfoLength)
            
            guard request_fd != Server.INVALID_FILE_DESCRIPTOR else {
                defer {
                    if request_fd != Server.INVALID_FILE_DESCRIPTOR {
                        close(request_fd)
                    }
                }
                let errorMessage = String(utf8String: strerror(errno)) ?? "Unknown error"
                
                switch errno {
                                  /** Recoverable errors: **/
                case EBADF,       /* socket is not a valid file descriptor. */
                     ECONNABORTED,/* The connection to socket has been aborted. */
                     EWOULDBLOCK, /* socket is marked as non-blocking and no connections are present to be accepted. */
                     EINTR,       /* The accept() system call was terminated by a signal. */
                     EINVAL:      /* socket is unwilling to accept connections. */
                    throw NetworkError.accept(recoverable: true, errorMessage: errorMessage, errorCode: errno)
                
                                  /** Non-recoverable errors: **/
                case EFAULT,      /* The address parameter is not in a writable part of the user address space. */
                     EMFILE,      /* The pre-process descriptor table is full. */
                     ENFILE,      /* The system file table is full. */
                     ENOMEM,      /* Insufficient memory was available to complete the operation. */
                     ENOTSOCK,    /* socket references a file type other than a socket. */
                     EOPNOTSUPP:  /* socket is not of type SOCK_STREAM and thus does not accept connections. */
                    break
                default:          /* Non-documented errors are non-recoverable. */
                    break
                }
                throw NetworkError.accept(recoverable: false, errorMessage: errorMessage, errorCode: errno)
            }
        }
        
        /**
          Receives and processes GUI-o-Matic Stage 3 protocol commands.
         
          - Throws:
          An error of type `NetworkError.read` if the received data is not a stage 3 protocol command and
          this method can recover from that error.
        */
        func receiveAndProcessData() throws {
            defer {
                close(self.request_fd)
            }
            while (true) {
                var line: String = ""
                var buff_rcvd = CChar()
                
                /* Read a gui-o-matic command from the socket. */
                while line.last != Constants.NEWLINE_CHAR {
                    let status = read(self.request_fd,
                         &buff_rcvd,
                         1) /* The number of bytes to read. */
                    
                    guard status != -1 else {
                        let errorMessage = String(utf8String: strerror(errno)) ?? "Unknown error"
                        switch errno {
                                            /** Recoverable errors. **/
                            case EBADF,     /* fildes is not a valid file or socket descriptor open for reading. */
                                 EINTR,     /* A read from a slow device was interrupted before any data arrived
                                             * by the delivery of a signal. */
                                 ENOBUFS,   /* An attempt to allocate a memory buffer fails. */
                                 ECONNRESET,/* The connection is closed by the peer during a read attempt on a socket.*/
                                 ENOTCONN,  /* A read is attempted on an unconnected socket. */
                                 ETIMEDOUT: /* A transmission timeout occurs during a read attempt on a socket. */
                                throw NetworkError.accept(recoverable: true,
                                                          errorMessage: errorMessage,
                                                          errorCode: errno)
                            
                                            /** Non-recoverable errors: **/
                            case EAGAIN,    /* The file was marked for non-blocking I/O,
                                             * and no data were ready to be read. */
                                 EFAULT,    /* Buf points outside the allocated address space. */
                                 EINVAL,    /* The pointer associated with fildes was negative. */
                                 EIO,       /* The process group is orphaned. */
                                 EISDIR,    /* An attempt is made to read a directory. */
                                 ENOMEM,    /* Insufficient memory is available. */
                                 ENXIO:     /* A requested action cannot be performed by the device. */
                            break
                        default:            /* Non-documented errors are non-recoverable. */
                            break
                        }
                        throw NetworkError.accept(recoverable: false, errorMessage: errorMessage, errorCode: errno)
                    }
                    
                    line.append(String(format:"%c", buff_rcvd))
                }
                
                /* Parse the gui-o-matic command */
                do {
                    let cmd = try Parser.guiomaticCommandToOperationAndArgs(guiomaticCommand: line)
                    if (cmd.op == Operation.show_main_window) {
                        Blackboard.shared.canMainWindowBeVisible = true
                    } else if (cmd.op == Operation.hide_main_window) {
                        Blackboard.shared.canMainWindowBeVisible = false
                    }
                    let command = CommandFactory.build(forOperation: cmd.op, withArgs: cmd.args)
                    
                    
                    /* Dispatch the command for execution on the GUI thread. */
                    DispatchQueue.main.async {
                        command.execute(sender: self)
                    }
                } catch ParsingError.empty {
                    continue
                } catch ParsingError.notStage3Command {
                    continue
                } catch ParsingError.notJSON {
                    continue
                }
            }
        }
        
        func logError(_ errorMessage: String, _ errorCode: Int32? = nil) {
            // TODO change to os_log.
            NSLog(errorMessage + (errorCode != nil ? " ("+String(errorCode!)+")." : ""))
        }
        
        // TODO Refactor out.
        func displayErrorToUser(preferredErrorMessage: String) {
            DispatchQueue.main.async {
                func showAlert() {
                    let alert = NSAlert()
                    if let error = Blackboard.shared.nextErrorMessage {
                        Blackboard.shared.nextErrorMessage = nil
                        alert.messageText = error
                    } else {
                        alert.messageText = "Error"
                    }
                    alert.informativeText = preferredErrorMessage
                    alert.addButton(withTitle: "Exit")
                    alert.alertStyle = NSAlert.Style.critical
                    alert.runModal()
                    NSApp.terminate(self)
                }
                showAlert()
                NSApp.requestUserAttention(.criticalRequest)
            }
        }
        
        while (true) {
            do {
                Blackboard.shared.tcp_port = nil
                let port = UInt16.random(min: 1024, max: UInt16.max)
                try setupDataStructures(portToListenOn: port)
                try getSocketFileDescriptor()
                /* NOTE: bindSocketFileDescriptorToPort throws a recoverable exception should it fail
                 * to bind a socket to a port, in which case the error handling spins this loop around
                 * and an attempt will be made to bind a new socket to a different port. */
                try bindSocketFileDescriptorToPort()
                try listenForACall()
                Blackboard.shared.tcp_port = port
                dispatchForExecutionWhenChannelIsOpened()
                try acceptCall()
                
                
                try receiveAndProcessData()
            }
            /*
             *    Handle recoverable errors.
             */
            catch let NetworkError.getaddrinfo(recoverable, errorMessage, errorCode) where recoverable  {
                logError(errorMessage, errorCode)
                continue
            } catch let NetworkError.socket(recoverable, errorMessage, errorCode) where recoverable {
                logError(errorMessage, errorCode)
                continue
            } catch let NetworkError.bind(recoverable, errorMessage, errorCode) where recoverable {
                logError(errorMessage, errorCode)
                continue
            } catch let NetworkError.listen(recoverable, errorMessage, errorCode) where recoverable {
                logError(errorMessage, errorCode)
                continue
            } catch let NetworkError.accept(recoverable, errorMessage, errorCode) where recoverable {
                logError(errorMessage, errorCode)
                continue
            } catch let NetworkError.read(recoverable, errorMessage, errorCode) where recoverable {
                logError(errorMessage, errorCode)
                continue
            }
            /*
             *    Handle non-recoverable errors.
             */
            catch let NetworkError.getaddrinfo(recoverable, errorMessage, errorCode) where !recoverable  {
                logError(errorMessage, errorCode)
                displayErrorToUser(preferredErrorMessage: errorMessage)
                return
            } catch let NetworkError.socket(recoverable, errorMessage, errorCode) where !recoverable {
                logError(errorMessage, errorCode)
                displayErrorToUser(preferredErrorMessage: errorMessage)
                return
            } catch let NetworkError.bind(recoverable, errorMessage, errorCode) where !recoverable {
                logError(errorMessage, errorCode)
                displayErrorToUser(preferredErrorMessage: errorMessage)
                return
            } catch let NetworkError.listen(recoverable, errorMessage, errorCode) where !recoverable {
                logError(errorMessage, errorCode)
                displayErrorToUser(preferredErrorMessage: errorMessage)
                return
            } catch let NetworkError.accept(recoverable, errorMessage, errorCode) where !recoverable {
                logError(errorMessage, errorCode)
                displayErrorToUser(preferredErrorMessage: errorMessage)
                return
            } catch let NetworkError.read(recoverable, errorMessage, errorCode) where !recoverable {
                logError(errorMessage, errorCode)
                displayErrorToUser(preferredErrorMessage: errorMessage)
                return
            } catch {
                let errorMessage = "An unknown network error has occured."
                logError(errorMessage)
                displayErrorToUser(preferredErrorMessage: errorMessage)
                return
            }
        }
        
    }
}
