import Foundation

// source: https://rderik.com/guides/

print("Welcome to my simple echo server!")

var server = Server()
server.start()

RunLoop.main.run()
exit(EXIT_SUCCESS)
