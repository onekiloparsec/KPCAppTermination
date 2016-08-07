//
//  AppDelegate.swift
//  KPCAppTerminationDemo
//
//  Created by Cédric Foellmi on 07/08/16.
//  Copyright © 2016 onekiloparsec. All rights reserved.
//

import Cocoa
import KPCAppTermination

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let appTermination = AppTermination()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

