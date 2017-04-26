//
//  SearchHistoryTableViewController.swift
//  SmashTag
//
//  Created by John Patton on 4/23/17.
//  Copyright © 2017 JohnPattonXP. All rights reserved.
//

import UIKit

class SearchHistoryTableViewController: UITableViewController {

    private var searchHistory: [String]!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userDefaults = UserDefaults.standard
        if let savedSearchHistory = userDefaults.array(forKey: "SearchHistory") as? [String] {
            searchHistory = savedSearchHistory
        } else {
            searchHistory = []
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tweetTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "TweetTableViewController") as! TweetTableViewController
        tweetTableViewController.searchText = searchHistory[indexPath.row]
        
        if let navigationController = self.navigationController {
            navigationController.pushViewController(tweetTableViewController, animated: true)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistory.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchText", for: indexPath)
        cell.textLabel?.text = searchHistory[indexPath.row]
        return cell
    }
    

}
