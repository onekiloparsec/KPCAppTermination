//
//  AppTermination.swift
//  KPCAppTermination
//
//  Created by Cédric Foellmi on 07/08/16.
//  Licensed under the MIT License (see LICENSE file)
//

import Foundation

open class AppTermination : NSObject {
    
    @IBOutlet open var quittingWindow: NSWindow?
    
    open var minimumTimerInterval: TimeInterval = 0.5
    open var finalTimerInterval: TimeInterval = 0.5
    open var finalTerminationBlock: ((_ quittingWindow: NSWindow?) -> Void)?

    fileprivate var terminationTimer: Timer? = nil
    fileprivate var terminationBlocks: [((_ quittingWindow: NSWindow?) -> Void)] = []
    
    open func registerAsyncTerminationBlock(_ block: @escaping ((_ quittingWindow: NSWindow?) -> Void)) {
        self.terminationBlocks.append(block)
    }
    
    open func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        
        NSApp.windows.forEach { $0.close() }
        self.quittingWindow?.makeKeyAndOrderFront(self)
        
        while self.terminationBlocks.count > 0 {
            let block = self.terminationBlocks.remove(at: 0)
            
            let terminationBlock: ()->() = {
                block(self.quittingWindow)
                
                if self.terminationBlocks.count == 0 && self.terminationTimer == nil {
                    if let finalBlock = self.finalTerminationBlock {
                        DispatchQueue.main.async(execute: {
                            finalBlock(self.quittingWindow)
                        })
                    }
                    self.startFinalTerminationTimer()
                }
            }
            
            DispatchQueue.global().async(execute: {
                terminationBlock()
            })
        }
        
        let weakTarget = WeakTimerTarget(realTarget: self,
                                         realSelector: #selector(AppTermination.finallyLaunchAppTermination(_:)),
                                         timerRepeat: false)
        
        // This timer is only here to make sure we show the quitting window at least for a little while, even
        // if there are no termination blocks, or those are very quick to complete.
        self.terminationTimer = Timer(timeInterval: self.minimumTimerInterval,
                                        target: weakTarget,
                                        selector: #selector(WeakTimerTarget.timerDidFire(_:)),
                                        userInfo: nil,
                                        repeats: weakTarget.timerRepeat)
        
        RunLoop.main.add(self.terminationTimer!, forMode: RunLoopMode.modalPanelRunLoopMode)
        
        return .terminateLater
    }
    
    @objc fileprivate func finallyLaunchAppTermination(_ timer: Timer) {
        self.terminationTimer = nil;
        
        if (self.terminationBlocks.count == 0) {
            if let finalBlock = self.finalTerminationBlock {
                DispatchQueue.main.async(execute: {
                    finalBlock(self.quittingWindow)
                })
            }
            self.startFinalTerminationTimer()
        }
        // else: Reprieve timer is over but termination blocks are not. Keep going...
    }
    
    fileprivate func startFinalTerminationTimer() {
        let deathTimer = Timer(timeInterval: self.finalTimerInterval,
                                 target: self,
                                 selector: #selector(AppTermination.terminateAppNow(_:)),
                                 userInfo: nil,
                                 repeats:false)
        
        RunLoop.main.add(deathTimer, forMode: RunLoopMode.modalPanelRunLoopMode)
    }
    
    @objc fileprivate func terminateAppNow(_ timer: Timer) {
        NSApplication.shared().reply(toApplicationShouldTerminate: true)
    }
}
