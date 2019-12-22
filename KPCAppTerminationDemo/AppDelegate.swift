
//
//  AppDelegate.swift
//  KPCAppTerminationDemo
//
//  Created by Cédric Foellmi on 07/08/16.
//  Licensed under the MIT License (see LICENSE file)
//

import Cocoa
import KPCAppTermination

class QuittingPanel : NSPanel {
    @IBOutlet var messageLabel: NSTextField?
    @IBOutlet var progressIndicator: NSProgressIndicator?
    
    static func loadFromXib() -> QuittingPanel? {
        var topLevels: NSArray?
        Bundle.main.loadNibNamed("QuittingWindow", owner: self, topLevelObjects: &topLevels)
        return topLevels?.filter({ $0 is QuittingPanel }).first as? QuittingPanel
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let appTermination = AppTermination()
    let quittingWindow = QuittingPanel.loadFromXib()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Assign the quittingWindow
        self.appTermination.quittingWindow = self.quittingWindow
        self.appTermination.minimumTimerInterval = 5.0
        self.appTermination.finalTimerInterval = 1.0
        
        self.appTermination.finalTerminationBlock = { (quittingWindow) in
            // No need to wrap around mainQueue, as the final block is launched from it already.
            if let panel = quittingWindow as? QuittingPanel {
                panel.title = "Ready To Quit"
                panel.messageLabel?.stringValue = "Done"
                panel.progressIndicator?.stopAnimation(self)
            }
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        print(#function)
        
        self.appTermination.registerAsyncTerminationBlock { (quittingWindow) in
            if let panel = quittingWindow as? QuittingPanel {
                DispatchQueue.main.async(execute: {
                    panel.title = "Quitting App..."
                    panel.messageLabel?.stringValue = "Processing termination block #1"
                    panel.progressIndicator?.startAnimation(self)
                })
                print("Processing termination block #1...")
            }
        }
        
        self.appTermination.registerAsyncTerminationBlock { (quittingWindow) in
            if let panel = quittingWindow as? QuittingPanel {
                DispatchQueue.main.async(execute: {
                    panel.messageLabel?.stringValue = "Processing termination block #2"
                })
                print("Processing termination block #2...")
            }
        }

        // Must be the last
        return self.appTermination.applicationShouldTerminate(sender)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        print(#function)
    }
}

