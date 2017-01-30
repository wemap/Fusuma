//
//  FSAlbumViewCell.swift
//  Fusuma
//
//  Created by Yuta Akizuki on 2015/11/14.
//  Copyright © 2015年 ytakzk. All rights reserved.
//

import UIKit
import Photos

final class FSAlbumViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraView: UIImageView!
    
    var image: UIImage? {
        didSet {
            self.imageView.image = image            
        }
    }
    
    var type: PHAssetMediaType = .image {
        didSet {
            cameraView.isHidden = type == .video ? false : true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSelected = false
    }
    
    override var isSelected : Bool {
        didSet {
            self.layer.borderColor = isSelected ? fusumaTintColor.cgColor : UIColor.clear.cgColor
            self.layer.borderWidth = isSelected ? 2 : 0
        }
    }
}
