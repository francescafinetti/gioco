import SwiftUI
import MultipeerConnectivity

struct ConnectView: View {
    @StateObject private var multipeerManager = MultipeerManager()
    @State private var isConnected = false
    @State private var isSearching = false
    @State private var btHelper = BluetoothPermissionHelper()
    @State private var networkHelper = NetworkPermissionHelper()

    @State private var peerConnectionStates: [String: MCSessionState] = [:]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Multiplayer Match")
                    .font(.largeTitle)
                    .bold()

                Text("Connected Peers: \(multipeerManager.connectedPeers.count)")
                    .foregroundColor(.gray)

                if !multipeerManager.connectedPeers.isEmpty {
                    VStack(alignment: .leading) {
                        ForEach(multipeerManager.connectedPeers, id: \.self) { peer in
                            Text("\(peer.displayName)")
                                .foregroundColor(.green)
                        }
                    }
                }

                NavigationLink(
                    destination: MultiplayerGameView(multipeerManager: multipeerManager as MultipeerManager),
                    isActive: $isConnected,
                    label: { EmptyView() }
                )

                if !isConnected {
                    if !isSearching {
                        Button("Look for nearby players") {
                            multipeerManager.startLooking()
                            isSearching = true
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    } else {
                        Text("Looking for nearby players...")
                            .foregroundColor(.blue)
                    }

                    if !multipeerManager.discoveredPeers.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Peers found:")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            ForEach(multipeerManager.discoveredPeers, id: \.self) { peer in
                                Button(action: {
                                    multipeerManager.invite(peer)
                                }) {
                                    HStack {
                                        Text(peer.displayName)
                                        Spacer()
                                        Text(connectionStateString(peer))
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                    .padding(8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(radius: 1)
                                }
                            }
                        }
                        .padding(.top)
                    } else {
                        Text("No peer found yet...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else {
                    Text("Connected! Starting the game...")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .onChange(of: multipeerManager.connectedPeers) { peers in
                if !peers.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isConnected = true
                    }
                }
            }
        }
        .onAppear {
            btHelper = BluetoothPermissionHelper()
            networkHelper.triggerLocalNetworkPermission()
        }
        .onReceive(multipeerManager.$peerConnectionStates) { states in
            self.peerConnectionStates = states
        }
    }

    func connectionStateString(_ peer: MCPeerID) -> String {
        switch peerConnectionStates[peer.displayName] {
        case .connected: return "Connected"
        case .connecting: return "Connecting"
        case .notConnected: return "Not Connected"
        default: return "Unknown"
        }
    }
}
