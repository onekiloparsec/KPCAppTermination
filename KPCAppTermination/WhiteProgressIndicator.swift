//
//  WhiteProgressIndicator.swift
//  KPCAppTermination
//
//  Created by Cédric Foellmi on 07/08/16.
//  Licensed under the MIT License (see LICENSE file)
//

import Cocoa
import QuartzCore

open class WhiteProgressIndicator: NSProgressIndicator {
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.makeItWhite()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.makeItWhite()
    }
    
    open func makeItWhite() {
        let lighten = CIFilter(name: "CIColorControls")!
        lighten.setDefaults()
        lighten.setValue(1, forKey: "inputBrightness")
        self.contentFilters = [lighten]
    }
}

