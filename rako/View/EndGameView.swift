import SwiftUI
import WebKit

struct EndGameView: View {
    let winner: Int // 0 = ha vinto il player 1 / l’utente, 1 = ha vinto il player 2 / il bot
    var isTwoPlayer: Bool = false
    var winningPlayerIndex: Int? = nil
    @Environment(\.dismiss) var dismiss
    
    @State private var bounceLeft = false
    @State private var bounceRight = false
    @State private var bounceTimer: Timer?
    
    var body: some View {
        ZStack {
            Image("pic")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Text(isTwoPlayer ? "GAME OVER" : (winner == 0 ? "VICTORY" : "DEFEAT"))
                    .font(.custom("Futura-Bold", size: 55))
                    .foregroundStyle(
                        winner == 1 && !isTwoPlayer
                        ? AnyShapeStyle(Color.red)
                        : AnyShapeStyle(LinearGradient(colors: [.yellow, .orange, .blue, .purple], startPoint: .leading, endPoint: .trailing))
                    )
                
                // Sottotitolo dinamico
                Group {
                    if isTwoPlayer, let winnerIndex = winningPlayerIndex {
                        let loserIndex = winnerIndex == 0 ? 1 : 0
                        (
                            Text("Player \(winnerIndex + 1) is ")
                                .font(.custom("FuturaPT", size: 20))
                                .foregroundColor(.black)
                            +
                            Text("RA-pido\n")
                                .font(.custom("Futura-Bold", size: 20))
                                .bold()
                                .foregroundColor(.black)
                            +
                            Text("Player \(loserIndex + 1) is ")
                                .font(.custom("FuturaPT", size: 20))
                                .foregroundColor(.black)
                            +
                            Text("KO!")
                                .font(.custom("Futura-Bold", size: 20))
                                .bold()
                                .foregroundColor(.black)
                        )
                    } else {
                        if winner == 0 {
                            (
                                Text("You are ")
                                    .font(.custom("FuturaPT", size: 20))
                                    .foregroundColor(.black)
                                +
                                Text("RA-pido!")
                                    .font(.custom("Futura-Bold", size: 20))
                                    .bold()
                                    .foregroundColor(.black)
                            )
                        } else {
                            (
                                Text("You are ")
                                    .font(.custom("FuturaPT", size: 20))
                                    .foregroundColor(.black)
                                +
                                Text("KO!")
                                    .font(.custom("Futura-Bold", size: 20))
                                    .bold()
                                    .foregroundColor(.black)
                            )
                        }
                    }
                }
                .multilineTextAlignment(.center)
                
                Spacer()
                
                // Animazione
                if isTwoPlayer || winner == 0 {
                    // Carte saltellanti (vittoria o modalità 2 player)
                    HStack(spacing: -40) {
                        Image("back_chiaro")
                            .resizable()
                            .frame(width: 160, height: 240)
                            .rotationEffect(.degrees(-10))
                            .offset(y: bounceLeft ? -30 : 0)
                            .animation(.interpolatingSpring(stiffness: 200, damping: 5).repeatForever(autoreverses: true).delay(0.1), value: bounceLeft)
                        
                        Image("back_chiaro")
                            .resizable()
                            .frame(width: 160, height: 240)
                            .rotationEffect(.degrees(10))
                            .offset(y: bounceRight ? -30 : 0)
                            .animation(.interpolatingSpring(stiffness: 200, damping: 5).repeatForever(autoreverses: true).delay(0.3), value: bounceRight)
                    }
                } else {
                    // Sconfitta in single player: GIF con effetto distruzione
                    AnimatedGIFView(gifName: "defeat")
                        .frame(width: 500, height: 350)
                        .ignoresSafeArea()
                }
                
                Spacer()
                
                // Pulsanti
                
                VStack(spacing: 12) {
                    
                    NavigationLink(destination: SinglePlayerView()) {
                        Text("Play again")
                            .font(.custom("Futura-Bold", size: 26))
                            .bold()
                            .foregroundColor(.black)
                    }
                    
                    Button(action: {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            let hostingController = UIHostingController(rootView: HomeView())
                            hostingController.overrideUserInterfaceStyle = .light
                            window.rootViewController = hostingController
                            window.makeKeyAndVisible()
                        }
                    }) {
                        Text("Go Home")
                            .font(.custom("FuturaPT", size: 20))
                            .foregroundColor(.gray)
                    }
                    .padding(.top)


                }
                
                Spacer()
            }
        }
            .onAppear {
                if winner == 0 || isTwoPlayer {
                    bounceLeft = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        bounceRight = true
                    }
                    bounceTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                        bounceLeft.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            bounceRight.toggle()
                        }
                    }
                }
            }
            .onDisappear {
                bounceTimer?.invalidate()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
        }
    }


// Supporto GIF per animazione sconfitta
struct AnimatedGIFView: UIViewRepresentable {
    let gifName: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        if let path = Bundle.main.path(forResource: gifName, ofType: "gif") {
            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
            webView.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: .init(fileURLWithPath: path))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

#Preview {
    NavigationView {
        EndGameView(winner: 0, isTwoPlayer: false, winningPlayerIndex: 1)
    }
}
