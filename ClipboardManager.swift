import Cocoa

// MARK: - ClipboardManager

class ClipboardManager: NSObject {
    static let shared = ClipboardManager()
    
    private let pasteboard = NSPasteboard.general
    private var clipboardItems: [String] = []
    private var lastChangeCount: Int
    private var timer: Timer?
    
    private override init() {
        lastChangeCount = pasteboard.changeCount
        super.init()
        print("ClipboardManager initialized")
        loadSavedItems()
        startMonitoring()
    }
    
    private func startMonitoring() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForPasteboardChanges()
        }
        RunLoop.main.add(timer!, forMode: .common)
        print("Monitoring started")
    }
    
    private func checkForPasteboardChanges() {
        let currentChangeCount = pasteboard.changeCount
        
        guard currentChangeCount != lastChangeCount else { return }
        
        lastChangeCount = currentChangeCount
        print("Change detected")
        
        if let newString = pasteboard.string(forType: .string), !newString.isEmpty {
            if clipboardItems.isEmpty || newString != clipboardItems[0] {
                clipboardItems.insert(newString, at: 0)
                print("New item added: \(newString)")
                
                if clipboardItems.count > 10 {
                    clipboardItems.removeLast()
                }
                
                saveItems()
                NotificationCenter.default.post(name: Notification.Name("ClipboardUpdated"), object: nil)
            }
        }
    }
    
    func getClipboardItems() -> [String] {
        return clipboardItems
    }
    
    func copyItem(at index: Int) {
        guard index < clipboardItems.count else { return }
        
        let item = clipboardItems[index]
        print("Copying item: \(item)")
        
        // Do not modify the pasteboard here
        // Instead, just update our internal state
        clipboardItems.removeAll { $0 == item }
        clipboardItems.insert(item, at: 0)
        saveItems()
        
        print("Item at index \(index) moved to top of history")
        NotificationCenter.default.post(name: Notification.Name("ClipboardUpdated"), object: nil)
    }
    
    private func saveItems() {
        UserDefaults.standard.set(clipboardItems, forKey: "SavedClipboardItems")
    }
    
    private func loadSavedItems() {
        if let savedItems = UserDefaults.standard.stringArray(forKey: "SavedClipboardItems") {
            clipboardItems = savedItems
            print("Loaded \(savedItems.count) saved items")
        }
    }
    
    func clearAllItems() {
        clipboardItems.removeAll()
        saveItems()
        NotificationCenter.default.post(name: Notification.Name("ClipboardUpdated"), object: nil)
    }
    
    deinit {
        timer?.invalidate()
    }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var clipboardManager: ClipboardManager!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        clipboardManager = ClipboardManager.shared
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard")
            if button.image == nil {
                button.title = "📋"
            }
        }
        
        setupMenu()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMenu), name: Notification.Name("ClipboardUpdated"), object: nil)
    }
    
    func setupMenu() {
        let menu = NSMenu()
        updateMenuItems(menu)
        statusItem.menu = menu
    }
    
    @objc func updateMenu() {
        if let menu = statusItem.menu {
            menu.removeAllItems()
            updateMenuItems(menu)
        }
    }
    
    func updateMenuItems(_ menu: NSMenu) {
        let items = clipboardManager.getClipboardItems()
        
        for (index, item) in items.prefix(10).enumerated() {
            let truncatedItem = String(item.prefix(30)) + (item.count > 30 ? "..." : "")
            let menuItem = NSMenuItem(title: truncatedItem, action: #selector(copyItem(_:)), keyEquivalent: "")
            menuItem.tag = index
            menu.addItem(menuItem)
        }
        
        if !items.isEmpty {
            menu.addItem(NSMenuItem.separator())
        }
        
        menu.addItem(NSMenuItem(title: "Clear All Items", action: #selector(clearAllItems), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
    
    @objc func copyItem(_ sender: NSMenuItem) {
        let index = sender.tag
        let items = clipboardManager.getClipboardItems()
        if index < items.count {
            let item = items[index]
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(item, forType: .string)
            clipboardManager.copyItem(at: index)
        }
    }
    
    @objc func clearAllItems() {
        clipboardManager.clearAllItems()
        updateMenu()
    }
}

// MARK: - Main

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.activate(ignoringOtherApps: true)
app.run()