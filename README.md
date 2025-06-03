# Earth Cards Game

A location-based card game built with SwiftUI that determines your playing side based on your geographic location.

## Features

- Location-based gameplay - your side (East/West) is determined by your longitude
- Name registration with persistent storage
- 10 rounds of automated card battles against computer
- Real-time score tracking
- Dark mode support with adaptive UI
- Portrait and landscape orientation support
- Background music and sound effects
- Proper app lifecycle management (pause/resume functionality)

## How to Play

1. Launch the app and grant location permission when prompted
2. Enter your name (required only on first launch)
3. Your side is automatically assigned based on your location relative to longitude 34.817549168324334
4. Tap START to begin the game
5. Watch 10 rounds of automatic card battles
6. View final results and return to main menu

## Required Assets

### Audio

- `background_music.mp3` - Background music during gameplay
- `card_flip.wav` - Card flip sound effect
- `win_sound.wav` - Victory sound effect

## Game Rules

- Total of 10 rounds
- Higher card wins the round
- Equal cards result in no score change
- If final scores are tied, computer wins

## Configuration

The longitude divider is set to `34.817549168324334`. Players east of this coordinate play as **East Side**, players west play as **West Side**.

---
