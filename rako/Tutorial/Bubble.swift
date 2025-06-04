import SwiftUI

enum BubblePosition {
    case top, bottom, center
}

struct Bubble: View {
    var text: String
    var position: BubblePosition
    var allowTapToAdvance: Bool = true
    var onTap: (() -> Void)?
    var offsetX: CGFloat = 0 // ← Default ora è 0

    // Distanze verticali personalizzate per i due mazzi
    let mazzoGiocatoreY: CGFloat = UIScreen.main.bounds.height - 220
    let mazzoBotY: CGFloat = 180

    var body: some View {
        VStack(spacing: 0) {
           

            Text(text)
                .font(.headline)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 5)
                .foregroundColor(.black)

            
        }
        .position(
            x: UIScreen.main.bounds.width / 2 + offsetX,
            y: yPosition()
        )
        .onTapGesture {
            if allowTapToAdvance {
                onTap?()
            }
        }
    }

    private func yPosition() -> CGFloat {
        switch position {
        case .top:
            return mazzoBotY - 36
        case .bottom:
            return mazzoGiocatoreY + 36
        case .center:
            return UIScreen.main.bounds.height / 2
        }
    }
}

#Preview {
    TutorialIntroView()
}
