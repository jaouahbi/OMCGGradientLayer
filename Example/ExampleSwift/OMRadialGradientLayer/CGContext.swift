////
////  CGContext+Gradient.swift
////  ExampleSwift
////
////  Created by Jorge on 14/4/16.
////  Copyright © 2016 Scott Gardner. All rights reserved.
////
//
//import CoreGraphics
//
//public extension CGContext {
//    
//    public func fill(style:Gradient?) -> Bool {
//        let frame = CGContextGetClipBoundingBox(self)
//        if style != nil && !frame.isEmpty {
//            var style = style!
//            if let cgGradient = style.getGradient() {
//                if style.axial {
//                    let mid = CGPoint(x: frame.size.width / 2,y: frame.size.height / 2)
//                    CGContextDrawRadialGradient(self,
//                                                cgGradient,
//                                                mid,
//                                                0,
//                                                mid,
//                                                max(frame.width, frame.height),
//                                                CGGradientDrawingOptions())
//                } else {
//                    
//                    let p1 = frame.origin + style.orientation!.0 * frame.size
//                    let p2 = frame.origin + style.orientation!.1 * frame.size
//                    CGContextDrawLinearGradient(self,
//                                                cgGradient,
//                                                p1,
//                                                p2,
//                                                CGGradientDrawingOptions())
//                }
//                return true
//            }
//        }
//        return false
//    }
//    
//    public func fillPath(style:Gradient?, path:CGPath?) -> Bool {
//        var ret = false
//        if style != nil && path != nil {//&& path!.isClosed {
//            CGContextSaveGState(self)
//            CGContextAddPath(self, path!)
//            CGContextClip(self)
//            ret = fill(style)
//            CGContextRestoreGState(self)
//        }
//        return ret
//    }
//    
//    public func fillEllipseInRect(style:Gradient?, rect:CGRect) -> Bool {
//        var ret = false
//        if style != nil {
//            CGContextSaveGState(self)
//            CGContextAddEllipseInRect(self, rect)
//            CGContextClip(self)
//            ret = fill(style)
//            CGContextRestoreGState(self)
//        }
//        return ret
//    }
//    
//}
