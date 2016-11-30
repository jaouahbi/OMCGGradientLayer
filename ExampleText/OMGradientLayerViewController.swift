
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


import UIKit


class OMGradientLayerViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    let kDefaultCellFont = UIFont(name: "Helvetica", size: 9.0)
    let kDefaultAnimationDuration:TimeInterval = 5.0
    let kMinNumberOfColorsAndLocations:UInt32    = 2
    let kMaxNumberOfColorsAndLocations:UInt32    = 101
    
    
    @IBOutlet weak var tableViewColorsAndLocations:  UITableView!
    @IBOutlet weak var tableView:  UITableView!
    @IBOutlet weak var viewPanel:  UIView!
    
    @IBOutlet weak var pointStartX  :  UISlider!
    @IBOutlet weak var pointEndX    :  UISlider!
    
    @IBOutlet weak var pointStartY  :  UISlider!
    @IBOutlet weak var pointEndY    :  UISlider!
    
    @IBOutlet weak var endPointSliderValueLabel   : UILabel!
    @IBOutlet weak var startPointSliderValueLabel : UILabel!
    
    @IBOutlet weak var viewForShadingGradientLayer : UIView!
    @IBOutlet weak var viewForGradientLayer : UIView!
    
    @IBOutlet weak var startRadiusSlider    : UISlider!
    @IBOutlet weak var endRadiusSlider      : UISlider!
    
    @IBOutlet weak var startRadiusSliderValueLabel  : UILabel!
    @IBOutlet weak var endRadiusSliderValueLabel    : UILabel!
    
    @IBOutlet weak var typeGardientSwitch: UISwitch!
    @IBOutlet weak var typeFunctionSwitch: UISwitch!
    
    @IBOutlet weak var extendsPastEnd   : UISwitch!
    @IBOutlet weak var extendsPastStart : UISwitch!
    
    @IBOutlet weak var strokeSwitch   : UISwitch!
    @IBOutlet weak var pathSwitch     : UISwitch!
    
    var textLayer:OMTextLayer = OMTextLayer(string: "Core Graphics", font: UIFont(name: "Helvetica",size: 35)!)
    
    var colors      : [UIColor] = [UIColor]()
    var locations   : [CGFloat] = []
    
    var subviewForGradientLayer  : OMGradientView<OMCGGradientLayer>!
    var gradientLayer:OMCGGradientLayer = OMCGGradientLayer(type:.axial)
    
    var gradientAnimation = false
    
    
    lazy var slopeFunction: [(Double) -> Double] = {
        return [
            Linear,
            QuadraticEaseIn,
            QuadraticEaseOut,
            QuadraticEaseInOut,
            CubicEaseIn,
            CubicEaseOut,
            CubicEaseInOut,
            QuarticEaseIn,
            QuarticEaseOut,
            QuarticEaseInOut,
            QuinticEaseIn,
            QuinticEaseOut,
            QuinticEaseInOut,
            SineEaseIn,
            SineEaseOut,
            SineEaseInOut,
            CircularEaseIn,
            CircularEaseOut,
            CircularEaseInOut,
            ExponentialEaseIn,
            ExponentialEaseOut,
            ExponentialEaseInOut,
            ElasticEaseIn,
            ElasticEaseOut,
            ElasticEaseInOut,
            BackEaseIn,
            BackEaseOut,
            BackEaseInOut,
            BounceEaseIn,
            BounceEaseOut,
            BounceEaseInOut,
            ]
    }()
    
    lazy var slopeFunctionString:[String] = {
        return [
            "LinearInterpolation",
            "QuadraticEaseIn",
            "QuadraticEaseOut",
            "QuadraticEaseInOut",
            "CubicEaseIn",
            "CubicEaseOut",
            "CubicEaseInOut",
            "QuarticEaseIn",
            "QuarticEaseOut",
            "QuarticEaseInOut",
            "QuinticEaseIn",
            "QuinticEaseOut",
            "QuinticEaseInOut",
            "SineEaseIn",
            "SineEaseOut",
            "SineEaseInOut",
            "CircularEaseIn",
            "CircularEaseOut",
            "CircularEaseInOut",
            "ExponentialEaseIn",
            "ExponentialEaseOut",
            "ExponentialEaseInOut",
            "ElasticEaseIn",
            "ElasticEaseOut",
            "ElasticEaseInOut",
            "BackEaseIn",
            "BackEaseOut",
            "BackEaseInOut",
            "BounceEaseIn",
            "BounceEaseOut",
            "BounceEaseInOut",
            ]
    }()
    
    // MARK: - UITableView Helpers
    
    // select the row in the section of the tv
    func selectIndexPath(_ tableView:UITableView,row:Int, section:Int = 0) {
        let indexPath = IndexPath(item: row, section: section)
        tableView.selectRow(at: indexPath,animated: true,scrollPosition: .bottom)
    }
    
    func selectIndexPathAndUpdate(_ tableView:UITableView,row:Int, section:Int = 0) {
        let indexPath = IndexPath(item: row, section: section)
        tableView.selectRow(at: indexPath,animated: true,scrollPosition: .bottom)
    }
    
    var numberOfLocations : Int {
        return max(locations.count,colors.count)
    }
    // MARK: - UITableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.tableView == tableView) {
            return slopeFunction.count
        } else if(self.tableViewColorsAndLocations == tableView) {
            return numberOfLocations
        } else {
            assertionFailure()
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font          = kDefaultCellFont
        cell.layer.cornerRadius       = cell.bounds.size.height * 0.5
        cell.layer.masksToBounds      = true
        
        if (self.tableView == tableView) {
            cell.textLabel?.text  = "\(slopeFunctionString[(indexPath as NSIndexPath).row])"
        } else if(self.tableViewColorsAndLocations == tableView) {
            cell.textLabel?.text  = locations[(indexPath as NSIndexPath).row].format(false)
            let currentColor = colors[(indexPath as NSIndexPath).row]
            cell.selectedBackgroundView                  = UIView()
            cell.selectedBackgroundView!.backgroundColor = currentColor
            cell.contentView.backgroundColor             = currentColor
            cell.textLabel!.backgroundColor              = currentColor
            
        } else {
            assertionFailure()
        }
        return cell
    }
    // MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let i = indexPath.row
