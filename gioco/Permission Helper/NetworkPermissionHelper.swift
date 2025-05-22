import Foundation
import Network

class NetworkPermissionHelper {
    private var connection: NWConnection?

    func triggerLocalNetworkPermission() {
        let host = NWEndpoint.Host("apple.local")
        let port = NWEndpoint.Port(integerLiteral: 1234)

        connection = NWConnection(host: host, port: port, using: .tcp)
        connection?.start(queue: .main)

        // Chiudiamo subito: serve solo per forzare il permesso
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.connection?.cancel()
        }
    }
}
