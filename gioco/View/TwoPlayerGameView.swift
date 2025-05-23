//
//  TwoPlayerGameView.swift
//  gioco
//
//  Created by Giovanni Fioretto on 23/05/25.
//


import SwiftUI
import UniformTypeIdentifiers

struct TwoPlayerGameView: View {
    @StateObject var viewModel = GameViewModel(playerCount: 2, isCPUEnabled: false)
    @Namespace private var animation

    // Drag states for central card
    @State private var centralDragOffset: CGSize = .zero
    @State private var isDraggingCentral = false

    // Drag states for player decks
    @State private var player1DragOffset: CGSize = .zero
    @State private var isPlayer1Dragging = false
    @State private var player2DragOffset: CGSize = .zero
    @State private var isPlayer2Dragging = false

    // Victory banner
    @State private var showVictoryBanner = false

    // Timer for central pile
    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer?
    let duration: TimeInterval = 7.0

    var body: some View {
        ZStack {
            Image("es")
                .ignoresSafeArea()

            VStack(spacing: 50) {
                Spacer()

                // PLAYER 2 DECK (top)
                VStack(spacing: 8) {
                    Text("Player 2")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Image("back")
                        .resizable()
                        .frame(width: 80, height: 110)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .offset(player2DragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { g in
                                    guard viewModel.currentPlayer == 1 else { return }
                                    player2DragOffset = g.translation
                                    isPlayer2Dragging = true
                                }
                                .onEnded { g in
                                    guard viewModel.currentPlayer == 1 else {
                                        withAnimation { resetPlayer2Drag() }
                                        return
                                    }
                                    if g.translation.height > 120 {
                                        viewModel.playCard()
                                    }
                                    withAnimation { resetPlayer2Drag() }
                                }
                        )

                    Text("Cards: \(viewModel.players.indices.contains(1) ? viewModel.players[1].count : 0)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // CENTRAL PILE
                VStack(spacing: 10) {
                    ZStack {
                        if let lastCard = viewModel.centralPile.last {

                            // TIMER AROUND THE CARD
                            RoundedRectangle(cornerRadius: 16)
                                .trim(from: 0.0, to: progress / CGFloat(duration))
                                .stroke(Color.black, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 170, height: 263)
                                .animation(.linear(duration: 0.01), value: progress)

                            // CENTRAL CARD DRAGGABLE
                            Image(lastCard.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 250)
                                .cornerRadius(14)
                                .shadow(radius: 6)
                                .offset(centralDragOffset)
                                .gesture(
                                    DragGesture()
                                        .onChanged { g in
                                            centralDragOffset = CGSize(width: 0, height: g.translation.height)
                                            isDraggingCentral = true
                                        }
                                        .onEnded { g in
                                            defer {
                                                withAnimation(.easeOut) {
                                                    centralDragOffset = .zero
                                                    isDraggingCentral = false
                                                }
                                            }

                                            guard viewModel.centralPile.count >= 2 else { return }
                                            let topVal = viewModel.centralPile.last!.value
                                            let secVal = viewModel.centralPile[viewModel.centralPile.count - 2].value
                                            guard topVal == secVal else { return }

                                            let threshold: CGFloat = 100
                                            if g.translation.height > threshold {
                                                print("Giocatore 1 ha trascinato coppia")
                                                viewModel.tapForDoppia(by: 0)
                                            } else if g.translation.height < -threshold {
                                                print("Giocatore 2 ha trascinato coppia")
                                                viewModel.tapForDoppia(by: 1)
                                            }
                                        }
                                )
                                .transition(.scale)

                        } else {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 200, height: 250)
                                .overlay(Text("Empty").font(.caption).foregroundColor(.gray))
                        }
                    }
                }

                // PLAYER 1 DECK (bottom)
                VStack(spacing: 8) {
                    Text("Player 1")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Image("back")
                        .resizable()
                        .frame(width: 80, height: 110)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .offset(player1DragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { g in
                                    guard viewModel.currentPlayer == 0 else { return }
                                    player1DragOffset = g.translation
                                    isPlayer1Dragging = true
                                }
                                .onEnded { g in
                                    guard viewModel.currentPlayer == 0 else {
                                        withAnimation { resetPlayer1Drag() }
                                        return
                                    }
                                    if g.translation.height < -120 {
                                        viewModel.playCard()
                                    }
                                    withAnimation { resetPlayer1Drag() }
                                }
                        )

                    Text("Cards: \(viewModel.players.indices.contains(0) ? viewModel.players[0].count : 0)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // GAME OVER
                if let winner = viewModel.winner {
                    VStack(spacing: 12) {
                        Text("Player \(winner + 1) won!")
                            .font(.title2)
                            .foregroundColor(.green)
                            .bold()

                        Button("New Game") {
                            viewModel.startGame(playerCount: 2)
                        }
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    .onAppear {
                        if !showVictoryBanner {
                            showVictoryBanner = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                showVictoryBanner = false
                            }
                        }
                    }
                }

                Spacer()
            }

            // VICTORY BANNER OVERLAY
            if showVictoryBanner, let winner = viewModel.winner {
                VStack {
                    Spacer()
                    Text("🏆 Player \(winner + 1) won the game!")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .background(.black.opacity(0.85))
                        .cornerRadius(16)
                        .shadow(radius: 10)
                        .transition(.opacity)
                    Spacer()
                }
                .zIndex(2)
            }
        }
        .onChange(of: viewModel.currentPlayer) { _ in
            startTimer()
        }
    }

    func startTimer() {
        progress = CGFloat(duration)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { t in
            if progress > 0 { progress -= 0.01 } else { progress = 0; t.invalidate() }
        }
    }

    private func resetPlayer1Drag() {
        player1DragOffset = .zero
        isPlayer1Dragging = false
    }
    private func resetPlayer2Drag() {
        player2DragOffset = .zero
        isPlayer2Dragging = false
    }
}

#Preview {
    TwoPlayerGameView()
}
