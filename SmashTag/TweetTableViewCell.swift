//
//  TweetTableViewCell.swift
//  SmashTag
//
//  Created by John Patton on 4/14/17.
//  Copyright © 2017 JohnPattonXP. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    var tweet: Twitter.Tweet? { didSet { updateUI() } }
    
    private struct Colors {
        static let userMention = UIColor.gray
        static let hashtag = UIColor.red
        static let url = UIColor.blue
    }
    
    private func updateUI() {
        
        // Set user name
        tweetUserLabel?.text = tweet?.user.description
        
        // Set tweet text
        if let unformattedTweetText = tweet?.text {
            let formattedTweetText = NSMutableAttributedString(string: unformattedTweetText)
            if let hashtags = tweet?.hashtags {
                for hashtag in hashtags {
                    formattedTweetText.addAttributes([NSForegroundColorAttributeName: Colors.hashtag], range: hashtag.nsrange)
                }
            }
            if let urls = tweet?.urls {
                for url in urls {
                    formattedTweetText.addAttributes([NSForegroundColorAttributeName: Colors.url], range: url.nsrange)
                }
            }
            if let userMentions = tweet?.userMentions {
                for userMention in userMentions {
                    formattedTweetText.addAttributes([NSForegroundColorAttributeName: Colors.userMention], range: userMention.nsrange)
                }
            }
            
            tweetTextLabel?.attributedText = formattedTweetText
        } else {
            tweetTextLabel?.text = "Error displaying tweet"
        }
        
        // Set profile picture
        if let profileImageURL = tweet?.user.profileImageURL {
            let lastProfileImageURL = profileImageURL // store the URL so we can check if it is still the same before we update UI on main thread
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: profileImageURL) {
                    DispatchQueue.main.async { [weak self] in
                        if profileImageURL == lastProfileImageURL { // make sure we aren't coming back to a cell that got reused for another tweet before displaying result
                            self?.tweetProfileImageView?.image = UIImage(data: imageData)
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.tweetProfileImageView?.image = nil
                    }
                }
            }
        }
        
        // Set created time label
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel?.text = formatter.string(from: created)
        } else {
            tweetCreatedLabel?.text = nil
        }
    }
}
