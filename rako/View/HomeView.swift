import SwiftUI
import GameKit

struct HomeView: View {
    @State private var selectedMode = 1
    @State private var dragOffset: CGFloat = 0.0
    @State private var isSettingsFlipped = false
    @State private var showSinglePlayer = false
    @State private var showTwoPlayer = false
    @State private var showMultiplayer = false
    @State private var showTutorial = false
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false

    @AppStorage("volumeEnabled") private var volumeEnabled = true
    @AppStorage("isLeftHanded") private var isLeftHanded = false
    @StateObject var gameCenterManager = GameCenterManager()

    let gameModes = ["Settings" ,"Single Player", "Two Players", "Multiplayer"]
    let cardImages = ["card_settings", "single_player", "two_players", "multiplayer"]
    
    let cardWidth: CGFloat = 250
    let spacing: CGFloat = 10
    let dragThreshold: CGFloat = 80

    var body: some View {
        NavigationStack {
            ZStack {
                Image("pic")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                if isSettingsFlipped {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                isSettingsFlipped = false
                            }
                        }
                        .ignoresSafeArea()
                }

                VStack {
                    GeometryReader { geometry in
                        let totalWidth = geometry.size.width
                        let itemWidth = cardWidth + spacing
                        let offsetX = -CGFloat(selectedMode) * itemWidth + dragOffset + (totalWidth - cardWidth) / 2

                        HStack(spacing: spacing) {
                            ForEach(gameModes.indices, id: \.self) { index in
                                let isSelected = index == selectedMode
                                let rotationAngle: Double = isSelected ? 0 : (index < selectedMode ? 8 : -8)
                                let scale: CGFloat = isSelected ? 1.0 : 0.85
                                let opacity: Double = isSelected ? 1.0 : 0.6
                                let shadow: CGFloat = isSelected ? 10 : 0

                                Group {
                                    if gameModes[index] == "Settings" {
                                        FlipView(isFlipped: isSettingsFlipped) {
                                            Image("card_settings")
                                                .resizable()
                                                .scaledToFit()
                                        } back: {
                                            SettingsCardView()
                                                .frame(width: cardWidth, height: 400)
                                        }
                                    } else {
                                        ZStack {
                                            Image(cardImages[index])
                                                .resizable()
                                                .scaledToFit()

                                            if gameModes[index] == "Multiplayer" {
                                                Image(systemName: "lock.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 60, height: 60)
                                                    .foregroundColor(.black)
                                                    .offset(y: -100)
                                            }
                                        }
                                    }
                                }
                                .frame(width: cardWidth, height: isSelected ? 600 : 500)
                                .scaleEffect(scale)
                                .opacity(opacity)
                                .shadow(radius: shadow)
                                .rotation3DEffect(.degrees(rotationAngle), axis: (x: 0, y: 1, z: 0))
                                .animation(.easeInOut(duration: 0.25), value: selectedMode)
                                .onTapGesture {
                                    guard isSelected else { return }

                                    switch gameModes[index] {
                                    case "Single Player":
                                        if !hasSeenTutorial {
                                            showTutorial = true
                                        } else {
                                            showSinglePlayer = true
                                        }
                                    case "Two Players":
                                        showTwoPlayer = true
                                    case "Multiplayer":
                                        showMultiplayer = true
                                    case "Settings":
                                        withAnimation(.easeInOut(duration: 0.6)) {
                                            isSettingsFlipped.toggle()
                                        }
                                    default:
                                        break
                                    }
                                }
                            }
                        }
                        .offset(x: offsetX)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation.width
                                }
                                .onEnded { value in
                                    if isSettingsFlipped {
                                        withAnimation(.easeInOut(duration: 0.6)) {
                                            isSettingsFlipped = false
                                        }
                                        // Se lo swipe è verso sinistra e non siamo già all'ultima card
                                        if value.translation.width < -dragThreshold && selectedMode < gameModes.count - 1 {
                                            selectedMode += 1
                                        }
                                        dragOffset = 0
                                        return
                                    }

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

                    VStack(spacing: 8) {
                        Text(subtitleText)
                            .font(.custom("Futura", size: 20))
                            .foregroundColor(.white)
                            .shadow(radius: 3)

                        Text(tapInstructionText)
                            .font(.custom("Futura-Bold", size: 30))
                            .foregroundColor(.white)
                            .shadow(radius: 6)
                    }
                    .padding(.bottom, 60)
                }

                NavigationLink(destination: TutorialIntroView()
                    .onDisappear {
                        hasSeenTutorial = true
                        showTutorial = false
                        showSinglePlayer = true
                    }, isActive: $showTutorial) {
                    EmptyView()
                }

                NavigationLink(destination: SinglePlayerView(), isActive: $showSinglePlayer) {
                    EmptyView()
                }

                NavigationLink(destination: TwoPlayerGameView(), isActive: $showTwoPlayer) {
                    EmptyView()
                }

                /*NavigationLink(destination: GameCenterConnectView(), isActive: $showMultiplayer) {
                    EmptyView()
                }*/
            }
            .onAppear {
                GKAccessPoint.shared.location = .topTrailing
                GKAccessPoint.shared.isActive = true

                if volumeEnabled {
                    AudioManager.shared.startBackgroundMusic()
                }
            }
            .onDisappear {
                GKAccessPoint.shared.isActive = false
                AudioManager.shared.stopBackgroundMusic()
            }
            .onChange(of: volumeEnabled) { newValue in
                if newValue {
                    AudioManager.shared.startBackgroundMusic()
                } else {
                    AudioManager.shared.stopBackgroundMusic()
                }
            }
        }
    }

    private var tapInstructionText: String {
        if gameModes[selectedMode] == "Settings" {
            return isSettingsFlipped
                ? NSLocalizedString("Tap to Close", comment: "Close settings")
                : NSLocalizedString("Tap to Open", comment: "Open settings")
        } else {
            return NSLocalizedString("Tap to Start", comment: "Start game")
        }
    }

    private var subtitleText: String {
        switch gameModes[selectedMode] {
        case "Single Player":
            return NSLocalizedString("vs CPU", comment: "Single player description")
        case "Two Players":
            return NSLocalizedString("Split Screen", comment: "Two player description")
        case "Multiplayer":
            return NSLocalizedString("Online", comment: "Multiplayer description")
        case "Settings":
            return NSLocalizedString("Customize your game", comment: "Settings description")
        default:
            return ""
        }
    }
}

struct FlipView<Front: View, Back: View>: View {
    var isFlipped: Bool
    var front: () -> Front
    var back: () -> Back

    var body: some View {
        ZStack {
            front()
                .opacity(isFlipped ? 0.0 : 1.0)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))

            back()
                .opacity(isFlipped ? 1.0 : 0.0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .animation(.easeInOut(duration: 0.6), value: isFlipped)
    }
}

#Preview {
    HomeView()
}
