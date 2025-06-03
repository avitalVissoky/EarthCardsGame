import SwiftUI

struct SummaryView: View {
    let winnerName: String
    let winnerScore: Int
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("Winner: \(winnerName)")
                .font(.largeTitle)
                .bold()
                .foregroundColor(colorScheme == .dark ? .white : .primary)

            Text("Score: \(winnerScore)")
                .font(.title)
                .foregroundColor(colorScheme == .dark ? .white : .primary)

            Button(action: {
                dismiss()
            }) {
                Text("BACK TO MENU")
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .font(.title2)
                    .bold()
            }

            Spacer()
        }
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.clear)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}
