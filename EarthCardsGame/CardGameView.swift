import SwiftUI

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

    let totalTurns = 10
    let cardValues = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "A"]

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                VStack {
                    // ניקוד
                    HStack {
                        VStack {
                            Text(playerName)
                            Text("\(leftScore)")
                        }
                        Spacer()
                        VStack {
                            Text("PC")
                            Text("\(rightScore)")
                        }
                    }
                    .font(.title)
                    .padding(.horizontal)
                    .padding(.top, geo.safeAreaInsets.top + 20)
                    
                    // קלפים + טיימר במרכז
                    HStack(spacing: 30) {
                        cardImage(for: leftCard, isFaceUp: flip)
                        VStack {
                            Image(systemName: "clock")
                            Text("\(timerCount)")
                        }
                        cardImage(for: rightCard, isFaceUp: flip)
                    }
                    .padding(.top, 40)

                    Spacer()
                }
//                .frame(width: geo.size.width, height: geo.size.height)
                .onAppear {
                    startTurn()
                }
                .navigationDestination(isPresented: $showSummary) {
                    SummaryView(
                        winnerName: gameResult().name,
                        winnerScore: max(leftScore, rightScore)
                    )
                }
            }
        }
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

    func startTurn() {
        guard turn < totalTurns else {
            gameOver = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showSummary = true
            }
            return
        }

        turn += 1
        timerCount = 5
        flip = false

        let l = randomCard(prefix: "clubs")
        let r = randomCard(prefix: "hearts")
        leftCard = l.name
        rightCard = r.name

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            timerCount -= 1

            if timerCount == 0 {
                timer.invalidate()
                flip = true

                if l.value > r.value {
                    leftScore += 1
                } else if r.value > l.value {
                    rightScore += 1
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    startTurn()
                }
            }
        }
    }

    func randomCard(prefix: String) -> (name: String, value: Int) {
        let index = Int.random(in: 0..<cardValues.count)
        let name = "\(prefix)_\(cardValues[index])"
        return (name, index + 2)
    }

    func gameResult() -> (name: String, text: String) {
        if leftScore > rightScore {
            return (playerName, "\(playerName) ניצח/ה 🎉")
        } else if rightScore > leftScore {
            return ("PC", "המחשב ניצח 🎉")
        } else {
            return ("תיקו", "תיקו 🤝")
        }
    }
}
