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
//  OMRadialGradientLayer.swift
//
//  Created by Jorge Ouahbi on 4/3/15.
//
//  0.1 (15-04-2015)
//      Now, all the properties are animatables.
//  0.2 (13-05-2015)
//      Added the oval type
//      Fixed error condition. When the locations count was less than the colors count.
//
//
import UIKit

// Animatable Properties

private struct OMRadialGradientLayerProperties {
    
    static var startCenter  = "startCenter"
    static var startRadius  = "startRadius"
    static var endCenter    = "endCenter"
    static var endRadius    = "endRadius"
    static var colors       = "colors"
    static var locations    = "locations"
};

let kOMRadialGradientLayerRadial: String  = "radial"
let kOMRadialGradientLayerOval: String    = "oval"

@objc class OMRadialGradientLayer : CALayer
{
    private(set) var gradient:OMGradient? = OMGradient()
    
    private var startCenterRatio : CGPoint = CGPointZero
    private var endCenterRatio   : CGPoint = CGPointZero
    
    private var startRadiusRatio : Double = 0
    private var endRadiusRatio   : Double = 0
    
    // The array of CGColorRef objects defining the color of each gradient
    // stop. Defaults to nil. Animatable.
    
    var colors: [CGColor] = [] {
        didSet {
            self.setNeedsDisplay()
        }
    }
    // An optional array of CGFloat objects defining the location of each
    // gradient stop as a value in the range [0,1]. The values must be
    // monotonically increasing. If a nil array is given, the stops are
    // assumed to spread uniformly across the [0,1] range. When rendered,
    // the colors are mapped to the output colorspace before being
    // interpolated. Defaults to nil. Animatable.
    
    var locations : [CGFloat]? = nil {
        didSet {
            self.setNeedsDisplay()
        }
    }
    // The kind of gradient that will be drawn. Default value is `radial'
    var type : String! = kOMRadialGradientLayerRadial {
        didSet {
            self.setNeedsDisplay();
        }
    }
    //Defaults to CGPointZero. Animatable.
    var startCenter: CGPoint = CGPointZero {
        didSet {
            startCenterRatio.x = startCenter.x / bounds.size.width;
            startCenterRatio.y = startCenter.y / bounds.size.height;
            self.setNeedsDisplay();
        }
    }
    //Defaults to CGPointZero. Animatable.
    var endCenter: CGPoint = CGPointZero {
        didSet{
            endCenterRatio.x = endCenter.x / bounds.size.width;
            endCenterRatio.y = endCenter.y / bounds.size.height;
            self.setNeedsDisplay();
        }
    }
    //Defaults to 0. Animatable.
    var startRadius: CGFloat = 0 {
        didSet {
            startRadiusRatio = Double(startRadius / min(bounds.size.height,bounds.size.width));
            self.setNeedsDisplay();
        }
    }
    //Defaults to 0. Animatable.
    var endRadius: CGFloat = 0 {
        didSet {
            endRadiusRatio = Double(endRadius / min(bounds.size.height,bounds.size.width));
            self.setNeedsDisplay();
        }
    }
    //Defaults to 0. Animatable.
    var options: CGGradientDrawingOptions = CGGradientDrawingOptions(rawValue:0) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var extendsPastStart : Bool  {
        set(newValue) {
            let isBitSet = (self.options.rawValue & CGGradientDrawingOptions.DrawsBeforeStartLocation.rawValue ) != 0
            if (newValue != isBitSet) {
                if newValue {
                    // add bits to mask
                    let newOptions = (self.options.rawValue | CGGradientDrawingOptions.DrawsBeforeStartLocation.rawValue)
                    self.options   = CGGradientDrawingOptions(rawValue:newOptions);
                } else {
                    // remove bits from mask
                    let newOptions  = (self.options.rawValue & ~CGGradientDrawingOptions.DrawsBeforeStartLocation.rawValue)
                    self.options    = CGGradientDrawingOptions(rawValue:newOptions);
                }
                self.setNeedsDisplay();
            }
        }
        get {
            return (self.options.rawValue & CGGradientDrawingOptions.DrawsBeforeStartLocation.rawValue) != 0
        }
    }
    
