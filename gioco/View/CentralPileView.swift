//
//  CentralPileView.swift
//  gioco
//
//  Created by Serena Pia Capasso on 22/05/25.
//


import SwiftUI

struct CentralPileView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var progress: CGFloat
    let duration: TimeInterval
    @Binding var centralDragOffset: CGSize
    @Binding var isDraggingCentral: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                if let lastCard = viewModel.centralPile.last {

                    // TIMER AROUND THE CARD
                    RoundedRectangle(cornerRadius: 25)
                        .trim(from: 0.0, to: progress / CGFloat(duration))
                        .stroke(Color.black, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 260, height: 410)
                        .animation(.linear(duration: 0.01), value: progress)

                    // CARD DISPLAYED
                    Image(lastCard.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280, height: 400)
                        .cornerRadius(14)
                        .shadow(radius: 6)
                        .transition(.scale)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    //valuta solo coordinate Y nel drag
                                    centralDragOffset = CGSize(width: 0, height: gesture.translation.height)
                                    isDraggingCentral = true
                                }
                                .onEnded { gesture in
                                    //rimettere carta in posizione dritta alla fine
                                    defer {
                                        withAnimation(.easeOut) {
                                            centralDragOffset = .zero
                                            isDraggingCentral = false
                                        }
                                    }
                                    
                                    //ci soo almeno 2 carte?
                                    guard viewModel.centralPile.count >= 2 else { return }
                                    let topValue    = viewModel.centralPile.last!.value
                                    let secondValue = viewModel.centralPile[viewModel.centralPile.count - 2].value
                                    guard topValue == secondValue else { return }
                                    
                                    //soglia è per dare un minimo di trascinamento
                                    let soglia: CGFloat = 100
                                    if gesture.translation.height > soglia {
                                        //drag verso il basso carte verso player 1
                                        print("Giocatore 1 ha trascinato coppia")
                                        viewModel.tapForDoppia(by: 0)
                                    } else if gesture.translation.height < -soglia {
                                        //drag verso l’alto carte player 2 (o bot)
                                        print("Giocatore 2 ha trascinato coppia")
                                        viewModel.tapForDoppia(by: 1)
                                    }
                                }
                        )
                        .transition(.scale)
                        /*
                         vecchio vers "tap" per la coppia
                         .onTapGesture {
                            if viewModel.centralPile.count >= 2 {
                                let top = viewModel.centralPile.last!
                                let second = viewModel.centralPile[viewModel.centralPile.count - 2]
                                if top.value == second.value {
                                    viewModel.tapForDoppia(by: 0)
                                }
                            }
                        }*/
                } else {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 280, height: 400)
                        .overlay(Text("Empty").font(.caption).foregroundColor(.gray))
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
