//
//  BotDeckView.swift
//  gioco
//
//  Created by Serena Pia Capasso on 22/05/25.
//


import SwiftUI

struct BotDeckViewL: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var showBotCard: Bool
    @Binding var botOffset: CGSize

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            HStack {
                ZStack {
                    // Mazzo sotto
                    Image("back_chiaro")
                        .resizable()
                        .frame(width: 200, height: 300)
                        .cornerRadius(10)
                        .shadow(radius: 2)

                    // Carta animata sopra (solo se visibile)
                    if showBotCard {
                        Image("back_chiaro")
                            .resizable()
                            .frame(width: 200, height: 300)
                            .cornerRadius(10)
                            .shadow(radius: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(viewModel.currentPlayer == 1 ? Color.green.opacity(0.8) : Color.clear, lineWidth: 4)
                                    .blur(radius: 1)
                                    .opacity(viewModel.currentPlayer == 1 ? 1 : 0)
                            )
                            .offset(botOffset)
                            .zIndex(1)
                            .animation(.easeInOut(duration: 0.4), value: botOffset)
                    }
                }
                .rotationEffect(.degrees(210))
                .position(x: width * 0.70, y: height * 0.5)
     
                //PER SEGNARE I PUNTI LATERALMENTE
                VStack(alignment: .center, spacing: 4) {
                                    Text("Player 2")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.black)
                                    Text("\(viewModel.players.indices.contains(1) ? viewModel.players[1].count : 0)")
                        .font(.title3)
                        .foregroundColor(.black)
                        .bold()
                                }
                                .padding(12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.04)))
                                .frame(width: 140)
                                .position(x: screenWidth - 895, y: screenHeight - 50)
                            }
        }
        .frame(height: 300)
    }
}

#Preview {
    NavigationStack {
        SinglePlayerL()
    }
}
