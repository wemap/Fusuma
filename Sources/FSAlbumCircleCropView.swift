//
//  FSAlbumCircleCropView.swift
//  Fusuma
//
//  Created by Ilya Seliverstov on 01/09/2017.
//  Copyright © 2017 ytakzk. All rights reserved.
//

import UIKit

final class FSAlbumCircleCropView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOpaque = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isOpaque = false
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        UIColor.black.withAlphaComponent(0.65).setFill()
        UIRectFill(rect)
        
        // Draw the circle
        let circle = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: rect.size))
        context?.setBlendMode(.clear)
        UIColor.clear.setFill()
        circle.fill()
    }
    
    // Allow touches through the circle crop cutter view
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews
            .filter {
                $0.isHidden && $0.alpha > 0 && $0.isUserInteractionEnabled && $0.point(inside: convert(point, to: $0), with: event)
            }.first != nil
    }
}
