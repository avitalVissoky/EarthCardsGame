import SwiftUI

struct SummaryView: View {
    let winnerName: String
    let winnerScore: Int
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("Winner: \(winnerName)")
                .font(.largeTitle)
                .bold()

            Text("Score: \(winnerScore)")
                .font(.title)

            Button(action: {
                dismiss() // חוזר אחורה ל־Welcome
            }) {
                Text("BACK TO MENU")
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
    }
}
