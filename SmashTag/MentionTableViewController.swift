//
//  MentionTableViewController.swift
//  SmashTag
//
//  Created by John Patton on 4/16/17.
//  Copyright © 2017 JohnPattonXP. All rights reserved.
//

import UIKit
import Twitter

class MentionTableViewController: UITableViewController {
    
    var displayTweet: Tweet?
    private var components = [[TweetComponent]]()

    enum TweetComponent {
        case mention(Mention)
        case image(MediaItem)
    }
    
    enum ComponentIndex: Int {
        case hashtags = 0, userMentions, urls, media
    }
    
    private let sectionHeaders: [Int: String] = [
        ComponentIndex.hashtags.rawValue: "Hashtags",
        ComponentIndex.userMentions.rawValue: "Users",
        ComponentIndex.urls.rawValue: "URLs",
        ComponentIndex.media.rawValue: "Images"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the row height to automatic so our image rows expand
        //tableView.estimatedRowHeight = 100
        //tableView.rowHeight = UITableViewAutomaticDimension

        // Break out tweets into compenents
        if let tweet = displayTweet {
            
            for _ in ComponentIndex.hashtags.rawValue...ComponentIndex.media.rawValue {
                // Set up the section arrays so we can append to them
                components.append([TweetComponent]())
            }
            
            for hashtag in tweet.hashtags {
                components[ComponentIndex.hashtags.rawValue].append(TweetComponent.mention(hashtag))
            }
            for userMention in tweet.userMentions {
                components[ComponentIndex.userMentions.rawValue].append(TweetComponent.mention(userMention))
            }
            for url in tweet.urls {
                components[ComponentIndex.urls.rawValue].append(TweetComponent.mention(url))
            }
            for mediaItem in tweet.media {
                components[ComponentIndex.media.rawValue].append(TweetComponent.image(mediaItem))
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return components.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return components[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tweetComponent = components[indexPath.section][indexPath.row]
        var reuseIdentifier: String
        
        switch tweetComponent {
        case .mention:
            reuseIdentifier = "Mention"
        case .image:
            reuseIdentifier = "TweetImage"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        switch tweetComponent {
        case .mention(let mention):
            cell.textLabel?.text = mention.keyword
        case .image(let image):
            if let cell = cell as? TweetImageTableViewCell {
                cell.tweetMediaItem = image
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if components[section].count > 0 {
            return sectionHeaders[section]
        } else {
            return nil
        }
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let tweetComponent = components[indexPath.section][indexPath.row]
        
        switch tweetComponent {
        case .mention:
            return UITableViewAutomaticDimension
        case .image(let mediaItem):
            return (view.frame.width+8) / CGFloat(mediaItem.aspectRatio)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let tweetComponent = components[indexPath.section][indexPath.row]
        var nextViewController: UIViewController?
        
        switch tweetComponent {
        case .mention(let mention):
            if indexPath.section == ComponentIndex.urls.rawValue {
                // User selected a URL - open in browser
                if let selectedURL = URL(string: mention.keyword) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(selectedURL)
                    } else {
                        UIApplication.shared.openURL(selectedURL)
                    }
                }
            } else {
                // User selected a username or hashtag - search for selection
                let tweetTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "TweetTableViewController") as! TweetTableViewController
                tweetTableViewController.searchText = mention.keyword
                nextViewController = tweetTableViewController
            }
        case .image(let mediaItem):
            // User clicked on an image - open in a scroll view
            let imageViewController = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
            imageViewController.imageURL = mediaItem.url
            nextViewController = imageViewController
        }
        
        if let navigationController = self.navigationController, nextViewController != nil {
            navigationController.pushViewController(nextViewController!, animated: true)
        }
        
    }

}
