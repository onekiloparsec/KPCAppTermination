
//
//  AppDelegate.swift
//  KPCAppTerminationDemo
//
//  Created by Cédric Foellmi on 07/08/16.
//  Copyright © 2016 onekiloparsec. All rights reserved.
//

import Cocoa
import KPCAppTermination

class QuittingPanel : NSPanel {
    @IBOutlet var messageLabel: NSTextField?
    @IBOutlet var progressIndicator: NSProgressIndicator?
    
    static func loadFromXib() -> QuittingPanel? {
        var topLevels: NSArray?
        NSBundle.mainBundle().loadNibNamed("QuittingWindow", owner: self, topLevelObjects: &topLevels)
        return topLevels?.filter({ $0 is QuittingPanel }).first as? QuittingPanel
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let appTermination = AppTermination()
    let quittingWindow = QuittingPanel.loadFromXib()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
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

    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        print(#function)
        
        self.appTermination.registerAsyncTerminationBlock { (quittingWindow) in
            if let panel = quittingWindow as? QuittingPanel {
                dispatch_async(dispatch_get_main_queue(), {
                    panel.title = "Quitting App..."
                    panel.messageLabel?.stringValue = "Processing termination block #1"
                    panel.progressIndicator?.startAnimation(self)
                })
                print("Processing termination block #1...")
            }
        }
        
        self.appTermination.registerAsyncTerminationBlock { (quittingWindow) in
            if let panel = quittingWindow as? QuittingPanel {
                dispatch_async(dispatch_get_main_queue(), {
                    panel.messageLabel?.stringValue = "Processing termination block #2"
                })
                print("Processing termination block #2...")
            }
        }

        // Must be the last
        return self.appTermination.applicationShouldTerminate(sender)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        print(#function)
    }
}

