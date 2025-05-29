import SwiftUI

struct GameResultView: View {
    let winner: Int
    let onRestart: () -> Void

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 40) {
                Text("🏆 Player \(winner + 1) won!")
                    .font(.largeTitle)
                    .foregroundColor(.green)
                    .bold()

                Text("😢 Player \(winner == 0 ? 2 : 1) lose.")
                    .font(.title2)
                    .foregroundColor(.red)

                Button("Play Again!") {
                    onRestart()
                }
                .font(.headline)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 5)
            }
        }
    }
}
