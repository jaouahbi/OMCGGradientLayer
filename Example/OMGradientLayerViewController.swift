import UIKit


let kDefaultAnimationDuration:TimeInterval = 5.0


/// Rainbow

extension UIColor
{
    /// Returns a array of the complete hue color spectre (0 - 360)
    ///
    /// - param: number of hue UIColor steps
    /// - param: start UIColor hue
    /// - returns: UIColor array
    
    
    class func rainbow(_ numberOfSteps:Int, hue:Double = 0.0) -> [UIColor]!{
        
        var colors:[UIColor] = []
        
        let iNumberOfSteps =  1.0 / Double(numberOfSteps)
        var hue:Double = hue
        while hue < 1.0 {
            if(colors.count == numberOfSteps){
                break
            }
            
            let color = UIColor(hue: CGFloat(hue),
                                saturation:CGFloat(1.0),
                                brightness:CGFloat(1.0),
                                alpha:CGFloat(1.0));
            
            colors.append(color)
            hue += iNumberOfSteps
        }
        
        // assert(colors.count == numberOfSteps, "Unexpected number of rainbow colors \(colors.count). Expecting \(numberOfSteps)")
        
        return colors
    }
}

class OMGradientLayerViewController : UIViewController {
    
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
    
    var colors      : [UIColor] = []
    let locations   : [CGFloat] = [0, 1/6.0, 1/3.0, 0.5, 2/3.0, 5/6.0, 1.0]
    
    let gradientLayer = OMCGGradientLayer(type: .radial)
    let shapeLayer    = CAShapeLayer()
    var animate       = false
    var animationDuration = kDefaultAnimationDuration
    
