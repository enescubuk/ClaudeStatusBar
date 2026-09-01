import AppKit
import SwiftUI

@main
struct ClaudeStatusBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let stateURL = FileManager.default.homeDirectoryForCurrentUser
        .appending(path: ".claude/statusbar/state.json")
    private var statusItem: NSStatusItem!
    private var timer: Timer?
    private var currentStatus: Status?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Equivalent to LSUIElement for this unbundled SwiftPM executable.
        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.imagePosition = .imageOnly
        statusItem.menu = makeMenu()
        refreshStatus()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.refreshStatus()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
    }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(withTitle: "ClaudeStatusBar", action: nil, keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q")
        return menu
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    private func refreshStatus() {
        let status = readStatus()
        guard status != currentStatus else { return }

        currentStatus = status
        let image = dotImage(color: status.color)
        image.isTemplate = false
        statusItem.button?.image = image
        statusItem.button?.toolTip = "Claude Code: \(status.label)"
    }

    private func readStatus() -> Status {
        guard let data = try? Data(contentsOf: stateURL),
              let state = try? JSONDecoder().decode(StateFile.self, from: data),
              let status = Status(rawValue: state.status) else {
            return .done
        }
        return status
    }

    private func dotImage(color: NSColor) -> NSImage {
        let size = NSSize(width: 14, height: 14)
        let image = NSImage(size: size)
        image.lockFocus()
        color.setFill()
        NSBezierPath(ovalIn: NSRect(x: 2, y: 2, width: 10, height: 10)).fill()
        image.unlockFocus()
        return image
    }
}

private struct StateFile: Decodable {
    let status: String
}

private enum Status: String, Equatable {
    case working
    case done
    case question

    var color: NSColor {
        switch self {
        case .working: NSColor(red: 245 / 255, green: 181 / 255, blue: 115 / 255, alpha: 1)
        case .done: NSColor(red: 126 / 255, green: 235 / 255, blue: 197 / 255, alpha: 1)
        case .question: NSColor(red: 255 / 255, green: 123 / 255, blue: 114 / 255, alpha: 1)
        }
    }

    var label: String { rawValue }
}
