import Foundation

class Server {
    
    let port = "1234"
    
    func start() {
        print("Server starting...")
        
        // MARK: 1. create socket
        // socket file descriptor
        let socketFD = socket(
            AF_INET6,    // AF_INET6    for IPV6
            SOCK_STREAM, // SOCK_STREAM for TCP
            IPPROTO_TCP // IPPROTO_TCP for ICMP
        )
        // check for errors
        if socketFD == -1 {
            print("Error creating BSD Socket")
            return
        }
        
        // MARK: 2. define the socket address structure
        
        // create hints
        var hints = addrinfo(
            ai_flags: AI_PASSIVE,
            ai_family: AF_UNSPEC,
            ai_socktype: SOCK_STREAM,
            ai_protocol: 0,
            ai_addrlen: 0,
            ai_canonname: nil,
            ai_addr: nil,
            ai_next: nil
        )
        
        var servinfo: UnsafeMutablePointer<addrinfo>? = nil
        let addrInfoResult = getaddrinfo(
            nil,
            port,
            &hints,
            &servinfo // serve info will have the ai_addr pointing to sockaddr struct.
        )
        // check for errors
        guard addrInfoResult == 0 else {
            print("Error getting address info: \(errno)")
            return
        }
        
        // MARK: 3. bind socket to the sockaddr
        guard
            let addr = servinfo?.pointee.ai_addr,
            let addrLen = servinfo?.pointee.ai_addrlen
        else {
            print("Failed to get the socket address.")
            return
        }
        let bindResult = bind(socketFD, addr, socklen_t(addrLen))
        // check for errors
        if bindResult == -1 {
            print("Error binding socket to Address: \(errno)")
            return
        }
        
        // MARK: 4. prepare to listen for connections
        let listenResult = listen(
            socketFD, // socket file descriptor
            8         // max length for the queue of pending connections
        )
        // check for errors
        if listenResult == -1 {
            print("Error setting our socket to listen")
            return
        }
        
        // MARK: 5. accept a connection
        // never-ending loop that will accept connections
        while true {
            // maximum transmission unit
            let MTU = 65536
            var addr = sockaddr()
            var addr_len: socklen_t = 0
            
            print("About to accept")
            let clientFD = accept(socketFD, &addr, &addr_len)
            print("Accepted new client with file descriptor: \(clientFD)")
            
            if clientFD == -1 {
                print("Error accepting connection")
            }
            
            // stores the data from the client
            var buffer = UnsafeMutableRawPointer.allocate(
                byteCount: MTU,
                alignment: MemoryLayout<CChar>.size
            )
            
            while true {
                let readResult = read(clientFD, &buffer, MTU)
                
                if readResult == 0 {
                    break // end of file
                } else if readResult == -1 {
                    print("Error reading from client \(clientFD) - \(errno)")
                    break
                } else {
                    let strResult = withUnsafePointer(to: &buffer) { pointer in
                        pointer.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: readResult)) { cstr in
                            String(cString: cstr)
                        }
                    }
                    print("Received from client (\(clientFD)): \(strResult)")
                    write(clientFD, &buffer, readResult)
                }
            }
        }
    }
    
}