//        self.gradientLayer.slopeFunction = self.slopeFunction[i];
        if(tableView == self.tableView) {
            updateGradientLayer()
        }else if(tableView == tableViewColorsAndLocations){
            
        }
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subviewForGradientLayer  = OMGradientView<OMCGGradientLayer>(frame:viewForShadingGradientLayer.frame)
        
        viewForShadingGradientLayer.addSubview(subviewForGradientLayer)
        
        gradientLayer   = subviewForGradientLayer!.gradientLayer
        
        gradientLayer.addSublayer(textLayer)
        gradientLayer.mask = textLayer

        
        #if DEBUG_UI
            viewPanel.layer.borderColor = UIColor.lightGrayColor().CGColor
            viewPanel.layer.borderWidth = 1.0
        #endif
        
        randomizeColorsAndLocations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 2%
        textLayer.borderWidth = self.viewForShadingGradientLayer.bounds.width * 0.02
        
        
        pointStartX.maximumValue   = 1
        pointStartY.maximumValue   = 1
        
        pointEndX.maximumValue     = 1
        pointEndY.maximumValue     = 1
        
        pointStartX.minimumValue   = 0
        pointStartY.minimumValue   = 0
        
        pointEndX.minimumValue     = 0
        pointEndY.minimumValue     = 0
        
        let isAxial = gradientLayer.isAxial
        
        typeGardientSwitch.isOn  = !isAxial
        extendsPastEnd.isOn      = true
        extendsPastStart.isOn    = true
        
        setUpGradientPoints(isAxial)
        
        endRadiusSlider.maximumValue     = 1.0
        endRadiusSlider.minimumValue     = 0
        startRadiusSlider.maximumValue   = 1.0
        startRadiusSlider.minimumValue   = 0
        
        endRadiusSlider.value            = 1.0
        startRadiusSlider.value          = 0.0;
        
        // select the first element
        selectIndexPath(tableView, row: 0)
        selectIndexPath(tableViewColorsAndLocations, row: 0)
        
        
        // update the gradient layer frame
        self.gradientLayer.frame = self.viewForShadingGradientLayer.bounds
        
        // text layers
        self.textLayer.frame = self.viewForShadingGradientLayer.bounds
        
        #if DEBUG_UI
            viewForShadingGradientLayer.layer.borderWidth = 1.0
            viewForShadingGradientLayer.layer.borderColor = UIColor.blackColor().CGColor
            viewForGradientLayer.layer.borderWidth = 1.0
            viewForGradientLayer.layer.borderColor = UIColor.blackColor().CGColor
        #endif
        
        updateGardientLocationsString()
        updateGradientLayer()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator){
        coordinator.animate(alongsideTransition: {(UIViewControllerTransitionCoordinatorContext) in
        }) {(UIViewControllerTransitionCoordinatorContext) in
            // update the gradient layer frame
            self.gradientLayer.frame = self.viewForShadingGradientLayer.bounds

        }
    }
    
    // MARK: - Triggered actions
    @IBAction func extendsPastStartChanged(_ sender: UISwitch) {
        updateGradientLayer()
    }
    @IBAction func extendsPastEndChanged(_ sender: UISwitch) {
        updateGradientLayer();
    }
    @IBAction func gradientSliderChanged(_ sender: UISlider) {
        updateGardientLocationsString();
        updateGradientLayer();
    }
    @IBAction func strokeSwitchChanged(_ sender: UISwitch) {
        if ((gradientLayer.path) != nil) {
            gradientLayer.stroke = sender.isOn

        } else  {
            strokeSwitch.isOn = false;
        }
        updateGradientLayer()
    }
    @IBAction func maskSwitchChanged(_ sender: UISwitch) {
        if (sender.isOn) {
            
            let pathShading = UIBezierPath.polygon(frame: viewForShadingGradientLayer.bounds,
                                                   sides: Int(arc4random_uniform(32)) + 4,
                                                   radius:  CGFloat(drand48()) * viewForShadingGradientLayer.bounds.size.min(),
                                                   startAngle: 0 ,
                                                   style: PolygonStyle(rawValue:Int(arc4random_uniform(6)))!,
                                                   percentInflection: CGFloat(drand48()))
            
            
            gradientLayer.path  = pathShading.cgPath

            
        } else {
            gradientLayer.path  = nil
            
            strokeSwitch.isOn         = false;
        }
        updateGradientLayer()
    }
    
    @IBAction func typeSwitchChanged(_ sender: UISwitch) {
        setUpGradientPoints(sender.isOn == false)
        updateGradientLayer()
    }
    
    @IBAction func functionSwitchChanged(_ sender: UISwitch) {
        updateGradientLayer()
    }
    @IBAction func randomButtonTouchUpInside(_ sender: UIButton) {
        // random radius
        //        let radii  = radius(gradientLayer.bounds.size);
        
        //        endRadiusSlider.value   = Float(drand48()*Double(radii));
        //        startRadiusSlider.value = Float(drand48()*Double(radii));
        
        // random points
        pointStartX.value = Float(drand48())
        pointStartY.value = Float(drand48())
        pointEndX.value   = Float(drand48())
        pointEndY.value   = Float(drand48())
        
        // select random slope function
        // selectIndexPath(tableView,row:Int(rand()) % tableView.numberOfRowsInSection(0))
        
        // random colors
        randomizeColorsAndLocations()
        // update the UI
        updateGardientLocationsString();
        // update the gradient layer
        updateGradientLayer()
    }
    
    @IBAction func animateSwitchChanged(_ sender: UISwitch) {
        self.gradientAnimation = sender.isOn;
        updateGradientLayer()
    }
    
    @IBAction func maskTextSwitchChanged(_ sender: UISwitch) {
        
        if (sender.isOn) {
            gradientLayer.mask = textLayer
        } else {
            gradientLayer.mask = nil
            gradientLayer.addSublayer(textLayer)
        }
        updateGradientLayer()
    }
    
    func randomColorsAndLocations(_ numberOfElements:Int) -> ([UIColor],[CGFloat]) {
        
        var locations:[CGFloat] = []
        var colors:[UIColor] = []
        srand48(time(nil))
        var elements = numberOfElements
        for _ in 0 ..< elements {
            let newLocation = CGFloat(drand48())
            if(!locations.contains(newLocation)){
                locations.append(newLocation)
                colors.append(UIColor.random()!)
            } else {
                elements += 1
            }
        }
        locations.sort { $0 < $1 }
        
        return (colors,locations)
    }
    
    // MARK: - Helpers
    
    func randomizeColorsAndLocations() {
        
        let numberOfElements:Int = max(Int(arc4random() % kMaxNumberOfColorsAndLocations), Int(kMinNumberOfColorsAndLocations))
        
        let colorsAndLocations = randomColorsAndLocations(numberOfElements)
        self.colors            = colorsAndLocations.0
        self.locations         = colorsAndLocations.1
        
        self.gradientLayer.colors    = self.colors
        self.gradientLayer.locations = self.locations

        
        tableViewColorsAndLocations.reloadData()
        
        let currentIndex:Int = 0
        
        selectIndexPath(tableViewColorsAndLocations, row: currentIndex)
        
        //updateTextGradient()
        
    }
    
    func animateLayers() {
        // allways remove all animations
        gradientLayer.removeAllAnimations()

        
        CATransaction.setAnimationDuration(kDefaultAnimationDuration)
        let mediaTime =  CACurrentMediaTime()
        CATransaction.begin()
        // OMShadingGradientLayer
        let minRad = minRadius(gradientLayer.bounds.size)
        let rndStartRadius = CGFloat(drand48()) * minRad
        let rndEndRadius   = CGFloat(drand48()) * minRad
        let rndStartPoint  = CGPoint(x: drand48(),y: drand48())
        let rndEndPoint    = CGPoint(x: drand48(),y: drand48())
        
        let colorsAndLocations = randomColorsAndLocations(max(Int(arc4random() % kMaxNumberOfColorsAndLocations),
                                                              Int(kMinNumberOfColorsAndLocations)))
        
        //weak var delegate = self
        
        gradientLayer.animateKeyPath("startRadius",
                                         fromValue: nil,
                                         toValue: rndStartRadius as AnyObject?,
                                         beginTime: mediaTime ,
                                         duration: kDefaultAnimationDuration,
                                         delegate: nil)
        
        
        gradientLayer.animateKeyPath("endRadius",
                                         fromValue: nil,
                                         toValue: rndEndRadius as AnyObject?,
                                         beginTime: mediaTime,
                                         duration: kDefaultAnimationDuration,
                                         delegate: nil)
        
        
        gradientLayer.animateKeyPath("startPoint",
                                         fromValue: nil,
                                         toValue: NSValue(cgPoint:rndStartPoint),
                                         beginTime: mediaTime ,
                                         duration: kDefaultAnimationDuration,
                                         delegate: nil)
        
        gradientLayer.animateKeyPath("endPoint",
                                         fromValue: nil,
                                         toValue: NSValue(cgPoint:rndEndPoint),
                                         beginTime: mediaTime,
                                         duration: kDefaultAnimationDuration,
                                         delegate: nil)
        
        
        gradientLayer.animateKeyPath("colors",
                                         fromValue:nil,
                                         toValue: colorsAndLocations.0 as AnyObject?,
                                         beginTime: mediaTime,
                                         duration: kDefaultAnimationDuration,
                                         delegate: nil)
        
        gradientLayer.animateKeyPath("locations",
                                         fromValue:nil,
                                         toValue: colorsAndLocations.1 as AnyObject?,
                                         beginTime: mediaTime,
                                         duration: kDefaultAnimationDuration,
                                         delegate: nil)

        CATransaction.commit()
    }
    
    // get the values from the UI and update the gradient
    
    func updateGradientLayer()  {
        
        let axial = !typeGardientSwitch.isOn
        gradientLayer.gradientType       = axial ? .axial : .radial
        gradientLayer.extendsBeforeStart = extendsPastStart.isOn
        gradientLayer.extendsPastEnd     = extendsPastEnd.isOn
        //gradientLayer.function           = typeFunctionSwitch.isOn ? .exponential : .linear;
        //gradientLayer.slopeFunction      = self.slopeFunction[(self.tableView.indexPathForSelectedRow! as NSIndexPath).row] ;
        
        let endRadius:CGFloat   = CGFloat(endRadiusSlider.value)
        let startRadius:CGFloat = CGFloat(startRadiusSlider.value)
        
        let startPoint = CGPoint(x:CGFloat(pointStartX.value),y:CGFloat(pointStartY.value))
        let endPoint   = CGPoint(x:CGFloat(pointEndX.value),y:CGFloat(pointEndY.value))
        
        #if (DEBUG_VERBOSE)
            print("Updating \(typeGardientSwitch.on ? "radial" : "axial") gradient")
            print("Points : start \(startPoint)  end \(endPoint)")
            print("Radius : start \(startRadius) end \(endRadius)")
            print("Extend : start \((extendsPastStart.on ? "YES" : "NO")) end: \((extendsPastEnd.on ? "YES" : "NO"))")
            print("Function \(typeFunctionSwitch.on ? "exponential" : "linear")")
            print("Slope function: \(kEasingFunctions[tableView.indexPathForSelectedRow!.row].1)")
        #endif
        
        if (self.gradientAnimation) {
            
            animateLayers()
            
        } else {
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
        
            gradientLayer.startPoint  = startPoint;
            gradientLayer.endPoint    = endPoint;
            gradientLayer.startRadius = startRadius
            gradientLayer.endRadius   = endRadius
            
            CATransaction.setDisableActions(false)
            CATransaction.commit();
            
            gradientLayer.setNeedsDisplay()
        }
    }
    
    func updateGardientLocationsString() {
        
        // points text
        startPointSliderValueLabel.text = "x:\(pointStartX.value.format(true))\ny:\(pointStartY.value.format(true))"
        endPointSliderValueLabel.text   = "x:\(pointEndX.value.format(true))\ny:\(pointEndY.value.format(true))"
        
        //radius text
        startRadiusSliderValueLabel.text = Float(gradientLayer.startRadius).format(true)
        endRadiusSliderValueLabel.text   = Float(gradientLayer.endRadius).format(true)
    }
    
    
    func setUpGradientPoints(_ isAxial:Bool) {
        if (isAxial) {
            // axial
            pointStartX.value = 0.0
            pointStartY.value = 0.5
            pointEndX.value   = 1.0
            pointEndY.value   = 0.5
            
        } else {
            //radial
            //center
            pointStartX.value  = 0.5
            pointStartY.value  = 0.5
            pointEndX.value    = 0.5
            pointEndY.value    = 0.5
        }
    }
}
