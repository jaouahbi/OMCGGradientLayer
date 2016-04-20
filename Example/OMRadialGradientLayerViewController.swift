import UIKit


let kDefaultAnimationDuration:NSTimeInterval = 5.0


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

class OMRadialGradientLayerViewController : UIViewController {
    
    @IBOutlet weak var centerStartX:  UISlider!
    @IBOutlet weak var centerEndX:  UISlider!
    
    @IBOutlet weak var centerStartY:  UISlider!
    @IBOutlet weak var centerEndY:  UISlider!
    
    @IBOutlet weak var endCenterSliderValueLabel : UILabel!
    @IBOutlet weak var startCenterSliderValueLabel : UILabel!
    
    @IBOutlet weak var viewForGradientLayer: UIView!
    
    @IBOutlet weak var startRadiusSlider: UISlider!
    @IBOutlet weak var startRadiusSliderValueLabel: UILabel!
    @IBOutlet weak var endRadiusSlider: UISlider!
    @IBOutlet weak var endRadiusSliderValueLabel: UILabel!
    
    @IBOutlet var colorLabels: [UILabel]!
    @IBOutlet var colorSwitches: [UISwitch]!
    @IBOutlet var locationSliders: [UISlider]!
    @IBOutlet var locationSliderValueLabels: [UILabel]!
    
    @IBOutlet weak var extendsPastEnd: UISwitch!
    @IBOutlet weak var extendsPastStart: UISwitch!
    
    var colors      : [CGColor] = [CGColor]()
    let locations   : [CGFloat] = [0, 1/6.0, 1/3.0, 0.5, 2/3.0, 5/6.0, 1.0]
    
    let gradientLayer = OMRadialGradientLayer(type: kOMRadialGradientLayerRadial)
    let shapeLayer    = CAShapeLayer()
    var animate       = false
    
    // MARK: - Quick reference
    

    
    func setUpGradientLayer() {
        
        // default values
        let center = CGPoint(x: viewForGradientLayer.bounds.width * 0.5,
                             y: viewForGradientLayer.bounds.height * 0.5)
        
        centerStartX.value = Float(center.x)
        centerStartY.value = Float(center.y)
        
        centerEndX.value = Float(center.x)
        centerEndY.value = Float(center.y)
        
        gradientLayer.frame         = viewForGradientLayer.bounds
        gradientLayer.colors        = colors
        gradientLayer.locations     = locations

        viewForGradientLayer.layer.addSublayer(gradientLayer)
        
        #if DEBUG
            viewForGradientLayer.layer.borderWidth = 1.0
            viewForGradientLayer.layer.borderColor = UIColor.blackColor().CGColor
        #endif
        
    }
    
    // based on http://ericasadun.com/2015/05/15/swift-playground-hack-of-the-day/
    
    func randomShape(size : CGSize) -> CGPath? {
        func RandomFloat() -> CGFloat {return CGFloat(arc4random()) / CGFloat(UINT32_MAX)}
        func RandomPoint() -> CGPoint {return CGPointMake(size.width * RandomFloat(), size.height * RandomFloat())}
        let path = UIBezierPath(); path.moveToPoint(RandomPoint())
        for _ in 0..<(3 + Int(arc4random_uniform(numericCast(10)))) {
            switch (random() % 3) {
            case 0: path.addLineToPoint(RandomPoint())
            case 1: path.addQuadCurveToPoint(RandomPoint(), controlPoint: RandomPoint())
            case 2: path.addCurveToPoint(RandomPoint(), controlPoint1: RandomPoint(), controlPoint2: RandomPoint())
            default: break;
            }
        }
        path.closePath()
        
        // maximize it
        
        let boundingBox = CGPathGetBoundingBox(path.CGPath)
        
        var affine  = CGAffineTransformMakeScale(size.width/boundingBox.size.width, size.height/boundingBox.size.height)
        
        return CGPathCreateCopyByTransformingPath(path.CGPath, &affine)
    }

