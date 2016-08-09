//
//  WeakTimerTarget.swift
//  KPCAppTermination
//
//  Created by Cédric Foellmi on 07/08/16.
//  Licensed under the MIT License (see LICENSE file)
//

import Foundation

public class WeakTimerTarget {
    weak var target: NSObject?
    var targetSelector: Selector
    var timerRepeat: Bool = false
    
    init(realTarget: NSObject?, realSelector: Selector, timerRepeat: Bool) {
        self.target = realTarget
        self.targetSelector = realSelector
        self.timerRepeat = timerRepeat
    }
    
    @objc func timerDidFire(timer: NSTimer) {
        if let target = self.target {
            target.performSelector(self.targetSelector, withObject: timer)
        }
        if self.timerRepeat == false {
            timer.invalidate()
        }
    }
}
