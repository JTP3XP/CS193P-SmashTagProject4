//
//  ImageViewController.swift
//  SmashTag
//
//  Created by John Patton on 4/22/17.
//  Copyright © 2017 JohnPattonXP. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageURL: URL? {
        didSet {
            image = nil
            if view.window != nil { // only fetch if we are on screen
                fetchImage()
            }
        }
    }
    
    private func fetchImage () {
        if let url = imageURL {
            spinner.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url)
                
                // second condition here handles the case where multiple images are being fetched - ignore all but the current one
                if let imageData = urlContents, url == self?.imageURL {
                    DispatchQueue.main.async {
                        // back on the main thread because the setter for image will do UI stuff
                        self?.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
        
    }
    
    fileprivate var imageView = UIImageView() // fileprivate so we can use it in extension
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet{
            // Set up zooming functionality
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 2.0
            
            // Set size
            scrollView.contentSize = imageView.frame.size // change content size when the scroll view is created
            scrollView.addSubview(imageView)
        }
    }
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            // Optional chain because we can set the image before outlets are set
            scrollView?.contentSize = imageView.frame.size // change content size when the image changes
            spinner?.stopAnimating() // stopping here catches all cases where the image is set - optional because this will execute before outlets are set
            
            // Start with the image zoomed so that it fills width of screen
            if imageView.frame.size.width > 0, imageView.frame.size.height > 0 {
                let maxZoomToShowAllWidth = view.frame.size.width / imageView.frame.size.width
                scrollView?.zoomScale = maxZoomToShowAllWidth
            }
        }
    }

}

// MARK:- Extension for Scroll View Delegate Protocol

extension ImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
