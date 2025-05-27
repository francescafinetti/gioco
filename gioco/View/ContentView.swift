
//
//  ContentView.swift
//  gioco
//
//  Created by Francesca Finetti on 08/05/25.
//
import SwiftUI

struct ContentView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = GameViewModel(playerCount: 2)
    @Namespace private var animation

    // MARK: – Stati di UI
    @State private var dragOffset: CGSize = .zero
    @State private var botOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var showBotCard = false
    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer?
    @State private var centralDragOffset: CGSize = .zero
    @State private var isDraggingCentral = false

    // MARK: – Stato per navigazione EndGameView
    @State private var showEndGame = false

    // MARK: – Costanti
    private let duration: TimeInterval = 7.0

    var body: some View {
        NavigationStack {
            ZStack {
                // Sfondo
                Image("es")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 50) {
                    Spacer()

                    BotDeckView(
                        viewModel: viewModel,
                        showBotCard: $showBotCard,
                        botOffset: $botOffset
                    )

                    CentralPileView(
                        viewModel: viewModel,
                        progress: $progress,
                        duration: duration,
                        centralDragOffset: $centralDragOffset,
                        isDraggingCentral: $isDraggingCentral
                    )

                    PlayerDeckView(
                        viewModel: viewModel,
                        dragOffset: $dragOffset,
                        isDragging: $isDragging
                    )

                    Spacer()
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "house.fill")
                            .foregroundColor(.black)
                    }
                }
            }
            // MARK: – Turno bot e timer
            .onChange(of: viewModel.currentPlayer) { newValue in
                if newValue == 1 {
                    showBotCard = true
                    botOffset = .zero
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation { botOffset = CGSize(width: 0, height: 200) }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showBotCard = false
                    }
                } else {
                    startTimer()
                }
            }
            // MARK: – Ricevi il publisher di isGameOver
            .onReceive(viewModel.$isGameOver) { over in
                if over {
                    showEndGame = true
                }
            }
            // MARK: – Link “nascosto” per EndGameView
            .background(
                NavigationLink(
                    destination: EndGameView(winner: viewModel.winner ?? 0),
                    isActive: $showEndGame
                ) {
                    EmptyView()
                }
            )
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
