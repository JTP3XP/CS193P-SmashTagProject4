//
//  TweetImageTableViewCell.swift
//  SmashTag
//
//  Created by John Patton on 4/19/17.
//  Copyright © 2017 JohnPattonXP. All rights reserved.
//

import UIKit
import Twitter

class TweetImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tweetImageView: UIImageView!
    
    var tweetMediaItem: MediaItem? { didSet { updateUI() } }
    
    func updateUI() {
        
        if let imageURL = tweetMediaItem?.url {
            let lastImageURL = imageURL
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: imageURL) {
                    DispatchQueue.main.async { [weak self] in
                        if imageURL == lastImageURL {
                            self?.tweetImageView.image = UIImage(data: imageData)
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.tweetImageView.image = nil
                    }
                }
            }
        }
    }
}