    // MARK: - Quick reference
    
    
    func setUpGradientLayer() {
        
        centerEndY.value            = 0.5
        centerStartY.value          = 0.5
        
        centerEndX.value            = 0.5
        centerStartX.value          = 0.5
        
        startRadiusSlider.value     = 1.0
        endRadiusSlider.value       = 0.0
        
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
    
    func randomShape(_ size : CGSize) -> CGPath? {
        func RandomFloat() -> CGFloat {return CGFloat(arc4random()) / CGFloat(UINT32_MAX)}
        func RandomPoint() -> CGPoint {return CGPoint(x: size.width * RandomFloat(), y: size.height * RandomFloat())}
        let path = UIBezierPath(); path.move(to: RandomPoint())
        for _ in 0..<(3 + Int(arc4random_uniform(numericCast(10)))) {
            switch (arc4random() % 3) {
            case 0: path.addLine(to: RandomPoint())
            case 1: path.addQuadCurve(to: RandomPoint(), controlPoint: RandomPoint())
            case 2: path.addCurve(to: RandomPoint(), controlPoint1: RandomPoint(), controlPoint2: RandomPoint())
            default: break;
            }
        }
        path.close()
        
        // maximize it
        
        let boundingBox = path.cgPath.boundingBox
        
        var affine  = CGAffineTransform(scaleX: size.width/boundingBox.size.width, y: size.height/boundingBox.size.height)
        
        return path.cgPath.copy(using: &affine)
    }
    
    func updateColorLabels()
    {
        for (index, color) in colors.enumerated() {
            self.colorLabels[index].layer.backgroundColor = color.cgColor
        }
    }
    
    
    func updateLocationSlidersFromLocations() {
        for (index, label) in locationSliderValueLabels.enumerated() {
            let colorSwitch = colorSwitches[index]
            if colorSwitch.isOn {
                let slider = locationSliders[index]
                slider.value = Float(locations[index])
                label.text   = String(format: "%.2f", slider.value)
                label.isHidden = false
            } else {
                label.isHidden = true
            }
        }
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLocationSlidersFromLocations()
        extendsPastEnd.isOn   = gradientLayer.extendsPastEnd
        extendsPastStart.isOn = gradientLayer.extendsBeforeStart
        
        self.colors =  UIColor.rainbow(7, hue:0).reversed()
        
        updateColorLabels()
        
        centerStartX.minimumValue   = 0
        centerStartX.maximumValue   = 1.0
        
        centerEndX.minimumValue     = 0
        centerEndX.maximumValue     = 1.0
        
        centerStartY.minimumValue   = 0
        centerStartY.maximumValue   = 1.0
        
        
        centerEndY.minimumValue     = 0
        centerEndY.maximumValue     = 1.0
        
        
        startRadiusSlider.minimumValue     = 0
        startRadiusSlider.maximumValue     = 1.0
        
        endRadiusSlider.minimumValue       = 0
        endRadiusSlider.maximumValue       = 1.0
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        setUpGradientLayer()
        updateGradientLayer()
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        coordinator.animate(alongsideTransition: {(UIViewControllerTransitionCoordinatorContext) in
            
        }) {(UIViewControllerTransitionCoordinatorContext) in
            // update the gradient layer frame
            self.gradientLayer.frame = self.viewForGradientLayer.bounds
        }
    }
    
    func updateGradientLayer()
    {
        viewForGradientLayer.layoutIfNeeded()
        
        let endRadius   = endRadiusSlider.value
        let startRadius = startRadiusSlider.value
        
        let startCenter = CGPoint(x:CGFloat(centerStartX.value),y:CGFloat(centerStartY.value))
        let endCenter   = CGPoint(x:CGFloat(centerEndX.value),y:CGFloat(centerEndY.value))
        
        #if DEBUG
            print("Update \(self.gradientLayer) gradient\n starCenter: \(startCenter)\n endCenter: \(endCenter)\n minRadius: \(startRadius)\nmaxRadius: \(endRadius)\n bounds: \(gradientLayer.bounds.integral)\n")
        #endif
        
        startCenterSliderValueLabel.text = String(format: "%.1f\n%.1f", centerEndX.value,centerEndY.value)
        endCenterSliderValueLabel.text   = String(format: "%.1f\n%.1f", centerStartX.value,centerStartY.value)
        
        startRadiusSliderValueLabel.text = String(format: "%.1f", startRadius)
        endRadiusSliderValueLabel.text   = String(format: "%.1f", endRadius)
        
        if (self.animate) {
            
            //allways remove all animations
            
            gradientLayer.removeAllAnimations()
            
            let mediaTime =  CACurrentMediaTime()
            CATransaction.begin()
            
            
            gradientLayer.animateKeyPath("startRadius",
                                         fromValue: Double(gradientLayer.startRadius) as AnyObject,
                                         toValue: startRadius as AnyObject,
                                         beginTime: mediaTime ,
                                         duration: animationDuration,
                                         delegate: nil)
            
            gradientLayer.animateKeyPath("endRadius",
                                         fromValue: Double(gradientLayer.endRadius) as AnyObject,
                                         toValue: endRadius as AnyObject?,
                                         beginTime: mediaTime,
                                         duration: animationDuration,
                                         delegate: nil)
            
            gradientLayer.animateKeyPath("startCenter",
                                         fromValue: NSValue(cgPoint: gradientLayer.startPoint),
                                         toValue: NSValue(cgPoint:startCenter),
                                         beginTime: mediaTime ,
                                         duration: animationDuration,
                                         delegate: nil)
            
            gradientLayer.animateKeyPath("endCenter",
                                         fromValue: NSValue(cgPoint:gradientLayer.endPoint),
                                         toValue: NSValue(cgPoint:endCenter),
                                         beginTime: mediaTime,
                                         duration: animationDuration,
                                         delegate: nil)
            
            gradientLayer.animateKeyPath("colors",
                                         fromValue:nil,
                                         toValue: colors as AnyObject,
                                         beginTime: mediaTime,
                                         duration: animationDuration,
                                         delegate: nil)
            
            gradientLayer.animateKeyPath("locations",
                                         fromValue:nil,
                                         toValue: locations as AnyObject,
                                         beginTime: mediaTime,
                                         duration: animationDuration,
                                         delegate: nil)
            CATransaction.commit()
            
        } else {
            
            gradientLayer.startPoint   =  startCenter
            gradientLayer.endPoint    =  endCenter
            //
            //            gradientLayer.colors        = self.colors
            //            gradientLayer.locations     = self.locations
            
            gradientLayer.startRadius   = CGFloat(startRadius)
            gradientLayer.endRadius     = CGFloat(endRadius)
            
            gradientLayer.setNeedsDisplay()
        }
    }
    
    @IBAction func extendsPastStartChanged(_ sender: UISwitch) {
        
        gradientLayer.extendsBeforeStart = sender.isOn
    }
    
    @IBAction func extendsPastEndChanged(_ sender: UISwitch) {
        
        gradientLayer.extendsPastEnd = sender.isOn
    }
    
    @IBAction func radialSliderChanged(_ sender: UISlider) {
        
        updateGradientLayer()
    }
    
    @IBAction func maskSwitchChanged(_ sender: UISwitch) {
        
        if (sender.isOn) {
            
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
    
    
    @IBAction func animateSwitchChanged(_ sender: UISwitch) {
        self.animate = sender.isOn;
        updateGradientLayer()
    }
    
    @IBAction func colorSwitchChanged(_ sender: UISwitch) {
        var gradientLayerColors:[UIColor] = []
        var locations:[CGFloat] = []
        
        for (index, colorSwitch) in colorSwitches.enumerated() {
            let slider = locationSliders[index]
            
            if colorSwitch.isOn {
                gradientLayerColors.append(colors[index])
                locations.append(CGFloat(slider.value))
                slider.isHidden = false
                colorLabels[index].isHidden = false;
            } else {
                slider.isHidden = true
                colorLabels[index].isHidden = true;
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
    
    @IBAction func locationSliderChanged(_ sender: UISlider) {
        var gradientLayerLocations = [CGFloat]()
        
        for (index, slider) in locationSliders.enumerated() {
            let colorSwitch = colorSwitches[index]
            
            if colorSwitch.isOn {
                gradientLayerLocations.append(CGFloat(slider.value))
            }
        }
        gradientLayer.locations = gradientLayerLocations
        updateLocationSlidersFromLocations()
        updateGradientLayer();
    }
    
    // MARK: - Triggered actions
    
    
    @IBAction func randomButtonTouchUpInside(_ sender: UIButton)
    {
        randomGardient()
    }
    
    func randomGardient()
    {
        endRadiusSlider.value   = Float(drand48())
        startRadiusSlider.value = Float(drand48())
        
        centerStartX.value = Float(drand48())
        centerStartY.value = Float(drand48())
        centerEndX.value   = Float(drand48())
        centerEndY.value   = Float(drand48())
        
        for (index, _) in locationSliders.enumerated() {
            
            if drand48() < 0.5 ? true : false {
                
                // random color
                
                let randomRed   = CGFloat(drand48())
                let randomGreen = CGFloat(drand48())
                let randomBlue  = CGFloat(drand48())
                //let randomAlpha = CGFloat(drand48())
                
                self.colors[index]  = UIColor(red  : randomRed,
                                              green: randomGreen,
                                              blue : randomBlue,
                                              //alpha: (randomAlpha != 0.0) ? randomAlpha : 1.0).CGColor
                    alpha: 1.0)
                
                // random  location
                locationSliders[index].value    = Float(drand48())
                locationSliders[index].isEnabled  = true
                colorSwitches[index].isOn         = true
                
            } else {
                locationSliders[index].isEnabled = false
                colorSwitches[index].isOn        = false
            }
        }
        
        updateColorLabels()
        
        // propage the changes
        for colorSwitch in colorSwitches {
            self.colorSwitchChanged(colorSwitch)
        }
        
    }
}
