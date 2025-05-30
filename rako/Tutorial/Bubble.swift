import SwiftUI

enum BubblePosition {
    case top, bottom, center
}

struct Bubble: View {
    var text: String
    var position: BubblePosition
    var allowTapToAdvance: Bool = true
    var onTap: (() -> Void)?
    var offsetX: CGFloat = 100  // <--- Offset orizzontale personalizzabile
    
    // Distanze verticali personalizzate per i due mazzi
    let mazzoGiocatoreY: CGFloat = UIScreen.main.bounds.height - 220
    let mazzoBotY: CGFloat = 180

    var body: some View {
        VStack(spacing: 0) {
            if position == .top {
                Triangle()
                    .frame(width: 24, height: 10)
                    .rotationEffect(.degrees(180))
                    .foregroundColor(.white)
            }
            Text(text)
                .font(.headline)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 5)
                .foregroundColor(.black)
            if position == .bottom {
                Triangle()
                    .frame(width: 24, height: 10)
                    .foregroundColor(.white)
            }
        }
        .position(
            x: UIScreen.main.bounds.width / 2 + offsetX, // Applica l'offset orizzontale qui
            y: position == .top
                ? mazzoBotY - 36    // sopra il mazzo del bot
                : position == .bottom
                    ? mazzoGiocatoreY + 36 // sotto il mazzo giocatore
                    : UIScreen.main.bounds.height / 2
        )
        .onTapGesture {
            if allowTapToAdvance {
                onTap?()
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}


#Preview {
    TutorialIntroView()
}
