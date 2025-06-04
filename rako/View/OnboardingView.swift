import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    let onboardingData = [
        OnboardingPage(
            title: "WELCOME TO \nra.ko",
            description: "Be rapido — or you’re KO.",
            imageName: "icona"
        ),
        OnboardingPage(
            title: "Train Your Reflexes",
            description: "Every move sharpens your focus. Quick hands. Sharp mind.",
            imageName: "icona"
        ),
        OnboardingPage(
            title: "You’re Ready.",
            description: "Get in. Play fast. Knock them all out.",
            imageName: "icona"
        )
    ]

    var body: some View {
        ZStack {
            Image("pic")
                .resizable()
                .ignoresSafeArea()

            VStack {
                TabView(selection: $currentPage) {
                    ForEach(onboardingData.indices, id: \.self) { index in
                        VStack(spacing: 24) {
                            Spacer()

                            Image(onboardingData[index].imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(30)
                                .shadow(radius: 15)
                                .padding(.horizontal, 30)
                                .padding(.bottom, 30)


                            VStack(spacing: 10) {
                                Text(onboardingData[index].title)
                                    .font(.custom("Futura-Bold", size: 34))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom)

                                Text(onboardingData[index].description)
                                    .font(.custom("FuturaPT", size: 18))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }

                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // 🔵 Page indicators
                HStack(spacing: 8) {
                    ForEach(onboardingData.indices, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.bottom, 20)

                // 🎮 Action button
                Button(action: {
                    if currentPage < onboardingData.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        hasSeenOnboarding = true
                    }
                }) {
                    Text(currentPage < onboardingData.count - 1 ? "Next" : "Start Playing")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.9))
                        .foregroundColor(.black)
                        .cornerRadius(20)
                        .padding(.horizontal, 50)
                        .shadow(radius: 8)
                }
                .padding(.bottom, 40)
            }
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
