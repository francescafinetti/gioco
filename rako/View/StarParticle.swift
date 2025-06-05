import SwiftUI

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let angle: Double
    var opacity: Double = 1
    var scale: CGFloat = 1
}

struct ConfettiExplosionView: View {
    @State private var confettis: [ConfettiParticle] = []
    @State private var animate = false
    
    let particleCount = 30
    let maxDistance: CGFloat = 500
    let confettiSize: CGFloat = 20
    
    let confettiColors: [Color] = [.yellow,.blue, .orange, .pink, .purple]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(confettis) { confetti in
                    Circle()
                        .fill(confetti.color)
                        .frame(width: confettiSize, height: confettiSize)
                        .position(confetti.position)
                        .opacity(confetti.opacity)
                        .scaleEffect(confetti.scale)
                        .animation(.easeOut(duration: 1.5), value: animate)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                createConfettis(center: center)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animateConfettis(center: center)
                    animate = true
                }
            }
        }
    }
    
    private func createConfettis(center: CGPoint) {
        confettis = []
        let step = 360.0 / Double(particleCount)
        for i in 0..<particleCount {
            let angle = step * Double(i)
            let color = confettiColors.randomElement() ?? .white
            confettis.append(ConfettiParticle(position: center, color: color, angle: angle))
        }
    }
    
    private func animateConfettis(center: CGPoint) {
        for i in 0..<confettis.count {
            let angle = confettis[i].angle
            let rad = angle * .pi / 180
            let finalX = center.x + cos(rad) * maxDistance
            let finalY = center.y + sin(rad) * maxDistance
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 1.5)) {
                    confettis[i].position = CGPoint(x: finalX, y: finalY)
                    confettis[i].opacity = 0
                    confettis[i].scale = 0.3
                }
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        ConfettiExplosionView()
    }
}
