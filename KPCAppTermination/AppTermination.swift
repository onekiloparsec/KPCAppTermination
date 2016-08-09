//
//  AppTermination.swift
//  KPCAppTermination
//
//  Created by Cédric Foellmi on 07/08/16.
//  Licensed under the MIT License (see LICENSE file)
//

import Foundation

public class AppTermination : NSObject {
    
    @IBOutlet public var quittingWindow: NSWindow?
    
    public var minimumTimerInterval: NSTimeInterval = 0.5
    public var finalTimerInterval: NSTimeInterval = 0.5
    public var finalTerminationBlock: ((quittingWindow: NSWindow?) -> Void)?

    private var terminationTimer: NSTimer? = nil
    private var terminationBlocks: [((quittingWindow: NSWindow?) -> Void)] = []
    
    public func registerAsyncTerminationBlock(block: ((quittingWindow: NSWindow?) -> Void)) {
        self.terminationBlocks.append(block)
    }
    
    public func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        
        NSApp.windows.forEach { $0.close() }
        self.quittingWindow?.makeKeyAndOrderFront(self)
        
        while self.terminationBlocks.count > 0 {
            let block = self.terminationBlocks.removeAtIndex(0)
            
            let terminationBlock: dispatch_block_t = {
                block(quittingWindow: self.quittingWindow)
                
                if self.terminationBlocks.count == 0 && self.terminationTimer == nil {
                    if let finalBlock = self.finalTerminationBlock {
                        dispatch_async(dispatch_get_main_queue(), {
                            finalBlock(quittingWindow: self.quittingWindow)
                        })
                    }
                    self.startFinalTerminationTimer()
                }
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                terminationBlock()
            })
        }
        
        let weakTarget = WeakTimerTarget(realTarget: self,
                                         realSelector: #selector(AppTermination.finallyLaunchAppTermination(_:)),
                                         timerRepeat: false)
        
        // This timer is only here to make sure we show the quitting window at least for a little while, even
        // if there are no termination blocks, or those are very quick to complete.
        self.terminationTimer = NSTimer(timeInterval: self.minimumTimerInterval,
                                        target: weakTarget,
                                        selector: #selector(WeakTimerTarget.timerDidFire(_:)),
                                        userInfo: nil,
                                        repeats: weakTarget.timerRepeat)
        
        NSRunLoop.mainRunLoop().addTimer(self.terminationTimer!, forMode: NSModalPanelRunLoopMode)
        
        return .TerminateLater
    }
    
    @objc private func finallyLaunchAppTermination(timer: NSTimer) {
        self.terminationTimer = nil;
        
        if (self.terminationBlocks.count == 0) {
            if let finalBlock = self.finalTerminationBlock {
                dispatch_async(dispatch_get_main_queue(), {
                    finalBlock(quittingWindow: self.quittingWindow)
                })
            }
            self.startFinalTerminationTimer()
        }
        // else: Reprieve timer is over but termination blocks are not. Keep going...
    }
    
    private func startFinalTerminationTimer() {
        let deathTimer = NSTimer(timeInterval: self.finalTimerInterval,
                                 target: self,
                                 selector: #selector(AppTermination.terminateAppNow(_:)),
                                 userInfo: nil,
                                 repeats:false)
        
        NSRunLoop.mainRunLoop().addTimer(deathTimer, forMode: NSModalPanelRunLoopMode)
    }
    
    @objc private func terminateAppNow(timer: NSTimer) {
        NSApplication.sharedApplication().replyToApplicationShouldTerminate(true)
    }
}
