//  TutorialIntroView.swift
//  rako
//
//  Created by Francesca Finetti on 30/05/25.

import SwiftUI

struct TutorialIntroView: View {
    @State private var tutorialStep = 0
    @State private var playerCardOffset: CGSize = .zero
    @State private var cardPlayed = false
    @State private var showBotCardInCenter = false
    @State private var isForcingPlays = false
    @State private var forcedPlaysDone = 0
    @State private var forcedCardOffset: CGSize = .zero
    @State private var showForcingInCenter = false
    @State private var centralPileOffset: CGSize = .zero
    @State private var showBotFive = false
    @State private var allowPlayerDrag = false
    @State private var playerPlayedFive = false
    @State private var isSinglePlayActive = false
    @State private var singlePlayOffset: CGSize = .zero
    @State private var allowPileDrag = false
    @State private var pileDragOffset: CGSize = .zero
    @State private var showFinalScreen = false
    
    @Environment(\.dismiss) private var dismiss
    
    let forcingCards = ["6_di_giallo", "10_di_arancione"]
    
    var body: some View {
        ZStack {
            Image("pic")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Mazzo bot (alto)
                Image("back_chiaro")
                    .resizable()
                    .frame(width: 150, height: 220)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                
                Spacer()
                
                // Pila centrale
                ZStack {
                    if playerPlayedFive {
                        Image("5_di_viola")
                            .resizable()
                            .frame(width: 150, height: 220)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .offset(pileDragOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { pileDragOffset = $0.translation }
                                    .onEnded { value in
                                        if value.translation.height > 150 {
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                allowPileDrag = false
                                                playerPlayedFive = false
                                                pileDragOffset = .zero
                                                tutorialStep = 9
                                            }
                                        } else {
                                            withAnimation {
                                                pileDragOffset = .zero
                                            }
                                        }
                                    }
                            )
                    } else if tutorialStep == 7 {
                        Image("5_di_viola")
                            .resizable()
                            .frame(width: 150, height: 220)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    } else if showForcingInCenter && forcedPlaysDone > 0 {
                        Image(forcingCards[forcedPlaysDone - 1])
                            .resizable()
                            .frame(width: 150, height: 220)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .offset(centralPileOffset)
                    } else if showBotCardInCenter {
                        Image("2_di_blu")
                            .resizable()
                            .frame(width: 150, height: 220)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .offset(centralPileOffset)
                    } else if cardPlayed {
                        Image("4_di_viola")
                            .resizable()
                            .frame(width: 150, height: 220)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .offset(centralPileOffset)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.2), style: StrokeStyle(lineWidth: 3, dash: [6]))
                            .frame(width: 160, height: 240)
                            .overlay(Text("Pila centrale").font(.caption).foregroundColor(.gray))
                    } 
                } 
                
                Spacer()
                
                // Mazzo player (basso)
                ZStack {
                    Image("back_chiaro")
                        .resizable()
                        .frame(width: 150, height: 220)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    
                    if !cardPlayed && !isForcingPlays && tutorialStep < 6 {
                        Image("back_chiaro")
                            .resizable()
                            .frame(width: 150, height: 220)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .offset(playerCardOffset)
                            .gesture(
                                tutorialStep >= 2 ?
                                DragGesture()
                                    .onChanged { playerCardOffset = $0.translation }
                                    .onEnded { value in
                                        if abs(value.translation.height) > 150 {
                                            withAnimation {
                                                cardPlayed = true
                                                tutorialStep = 3
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                                withAnimation {
                                                    showBotCardInCenter = true
                                                    tutorialStep = 4
                                                }
                                            }
                                        } else {
                                            withAnimation { playerCardOffset = .zero }
                                        }
                                    }
                                : nil
                            )
                    }
                    
                    if isForcingPlays && forcedPlaysDone < forcingCards.count {
                        Image("back_chiaro")
                            .resizable()
                            .frame(width: 150, height: 220)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .offset(forcedCardOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { forcedCardOffset = $0.translation }
                                    .onEnded { value in
                                        if abs(value.translation.height) > 150 {
                                            withAnimation {
                                                showForcingInCenter = true
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                                withAnimation {
                                                    forcedPlaysDone += 1
                                                    forcedCardOffset = .zero
                                                }
                                                if forcedPlaysDone == forcingCards.count {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                        withAnimation {
                                                            tutorialStep = 5
                                                            isForcingPlays = false
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            withAnimation { forcedCardOffset = .zero }
                                        }
                                    }
                            )
                    }
                    
                    if isSinglePlayActive {
                        Image("back_chiaro")
                            .resizable()
                            .frame(width: 150, height: 220)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .offset(singlePlayOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { singlePlayOffset = $0.translation }
                                    .onEnded { value in
                                        if abs(value.translation.height) > 150 {
                                            withAnimation {
                                                playerPlayedFive = true
                                                isSinglePlayActive = false
                                                tutorialStep = 8
                                            }
                                        } else {
                                            withAnimation { singlePlayOffset = .zero }
                                        }
                                    }
                            )
                    }
                }
                
                Spacer()
            }
            
            
            
            
            // Messaggi del tutorial
            if tutorialStep == 0 {
                Bubble(text: "Questo è il tuo mazzo", position: .bottom) {
                    tutorialStep = 1
                }
            } else if tutorialStep == 1 {
                Bubble(text: "Questo è il mazzo del bot", position: .top) {
                    tutorialStep = 2
                }
            } else if tutorialStep == 2 {
                Bubble(text: "Trascina la tua carta verso la pila centrale", position: .bottom, allowTapToAdvance: false)
            } else if tutorialStep == 3 {
                Bubble(text: "Perfetto! Hai giocato la tua carta.", position: .center) {
                    withAnimation {
                        showBotCardInCenter = true
                        tutorialStep = 4
                    }
                }
            } else if tutorialStep == 4 {
                Bubble(text: "Il bot ha giocato un 2! \nOra devi giocare due carte.", position: .center, allowTapToAdvance: false)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isForcingPlays = true
                                forcedPlaysDone = 0
                                tutorialStep = 100
                                showForcingInCenter = false
                            }
                        }
                    }
            } else if tutorialStep == 5 {
                Bubble(text: "Non sono 1-2-3. \nIl bot prende il mazzetto!", position: .center)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            centralPileOffset = CGSize(width: 0, height: -400)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                            withAnimation {
                                showBotCardInCenter = false
                                showForcingInCenter = false
                                cardPlayed = false
                                centralPileOffset = .zero
                                tutorialStep = 6
                            }
                        }
                    }
            } else if tutorialStep == 6 {
                Bubble(text: "Ora gioca il bot, dal momento che \nha preso il mazzetto", position: .center)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                tutorialStep = 7
                                showBotFive = true
                            }
                        }
                    }
                
            } else if tutorialStep == 7 {
                Bubble(text: "Il bot ha giocato un 5! Ora tira una carta tu.", position: .center)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                allowPlayerDrag = true
                                isSinglePlayActive = true
                            }
                        }
                    }
                
            } else if tutorialStep == 8 {
                Bubble(text: "Due carte uguali! Trascina il mazzetto \nverso di te per prenderlo!", position: .center)
                    .onAppear {
                        withAnimation {
                            allowPileDrag = true
                        }
                    }
            }
            else if tutorialStep == 9 {
                VStack(spacing: 30) {
                    Text("🎉 Complimenti!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Hai completato il tutorial.\nOra sei pronto per iniziare a giocare!")
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .padding(.horizontal)

                    Button(action: {
                               dismiss()
                           }) {
                        Text("Inizia a giocare")
                            .font(.headline)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white.opacity(0.9))
            }
        } .navigationBarBackButtonHidden(true)
    }
}


#Preview {
    TutorialIntroView()
}
