//
//  PlayerDeckView.swift
//  rako
//
//  Created by Serena Pia Capasso on 29/05/25.
//


import SwiftUI

struct PlayerDeckView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var dragOffset: CGSize
    @Binding var isDragging: Bool
    @AppStorage("isLeftHanded") private var isLeftHanded = false

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height

            HStack {
                VStack(alignment: .center, spacing: 4) {
                    Text("Player 1")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.black)

                    Text("\(viewModel.players.indices.contains(0) ? viewModel.players[0].count : 0)")
                        .font(.title3)
                        .foregroundColor(.black)
                        .bold()
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.04)))
                .frame(width: 140)
                .position(
                    x: isLeftHanded ? screenWidth - 295 : screenWidth - 495,
                    y: screenHeight - 50
                )

                ZStack {
                    Image("back_chiaro")
                        .resizable()
                        .frame(width: 200, height: 300)
                        .cornerRadius(10)
                        .shadow(radius: 2)

                    Image("back_chiaro")
                        .resizable()
                        .frame(width: 200, height: 300)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.currentPlayer == 0 ? Color.green.opacity(0.8) : Color.clear, lineWidth: 4)
                                .blur(radius: 1)
                                .opacity(viewModel.currentPlayer == 0 ? 1 : 0)
                        )
                        .offset(dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    guard viewModel.currentPlayer == 0 else { return }
                                    dragOffset = gesture.translation
                                    isDragging = true
                                }
                                .onEnded { gesture in
                                    guard viewModel.currentPlayer == 0 else {
                                        dragOffset = .zero
                                        isDragging = false
                                        return
                                    }

                                    if gesture.translation.height < -120 {
                                        withAnimation {
                                            dragOffset = .zero
                                            isDragging = false
                                            viewModel.playCard()
                                        }
                                    } else {
                                        withAnimation {
                                            dragOffset = .zero
                                            isDragging = false
                                        }
                                    }
                                }
                        )
                }
                .rotationEffect(.degrees(isLeftHanded ? 35 : -35))
                .position(
                    x: isLeftHanded ? width * -0.20 : width * 0.24,
                    y: height * 1.8
                )
            }
        }
        .frame(height: 100)
    }
}
