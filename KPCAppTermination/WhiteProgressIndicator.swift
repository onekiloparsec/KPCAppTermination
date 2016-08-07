//
//  WhiteProgressIndicator.swift
//  KPCAppTermination
//
//  Created by Cédric Foellmi on 07/08/16.
//  Copyright © 2016 onekiloparsec. All rights reserved.
//

import Cocoa
import QuartzCore

public class WhiteProgressIndicator: NSProgressIndicator {
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.makeItWhite()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.makeItWhite()
    }
    
    public func makeItWhite() {
        let lighten = CIFilter(name: "CIColorControls")!
        lighten.setDefaults()
        lighten.setValue(1, forKey: "inputBrightness")
        self.contentFilters = [lighten]
    }
}

