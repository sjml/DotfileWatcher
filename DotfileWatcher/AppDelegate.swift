import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    var statusItem: NSStatusItem? = nil
    var darkModeOn: Bool = false
    var timerCheck: Timer!
    var dotPath: String = ""

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        self.statusItem!.image = NSImage(named: "MenuBarImage")
        self.statusItem!.isVisible = false
        
        self.dotPath = NSHomeDirectory().appending("/.dotfiles")
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Open ~/.dotfiles…", action: #selector(openDotfiles), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(checkDotFiles), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.shared().terminate), keyEquivalent: ""))
        
        self.statusItem!.menu = menu
        
        checkDotFiles(nil)
        timerCheck = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(checkDotFiles), userInfo: nil, repeats: true)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // nada
    }

    func openDotfiles(_ sender: AnyObject?) {
        NSWorkspace.shared().openFile(self.dotPath, withApplication: "Visual Studio Code", andDeactivate: true)
    }
    
    func checkDotFiles(_ sender: AnyObject?) {
        let check = Process()
        let output = Pipe()
        check.currentDirectoryPath = self.dotPath
        check.launchPath = "/usr/bin/env"
        check.standardOutput = output
        check.arguments = ["git", "status", "--porcelain"]
        check.launch()
        check.waitUntilExit()
        
        let out = output.fileHandleForReading.readDataToEndOfFile()
        if (out.count > 0) {
            // something's going on
            self.statusItem?.isVisible = true
        }
        else {
            self.statusItem?.isVisible = false
        }
    }
}

