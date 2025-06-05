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
    @State private var showSkipAlert = false
    
    @Environment(\.dismiss) private var dismiss
    
    let forcingCards = ["6_di_giallo", "10_di_arancione"]
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                Image("pic")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    Image("back_chiaro")
                        .resizable()
                        .frame(width: 200, height: 300)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .rotationEffect(.degrees(-210))
                        .position(x: width * 0.04, y: height * 0.02)
                    
                    ZStack {
                        if playerPlayedFive {
                            Image("5_di_viola")
                                .resizable()
                                .frame(width: 260, height: 410)
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
                                                    tutorialStep = 10
                                                }
                                            } else {
                                                withAnimation { pileDragOffset = .zero }
                                            }
                                        }
                                )
                        } else if tutorialStep == 8 {
                            Image("5_di_viola")
                                .resizable()
                                .frame(width: 260, height: 410)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        } else if showForcingInCenter && forcedPlaysDone > 0 {
                            Image(forcingCards[forcedPlaysDone - 1])
                                .resizable()
                                .frame(width: 260, height: 410)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                                .offset(centralPileOffset)
                        } else if showBotCardInCenter {
                            Image("2_di_blu")
                                .resizable()
                                .frame(width: 260, height: 410)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                                .offset(centralPileOffset)
                        } else if cardPlayed {
                            Image("4_di_viola")
                                .resizable()
                                .frame(width: 260, height: 410)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                                .offset(centralPileOffset)
                        } else {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.accent2.opacity(0.5))
                                .shadow(radius: 10)
                                .frame(width: 260, height: 410)
                                .overlay(Text("Central Pile").font(.caption).foregroundColor(.gray))
                        }
                    }
                    .position(x: width * 0.50, y: height * 0.27)
                    
                    ZStack {
                        Image("back_chiaro")
                            .resizable()
                            .frame(width: 200, height: 300)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        
                        if !cardPlayed && !isForcingPlays && tutorialStep < 6 {
                            Image("back_chiaro")
                                .resizable()
                                .frame(width: 200, height: 300)
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
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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
                                .frame(width: 200, height: 300)
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
                                                                tutorialStep = 6
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
                                .frame(width: 200, height: 300)
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
                                                    tutorialStep = 9
                                                }
                                            } else {
                                                withAnimation { singlePlayOffset = .zero }
                                            }
                                        }
                                )
                        }
                    }
                    .rotationEffect(.degrees(-35))
                    .position(x: width * 0.97, y: height * 0.55)
                    
                    Spacer()
                }
                .padding(.bottom, 250)
                
                Group {
                    if tutorialStep == 0 {
                        Bubble(text: NSLocalizedString("This is your deck", comment: ""), position: .bottom) {
                            withAnimation { tutorialStep = 1 }
                        }
                    } else if tutorialStep == 1 {
                        Bubble(text: NSLocalizedString("This is the bot's deck", comment: ""), position: .top) {
                            withAnimation { tutorialStep = 2 }
                        }
                    } else if tutorialStep == 2 {
                        Bubble(text: NSLocalizedString("Drag your card to the central pile", comment: ""), position: .bottom, allowTapToAdvance: false)
                    } else if tutorialStep == 3 {
                        Bubble(text: NSLocalizedString("Great! You've played your card.", comment: ""), position: .center) {
                            withAnimation {
                                tutorialStep = 4
                                showBotCardInCenter = true
                            }
                        }
                    } else if tutorialStep == 4 {
                        Bubble(text: NSLocalizedString("The bot played a 2! \n — \nspecial cards are 1, 2, and 3: \nwhen one of them appears, \nthe opponent must throw exactly \nthe number of cards shown.", comment: ""), position: .center) {
                            withAnimation {
                                tutorialStep = 5
                            }
                        }
                    } else if tutorialStep == 5 {
                        Bubble(text: NSLocalizedString("If another 1, 2 or 3 appears, \nthe rule repeats, and the chain continues \nuntil a normal card ends it. \nSo, now you must play two cards", comment: ""), position: .center, allowTapToAdvance: false)
                            .onAppear {
                                withAnimation {
                                    isForcingPlays = true
                                    forcedPlaysDone = 0
                                    showForcingInCenter = false
                                }
                            }
                    } else if tutorialStep == 6 {
                        Bubble(text: NSLocalizedString("Not 1-2-3. \nThe bot takes the pile!", comment: ""), position: .center)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    centralPileOffset = CGSize(width: 0, height: -400)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                    withAnimation {
                                        showBotCardInCenter = false
                                        showForcingInCenter = false
                                        cardPlayed = false
                                        centralPileOffset = .zero
                                        tutorialStep = 7
                                    }
                                }
                            }
                    } else if tutorialStep == 7 {
                        Bubble(text: NSLocalizedString("Now the bot plays, since \nit took the pile", comment: ""), position: .center) {
                            withAnimation {
                                tutorialStep = 8
                                showBotFive = true
                            }
                        }
                    } else if tutorialStep == 8 {
                        Bubble(text: NSLocalizedString("The bot played a 5! Now you play a card.", comment: ""), position: .center)
                            .onAppear {
                                withAnimation {
                                    allowPlayerDrag = true
                                    isSinglePlayActive = true
                                }
                            }
                    } else if tutorialStep == 9 {
                        Bubble(text: NSLocalizedString("Two identical cards! Drag the pile \ntowards you to take it!", comment: ""), position: .center)
                            .onAppear {
                                withAnimation {
                                    allowPileDrag = true
                                }
                            }
                    } else if tutorialStep == 10 {
                        VStack(spacing: 30) {
                            Text(NSLocalizedString("Congratulations!", comment: ""))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text(NSLocalizedString("Now you’re ready to start playing!\nWin the game by collecting all 40 cards!", comment: ""))
                                .multilineTextAlignment(.center)
                                .font(.title3)
                                .padding(.horizontal)
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Text(NSLocalizedString("Start Playing", comment: ""))
                                    .font(.headline)
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 15)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 4)
                            }
                        }
                        .padding(.trailing, 190)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white.opacity(0.9))
                    }
                }
                
                if tutorialStep < 10 && tutorialStep != 2 && tutorialStep != 5 && tutorialStep != 8 && tutorialStep != 9  {
                    Button(action: {
                        withAnimation {
                            tutorialStep += 1
                        }
                    }) {
                        Text(NSLocalizedString("Next", comment: ""))
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(10)
                    }
                    .position(x: 80, y: height - 50)
                }
                
                if tutorialStep < 10 {
                    Button(action: { showSkipAlert = true }) {
                        Text(NSLocalizedString("Skip", comment: ""))
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(10)
                    }
                    .position(x: width * 0.8, y: height * 0.05)
                }
            }
            .navigationBarBackButtonHidden(true)
            .alert(NSLocalizedString("Are you sure you want to skip the tutorial?", comment: ""), isPresented: $showSkipAlert) {
                Button(NSLocalizedString("Skip", comment: ""), role: .destructive) {
                    withAnimation { tutorialStep = 10 }
                }
                Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) { }
            }
        }
    }
}

#Preview {
    TutorialIntroView()
}
