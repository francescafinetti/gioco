//
//  OnboardingView.swift
//  rako
//
//  Created by Serena Pia Capasso on 28/05/25.
//


import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    let onboardingData = [
        OnboardingPage(
            title: "Rapid Knock Out!",
            description: "Discover RAKO, Il mazzo è diviso in due. Ogni giocatore gioca una carta a turno.",
            imageName: "onboarding1"
        ),
        OnboardingPage(
            title: "Carte Speciali",
            description: "Se esce un 1, 2 o 3, l'avversario deve giocare il numero corrispondente di carte.",
            imageName: "onboarding2"
        ),
        OnboardingPage(
            title: "Doppie Carte",
            description: "Se escono due carte uguali di fila, puoi trascinarla verso di te per guadagnare punti!",
            imageName: "onboarding3"
        ),
        OnboardingPage(
            title: "Attento al Tempo!",
            description: "Hai solo 5 secondi per giocare! Se aspetti troppo, perdi delle carte.",
            imageName: "onboarding4"
        ),
        OnboardingPage(
            title: "Vittoria!",
            description: "Il gioco finisce quando un giocatore conquista tutte le carte. Buona fortuna!",
            imageName: "onboarding5"
        )
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(onboardingData.indices, id: \.self) { index in
                    VStack(spacing: 20) {
                        Spacer()

                        Text(onboardingData[index].title)
                            .font(.largeTitle)
                            .bold()

                        Text(onboardingData[index].description)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Spacer()
                        Button(action: {
                            if currentPage < onboardingData.count - 1 {
                                currentPage += 1
                            } else {
                                hasSeenOnboarding = true
                            }
                        }) {
                            Text(currentPage < onboardingData.count - 1 ? "Avanti" : "Inizia a giocare")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}

#Preview {
    OnboardingView()
}
