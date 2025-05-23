import SwiftUI

struct MultiplayerGameView: View {
    @ObservedObject var multipeerManager: MultipeerManager
    @StateObject private var viewModel = GameViewModel(playerCount: 2)
    @State private var localPlayerIndex = 0 // 0 o 1, da definire magari con nome peer

    var body: some View {
        VStack(spacing: 30) {
            Text("Connected with: \(multipeerManager.connectedPeers.first?.displayName ?? "")")
                .font(.headline)

            Text("Player \(viewModel.currentPlayer + 1)'s Turn")
                .bold()

            Button("Play Card") {
                if viewModel.currentPlayer == localPlayerIndex {
                    viewModel.playCard()
                    sendAction(.playCard)
                }
            }
            .disabled(viewModel.currentPlayer != localPlayerIndex)

            Button("Tap for double") {
                viewModel.tapForDoppia(by: localPlayerIndex)
                sendAction(.tapForDoppia)
            }

            Text("Player 1 cards: \(viewModel.players[0].count)")
            Text("Player 2 cards: \(viewModel.players[1].count)")

            if let winner = viewModel.winner {
                Text("Player \(winner + 1) won!")
                    .font(.title)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .onAppear {
            multipeerManager.onDataReceived = { data in
                if let action = try? JSONDecoder().decode(GameAction.self, from: data) {
                    handleReceivedAction(action)
                }
            }
        }
    }

    func sendAction(_ action: GameAction) {
        if let data = try? JSONEncoder().encode(action) {
            multipeerManager.send(data)
        }
    }

    func handleReceivedAction(_ action: GameAction) {
        switch action {
        case .playCard:
            viewModel.playCard()
        case .tapForDoppia:
            let otherPlayer = (localPlayerIndex + 1) % 2
            viewModel.tapForDoppia(by: otherPlayer)
        }
    }
}
