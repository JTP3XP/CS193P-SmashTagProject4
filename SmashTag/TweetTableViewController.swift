//
//  TweetTableViewController.swift
//  SmashTag
//
//  Created by John Patton on 4/13/17.
//  Copyright © 2017 JohnPattonXP. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    private var tweets = [[Tweet]]() {
        didSet {
            //print(tweets)
        }
    }
    
    var searchText: String? {
        didSet {
            searchTextField?.text = searchText
            searchTextField?.resignFirstResponder()
            lastTwitterRequest = nil
            tweets.removeAll()
            tableView.reloadData()
            addToSearchHistory()
            searchForTweets()
            title = searchText
        }
    }
    
    private func addToSearchHistory() {
        let searchHistoryMaxCount = 100
        let userDefaults = UserDefaults.standard
        let searchHistory = userDefaults.array(forKey: "SearchHistory") as? [String] ?? []
        if let searchText = searchText {
            // we want to append to the end even if it exists, but we filter it out first
            var updatedSearchHistory = searchHistory.filter({ $0.localizedCaseInsensitiveCompare(searchText) != .orderedSame })
            updatedSearchHistory = Array(updatedSearchHistory.suffix(searchHistoryMaxCount - 1))
            updatedSearchHistory.append(searchText)
            userDefaults.set(updatedSearchHistory, forKey: "SearchHistory")
            userDefaults.synchronize()
            print("\(userDefaults.array(forKey: "SearchHistory") as? [String] ?? ["Could not print search history"])")
        }
    }
    
    private func twitterRequest() -> Twitter.Request? {
        if let query = searchText, !query.isEmpty {
            return Twitter.Request(search: "\(query) -filter:safe -filter:retweets", count: 100)
        } else {
            return nil
        }
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    private func searchForTweets() {
        if let request = lastTwitterRequest?.newer ?? twitterRequest() {
            lastTwitterRequest = request
            request.fetchTweets { [weak self] newTweets in
                DispatchQueue.main.async {
                    if request == self?.lastTwitterRequest {
                        self?.tweets.insert(newTweets, at: 0)
                        self?.tableView.insertSections([0], with: .fade)
                    }
                    self?.refreshControl?.endRefreshing()
                }
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        searchForTweets()
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight // First estimate based on storyboard size
        tableView.rowHeight = UITableViewAutomaticDimension // Then autosize based on cell contents
    }
    
    // MARK: - Text Field Delegate
    
    // Set up the search text field at the top of the table
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            // sets the searchText var when user hits the return key on the keyboard
            searchText = searchTextField.text
        }
        return true
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet", for: indexPath)

        let tweet = tweets[indexPath.section][indexPath.row]
        
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let mentionViewController = self.storyboard!.instantiateViewController(withIdentifier: "MentionTableViewController") as? MentionTableViewController {
            
            mentionViewController.displayTweet = tweets[indexPath.section][indexPath.row]
            self.navigationController!.pushViewController(mentionViewController, animated: true)
            
        }
        
        
    }

    
}
