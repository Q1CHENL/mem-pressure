//
//  AppDelegate.swift
//  MemoryPressure
//
//  Created by 刘启辰 on 2023/6/16.
//

import Cocoa
import Foundation

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem!
    var updateTimer: Timer?
    var mainWindow: NSWindow!
    
    // items of submenus
    var plainItem: NSMenuItem!
    var colorizedItem: NSMenuItem!
    var oneSecItem: NSMenuItem!
    var threeSecItem: NSMenuItem!
    var fiveSecItem: NSMenuItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // prevent the app from showing in dock
        NSApp.setActivationPolicy(.accessory)
        
        // Create a status bar item with a custom view
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Create a button and set its appearance and action
        if let button = statusItem.button {
            updateButtonTitle()
            button.target = self
            button.action = #selector(statusBarButtonClicked(_:))
        }
        
        // Add a menu to the status bar item
        let menu = NSMenu()
        
        // Appearance
        let appearanceMenuItem = NSMenuItem(title: "Appearance", action: #selector(appearanceMenuItemClicked(_:)), keyEquivalent: "")
        menu.addItem(appearanceMenuItem)
        
        let submenu = NSMenu()

        plainItem = NSMenuItem(title: "Plain", action: #selector(plainItemClicked(_:)), keyEquivalent: "")
        submenu.addItem(plainItem)

        colorizedItem = NSMenuItem(title: "Colorized", action: #selector(colorizedItemClicked(_:)), keyEquivalent: "")
        submenu.addItem(colorizedItem)

        // Set the submenu for the appearanceMenuItem
        appearanceMenuItem.submenu = submenu
        
        // Add an Update Interval menu item
        let updateInterval = NSMenuItem(title: "Update Interval", action: #selector(updateIntervalItemClicked(_:)), keyEquivalent: "")
        menu.addItem(updateInterval)
        let submenuUpdateInterval = NSMenu()
        updateInterval.submenu = submenuUpdateInterval
        
        oneSecItem = NSMenuItem(title: "1s", action: #selector(oneSecItemClicked(_:)), keyEquivalent: "")
        threeSecItem = NSMenuItem(title: "3s", action: #selector(threeSecItemClicked(_:)), keyEquivalent: "")
        fiveSecItem = NSMenuItem(title: "5s", action: #selector(fiveSecItemClicked(_:)), keyEquivalent: "")
        threeSecItem.state  = .on
        
        submenuUpdateInterval.addItem(oneSecItem)
        submenuUpdateInterval.addItem(threeSecItem)
        submenuUpdateInterval.addItem(fiveSecItem)
        
        // Add an "Open Activity Monitor" menu item
        let openActivityMonitorMenuItem = NSMenuItem(title: "Open Activity Monitor", action: #selector(openActivityMonitorMenuItemClicked(_:)), keyEquivalent: "")
        menu.addItem(openActivityMonitorMenuItem)
        
        // Add a "Quit" menu item
        let quitMenuItem = NSMenuItem(title: "Quit MemPressure", action: #selector(quitMenuItemClicked(_:)), keyEquivalent: "")
        menu.addItem(quitMenuItem)
        
        // Set the menu for the status bar item
        statusItem.menu = menu
        
        // timer for update interval
        updateTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(updateButtonTitle), userInfo: nil, repeats: true)
        
        mainWindow = NSApplication.shared.windows.first
        mainWindow.isReleasedWhenClosed = false
        mainWindow.contentView = NSView(frame: NSRect.zero)
        mainWindow.setIsVisible(false)
    }
    

    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        // Implement any desired actions when the status bar button is clicked
    }
    
    
    @objc func updateIntervalItemClicked(_ sender: NSStatusBarButton) {
        // Implement any desired actions when the status bar button is clicked
    }
    
    @objc func quitMenuItemClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    @objc func appearanceMenuItemClicked(_ sender: NSMenuItem) {
      
    }
    
    @objc func oneSecItemClicked(_ sender: NSMenuItem){
        oneSecItem.state = .on
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateButtonTitle), userInfo: nil, repeats: true)
    }
    
    @objc func threeSecItemClicked(_ sender: NSMenuItem){
        threeSecItem.state = .on
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(updateButtonTitle), userInfo: nil, repeats: true)
    }
    
    @objc func fiveSecItemClicked(_ sender: NSMenuItem){
        fiveSecItem.state = .on
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(updateButtonTitle), userInfo: nil, repeats: true)
    }

    @objc func plainItemClicked(_ sender: NSMenuItem) {
        plainItem.state = .on
        colorizedItem.state = .off
    }
    
    @objc func colorizedItemClicked(_ sender: NSMenuItem) {
        plainItem.state = .off
        colorizedItem.state = .on
    }


    @objc func openActivityMonitorMenuItemClicked(_ sender: NSMenuItem) {
        let url = NSURL(fileURLWithPath: "/System/Applications/Utilities/Activity Monitor.app", isDirectory: true) as URL

        let path = "/bin"
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.arguments = [path]
        NSWorkspace.shared.openApplication(at: url,
                                           configuration: configuration,
                                           completionHandler: nil)
    }

    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    @objc func updateButtonTitle() {
        let title = getUpdatedTitle()
        
        let fontSize: CGFloat = 12.0  // Adjust the font size as desired
        
        if let button = statusItem.button {
            button.title = title
            let numericTitle = title.dropFirst().dropLast()
            if let pressure = Int(numericTitle) {
                if pressure < 65 {
                    button.attributedTitle = NSAttributedString(string: title, attributes: [.font: NSFont.boldSystemFont(ofSize: fontSize)])
                } else if pressure >= 65 && pressure <= 90 {
                    button.attributedTitle = NSAttributedString(string: title, attributes: [.foregroundColor: NSColor.orange, .font: NSFont.boldSystemFont(ofSize: fontSize)])
                } else {
                    button.attributedTitle = NSAttributedString(string: title, attributes: [.foregroundColor: NSColor.red, .font: NSFont.boldSystemFont(ofSize: fontSize)])
                }
            } else {
                // Handle the case when the title does not contain a valid numeric value
                button.attributedTitle = NSAttributedString(string: title, attributes: [.foregroundColor: NSColor.black, .font: NSFont.boldSystemFont(ofSize: fontSize)])
            }
        }
    }
    
    // Get string "MXX%"
    func getUpdatedTitle() -> String {
        let task = Process()
        let pipe = Pipe()
        let fixedValue  = 100
        task.standardOutput = pipe
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "memory_pressure -Q | tail -c 4"]
        
        task.launch()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            
            let numericValue = output.dropLast()
            
            if let pressure = Int(numericValue) {
                let result = fixedValue - pressure
                return "M\(result)%"
            } else {
                return ""
            }
            
        }
        return ""
    }
    
}

