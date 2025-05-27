
//
//  ContentView.swift
//  gioco
//
//  Created by Francesca Finetti on 08/05/25.
//
import SwiftUI

struct ContentView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = GameViewModel(playerCount: 2)

    // MARK: – Stati di UI
    @State private var dragOffset: CGSize = .zero
    @State private var botOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var showBotCard = false
    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer?
    @State private var showExitConfirmation: Bool = false

    @State private var centralDragOffset: CGSize = .zero
    @State private var isDraggingCentral = false

    // MARK: – Stato per navigazione EndGameView
    @State private var showEndGame = false

    // MARK: – Costanti
    private let duration: TimeInterval = 7.0

    var body: some View {
        ZStack {
            Image("es")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                // Bot deck animato posizionato sopra al mazzo centrale
                BotDeckView(
                    viewModel: viewModel,
                    showBotCard: $showBotCard,
                    botOffset: $botOffset
                )
                .zIndex(showBotCard ? 1 : 0)

                // Mazzo centrale
                CentralPileView(
                    viewModel: viewModel,
                    progress: $progress,
                    duration: duration,
                    centralDragOffset: $centralDragOffset,
                    isDraggingCentral: $isDraggingCentral
                )
                .zIndex(0)

                // Deck giocatore
                PlayerDeckView(
                    viewModel: viewModel,
                    dragOffset: $dragOffset,
                    isDragging: $isDragging
                )
                .zIndex(1)

                Spacer()
            }
            .padding(.bottom, 250)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showExitConfirmation = true
                } label: {
                    Image(systemName: "house.fill")
                        .foregroundColor(.black)
                }
            }
        }
        // Animazione bot: tempi mantenuti
        .onChange(of: viewModel.currentPlayer) { newValue in
            if newValue == 1 {
                showBotCard = true
                botOffset = .zero

                // Animazione immediata
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        botOffset = CGSize(width: 0, height: -200)
                    }
                    // Sparisce dopo 0.5 secondi
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showBotCard = false
                    }
                }
            } else {
                startTimer()
            }
        }
        .onReceive(viewModel.$isGameOver) { over in
            if over {
                showEndGame = true
            }
        }
        .background(
            NavigationLink(
                destination: EndGameView(winner: viewModel.winner ?? 0),
                isActive: $showEndGame
            ) {
                EmptyView()
            }
        )
        .alert("Are you sure you want to leave the match?", isPresented: $showExitConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                dismiss()
            }
        }
    }

    private func startTimer() {
        progress = CGFloat(duration)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { t in
            if progress > 0 {
                progress -= 0.01
            } else {
                progress = 0
                t.invalidate()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
