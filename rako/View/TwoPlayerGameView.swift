//
//  TwoPlayerGameView.swift
//  rako
//
//  Created by Giovanni Fioretto on 29/05/25.


import SwiftUI
import UniformTypeIdentifiers

struct TwoPlayerGameView: View {
    @StateObject var viewModel = GameViewModel(playerCount: 2, isCPUEnabled: false)
    @Namespace private var animation
    @Environment(\.dismiss) var dismiss
    @State private var centralDragOffset: CGSize = .zero
    @State private var isDraggingCentral = false
    @State private var player1DragOffset: CGSize = .zero
    @State private var isPlayer1Dragging = false
    @State private var player2DragOffset: CGSize = .zero
    @State private var isPlayer2Dragging = false
    @State private var showResultScreen = false
    @State private var showExitConfirmation = false
    @State private var showEndGame = false
    @AppStorage("volumeEnabled") private var volumeEnabled = true

    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer?
    let duration: TimeInterval = 7.0

    @State private var showPileAnimation = false
    @State private var pileOffset: CGSize = .zero
    @State private var pileDirection: Direction = .down

    enum Direction {
        case up, down
    }

    var body: some View {
        ZStack {
            Image("pic")
                .ignoresSafeArea()

            VStack {
                VStack {
                    // Player 2 area
                    HStack {
                        GeometryReader { geometry in
                            let width = geometry.size.width
                            let height = geometry.size.height
                            let screenWidth = geometry.size.width
                            let screenHeight = geometry.size.height

                            Image("back_chiaro")
                                .resizable()
                                .frame(width: 200, height: 300)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .offset(player2DragOffset)
                                .gesture(
                                    DragGesture()
                                        .onChanged { g in
                                            guard viewModel.currentPlayer == 1 else { return }
                                            // L’utente inizia a “slappare”
                                            viewModel.isUserSlapping = true
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
                                                viewModel.checkWinner()
                                            }
                                            // L’utente ha finito di slappare
                                            viewModel.isUserSlapping = false
                                            withAnimation { resetPlayer2Drag() }
                                        }
                                )
                                .rotationEffect(.degrees(-25))
                                .position(x: width * 0.30, y: height * 0.30)

                            // Player 2 score
                            VStack {
                                Text("PLAYER 2")
                                    .font(.custom("Futura-Bold", size: 22))
                                    .bold()
                                    .foregroundColor(.black)
                                Text("\(viewModel.players.indices.contains(1) ? viewModel.players[1].count : 0)")
                                    .font(.custom("FuturaPT", size: 18))
                                    .foregroundColor(.black)
                                    .bold()
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        viewModel.currentPlayer == 1 ?
                                            AnyShapeStyle(
                                                LinearGradient(
                                                    colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            : AnyShapeStyle(Color.gray.opacity(0.04))
                                    )
                                    .shadow(color: viewModel.currentPlayer == 0 ? Color.blue.opacity(0.4) : .clear,
                                            radius: 6, x: 0, y: 0)
                            )
                            .frame(width: 140)
                            .position(x: screenWidth - 290, y: screenHeight - 45)
                        }
                    }
                    .padding(.top, 50)

                    // Central pile
                    ZStack {
                        if let lastCard = viewModel.centralPile.last {
                            RoundedRectangle(cornerRadius: 16)
                                .trim(from: 0.0, to: progress / CGFloat(duration))
                                .stroke(Color.black, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 260, height: 410)
                                .animation(.linear(duration: 0.01), value: progress)

                            Image(lastCard.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 280, height: 400)
                                .cornerRadius(14)
                                .shadow(radius: 6)
                                .offset(centralDragOffset)
                                .gesture(
                                    DragGesture()
                                        .onChanged { g in
                                            // L’utente inizia a “slappare” il mazzo centrale
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
                                            }
                                            guard viewModel.centralPile.count >= 2 else {
                                                // Ripristino lo stato di slappo comunque
                                                viewModel.isUserSlapping = false
                                                return
                                            }
                                            let topVal = viewModel.centralPile.last!.value
                                            let secVal = viewModel.centralPile[viewModel.centralPile.count - 2].value
                                            guard topVal == secVal else {
                                                viewModel.isUserSlapping = false
                                                return
                                            }

                                            let threshold: CGFloat = 100
                                            if g.translation.height > threshold {
                                                viewModel.tapForDoppia(by: 0)
                                            } else if g.translation.height < -threshold {
                                                viewModel.tapForDoppia(by: 1)
                                            }
                                            viewModel.checkWinner()
                                            // Fine della gesture: rilasciato lo slappo
                                            viewModel.isUserSlapping = false
                                        }
                                )
                                .transition(.scale)
                        } else {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.accent2.opacity(0.5))
                                .shadow(radius: 10)
                                .frame(width: 260, height: 410)
                        }
                    }

                    // Player 1 area
                    HStack {
                        GeometryReader { geometry in
                            let width = geometry.size.width
                            let height = geometry.size.height
                            let screenWidth = geometry.size.width
                            let screenHeight = geometry.size.height

                            VStack {
                                Text("PLAYER 1")
                                    .font(.custom("Futura-Bold", size: 22))
                                    .bold()
                                    .foregroundColor(.black)
                                Text("\(viewModel.players.indices.contains(0) ? viewModel.players[0].count : 0)")
                                    .font(.custom("FuturaPT", size: 18))
                                    .foregroundColor(.black)
                                    .bold()
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        viewModel.currentPlayer == 0 ?
                                            AnyShapeStyle(
                                                LinearGradient(
                                                    colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            : AnyShapeStyle(Color.gray.opacity(0.04))
                                    )
                                    .shadow(color: viewModel.currentPlayer == 0 ? Color.blue.opacity(0.4) : .clear,
                                            radius: 6, x: 0, y: 0)
                            )
                            .frame(width: 140)
                            .position(x: screenWidth - 480, y: screenHeight - 250)

                            Image("back_chiaro")
                                .resizable()
                                .frame(width: 200, height: 300)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .offset(player1DragOffset)
                                .gesture(
                                    DragGesture()
                                        .onChanged { g in
                                            guard viewModel.currentPlayer == 0 else { return }
                                            viewModel.isUserSlapping = true
                                            player1DragOffset = g.translation
                                            isPlayer1Dragging = true
                                        }
                                        .onEnded { g in
                                            guard viewModel.currentPlayer == 0 else {
                                                viewModel.isUserSlapping = false
                                                withAnimation { resetPlayer1Drag() }
                                                return
                                            }
                                            if g.translation.height > 120 {
                                                viewModel.playCard()
                                                viewModel.checkWinner()
                                            }
                                            viewModel.isUserSlapping = false
                                            withAnimation { resetPlayer1Drag() }
                                        }
                                )
                                .rotationEffect(.degrees(-210))
                                .position(x: width * 0.70, y: height * 0.60)
                        }
                    }
                    .onChange(of: viewModel.currentPlayer) { _ in
                        startTimer()
                    }
                }
            }

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

            NavigationLink(
                destination: EndGameView(winner: 0, isTwoPlayer: true, winningPlayerIndex:  viewModel.winner ?? 0),
                isActive: $showEndGame,
                label: { EmptyView() }
            )
        }
        .onChange(of: viewModel.winner) { newWinner in
            if let _ = newWinner {
                showEndGame = true
            }
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
        .alert(
            "Are you sure you want to leave the match?",
            isPresented: $showExitConfirmation
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Leave", role: .destructive) { dismiss() }
        }
        .onReceive(viewModel.$lastCollector) { winner in
            guard let winner = winner else { return }
            pileDirection = winner == 0 ? .down : .up
            showPileAnimation = true
        }
        .onAppear {
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
    }

    func startTimer() {
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
    NavigationView {
        TwoPlayerGameView()
    }
}
