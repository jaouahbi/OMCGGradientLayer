
//
//    Copyright 2015 - Jorge Ouahbi
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

//
//  CGColor.swift
//
//  Created by Jorge Ouahbi on 25/11/15.
//  Copyright © 2015 Jorge Ouahbi. All rights reserved.
//

import UIKit
import CoreGraphics

#if os(OSX)
import AppKit
#else
import UIKit
#endif

extension CGColor: CustomStringConvertible {
    public var description: String {
        return CFCopyDescription(self) as String
    }
}

public extension CGColor {
    public var alpha:CGFloat {
        return CGColorGetAlpha(self)
    }
}

public extension CGColor {
    func withAlpha(alpha:CGFloat) -> CGColor {
        return CGColorCreateCopyWithAlpha(self, alpha)!
    }
}

public extension CGColorSpace {
#if os(OSX)
    var name:String {
        return CGColorSpaceCopyName(self) as! String
    }
#endif
}

public extension CGColor {
    var colorSpace:CGColorSpaceRef {
        return CGColorGetColorSpace(self)!
    }
}

public extension CGColor {
    class func rainbow(numberOfSteps:Int, hue:Double = 0.0) ->  Array<CGColorRef>!{
        
        var colors:Array<CGColorRef> = []
        let iNumberOfSteps = (1.0 - hue) / Double(numberOfSteps)
        for (var hue:Double = hue; hue < 1.0; hue += iNumberOfSteps) {
            if(colors.count == numberOfSteps){
                break
            }
            #if os(OSX)
                lcolors.append(NSColor(hue: CGFloat(hue),
                                saturation:CGFloat(1.0),
                                brightness:CGFloat(1.0),
                                alpha:CGFloat(1.0)).CGColor)
            #else
                colors.append(UIColor(hue: CGFloat(hue),
                                    saturation:CGFloat(1.0),
                                    brightness:CGFloat(1.0),
                                    alpha:CGFloat(1.0)).CGColor)
                
            #endif
        }
        
        assert(colors.count == numberOfSteps,
               "Unexpected number of rainbow colors \(colors.count). Expecting \(numberOfSteps)")
        
        return colors
    }
}
