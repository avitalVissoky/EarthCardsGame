import SwiftUI
import AVFoundation

struct CardGameView: View {
    @AppStorage("playerName") private var playerName: String = ""
    @State private var leftCard: String = ""
    @State private var rightCard: String = ""
    @State private var flip = false
    @State private var timerCount = 5
    @State private var leftScore = 0
    @State private var rightScore = 0
    @State private var turn = 0
    @State private var gameOver = false
    @State private var showSummary = false
    @State private var gameTimer: Timer?
    @State private var isGameActive = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    
    @State private var cardFlipPlayer: AVAudioPlayer?
    @State private var backgroundMusicPlayer: AVAudioPlayer?
    @State private var winSoundPlayer: AVAudioPlayer?

    let totalTurns = 10
    let cardValues = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "A"]

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                VStack {
                    HStack {
                        VStack {
                            Text(playerName)
                                .foregroundColor(colorScheme == .dark ? .white : .primary)
                            Text("\(leftScore)")
                                .foregroundColor(colorScheme == .dark ? .white : .primary)
                        }
                        Spacer()
                        VStack {
                            Text("PC")
                                .foregroundColor(colorScheme == .dark ? .white : .primary)
                            Text("\(rightScore)")
                                .foregroundColor(colorScheme == .dark ? .white : .primary)
                        }
                    }
                    .font(.title)
                    .padding(.horizontal)
                    .padding(.top, geo.safeAreaInsets.top + 20)
                    
                    Spacer()
                    
                    HStack(spacing: 30) {
                        cardImage(for: leftCard, isFaceUp: flip)
                        VStack {
                            Image(systemName: "clock")
                                .foregroundColor(colorScheme == .dark ? .white : .primary)
                            Text("\(timerCount)")
                                .foregroundColor(colorScheme == .dark ? .white : .primary)
                                .font(.title)
                        }
                        cardImage(for: rightCard, isFaceUp: flip)
                    }

                    Spacer()
                    
                    Text("Turn \(turn)/\(totalTurns)")
                        .foregroundColor(colorScheme == .dark ? .white : .secondary)
                        .padding(.bottom)
                }
                .background(colorScheme == .dark ? Color.black : Color.clear)
                .onAppear {
                    setupAudio()
                    startGame()
                }
                .onDisappear {
                    stopGame()
                }
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    handleScenePhaseChange(newPhase)
                }
                .navigationDestination(isPresented: $showSummary) {
                    SummaryView(
                        winnerName: gameResult().name,
                        winnerScore: max(leftScore, rightScore)
                    )
                }
                .navigationBarHidden(true)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    func cardImage(for name: String, isFaceUp: Bool) -> some View {
        Image(isFaceUp ? name : "back_light")
            .resizable()
            .scaledToFit()
            .frame(width: 125, height: 170)
            .rotation3DEffect(.degrees(isFaceUp ? 0 : 180), axis: (x: 0, y: 1, z: 0))
            .animation(.easeInOut(duration: 0.6), value: isFaceUp)
            .shadow(radius: 4)
    }
    
    func setupAudio() {
        if let musicPath = Bundle.main.path(forResource: "background_music", ofType: "wav") {
            let musicUrl = URL(fileURLWithPath: musicPath)
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: musicUrl)
                backgroundMusicPlayer?.numberOfLoops = -1
                backgroundMusicPlayer?.volume = 0.3
            } catch {
                print("Could not create background music player: \(error)")
            }
        }
        
        if let flipPath = Bundle.main.path(forResource: "card_flip", ofType: "wav") {
            let flipUrl = URL(fileURLWithPath: flipPath)
            do {
                cardFlipPlayer = try AVAudioPlayer(contentsOf: flipUrl)
                cardFlipPlayer?.volume = 0.5
            } catch {
                print("Could not create card flip player: \(error)")
            }
        }
        
        if let winPath = Bundle.main.path(forResource: "win_sound", ofType: "wav") {
            let winUrl = URL(fileURLWithPath: winPath)
            do {
                winSoundPlayer = try AVAudioPlayer(contentsOf: winUrl)
                winSoundPlayer?.volume = 0.7
            } catch {
                print("Could not create win sound player: \(error)")
            }
        }
    }
    
    func startGame() {
        guard !isGameActive else { return }
        isGameActive = true
        backgroundMusicPlayer?.play()
        startTurn()
    }
    
    func stopGame() {
        isGameActive = false
        gameTimer?.invalidate()
        gameTimer = nil
        backgroundMusicPlayer?.stop()
    }
    
    func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            if gameTimer == nil && isGameActive && !gameOver {
                startTurn()
            }
            backgroundMusicPlayer?.play()
        case .inactive, .background:
            gameTimer?.invalidate()
            gameTimer = nil
            backgroundMusicPlayer?.pause()
        @unknown default:
            break
        }
    }

    func startTurn() {
        guard turn < totalTurns && isGameActive else {
            endGame()
            return
        }

        turn += 1
        timerCount = 5
        flip = false

        let l = randomCard(prefix: "clubs")
        let r = randomCard(prefix: "hearts")
        leftCard = l.name
        rightCard = r.name

        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            timerCount -= 1

            if timerCount == 0 {
                timer.invalidate()
                gameTimer = nil
                
                
                cardFlipPlayer?.play()
                
                flip = true

                if l.value > r.value {
                    leftScore += 1
                } else if r.value > l.value {
                    rightScore += 1
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if isGameActive {
                        startTurn()
                    }
                }
            }
        }
    }
    
    func endGame() {
        gameOver = true
        stopGame()
        
        winSoundPlayer?.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showSummary = true
        }
    }

    func randomCard(prefix: String) -> (name: String, value: Int) {
        let index = Int.random(in: 0..<cardValues.count)
        let name = "\(prefix)_\(cardValues[index])"
        return (name, index + 2)
    }

    func gameResult() -> (name: String, text: String) {
        if leftScore > rightScore {
            return (playerName, "\(playerName) Won! ")
        } else if rightScore > leftScore {
            return ("PC", "PC Won! ")
        } else {
            return ("PC", "PC Won! ")
        }
    }
}
