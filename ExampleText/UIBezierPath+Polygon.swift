//
//  BezierPolygon.swift
//
//  Created by Jorge Ouahbi on 12/9/16.
//  Copyright © 2016 Jorge Ouahbi. All rights reserved.
//

// Based on Erica Sadun code
// https://gist.github.com/erica/c54826fd3411d6db053bfdfe1f64ab54

import UIKit

public enum PolygonStyle : Int { case flatsingle, flatdouble, curvesingle, curvedouble, flattruple, curvetruple }

public struct Bezier {
    
    static func polygon(
        sides sideCount: Int = 5,
        radius: CGFloat = 50.0,
        startAngle offset: CGFloat =  0.0,
        style: PolygonStyle = .curvesingle,
        percentInflection: CGFloat = 0.0) -> BezierPath
    {
        guard sideCount >= 3 else {
            OMLog.printe("Bezier polygon construction requires 3+ sides")
            return BezierPath()
        }
        
        func pointAt(_ theta: CGFloat, inflected: Bool = false, centered: Bool = false) -> CGPoint {
            let inflection = inflected ? percentInflection : 0.0
            let r = centered ? 0.0 : radius * (1.0 + inflection)
            return CGPoint(
                x: r * CGFloat(cos(theta)),
                y: r * CGFloat(sin(theta)))
        }
        
        let π = CGFloat(Double.pi); let 𝜏 = 2.0 * π
        let path = BezierPath()
        let dθ = 𝜏 / CGFloat(sideCount)
        
        path.move(to: pointAt(0.0 + offset))
        switch (percentInflection == 0.0, style) {
        case (true, _):
            for θ in stride(from: 0.0, through: 𝜏, by: dθ) {
                path.addLine(to: pointAt(θ + offset))
            }
        case (false, .curvesingle):
            let cpθ = dθ / 2.0
            for θ in stride(from: 0.0, to: 𝜏, by: dθ) {
                path.addQuadCurve(
                    to: pointAt(θ + dθ + offset),
                    controlPoint: pointAt(θ + cpθ + offset, inflected: true))
            }
        case (false, .flatsingle):
            let cpθ = dθ / 2.0
            for θ in stride(from: 0.0, to: 𝜏, by: dθ) {
                path.addLine(to: pointAt(θ + cpθ + offset, inflected: true))
                path.addLine(to: pointAt(θ + dθ + offset))
            }
        case (false, .curvedouble):
            let (cp1θ, cp2θ) = (dθ / 3.0, 2.0 * dθ / 3.0)
            for θ in stride(from: 0.0, to: 𝜏, by: dθ) {
                path.addCurve(
                    to: pointAt(θ + dθ + offset),
                    controlPoint1: pointAt(θ + cp1θ + offset, inflected: true),
                    controlPoint2: pointAt(θ + cp2θ + offset, inflected: true)
                )
            }
        case (false, .flatdouble):
            let (cp1θ, cp2θ) = (dθ / 3.0, 2.0 * dθ / 3.0)
            for θ in stride(from: 0.0, to: 𝜏, by: dθ) {
                path.addLine(to: pointAt(θ + cp1θ + offset, inflected: true))
                path.addLine(to: pointAt(θ + cp2θ + offset, inflected: true))
                path.addLine(to: pointAt(θ + dθ + offset))
            }
            
        case (false, .flattruple):
            let (cp1θ, cp2θ) = (dθ / 3.0, 2.0 * dθ / 3.0)
            for θ in stride(from: 0.0, to: 𝜏, by: dθ) {
                path.addLine(to: pointAt(θ + cp1θ + offset, inflected: true))
                path.addLine(to: pointAt(θ + dθ / 2.0 + offset, centered: true))
                path.addLine(to: pointAt(θ + cp2θ + offset, inflected: true))
                path.addLine(to: pointAt(θ + dθ + offset))
            }
        case (false, .curvetruple):
            let (cp1θ, cp2θ) = (dθ / 3.0, 2.0 * dθ / 3.0)
            for θ in stride(from: 0.0, to: 𝜏, by: dθ) {
                path.addQuadCurve(
                    to: pointAt(θ + dθ / 2.0 + offset, centered:true),
                    controlPoint: pointAt(θ + cp1θ + offset, inflected: true))
                path.addQuadCurve(
                    to: pointAt(θ + dθ + offset),
                    controlPoint: pointAt(θ + cp2θ + offset, inflected: true))
            }
        }
        
        path.close()
        return path
    }
}

extension UIBezierPath {
    
