import UIKit

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
    
    @IBOutlet var colorSwitches: [UISwitch]!
    @IBOutlet var locationSliders: [UISlider]!
    @IBOutlet var locationSliderValueLabels: [UILabel]!
    
    @IBOutlet weak var extendsPastEnd: UISwitch!
    @IBOutlet weak var extendsPastStart: UISwitch!
    
    let gradientLayer = OMRadialGradientLayer(type: kOMGradientLayerRadial)
    var colors = [AnyObject]()
    let locations: [Float] = [0, 1/6.0, 1/3.0, 0.5, 2/3.0, 5/6.0, 1.0]
    
    var radius : Float = 0.0
    
    // MARK: - Quick reference
    
    func setUpColors() {
        colors = [cgColorForRed(209.0, green: 0.0, blue: 0.0),
            cgColorForRed(255.0, green: 102.0, blue: 34.0),
            cgColorForRed(255.0, green: 218.0, blue: 33.0),
            cgColorForRed(51.0, green: 221.0, blue: 0.0),
            cgColorForRed(17.0, green: 51.0, blue: 204.0),
            cgColorForRed(34.0, green: 0.0, blue: 102.0),
            cgColorForRed(51.0, green: 0.0, blue: 68.0)]
    }
    
    func setUpGradientLayer() {
        
        
        gradientLayer.frame     = viewForGradientLayer.bounds
        gradientLayer.colors    = colors
        gradientLayer.locations = locations
        
        let center = CGPoint(x: viewForGradientLayer.bounds.width * 0.5,
                             y: viewForGradientLayer.bounds.height * 0.5)
        
        centerStartX.value = Float(center.x)
        centerStartY.value = Float(center.y)
        
        centerEndX.value = Float(center.x)
        centerEndY.value = Float(center.y)
        
        gradientLayer.startCenter = center
        gradientLayer.endCenter   = center
    }
    
    func setUpLocationSliders() {
        let sliders = locationSliders
        
        for (index, slider) in sliders.enumerate() {
            slider.value = locations[index]
        }
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpColors()
        
        //viewForGradientLayer.backgroundColor = UIColor.blackColor()
        viewForGradientLayer.layer.borderWidth = 1.0
        viewForGradientLayer.layer.borderColor = UIColor.blackColor().CGColor

        viewForGradientLayer.layer.addSublayer(gradientLayer)

        setUpLocationSliders()
        updateLocationSliderValueLabels()
        extendsPastEnd.on   = (gradientLayer.options.rawValue & CGGradientDrawingOptions.DrawsAfterEndLocation.rawValue) != 0
        extendsPastStart.on = (gradientLayer.options.rawValue & CGGradientDrawingOptions.DrawsBeforeStartLocation.rawValue) != 0
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
            
            self.gradientLayer.frame = self.viewForGradientLayer.bounds
        }
    }
    
    func updateGradientLayer()
    {
        var startCenter:CGPoint  = CGPointZero;
        var endCenter:CGPoint    = CGPointZero;
        
        // radius
        self.radius = Float(min(viewForGradientLayer.bounds.height,viewForGradientLayer.bounds.width))
        
        gradientLayer.startRadius  = CGFloat(radius * startRadiusSlider.value)
        gradientLayer.endRadius    = CGFloat(radius * endRadiusSlider.value)
    
        startCenter = CGPoint(x:CGFloat(centerStartX.value),
                              y:CGFloat(centerStartY.value))
    
        endCenter = CGPoint(x:CGFloat(centerEndX.value),
                            y:CGFloat(centerEndY.value))
        
        gradientLayer.endCenter     = endCenter
        gradientLayer.startCenter   = startCenter
        
        print("Update  radial gradient : sc: \(startCenter) ec: \(endCenter) sr: \(gradientLayer.startRadius) er: \(gradientLayer.endRadius) b: \(viewForGradientLayer.bounds.integral) ms: \(radius)")
        
        gradientLayer.setNeedsDisplay();
        
        startCenterSliderValueLabel.text    = "\(centerStartX.value)\n\(centerStartY.value)"
        endCenterSliderValueLabel.text      = "\(centerEndX.value)\n\(centerEndY.value)"
        
        startRadiusSliderValueLabel.text = String(format: "%.1f", gradientLayer.startRadius)
        endRadiusSliderValueLabel.text   = String(format: "%.1f", gradientLayer.endRadius)
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
    
    @IBAction func typeSwitchChanged(sender: UISwitch) {
        
        gradientLayer.type = (sender.on) ? kOMGradientLayerOval : kOMGradientLayerRadial
        
        updateGradientLayer()
        gradientLayer.setNeedsDisplay();
        
    }
    @IBAction func colorSwitchChanged(sender: UISwitch) {
        var gradientLayerColors = [AnyObject]()
        var locations = [NSNumber]()
        
        for (index, colorSwitch) in colorSwitches.enumerate() {
            let slider = locationSliders[index]
            
            if colorSwitch.on {
                gradientLayerColors.append(colors[index])
                locations.append(NSNumber(float: slider.value))
                slider.hidden = false
            } else {
                slider.hidden = true
            }
        }
        
        if gradientLayerColors.count == 1 {
            gradientLayerColors.append(gradientLayerColors[0])
        }
        
        gradientLayer.colors = gradientLayerColors
        gradientLayer.locations = locations.count > 1 ? locations : nil
        updateLocationSliderValueLabels()
        
        updateGradientLayer()
    }
    
    @IBAction func locationSliderChanged(sender: UISlider) {
        var gradientLayerLocations = [NSNumber]()
        
        for (index, slider) in locationSliders.enumerate() {
            let colorSwitch = colorSwitches[index]
            
            if colorSwitch.on {
                gradientLayerLocations.append(NSNumber(float: slider.value))
            }
        }
        
        gradientLayer.locations = gradientLayerLocations
        updateLocationSliderValueLabels()
        
        updateGradientLayer()
    }
    
    // MARK: - Triggered actions
    
    func updateStartAndEndRadiusValueLabels() {
    }
    
    
    func updateStartAndEndCenterValueLabels() {
    }
    
    func updateLocationSliderValueLabels() {
        for (index, label) in locationSliderValueLabels.enumerate() {
            let colorSwitch = colorSwitches[index]
            
            if colorSwitch.on {
                let slider = locationSliders[index]
                label.text = String(format: "%.2f", slider.value)
                label.hidden = false
            } else {
                label.hidden = true
            }
        }
    }
    
    // MARK: - Helpers
    
    func cgColorForRed(red: CGFloat, green: CGFloat, blue: CGFloat) -> AnyObject {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0).CGColor as AnyObject
    }
    
}