    var extendsPastEnd:Bool {
        set(newValue) {
            let isBitSet = (self.options.rawValue & CGGradientDrawingOptions.DrawsAfterEndLocation.rawValue ) != 0
            if (newValue != isBitSet) {
                if newValue {
                    let newOptions = (self.options.rawValue | CGGradientDrawingOptions.DrawsAfterEndLocation.rawValue)
                    self.options   = CGGradientDrawingOptions(rawValue:newOptions);
                } else {
                    let newOptions = (self.options.rawValue & ~CGGradientDrawingOptions.DrawsAfterEndLocation.rawValue)
                    self.options   = CGGradientDrawingOptions(rawValue:newOptions);
                }
                self.setNeedsDisplay();
            }
        }
        get {
            return (self.options.rawValue & CGGradientDrawingOptions.DrawsAfterEndLocation.rawValue) != 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    convenience init(type:String!) {
        self.init()
        self.type = type
    }
    
    // MARK: - Object Overrides
    
    override init() {
        super.init()
        self.allowsEdgeAntialiasing     = true
        self.contentsScale              = UIScreen.mainScreen().scale
        self.needsDisplayOnBoundsChange = true;
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
        if let other = layer as? OMRadialGradientLayer {
            
            // common
            self.colors      = other.colors
            self.locations   = other.locations
            self.type        = other.type
            
            // radial and oval
            self.startCenter = other.startCenter
            self.startRadius = other.startRadius
            self.endCenter   = other.endCenter
            self.endRadius   = other.endRadius
            self.options     = other.options
            self.gradient    = other.gradient
        }
    }
    
    override class func needsDisplayForKey(event: String) -> Bool {
        if (event == OMRadialGradientLayerProperties.startCenter ||
            event == OMRadialGradientLayerProperties.startRadius ||
            event == OMRadialGradientLayerProperties.locations   ||
            event == OMRadialGradientLayerProperties.colors      ||
            event == OMRadialGradientLayerProperties.endCenter   ||
            event == OMRadialGradientLayerProperties.endRadius) {
            return true
        }
        
        return super.needsDisplayForKey(event)
    }
    
    override func actionForKey(event: String) -> CAAction? {
        if (event == OMRadialGradientLayerProperties.startCenter ||
            event == OMRadialGradientLayerProperties.startRadius ||
            event == OMRadialGradientLayerProperties.locations   ||
            event == OMRadialGradientLayerProperties.colors      ||
            event == OMRadialGradientLayerProperties.endCenter   ||
            event == OMRadialGradientLayerProperties.endRadius) {
            return animationActionForKey(event);
            
        }
        return super.actionForKey(event)
    }
    
    override func drawInContext(ctx: CGContext) {
        
        super.drawInContext(ctx)
        
        var startCenter : CGPoint = CGPoint(x: bounds.size.width  * startCenterRatio.x, y: bounds.size.height * startCenterRatio.y)
        var endCenter   : CGPoint = CGPoint(x: bounds.size.width  * endCenterRatio.x, y: bounds.size.height * endCenterRatio.y);
        
        let minRadius = startRadius * CGFloat(startRadiusRatio);
        let maxRadius = endRadius   * CGFloat(endRadiusRatio);

        if let player = self.presentationLayer() as? OMRadialGradientLayer {
#if DEBUG
            print("drawing presentationLayer\n\(player)")
#endif
            self.gradient!.setColors(player.colors, withLocations: player.locations)
            
            startCenter   = player.startCenter
            endCenter     = player.endCenter
            startRadius   = player.startRadius
            endRadius     = player.endRadius
            
        } else {
            self.gradient!.setColors(self.colors, withLocations: self.locations)
        }
        
        if let gradient = self.gradient!.getGradient() {
            
            // Draw the radial gradient
            if (self.type == kOMRadialGradientLayerRadial) {
#if DEBUG
                print("Drawing \(self.type) gradient\nstarCenter: \(startCenter)\nendCenter: \(endCenter)\nminRadius: \(minRadius)\n maxRadius: \(maxRadius)\nbounds: \(self.bounds.integral)\nanchorPoint: \(self.anchorPoint)")
#endif
                
                CGContextDrawRadialGradient(ctx,
                                            gradient,
                                            startCenter,
                                            minRadius ,
                                            endCenter,
                                            maxRadius ,
                                            options);
                
            }
            //
            // TODO: remove this code and use a user supply transform for draw the gradient
            //
            else if( self.type == kOMRadialGradientLayerOval)
            {
                // Scaling transformation and keeping track of the inverse
                
                let scaleT    = CGAffineTransformMakeScale(2, 1.0);
                let invScaleT = CGAffineTransformInvert(scaleT);
                
                // Extract the Sx and Sy elements from the inverse matrix
                // (See the Quartz documentation for the math behind the matrices)
                let invS = CGPoint(x:invScaleT.a, y:invScaleT.d);
                
                
                // Transform center and radius of gradient with the inverse
                let ovalStartCenter = CGPointMake(startCenter.x * invS.x, startCenter.y * invS.y);
                let ovalEndCenter   = CGPointMake(endCenter.x   * invS.x, endCenter.y   * invS.y);
                let ovalStartRadius = minRadius * invS.x;
                let ovalEndRadius   = maxRadius * invS.x;
                
                // Draw the gradient with the scale transform on the context
                CGContextScaleCTM(ctx, scaleT.a, scaleT.d);
                CGContextDrawRadialGradient(ctx,
                                            gradient,
                                            ovalStartCenter,
                                            ovalStartRadius,
                                            ovalEndCenter,
                                            ovalEndRadius,
                                            options);
                
                // Reset the context
                CGContextScaleCTM(ctx, invS.x, invS.y);
            }
        }
    }
    
    override var description:String {
        
        get {
            var str:String = "type: \(self.type)"
            
            if (locations != nil) {
                str += "\(locations)"
            }
            
            if (colors.count > 0) {
                str += "\(colors)"
            }
            
            if (type == kOMRadialGradientLayerRadial || type == kOMRadialGradientLayerOval) {
                str += " center from : \(startCenter) to \(endCenter), radius from : \(startRadius) to \(endRadius)"
            }
            
            if  (self.extendsPastEnd)  {
                str += " draws after end location"
            }
            if  (self.extendsPastStart)  {
                str += " draws before start location"
            }
            return str
        }
    }
    
    // MARK: - Animation Helpers
    
    func animationActionForKey(event:String!) -> CABasicAnimation! {
        let animation = CABasicAnimation(keyPath: event)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fromValue = self.presentationLayer()!.valueForKey(event);
        return animation
    }
    
    func animateKeyPath(keyPath : String, fromValue : AnyObject?, toValue:AnyObject?, beginTime:NSTimeInterval, duration:NSTimeInterval, delegate:AnyObject?)
    {
        let animation = CABasicAnimation(keyPath:keyPath);
        
        var currentValue: AnyObject? = self.presentationLayer()?.valueForKey(keyPath)
        
        if (currentValue == nil) {
            currentValue = fromValue
        }
        
        animation.fromValue = currentValue
        animation.toValue   = toValue
        animation.delegate  = delegate
        
        if(duration > 0.0){
            animation.duration = duration
        }
        if(beginTime > 0.0){
            animation.beginTime = beginTime
        }
        
        animation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionLinear)
        animation.setValue(self,forKey:keyPath)
        
        self.addAnimation(animation, forKey:keyPath)
        
        self.setValue(toValue,forKey:keyPath)
    }
}
