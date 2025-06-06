import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        ZStack {
            Image("pic")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    
                    VStack(spacing: 20) {
                        Spacer(minLength: 80)
                        
                        Image("icona")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .shadow(radius: 10)
                            .cornerRadius(35)
                        
                        Text("WELCOME TO\nra.ko")
                            .font(.custom("Futura-Bold", size: 34))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .padding(.horizontal, 30)
                        
                        Text("Be RA-pido — or you’re -KO.")
                            .font(.custom("FuturaPT", size: 20))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black.opacity(0.8))
                            .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                    .tag(0)
                    
                    RulesLoopPage(
                        title: "How the Game Works",
                        description: "Players take turns throwing one card to the center. The goal is to win all 40 cards.",
                        imageNames: ["1", "2", "3", "4", "5", "6", "7"]
                    )
                    .tag(1)
                    
                    RulesLoopPage(
                        title: "ra.ko Cards",
                        description: "1, 2, and 3 are ra.ko cards. When one of them appears, the opponent must throw exactly the number of cards shown. Let's say Player 1 throw a 2, Player 2 has to throw two cards from his deck. If another ra.ko card appears during this sequence, the rule repeats and the chain continues. When no more ra.ko cards appear, the player who played the last ra.ko card takes the whole pile.",
                        imageNames: ["1", "2", "8", "9", "10", "6", "4"]
                    )
                    .tag(2)
                    
                    RulesLoopPage(
                        title: "Doubles",
                        description: "When two identical cards are played one after the other — for example, two 7s or two 5s, etc. — the fastest player to drag the pile toward themselves wins it.",
                        imageNames: ["1", "11", "12", "13", "14", "15", "16"]
                    )
                    .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 5, height: 5)
                            .scaleEffect(index == currentPage ? 1.4 : 1.0)
                            .animation(.spring(), value: currentPage)
                    }
                }
                
                Button(action: {
                    if currentPage < 3 {
                        withAnimation { currentPage += 1 }
                    } else {
                        hasSeenOnboarding = true
                    }
                }) {
                    Text(currentPage < 3 ? "Next" : "Start Playing")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.95))
                        .foregroundColor(.black)
                        .cornerRadius(25)
                        .padding(.horizontal, 70)
                        .shadow(radius: 8)
                }
                .padding(.vertical, 10)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
