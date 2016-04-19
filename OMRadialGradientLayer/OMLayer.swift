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
//  OMLayer.swift
//
//  Created by Jorge Ouahbi on 26/3/15.
//
//  Description:
//  Derived CALayer class without implicit animations.


import UIKit

@objc class OMLayer : CALayer
{
    var maskingPath : CGPathRef?
    
    // angle in radians
    var angleOrientation : Double = 0.0 {
        didSet {
            self.transform = CATransform3DMakeRotation(CGFloat(angleOrientation), 0.0, 0.0, 1.0)
        }
    }
    
    override init() {
        
        super.init()
        
        self.contentsScale              = UIScreen.mainScreen().scale
        self.needsDisplayOnBoundsChange = true;
        
        // https://github.com/danielamitay/iOS-App-Performance-Cheatsheet/blob/master/QuartzCore.md
        
        //self.shouldRasterize = true
        self.drawsAsynchronously = true
        self.allowsGroupOpacity  = false
        
        #if DEBUG
            self.borderColor = UIColor.redColor().CGColor
            self.borderWidth = 5
        #endif
        
        // Disable animating view refreshes
        self.actions = [
            "position"      :    NSNull(),
            "bounds"        :    NSNull(),
            "contents"      :    NSNull(),
            "shadowColor"   :    NSNull(),
            "shadowOpacity" :    NSNull(),
            "shadowOffset"  :    NSNull() ,
            "shadowRadius"  :    NSNull()]
    }
    
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func flipContext(context:CGContext!) {
        assert(context != nil, "nil CGContext")
        CGContextTranslateCTM(context, 0, self.bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
    }
    
    // Sets the clipping path of the given graphics context to mask the content.
    func applyMaskToContext(context: CGContext!) {
        assert(context != nil, "nil CGContext")
        if let maskPath = self.maskingPath {
            CGContextAddPath(context, maskPath)
            CGContextClip(context);
        }
    }
    
    override func drawInContext(ctx: CGContext) {
        super.drawInContext(ctx);
        // Clear the layer
        CGContextClearRect(ctx, CGContextGetClipBoundingBox(ctx));
        if (!self.contentsAreFlipped()) {
           self.flipContext(ctx)
        }
        //applyMaskToContext(ctx)
    }
    
#if DEBUG
    override func display() {
        if (self.hidden) {
            print("[!] WARNING: hidden layer. \(self.name)")
        } else {
            if(self.bounds.isEmpty) {
                print("[!] WARNING: empty layer. \(self.name)")
            }else{
                super.display()
            }
        }
    }
#endif
}
