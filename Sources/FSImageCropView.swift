//
//  FZImageCropView.swift
//  Fusuma
//
//  Created by Yuta Akizuki on 2015/11/16.
//  Copyright © 2015年 ytakzk. All rights reserved.
//

import UIKit
import Photos

final class FSImageCropView: UIScrollView {
    var imageView = UIImageView()
    var imageSize: CGSize?
    var image: UIImage! = nil {
        didSet {
            if image != nil {
                if imageView.isDescendant(of: self) == false {
                    self.imageView.alpha = 1.0
                    self.addSubview(imageView)
                }
            } else {
                imageView.image = nil
                return
            }

            if fusumaCropImage == false {
                // Disable scroll view and set image to fit in view
                imageView.frame = self.frame
                imageView.contentMode = .scaleAspectFit
                self.isUserInteractionEnabled = false

                imageView.image = image
                return
            }

            let imageSize = self.imageSize ?? image.size

            let ratioW = frame.width / imageSize.width // 400 / 1000 => 0.4
            let ratioH = frame.height / imageSize.height // 300 / 500 => 0.6

            if ratioH > ratioW {
                imageView.frame = CGRect(origin: CGPoint.zero,
                                         size: CGSize(width: imageSize.width  * ratioH,
                                                      height: frame.height)
                )
            } else {
                imageView.frame = CGRect(origin: CGPoint.zero,
                                         size: CGSize(width: frame.width,
                                                      height: imageSize.height  * ratioW)
                )
            }

            self.contentOffset = CGPoint(x: imageView.center.x - self.center.x,
                                         y: imageView.center.y - self.center.y)
            self.contentSize = CGSize(width: imageView.frame.width + 1,
                                      height: imageView.frame.height + 1)
            
            imageView.image = image
            
            self.zoomScale = 1.0
        }
    }
    
    func croppedImage(phAsset: PHAsset,
                      cropHeightRatio: CGFloat,
                      completion: @escaping ((_ video: AVAsset?, _ image: UIImage?) -> Void)) {
        let normalizedX = contentOffset.x / contentSize.width
        let normalizedY = contentOffset.y / contentSize.height
        let normalizedWidth = frame.width / contentSize.width
        let normalizedHeight = frame.height / contentSize.height
        let cropRect = CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)

        DispatchQueue.global(qos: .default).async(execute: {
            if phAsset.mediaType == .video {
                let options = PHVideoRequestOptions()
                options.version = .current
                
                PHImageManager.default()
                    .requestExportSession(forVideo: phAsset,
                                          options: options,
                                          exportPreset: AVAssetExportPresetPassthrough,
                                          resultHandler: { session, _ in
                                            completion(session?.asset, nil)
                })
            } else {
                let targetWidth = floor(CGFloat(phAsset.pixelWidth) * cropRect.width)
                let targetHeight = floor(CGFloat(phAsset.pixelHeight) * cropRect.height)
                let dimensionW = max(min(targetHeight, targetWidth), 1024 * UIScreen.main.scale)
                let dimensionH = dimensionW * cropHeightRatio
                let targetSize = CGSize(width: dimensionW, height: dimensionH)
                
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.isNetworkAccessAllowed = true
                options.normalizedCropRect = cropRect
                options.resizeMode = .exact

                PHImageManager.default()
                    .requestImage(for: phAsset,
                                  targetSize: targetSize,
                                  contentMode: .aspectFill,
                                  options: options,
                                  resultHandler: { result, _ in
                                    completion(nil, fusumaCropMode == .circle ? result?.cropCircle(size: targetSize)
                                                                              : result)
                })
            }
        })
    }

    func cropCircle(image: UIImage?, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: size))
        circlePath.addClip()
        
        var sharpRect = CGRect(origin: CGPoint.zero, size: size)
        sharpRect = sharpRect.integral

        image?.draw(in: sharpRect)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!

        self.frame.size      = CGSize.zero
        self.clipsToBounds   = true
        self.imageView.alpha = 0.0
        
        imageView.frame = CGRect(origin: CGPoint.zero, size: CGSize.zero)
        
        self.maximumZoomScale = 2.0
        self.minimumZoomScale = 0.8
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator   = false
        self.bouncesZoom = true
        self.bounces = true
        self.scrollsToTop = false
        
        self.delegate = self
    }
    
    func changeScrollable(_ isScrollable: Bool) {
        self.isScrollEnabled = isScrollable
    }
}

extension FSImageCropView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { return imageView }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.contentSize = CGSize(width: imageView.frame.width + 1, height: imageView.frame.height + 1)
    }
}