    func updateColorLabels()
    {
        for (index, color) in colors.enumerate() {
            self.colorLabels[index].layer.backgroundColor = color
        }
    }
    
    
    func updateLocationSlidersFromLocations() {
        for (index, label) in locationSliderValueLabels.enumerate() {
            let colorSwitch = colorSwitches[index]
            if colorSwitch.on {
                let slider = locationSliders[index]
                slider.value = Float(locations[index])
                label.text   = String(format: "%.2f", slider.value)
                label.hidden = false
            } else {
                label.hidden = true
            }
        }
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLocationSlidersFromLocations()
        extendsPastEnd.on   = (gradientLayer.options.rawValue & CGGradientDrawingOptions.DrawsAfterEndLocation.rawValue) != 0
        extendsPastStart.on = (gradientLayer.options.rawValue & CGGradientDrawingOptions.DrawsBeforeStartLocation.rawValue) != 0
        
        self.colors   =  CGColor.rainbow(7, hue:0).reverse()
        
        updateColorLabels()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        centerEndX.minimumValue     = 0
        centerStartX.minimumValue   = 0
        
        centerEndX.maximumValue     = Float(viewForGradientLayer.bounds.size.width * 0.5)
        centerStartX.maximumValue   = Float(viewForGradientLayer.bounds.size.width * 0.5)
        
        centerEndY.minimumValue     = 0
        centerStartY.minimumValue   = 0
        
        centerEndY.maximumValue     = Float(viewForGradientLayer.bounds.size.height * 0.5)
        centerStartY.maximumValue   = Float(viewForGradientLayer.bounds.size.height * 0.5)
        
        startRadiusSlider.value     = 0
        endRadiusSlider.value       = 1.0
        
        setUpGradientLayer()
        updateGradientLayer()
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
    {
        coordinator.animateAlongsideTransition({(UIViewControllerTransitionCoordinatorContext) in
            
        }) {(UIViewControllerTransitionCoordinatorContext) in
            // update the gradient layer frame
            self.gradientLayer.frame = self.viewForGradientLayer.bounds
        }
    }
    
    func updateGradientLayer()
    {
        viewForGradientLayer.layoutIfNeeded()
        
        let radius      = Float(min(viewForGradientLayer.bounds.height, viewForGradientLayer.bounds.width))
        
        let endRadius   = Double(radius * endRadiusSlider.value)
        let startRadius = Double(radius * startRadiusSlider.value)
        
        let startCenter = CGPoint(x:CGFloat(centerStartX.value),y:CGFloat(centerStartY.value))
        let endCenter   = CGPoint(x:CGFloat(centerEndX.value),y:CGFloat(centerEndY.value))
        
        #if DEBUG
            print("Update \(self.gradientLayer) gradient\n starCenter: \(startCenter)\n endCenter: \(endCenter)\n minRadius: \(startRadius)\nmaxRadius: \(endRadius)\n bounds: \(gradientLayer.bounds.integral)\n")
        #endif
        
        startCenterSliderValueLabel.text = "\(centerStartX.value)\n\(centerStartY.value)"
        endCenterSliderValueLabel.text   = "\(centerEndX.value)\n\(centerEndY.value)"
        
        startRadiusSliderValueLabel.text = String(format: "%.1f", startRadius)
        endRadiusSliderValueLabel.text   = String(format: "%.1f", endRadius)
    
        if (self.animate) {
            
            //allways remove all animations
            
            gradientLayer.removeAllAnimations()
            
            let mediaTime =  CACurrentMediaTime()
            CATransaction.begin()
            
            gradientLayer.animateKeyPath("startRadius",
                                         fromValue: Double(gradientLayer.startRadius),
                                         toValue: startRadius,
                                         beginTime: mediaTime ,
                                         duration: kDefaultAnimationDuration,
                                         delegate: nil)
            
            gradientLayer.animateKeyPath("endRadius",
                                         fromValue: Double(gradientLayer.endRadius),
                                         toValue: endRadius,
                                         beginTime: mediaTime,
                                         duration: kDefaultAnimationDuration,
                                         delegate: nil)
            
            gradientLayer.animateKeyPath("startCenter",
                                         fromValue: NSValue(CGPoint: gradientLayer.startCenter),
                                         toValue: NSValue(CGPoint:startCenter),
                                         beginTime: mediaTime ,
                                         duration: kDefaultAnimationDuration,
                                         delegate: nil)
            
            gradientLayer.animateKeyPath("endCenter",
                                         fromValue: NSValue(CGPoint:gradientLayer.endCenter),
                                         toValue: NSValue(CGPoint:endCenter),
                                         beginTime: mediaTime,
                                         duration: kDefaultAnimationDuration,
                                         delegate: nil)
            
            gradientLayer.animateKeyPath("colors",
                                         fromValue:nil,
                                         toValue: colors,
                                         beginTime: mediaTime,
                                         duration: kDefaultAnimationDuration,
                                         delegate: nil)
            
            gradientLayer.animateKeyPath("locations",
                                         fromValue:nil,
                                         toValue: locations.reverse(),
                                         beginTime: mediaTime,
                                         duration: kDefaultAnimationDuration,
                                         delegate: nil)
            CATransaction.commit()
            
        } else {
            
            gradientLayer.startCenter   =  startCenter
            gradientLayer.endCenter     =  endCenter
//            
//            gradientLayer.colors        = self.colors
//            gradientLayer.locations     = self.locations
            
            gradientLayer.startRadius   = CGFloat(startRadius)
            gradientLayer.endRadius     = CGFloat(endRadius)
            
            self.gradientLayer.setNeedsDisplay()
        }
    }
    
    @IBAction func extendsPastStartChanged(sender: UISwitch) {
        
        gradientLayer.extendsPastStart = sender.on
    }
    
    @IBAction func extendsPastEndChanged(sender: UISwitch) {
        
        gradientLayer.extendsPastEnd = sender.on
    }
    
    @IBAction func radialSliderChanged(sender: UISlider) {
        
        updateGradientLayer()
    }

    @IBAction func maskSwitchChanged(sender: UISwitch) {
        
        if (sender.on) {
            
            // mask with a random shape path
            
            shapeLayer.frame            = viewForGradientLayer.bounds
            shapeLayer.fillRule         = drand48() > 0.5 ? kCAFillRuleEvenOdd : kCAFillRuleNonZero
            shapeLayer.miterLimit       = 4.0
            shapeLayer.contentsScale    = gradientLayer.contentsScale
            shapeLayer.setAffineTransform(gradientLayer.affineTransform())
            shapeLayer.path             = randomShape(viewForGradientLayer.bounds.size)
            gradientLayer.mask          = shapeLayer
        } else {
            gradientLayer.mask          = nil
        }
        
        updateGradientLayer()
    }
    
    
    @IBAction func animateSwitchChanged(sender: UISwitch) {
        self.animate = sender.on;
        updateGradientLayer()
    }
    
    @IBAction func colorSwitchChanged(sender: UISwitch) {
        var gradientLayerColors = [CGColor]()
        var locations = [CGFloat]()
        
        for (index, colorSwitch) in colorSwitches.enumerate() {
            let slider = locationSliders[index]
            
            if colorSwitch.on {
                gradientLayerColors.append(colors[index])
                locations.append(CGFloat(slider.value))
                slider.hidden = false
                colorLabels[index].hidden = false;
            } else {
                slider.hidden = true
                colorLabels[index].hidden = true;
            }
        }
        
        if gradientLayerColors.count == 1 {
            gradientLayerColors.append(gradientLayerColors[0])
        }
        
        gradientLayer.colors    = gradientLayerColors
        gradientLayer.locations = locations.count > 1 ? locations : nil
        updateColorLabels()
        updateLocationSlidersFromLocations()
        updateGradientLayer();
    }
    
    @IBAction func locationSliderChanged(sender: UISlider) {
        var gradientLayerLocations = [CGFloat]()
        
        for (index, slider) in locationSliders.enumerate() {
            let colorSwitch = colorSwitches[index]
            
            if colorSwitch.on {
                gradientLayerLocations.append(CGFloat(slider.value))
            }
        }
        gradientLayer.locations = gradientLayerLocations
        updateLocationSlidersFromLocations()
        updateGradientLayer();
    }
    
    // MARK: - Triggered actions

    
    @IBAction func randomButtonTouchUpInside(sender: UIButton)
    {
        let maxSize = self.gradientLayer.bounds.size
        
        endRadiusSlider.value   = Float(drand48());
        startRadiusSlider.value = Float(drand48());
        
        centerStartX.value = Float( maxSize.width * CGFloat(drand48()))
        centerStartY.value = Float( maxSize.height * CGFloat(drand48()))
        centerEndX.value   = Float( maxSize.width * CGFloat(drand48()))
        centerEndY.value   = Float( maxSize.height * CGFloat(drand48()))
    
        for (index, _) in locationSliders.enumerate() {
    
            if (drand48() < 0.5 ? true : false) {
                
                // random color
                
                let randomRed   = CGFloat(drand48())
                let randomGreen = CGFloat(drand48())
                let randomBlue  = CGFloat(drand48())
                //let randomAlpha = CGFloat(drand48())
                
                self.colors[index]  = UIColor(red  : randomRed,
                                              green: randomGreen,
                                              blue : randomBlue,
                                              //alpha: (randomAlpha != 0.0) ? randomAlpha : 1.0).CGColor
                                              alpha: 1.0).CGColor
                
                // random  location
                locationSliders[index].value    = Float(drand48())
                locationSliders[index].enabled  = true
                colorSwitches[index].on         = true
                
            } else {
                locationSliders[index].enabled = false
                colorSwitches[index].on        = false
            }
        }
        
        updateColorLabels()
        
        // propage the changes
        for colorSwitch in colorSwitches {
            self.colorSwitchChanged(colorSwitch)
        }
    }
}
