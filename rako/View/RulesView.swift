import SwiftUI

struct RulesView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Image("pic")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    RulesLoopPage(
                        title: "How the Game Works",
                        description: "Players take turns throwing one card to the center. The goal is to win all 40 cards.",
                        imageNames: ["1", "2", "3", "4", "5"]
                    )
                    .tag(0)
                    
                    RulesLoopPage(
                        title: "ra.ko Cards",
                        description: "1, 2, and 3 are ra.ko cards. When one of them appears, the opponent must throw exactly the number of cards shown. Let's say Player 1 throws a 2, Player 2 has to throw two cards from their deck. If another ra.ko card appears during this sequence, the rule repeats and the chain continues. When no more ra.ko cards appear, the player who played the last ra.ko card takes the whole pile.",
                        imageNames: ["6", "7", "8", "9", "10"]
                    )
                    .tag(1)
                    
                    RulesLoopPage(
                        title: "Doubles",
                        description: "When two identical cards are played one after the other — for example, two 7s or two 5s — the fastest player to drag the pile toward themselves wins it.",
                        imageNames: ["11", "12", "13", "14", "15"]
                    )
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 6, height: 6)
                            .scaleEffect(index == currentPage ? 1.3 : 1.0)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.top, 10)
                
                // Bottone Next o Close
                Button(action: {
                    if currentPage < 2 {
                        withAnimation { currentPage += 1 }
                    } else {
                        dismiss()
                    }
                }) {
                    Text(currentPage < 2 ? "Next" : "Close")
                        .font(.custom("Futura-Bold", size: 20))
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
        }.navigationBarBackButtonHidden(true)
    }
}

#Preview {
    HomeView()
}
