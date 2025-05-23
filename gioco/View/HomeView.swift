import SwiftUI

struct HomeView: View {
    @State private var isGameActive = false
    @State private var showSettings = false
    @State private var selectedMode = 0

    let gameModes = ["Classic", "Speed", "Mirror"]

    var body: some View {
        NavigationStack {
            ZStack {
                Image("es")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    TabView(selection: $selectedMode) {
                        ForEach(0..<gameModes.count, id: \.self) { index in
                            ZStack {
                                Image("back")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 220, height: 500)
                                    .scaleEffect(index == selectedMode ? 1.0 : 0.85)
                                    .opacity(index == selectedMode ? 1.0 : 0.6)
                                    .shadow(radius: index == selectedMode ? 10 : 0)
                                    .animation(.easeInOut(duration: 0.3), value: selectedMode)

                                VStack {
                                    Spacer()
                                    Text(gameModes[index])
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .shadow(radius: 3)
                                        .padding(.bottom, 40)
                                }
                            }
                            .tag(index)
                            .padding(.horizontal, 40)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 520)
                    .padding(.top, 20)

                    Text("Tap to Start")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 6)
                        .padding(.bottom, 60)

                    Spacer()
                }

                // Tapping anywhere starts the game
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
}

#Preview {
    HomeView()
}
