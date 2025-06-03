import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    let onboardingData = [
        OnboardingPage(
            title: "Welcome to RA.KO",
            description: "Be rapido — or you’re KO.",
            imageName: "onboarding1"
        ),
        OnboardingPage(
            title: "Train Your Reflexes",
            description: "Every move sharpens your focus. Quick hands. Sharp mind.",
            imageName: "onboarding2"
        ),
        OnboardingPage(
            title: "You’re Ready.",
            description: "Get in. Play fast. Knock them all out.",
            imageName: "onboarding3"
        )
    ]

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color.blue.opacity(0.8)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            TabView(selection: $currentPage) {
                ForEach(onboardingData.indices, id: \.self) { index in
                    VStack(spacing: 30) {
                        Spacer()

                        Image(onboardingData[index].imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 280)
                            .cornerRadius(25)
                            .shadow(radius: 10)

                        VStack(spacing: 12) {
                            Text(onboardingData[index].title)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Text(onboardingData[index].description)
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                        }

                        Spacer()

                        Button(action: {
                            if currentPage < onboardingData.count - 1 {
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                hasSeenOnboarding = true
                            }
                        }) {
                            Text(currentPage < onboardingData.count - 1 ? "Next" : "Start Playing")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .foregroundColor(.blue)
                                .cornerRadius(16)
                                .padding(.horizontal, 40)
                                .shadow(radius: 5)
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
