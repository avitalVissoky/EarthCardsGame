import SwiftUI
import CoreLocation

struct Welcome: View {
    @AppStorage("playerName") private var savedName: String = ""
    @State private var nameInput: String = ""
    @State private var showNamePrompt = false

    @StateObject private var locationService = LocationManagerService()
    @State private var navigateToGame = false // ✅ משתנה ניווט

    private let dividerLongitude = 34.817549168324334

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                if savedName.isEmpty {
                    Button("Insert name") {
                        showNamePrompt = true
                    }
                    .foregroundColor(.blue)
                }

                if showNamePrompt {
                    TextField("Enter your name", text: $nameInput, onCommit: {
                        if !nameInput.trimmingCharacters(in: .whitespaces).isEmpty {
                            savedName = nameInput
                            showNamePrompt = false
                        }
                    })
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                }

                if !savedName.isEmpty {
                    Text("Hi \(savedName)")
                        .font(.title)
                }

                HStack {
                    VStack {
                        Image("day-left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                        Text("West Side")
                    }

                    Spacer()

                    VStack {
                        Image("day-right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                        Text("East Side")
                    }
                }
                .padding(.horizontal, 40)

                if let side = playerSide {
                    Text("Your Side: \(side)")
                        .font(.headline)
                }

                if savedName.isEmpty || !locationService.isLocationAvailable {
                    ProgressView()
                        .padding()
                }

                if locationService.isLocationAvailable && !savedName.isEmpty {
                    // ✅ קישור ניווט
                    NavigationLink(destination: CardGameView(), isActive: $navigateToGame) {
                        EmptyView()
                    }

                    // ✅ כפתור START
                    Button(action: {
                        navigateToGame = true
                    }) {
                        Text("START")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .onAppear {
                locationService.requestLocation()
            }
            .alert("Location Access Denied", isPresented: $locationService.permissionDenied) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    private var playerSide: String? {
        guard let longitude = locationService.lastKnownLongitude else { return nil }
        return longitude > dividerLongitude ? "East Side" : "West Side"
    }
}
