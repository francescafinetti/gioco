struct StarParticle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let rotation: Double
    var opacity: Double
}

struct StarAnimationView: View {
    @State private var particles: [StarParticle] = []
    let particleCount = 20
    let animationDuration: Double = 1.0

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Image(systemName: "star.fill")
                    .resizable()
                    .frame(width: particle.size, height: particle.size)
                    .position(x: particle.x, y: particle.y)
                    .rotationEffect(.degrees(particle.rotation))
                    .opacity(particle.opacity)
                    .animation(.easeOut(duration: animationDuration), value: particle.opacity)
            }
        }
        .onAppear {
            createParticles()
        }
    }

    private func createParticles() {
        particles = []
        for _ in 0..<particleCount {
            let particle = StarParticle(
                x: CGFloat.random(in: 50...350),
                y: CGFloat.random(in: 50...650),
                size: CGFloat.random(in: 10...30),
                rotation: Double.random(in: 0...360),
                opacity: 1.0
            )
            particles.append(particle)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                particles = particles.map { p in
                    StarParticle(
                        id: p.id,
                        x: p.x,
                        y: p.y,
                        size: p.size,
                        rotation: p.rotation + 180,
                        opacity: 0
                    )
                }
            }
        }
    }
}
