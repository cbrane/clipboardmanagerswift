# ClipboardManager

ClipboardManager is a simple macOS application that monitors and manages your clipboard history. It runs in the background and allows you to access your recent clipboard items quickly and easily.
Based off an amazing demo by Ricardo Mahfoud: https://x.com/imrat/status/1832805149489680762

## Features

- Monitors clipboard changes in real-time
- Stores up to 10 recent clipboard items
- Displays clipboard history in the menu bar
- Allows quick access to previous clipboard items
- Persists clipboard history between app restarts

## Requirements

- macOS 10.15 or later
- Swift 5.0 or later

## Installation

1. Clone this repository or download the `ClipboardManager.swift` file.

2. Open Terminal and navigate to the directory containing `ClipboardManager.swift`.

3. Compile the project using the following command:

swiftc ClipboardManager.swift -o ClipboardManager


This will create an executable file named `ClipboardManager`.

## Usage

1. After compiling, run the application using:

./ClipboardManager


2. The ClipboardManager icon (📋) will appear in your menu bar.

3. Click on the icon to see your clipboard history and interact with the app:
- Select an item to copy it to your clipboard
- Use "Clear All Items" to remove all stored clipboard items
- Choose "Quit" to exit the application

## How It Works

- The app monitors your system clipboard for changes every 0.5 seconds.
- When a new item is copied, it's added to the top of the history.
- The app stores up to 10 recent items, removing the oldest when this limit is reached.
- Clipboard history is saved between app restarts using UserDefaults.

## Contributing

Contributions, issues, and feature requests are welcome. Feel free to check issues page if you want to contribute.

## License

[MIT License](https://opensource.org/licenses/MIT)
