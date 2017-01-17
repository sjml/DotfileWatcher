import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    var statusItem: NSStatusItem? = nil
    var darkModeOn: Bool = false
    var timerCheck: Timer!
    var dotPath: String? = ""
    let preferences = UserDefaults.standard

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        self.statusItem!.image = NSImage(named: "MenuBarImage")
        self.statusItem!.isVisible = false
        
        var targetApp: String? = self.preferences.string(forKey: "targetApp")
        if (targetApp == nil || targetApp?.characters.count == 0 ) {
            targetApp = "Finder"
        }
        
        // so an intrepid hacker could override it with a defaults command
        self.dotPath = self.preferences.string(forKey: "dotPath")
        if (self.dotPath == nil || self.dotPath?.characters.count == 0 ) {
            self.dotPath = NSHomeDirectory().appending("/.dotfiles")
        }
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Open ~/.dotfiles…", action: #selector(openDotfiles), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(checkDotFiles), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Set app…", action: #selector(chooseApp), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.shared().terminate), keyEquivalent: ""))
        
        self.statusItem!.menu = menu
        
        checkDotFiles(nil)
        timerCheck = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(checkDotFiles), userInfo: nil, repeats: true)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // nada
    }
    
    func doesDotPathExist()-> Bool {
        var isDir: ObjCBool = false
        if (FileManager.default.fileExists(atPath: self.dotPath!, isDirectory: &isDir)) {
            if !isDir.boolValue {
                return false
            }
        }
        else {
            return false
        }
        
        return true
    }

    func openDotfiles(_ sender: AnyObject?) {
        if !self.doesDotPathExist() {
            return
        }
        var targetApp: String? = self.preferences.string(forKey: "targetApp")
        if (targetApp == nil || targetApp?.characters.count == 0 ) {
            targetApp = "Finder"
        }
        
        NSWorkspace.shared().openFile(self.dotPath!, withApplication: targetApp, andDeactivate: true)
    }
    
    func chooseApp(_ sender: AnyObject?) {
        let openPanel = NSOpenPanel()
        
        openPanel.title = "Choose an application to open your ~/.dotfiles directory."
        openPanel.message = openPanel.title
        openPanel.prompt = "Choose"
        openPanel.showsResizeIndicator = true
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.directoryURL = NSURL.fileURL(withPath: "/Applications")
        openPanel.allowedFileTypes = ["app"]
        
        if (openPanel.runModal() == NSModalResponseOK) {
            self.preferences.set(openPanel.url, forKey: "targetApp")
            self.openDotfiles(nil)
        }
        
        // don't know if this is necessary, but it *does* clear out some memory...
        openPanel.close()
    }
    
    func checkDotFiles(_ sender: AnyObject?) {
        if !self.doesDotPathExist() {
            return
        }
        
        let check = Process()
        let output = Pipe()
        check.currentDirectoryPath = self.dotPath!
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

