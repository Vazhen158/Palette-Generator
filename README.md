# Palette Generator

Palette Generator is an iOS color palette generator built with SwiftUI. The app creates color palettes using common harmony rules, displays color names and HEX values, and lets users quickly copy colors to the clipboard.

## Features

- Generate random color palettes
- Support for monochromatic, analogous, complementary, triadic, and tetradic palettes
- Display recognized color names (matched in CIE L*a*b* space) and HEX values
- Copy a color HEX value by tapping a color card
- Edit any color with HSB sliders
- Save palettes and browse history (file-backed `PaletteRepository`)
- Adaptive text and icon colors for better contrast
- Glassmorphism-style SwiftUI interface
- MVVM-based project structure

## Architecture

The project follows MVVM and keeps UI, state, domain models, services, and extensions separated.

```text
TestColorPicker/
├── App/                  # App entry point and root view
├── Models/               # Data models
├── ViewModels/           # Screen state and presentation logic
├── Services/             # Business logic and platform services
├── PaletteGeneratorView/ # SwiftUI views for palette generation
├── Glass/                # UI modifiers and styles
├── Extensions/           # Swift extensions
└── Assets.xcassets/      # App assets
```

## Main Components

- `ColorGenerateView` renders the palette generator screen.
- `ColorGenerateViewModel` stores screen state and coordinates palette generation.
- `PaletteGeneratorService` contains palette generation logic.
- `ColorNamingService` resolves readable color names via Lab ΔE matching.
- `PaletteRepository` abstracts palette persistence (`FilePaletteRepository` for production, `InMemoryPaletteRepository` for previews/tests).
- `ClipboardService` isolates clipboard access from SwiftUI views.
- `RecognizedColor` and `ColorPalette` describe the app's core data.

## Requirements

- Xcode 16 or newer
- iOS 18.4 or newer
- Swift 5

## Getting Started

1. Clone the repository.
2. Open `TestColorPicker.xcodeproj` in Xcode.
3. Select the `TestColorPicker` scheme.
4. Choose an iOS Simulator or connected iPhone.
5. Build and run the app.

## Build From Terminal

```bash
xcodebuild \
  -project TestColorPicker.xcodeproj \
  -scheme TestColorPicker \
  -configuration Debug \
  -sdk iphonesimulator \
  build CODE_SIGNING_ALLOWED=NO
```

## Project Status

The project covers palette generation, history, persistence and HSB color editing. The codebase follows MVVM with protocol-based dependencies (`PaletteGenerating`, `PaletteRepository`, `ColorNaming`, `ClipboardManaging`), making services trivial to substitute in previews and unit tests.
