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
            description: "Discover RAKO. The deck is split in two. Each player takes turns playing a card.",
            imageName: "onboarding1"
        ),
        OnboardingPage(
            title: "Special Cards",
            description: "If a 1, 2, or 3 appears, the opponent must play the corresponding number of cards.",
            imageName: "onboarding2"
        ),
        OnboardingPage(
            title: "Double Cards",
            description: "If two identical cards appear in a row, drag it towards you to score points!",
            imageName: "onboarding3"
        ),
        OnboardingPage(
            title: "Watch the Time!",
            description: "You have only 5 seconds to play! If you wait too long, you lose cards.",
            imageName: "onboarding4"
        ),
        OnboardingPage(
            title: "Victory!",
            description: "The game ends when one player conquers all the cards. Good luck!",
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
                            Text(currentPage < onboardingData.count - 1 ? "Next" : "Start Playing")
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
