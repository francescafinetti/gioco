import SwiftUI
import MultipeerConnectivity

enum GameAction: Codable {
    case playCard
    case tapForDoppia
}

class MultipeerManager: NSObject, ObservableObject {
    private let serviceType = "straccia-game"

    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!

    @Published var connectedPeers: [MCPeerID] = []
    @Published var discoveredPeers: [MCPeerID] = []
    @Published var peerConnectionStates: [String: MCSessionState] = [:]
    var onDataReceived: ((Data) -> Void)?

    override init() {
        super.init()
        print("🧩 MultipeerManager init - PeerID: \(myPeerID.displayName)")

        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self

        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self

        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser.delegate = self
    }

    func startLooking() {
        print("🚀 startLooking chiamato da: \(myPeerID.displayName)")
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
        print("📡 Iniziato advertising + browsing")
    }

    func send(_ data: Data) {
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            print("📤 Dati inviati a: \(session.connectedPeers.map { $0.displayName })")
        } catch {
            print("❌ Errore invio dati: \(error.localizedDescription)")
        }
    }

    func invite(_ peer: MCPeerID) {
        print("📨 Invitando peer manualmente: \(peer.displayName)")
        browser.invitePeer(peer, to: session, withContext: nil, timeout: 10)
    }
}

extension MultipeerManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        let stateString: String
        switch state {
        case .notConnected: stateString = "❌ Not Connected"
        case .connecting: stateString = "🔄 Connecting"
        case .connected: stateString = "✅ Connected"
        @unknown default: stateString = "❓ Unknown"
        }

        print("📶 Stato connessione con \(peerID.displayName): \(stateString)")

        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
            self.peerConnectionStates[peerID.displayName] = state
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            print("📨 Ricevuti dati da: \(peerID.displayName)")
            self.onDataReceived?(data)
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("📩 Ricevuto invito da: \(peerID.displayName)")
        invitationHandler(true, self.session)
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("🔍 Trovato peer: \(peerID.displayName)")
        DispatchQueue.main.async {
            if !self.discoveredPeers.contains(peerID) {
                self.discoveredPeers.append(peerID)
            }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("❌ Perso peer: \(peerID.displayName)")
        DispatchQueue.main.async {
            self.discoveredPeers.removeAll { $0 == peerID }
        }
    }
}

