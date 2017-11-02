//
//  UIImage+Extension.swift
//  Fusuma
//
//  Created by Ilya Seliverstov on 05/09/2017.
//  Copyright © 2017 ytakzk. All rights reserved.
//

import UIKit

extension UIImage {
    func cropCircle(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: size))
        circlePath.addClip()
        
        var sharpRect = CGRect(origin: CGPoint.zero, size: size)
        sharpRect = sharpRect.integral
        
        self.draw(in: sharpRect)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage
    }
}