    public class func polygon(frame : CGRect,
                              sides: Int = 5,
                              radius: CGFloat = 50.0,
                              startAngle : CGFloat =  0.0,
                              style: PolygonStyle = .curvesingle,
                              percentInflection: CGFloat = 0.0) -> UIBezierPath
    {
        let bezier = Bezier.polygon(
            sides:sides,
            radius:radius,
            startAngle:startAngle,
            style: style,
            percentInflection:percentInflection)
        
        bezier.MovePathCenterToPoint(CGPoint(x:frame.midX,y:frame.midY));
        return bezier;
    }
}


func RectGetCenter(_ rect : CGRect)-> CGPoint
{
    return CGPoint(x:rect.midX, y:rect.midY);
}

func SizeScaleByFactor(_ aSize:CGSize,  factor:CGFloat) -> CGSize
{
    return CGSize(width:aSize.width * factor, height: aSize.height * factor);
}

func AspectScaleFit(_ sourceSize:CGSize,  destRect:CGRect) -> CGFloat
{
    let  destSize = destRect.size;
    let scaleW = destSize.width / sourceSize.width;
    let scaleH = destSize.height / sourceSize.height;
    return min(scaleW, scaleH);
}


func RectAroundCenter(_ center:CGPoint, size:CGSize) -> CGRect
{
    let halfWidth = size.width / 2.0;
    let halfHeight = size.height / 2.0;
    
    return CGRect(x:center.x - halfWidth, y:center.y - halfHeight, width:size.width, height:size.height);
}

func RectByFittingRect(sourceRect:CGRect, destinationRect:CGRect) -> CGRect
{
    let aspect = AspectScaleFit(sourceRect.size, destRect: destinationRect);
    let  targetSize = SizeScaleByFactor(sourceRect.size, factor: aspect);
    return RectAroundCenter(RectGetCenter(destinationRect), size: targetSize);
}

extension UIBezierPath
{
    func FitPathToRect( _ destRect:CGRect) {
        let bounds = self.boundingBox();
        let fitRect = RectByFittingRect(sourceRect: bounds, destinationRect: destRect);
        let scale = AspectScaleFit(bounds.size, destRect: destRect);
        
        let newCenter = RectGetCenter(fitRect);
        self.MovePathCenterToPoint(newCenter);
        self.ScalePath(sx: scale, sy:  scale);
    }
    
    func AdjustPathToRect( _ destRect:CGRect) {
        let bounds = self.boundingBox();
        let scaleX = destRect.size.width / bounds.size.width;
        let scaleY = destRect.size.height / bounds.size.height;
        
        let newCenter = CGPoint(x:destRect.midX,y:destRect.midY)
        self.MovePathCenterToPoint(newCenter);
        self.ScalePath(sx: scaleX, sy: scaleY);
    }
    
    func ApplyCenteredPathTransform(_ transform:CGAffineTransform) {
        let center = self.boundingBox().size.center()
        var t = CGAffineTransform.identity;
        t = t.translatedBy(x: center.x, y: center.y);
        t = transform.concatenating(t);
        t = t.translatedBy(x: -center.x, y: -center.y);
        self.apply(t);
    }
    
    class func PathByApplyingTransform( _ transform:CGAffineTransform) -> UIBezierPath {
        let copy = self.copy();
        (copy as! UIBezierPath).ApplyCenteredPathTransform(transform);
        return copy as! UIBezierPath;
    }
    
    func RotatePath(_ theta:CGFloat) {
        let t = CGAffineTransform(rotationAngle: theta);
        self.ApplyCenteredPathTransform(t);
    }
    
    func ScalePath( sx:CGFloat, sy:CGFloat) {
        let t = CGAffineTransform(scaleX: sx, y: sy);
        self.ApplyCenteredPathTransform( t);
    }
    
    func OffsetPath(_ offset:CGSize) {
        let t = CGAffineTransform(translationX: offset.width, y: offset.height);
        self.ApplyCenteredPathTransform( t);
    }
    
    func MovePathToPoint( _ destPoint:CGPoint) {
        let bounds = self.boundingBox()
        let p1 = bounds.origin;
        let p2 = destPoint;
        let vector = CGSize(width:p2.x - p1.x,
                            height:p2.y - p1.y);
        self.OffsetPath(vector);
    }
    
    func MovePathCenterToPoint(_ destPoint:CGPoint) {
        let bounds = self.boundingBox()
        let p1 = bounds.origin;
        let p2 = destPoint;
        var vector = CGSize(width:p2.x - p1.x, height:p2.y - p1.y);
        vector.width -= bounds.size.width / 2.0;
        vector.height -= bounds.size.height / 2.0;
        self.OffsetPath( vector);
    }
    
    func boundingBox() -> CGRect {
        return self.cgPath.boundingBox
    }
    
}
