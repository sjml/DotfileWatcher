import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    var statusItem: NSStatusItem? = nil
    var darkModeOn: Bool = false
    var timerCheck: Timer!
    var dotPath: String? = ""
    var displayDotPath: String = ""
    let preferences = UserDefaults.standard
    
    var openMenuItem: NSMenuItem? = nil

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        self.statusItem!.image = NSImage(named: "MenuBarImage")
        self.statusItem!.isVisible = false
        
        var targetApp: String? = self.preferences.string(forKey: "targetApp")
        if (targetApp == nil || targetApp?.characters.count == 0 ) {
            targetApp = "Finder"
        }
        
        let menu = NSMenu()
        self.openMenuItem = NSMenuItem(title: "Open \(self.displayDotPath)…", action: #selector(openDotfiles), keyEquivalent: "")
        menu.addItem(self.openMenuItem!)
        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(checkDotFiles), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Set watched directory…", action: #selector(chooseDotPath), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Set app…", action: #selector(chooseApp), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.shared().terminate), keyEquivalent: ""))
        self.statusItem!.menu = menu
        
        var dotPath: String? = self.preferences.string(forKey: "dotPath")
        if (dotPath == nil || dotPath?.characters.count == 0 ) {
            self.setDotPath(newDotPath: NSHomeDirectory().appending("/.dotfiles"))
        }
        else {
            self.setDotPath(newDotPath: dotPath!)
        }
        
        timerCheck = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(checkDotFiles), userInfo: nil, repeats: true)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // nada
    }
    
    func doesPathExist(testingPath: String)-> Bool {
        var isDir: ObjCBool = false
        if (FileManager.default.fileExists(atPath: testingPath, isDirectory: &isDir)) {
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
        if !self.doesPathExist(testingPath: self.dotPath!) {
            return
        }
        var targetApp: String? = self.preferences.string(forKey: "targetApp")
        if (targetApp == nil || targetApp?.characters.count == 0 ) {
            targetApp = "Finder"
        }
        
        NSWorkspace.shared().openFile(self.dotPath!, withApplication: targetApp, andDeactivate: true)
    }
    
    func chooseDotPath(_ sender: AnyObject?) {
        let openPanel = NSOpenPanel()
        
        openPanel.title = "Choose an directory to watch."
        openPanel.message = openPanel.title
        openPanel.prompt = "Choose"
        openPanel.showsResizeIndicator = true
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.showsHiddenFiles = true
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.directoryURL = NSURL.fileURL(withPath: NSHomeDirectory())
        openPanel.allowedFileTypes = ["app"]
        
        if (openPanel.runModal() == NSModalResponseOK) {
            self.setDotPath(newDotPath: (openPanel.url?.path)!)
        }
        openPanel.close()
    }
    
    func setDotPath(newDotPath: String) {
        if !self.doesPathExist(testingPath: newDotPath) {
            self.openMenuItem!.title = "[No valid dotpath.]"
            self.openMenuItem!.action = nil
            self.statusItem?.isVisible = true
            return
        }
        
        self.preferences.set(newDotPath, forKey: "dotPath")
        self.dotPath = newDotPath
        self.displayDotPath = newDotPath.replacingOccurrences(of: NSHomeDirectory(), with: "~")
        self.openMenuItem!.title = "Open \(self.displayDotPath)…"
        self.openMenuItem?.action = #selector(openDotfiles)
        checkDotFiles(nil)
    }
    
    func chooseApp(_ sender: AnyObject?) {
        let openPanel = NSOpenPanel()
        
        openPanel.title = "Choose an application to open \(self.displayDotPath)."
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
        openPanel.close()
    }
    
    func checkDotFiles(_ sender: AnyObject?) {
        if !self.doesPathExist(testingPath: self.dotPath!) {
            self.statusItem?.isVisible = true
            return
        }
        
        let check = Process()
        let output = Pipe()
        let error = Pipe()
        check.currentDirectoryPath = self.dotPath!
        check.launchPath = "/usr/bin/env"
        check.standardOutput = output
        check.standardError = error
        check.arguments = ["git", "status", "--porcelain"]
        check.launch()
        check.waitUntilExit()
        
        let errorOutput = error.fileHandleForReading.readDataToEndOfFile()
        if (errorOutput.count > 0) {
            // not a git directory; leave it visible
            self.statusItem?.isVisible = true
            self.openMenuItem?.title = "[Not a git repository.]"
            self.openMenuItem?.action = nil
            return
        }
        else {
            self.openMenuItem?.action = #selector(openDotfiles)
        }
        
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

