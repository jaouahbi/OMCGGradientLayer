
import Foundation
import CoreGraphics

@objc public class OMGradient : NSObject
{
    private(set) var gradientCached  : CGGradientRef?
    
    var locations : [CGFloat]? {
        didSet { gradientCached = nil }
    }
    var colors: [CGColor] = [] {
        didSet { gradientCached = nil }
    }
    
    convenience init(colors:[CGColor], locations:[CGFloat]?) {
        self.init()
        self.colors = colors
        self.locations = locations
    }
    
    func getGradient() -> CGGradientRef? {
        
        var colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()!
        var numberOfComponents:Int   = 4 // RGBA
        var components:Array<CGFloat>?
        let numberOfLocations:Int
        
        if (colors.count > 0) {
            if let gradientCached = gradientCached {
#if DEBUG
                print("*** hit cached gradient")
#endif
                return gradientCached
            }
            if locations != nil {
                numberOfLocations = min(locations!.count, colors.count)
            } else {
                // If a nil array is given, the stops are assumed to spread uniformly across the [0,1] range
                numberOfLocations = colors.count
            }
            
            if (numberOfLocations > 0) {
                
                // analize one color
                let colorRef       = colors.first
                numberOfComponents = Int(CGColorGetNumberOfComponents(colorRef))
                colorSpace         = colorRef!.colorSpace
                
                if (numberOfComponents > 0) {
                    
                    components = [CGFloat](count: numberOfLocations * numberOfComponents, repeatedValue: 0.0)
                    
                    
                    for locationIndex in 0 ..< numberOfLocations {
                        let color = colors[locationIndex]
                        
                        assert(numberOfComponents == Int(CGColorGetNumberOfComponents(color)))
                        assert(CGColorSpaceGetModel(color.colorSpace) == CGColorSpaceGetModel(colorSpace));
                        
                        let colorComponents = CGColorGetComponents(color);
                        
                        for componentIndex in 0 ..< numberOfComponents {
                            components?[numberOfComponents * locationIndex + componentIndex] = colorComponents[componentIndex]
                        }
                    }
                    
                    //
                    // If locations is NULL, the first color in colors is assigned to location 0, the last color incolors is assigned
                    // to location 1, and intervening colors are assigned locations that are at equal intervals in between.
                    
                    if (locations != nil) {
                        
                        gradientCached = CGGradientCreateWithColorComponents(colorSpace,
                                                                            UnsafePointer<CGFloat>(components!),
                                                                            UnsafePointer<CGFloat>(locations!),
                                                                            numberOfLocations);
                    } else {
                        gradientCached = CGGradientCreateWithColorComponents(colorSpace,
                                                                            UnsafePointer<CGFloat>(components!),
                                                                            nil,
                                                                            numberOfLocations);
                    }
                    
                    return gradientCached;
                }
            }
        }
        
        return nil
    }
}

func ==(lhs: Array<CGColor>, rhs: Array<CGColor>) -> Bool {
    var equ = true
    if(lhs.count != rhs.count){
        return false;
    }
    for i in 0 ..< lhs.count {
        if(!CGColorEqualToColor(lhs[i],rhs[i])){
            equ = false
            break;
        }
    }
    return equ
}

func !=(lhs: Array<CGColor>, rhs: Array<CGColor>) -> Bool {
    return !(lhs == rhs);
}

