//
//  ViewController.swift
//  Spitfire
//
//  Created by seanmcneil on 08/17/2019.
//  Copyright (c) 2019 seanmcneil. All rights reserved.
//

import UIKit
import Photos

import Spitfire

class ViewController: UIViewController {
    lazy var spitfire: Spitfire = {
        return Spitfire(delegate: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createVideo()
    }
    
    func createVideo() {
        var images = [UIImage]()
        for _ in 0..<30 {
            let image = UIImage(named: "spitfire")!
            images.append(image)
        }
        spitfire.makeVideo(with: images,
                           fps: 30)
    }
}

extension ViewController: SpitfireDelegate {
    func videoProgress(progress: Progress) {
        let percent = (progress.fractionCompleted * 100).roundTo(places: 2)
        print("\(percent)%")
    }
    
    func videoCompleted(url: URL) {
        print(url)
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { saved, error in
            if saved {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: NSLocalizedString("Your video was saved", comment: ""), message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            } else if let error = error {
                print(error)
            }
        }

    }
    
    func videoFailed(error: SpitfireError) {
        print(error)
    }
}

extension Double {
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
