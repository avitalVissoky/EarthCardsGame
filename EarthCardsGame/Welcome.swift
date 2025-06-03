import SwiftUI
import CoreLocation

struct Welcome: View {
    @AppStorage("playerName") private var savedName: String = ""
    @State private var nameInput: String = ""
    @State private var showNamePrompt = false
    @Environment(\.colorScheme) var colorScheme

    @StateObject private var locationService = LocationManagerService()
    @State private var navigateToGame = false

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
                    .font(.title2)
                }

                if showNamePrompt {
                    TextField("Enter your name", text: $nameInput)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .onSubmit {
                            if !nameInput.trimmingCharacters(in: .whitespaces).isEmpty {
                                savedName = nameInput
                                showNamePrompt = false
                                nameInput = ""
                            }
                        }
                }

                if !savedName.isEmpty {
                    Text("Hi \(savedName)")
                        .font(.title)
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                }


                HStack {
                    VStack {
                        Image(colorScheme == .dark ? "night-left" : "day-left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                        Text("West Side")
                            .foregroundColor(colorScheme == .dark ? .white : .primary)
                    }

                    Spacer()

                    VStack {
                        Image(colorScheme == .dark ? "night-right" : "day-right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                        Text("East Side")
                            .foregroundColor(colorScheme == .dark ? .white : .primary)
                    }
                }
                .padding(.horizontal, 40)


                if let side = playerSide {
                    Text("Your Side: \(side)")
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .primary)
                }

                if savedName.isEmpty || !locationService.isLocationAvailable {
                    ProgressView()
                        .padding()
                        .tint(colorScheme == .dark ? .white : .blue)
                }

                if locationService.isLocationAvailable && !savedName.isEmpty {
                    Button(action: {
                        navigateToGame = true
                    }) {
                        Text("START")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.title2)
                            .bold()
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .background(colorScheme == .dark ? Color.black : Color.clear)
            .onAppear {
                locationService.requestLocation()
            }
            .navigationDestination(isPresented: $navigateToGame) {
                CardGameView()
            }
            .alert("Location Access Denied", isPresented: $locationService.permissionDenied) {
                Button("Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please enable location access in Settings to play the game.")
            }
        }
    }

    private var playerSide: String? {
        guard let longitude = locationService.lastKnownLongitude else { return nil }
        return longitude > dividerLongitude ? "East Side" : "West Side"
    }
}
