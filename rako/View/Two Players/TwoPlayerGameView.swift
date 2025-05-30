//  TwoPlayerGameView.swift
//  gioco


// è da capire che succ perchè ad un certo punto spariscono le carte, che fine fanno? boh non si sa

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

    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer?
    let duration: TimeInterval = 7.0

    // Mazzetto animato
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
                                            withAnimation { resetPlayer2Drag() }
                                        }
                                )
                                .rotationEffect(.degrees(-25))
                                .position(x: width * 0.30, y: height * 0.30)

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
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.04)))
                            .frame(width: 140)
                            .position(x: screenWidth - 290, y: screenHeight - 45)
                        }
                    }
                    .padding(.top, 50)

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
                                                viewModel.tapForDoppia(by: 0)
                                            } else if g.translation.height < -threshold {
                                                viewModel.tapForDoppia(by: 1)
                                            }
                                            viewModel.checkWinner()
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
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.04)))
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
                                            player1DragOffset = g.translation
                                            isPlayer1Dragging = true
                                        }
                                        .onEnded { g in
                                            guard viewModel.currentPlayer == 0 else {
                                                withAnimation { resetPlayer1Drag() }
                                                return
                                            }
                                            if g.translation.height > 120 {
                                                viewModel.playCard()
                                                viewModel.checkWinner()
                                            }
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

            // ANIMAZIONE MAZZETTINO
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
                        pileOffset = pileDirection == .up ? CGSize(width: 0, height: -320) : CGSize(width: 0, height: 320)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        showPileAnimation = false
                        pileOffset = .zero
                    }
                }
            }

            NavigationLink(
                destination: EndGameView(winner: viewModel.winner ?? 0),
                isActive: $showResultScreen,
                label: { EmptyView() }
            )
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
        .alert("Are you sure you want to leave the match?", isPresented: $showExitConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                dismiss()
            }
        }
        .onReceive(viewModel.$lastCollector) { winner in
            guard let winner = winner else { return }
            pileDirection = winner == 0 ? .down : .up
            showPileAnimation = true
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
    NavigationView{
        TwoPlayerGameView()
    }
}
