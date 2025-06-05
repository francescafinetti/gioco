//
//  SinglePlayerView.swift
//  rako
//
//  Created by Serena Pia Capasso on 29/05/25.
//

import SwiftUI

struct SinglePlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = GameViewModel(playerCount: 2)
    @AppStorage("isLeftHanded") private var isLeftHanded = false
    @AppStorage("volumeEnabled") private var volumeEnabled = true

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

    // MARK: – Stati per animazione mazzetto
    @State private var showPileAnimation = false
    @State private var pileOffset: CGSize = .zero
    @State private var pileDirection: Direction = .down

    enum Direction {
        case up, down
    }

    // MARK: – Costanti
    private let duration: TimeInterval = 7.0

    var body: some View {
        ZStack {
            Image("pic")
                .ignoresSafeArea()

            VStack {
                BotDeckView(
                    viewModel: viewModel,
                    showBotCard: $showBotCard,
                    botOffset: $botOffset
                )
                .zIndex(showBotCard ? 1 : 0)

                // Cattura la “doppia” nel mazzo centrale
                CentralPileView(
                    viewModel: viewModel,
                    progress: $progress,
                    duration: duration,
                    centralDragOffset: $centralDragOffset,
                    isDraggingCentral: $isDraggingCentral
                )
                .zIndex(0)
                .gesture(
                    DragGesture()
                        .onChanged { g in
                            // L’utente inizia lo slappo
                            viewModel.isUserSlapping = true
                            centralDragOffset = CGSize(width: 0, height: g.translation.height)
                            isDraggingCentral = true
                        }
                        .onEnded { g in
                            defer {
                                withAnimation(.easeOut) {
                                    centralDragOffset = .zero
                                    isDraggingCentral = false
                                }
                                // L’utente ha finito lo slappo
                                viewModel.isUserSlapping = false
                            }
                            guard viewModel.centralPile.count >= 2 else { return }
                            let topVal = viewModel.centralPile.last!.value
                            let secVal = viewModel.centralPile[viewModel.centralPile.count - 2].value
                            guard topVal == secVal else { return }

                            let threshold: CGFloat = 100
                            if g.translation.height > threshold {
                                viewModel.tapForDoppia(by: 0)
                            } else if g.translation.height < -threshold {
                                viewModel.tapForDoppia(by: 1)
                            }
                            viewModel.checkWinner()
                        }
                )

                PlayerDeckView(
                    viewModel: viewModel,
                    dragOffset: $dragOffset,
                    isDragging: $isDragging
                )
                .zIndex(1)

                Spacer()
            }
            .padding(.bottom, 250)

            // Animazione “pile” quando lastCollector cambia
            ZStack {
                if showPileAnimation {
                    ForEach(0..<3, id: \.self) { i in
                        Image("back_chiaro")
                            .resizable()
                            .frame(width: 150, height: 200)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                            .offset(x: CGFloat(i) * 3, y: CGFloat(i) * 3)
                    }
                }
            }
            .offset(pileOffset)
            .opacity(showPileAnimation ? 1 : 0)
            .zIndex(999)
            .onChange(of: showPileAnimation) { visible in
                if visible {
                    pileOffset = .zero
                    withAnimation(.easeInOut(duration: 0.6)) {
                        pileOffset = pileDirection == .up
                            ? CGSize(width: 0, height: -320)
                            : CGSize(width: 0, height: 320)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        showPileAnimation = false
                        pileOffset = .zero
                    }
                }
            }

            // Navigazione a EndGameView
            NavigationLink(
                destination: EndGameView(winner: viewModel.winner ?? 0),
                isActive: $showEndGame
            ) {
                EmptyView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(
                placement: isLeftHanded ? .navigationBarLeading : .navigationBarTrailing
            ) {
                Button {
                    showExitConfirmation = true
                } label: {
                    Image(systemName: "house.fill")
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            startTimer()
            if volumeEnabled {
                AudioManager.shared.fadeToMusic(
                    named: "gameview",
                    volume: Float(UserDefaults.standard.double(forKey: "musicVolume"))
                )
            }
        }
        .onDisappear {
            if volumeEnabled {
                AudioManager.shared.fadeToMusic(named: "homeview", volume: 0.5)
            }
        }
        .onReceive(viewModel.$cardPlayCount) { _ in
            startTimer()
        }
        .onReceive(viewModel.$botPlayCount) { count in
            guard count > 0 else { return }
            showBotCard = true
            botOffset = .zero
            withAnimation(.easeOut(duration: 0.5)) {
                botOffset = CGSize(width: 0, height: -200)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showBotCard = false
            }
        }
        .onReceive(viewModel.$isGameOver) { over in
            if over {
                showEndGame = true
            }
        }
        .onReceive(viewModel.$lastCollector) { winner in
            guard let winner = winner else { return }
            pileDirection = winner == 0 ? .down : .up
            showPileAnimation = true
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
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    let hostingController = UIHostingController(rootView: HomeView())
                    hostingController.overrideUserInterfaceStyle = .light // oppure .unspecified
                    window.rootViewController = hostingController
                    window.makeKeyAndVisible()
                }
            }
        }

    }

    private func startTimer() {
        progress = CGFloat(duration)
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.01,
            repeats: true
        ) { t in
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
        SinglePlayerView()
    }
}
