import SwiftUI

struct HomeView: View {
    @State private var isGameActive = false
    @State private var showSettings = false
    @State private var selectedMode = 0
    @State private var dragOffset: CGFloat = 0.0

    let gameModes = ["Classic", "Speed", "Mirror"]
    let cardWidth: CGFloat = 220
    let spacing: CGFloat = 20
    let dragThreshold: CGFloat = 80

    var body: some View {
        NavigationStack {
            ZStack {
                Image("es")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    GeometryReader { geometry in
                        let totalWidth = geometry.size.width
                        let itemWidth = cardWidth + spacing
                        let offsetX = -CGFloat(selectedMode) * itemWidth + dragOffset + (totalWidth - cardWidth) / 2

                        HStack(spacing: spacing) {
                            ForEach(gameModes.indices, id: \.self) { index in
                                deckImage(for: index)
                                    .frame(width: cardWidth, height: index == selectedMode ? 600 : 400)
                                    .scaleEffect(index == selectedMode ? 1.0 : 0.85)
                                    .opacity(index == selectedMode ? 1.0 : 0.6)
                                    .shadow(radius: index == selectedMode ? 10 : 0)
                                    .rotation3DEffect(.degrees(index == selectedMode ? 0 : (index < selectedMode ? 8 : -8)),
                                                      axis: (x: 0, y: 1, z: 0))
                                    .animation(.easeInOut(duration: 0.25), value: selectedMode)
                            }
                        }
                        .offset(x: offsetX)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation.width
                                }
                                .onEnded { value in
                                    if value.translation.width < -dragThreshold && selectedMode < gameModes.count - 1 {
                                        selectedMode += 1
                                    } else if value.translation.width > dragThreshold && selectedMode > 0 {
                                        selectedMode -= 1
                                    }
                                    withAnimation(.easeOut(duration: 0.25)) {
                                        dragOffset = 0
                                    }
                                }
                        )
                    }
                    .frame(height: 520)

                    Text(gameModes[selectedMode])
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                        .padding(.top, 20)

                    Spacer()

                    Text("Tap to Start")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 6)
                        .padding(.bottom, 60)

                    Spacer()
                }

                NavigationLink(destination: ContentView(), isActive: $isGameActive) {
                    EmptyView()
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isGameActive = true
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func deckImage(for index: Int) -> some View {
        Image("back")
            .resizable()
            .scaledToFit()
    }
}

#Preview {
    HomeView()
}
