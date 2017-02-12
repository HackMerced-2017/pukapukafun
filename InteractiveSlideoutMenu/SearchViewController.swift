//
//  SearchViewController.swift
//  InteractiveSlideoutMenu
//
//  Created by Krysia O on 2/12/17.
//  Copyright © 2017 Thorn Technologies, LLC. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var userSearchLbl: UILabel!
    
    @IBOutlet weak var SongTableView: UITableView!
    
    var labelText: String = ""
    
    var songs: [(songName: String, id: Int)] = []
    
    override func viewDidLoad() {
        userSearchLbl.text = "Search results for: " + labelText
        getSearchQuery()
    }
   
    func getSearchQuery() {
        // Querying a search for songs -- can be any term (ex: "Come Together", "The Beatles", "Paul McCartney"
        let queryKeyword = labelText
        
        let queryURL = "http://api.guitarparty.com/v2/songs/?query=\(queryKeyword)".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let songURL = URL(string: queryURL!)
        print(queryURL!)
        var songRequest = URLRequest(url: songURL!)
        
        // HTTP Header details -- need credentials in order to access API, max of 150 queries/hr
        songRequest.addValue("fc4c39eed80dd0ccd18ebaf2dd43beba7ce26ef9", forHTTPHeaderField: "Guitarparty-Api-Key")
        let sharedSession = URLSession.shared
        
        
        // The actual query
        sharedSession.dataTask(with:songRequest) { (data, response, error) in
            if error != nil {
                print(error ?? "Error")
            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    
                    let songResults = parsedData["objects"] as! [[String: Any]]
                    
                    for result in songResults {
                        
                        let songId = result["id"] as! NSNumber
                        let songTitle = result["title"] as! String
                        
                        var songArtist = ""
                        var songArtistURL = URL(fileURLWithPath: "")
                        
                        
                        let authors = result["authors"] as! [[String: Any]]
                        for contributor in authors {
                            let types = contributor["types"] as! [String]
                            if types.contains("cover") {
                                songArtist = contributor["name"] as! String
                                let miniArtistURL = contributor["uri"] as! String
                                songArtistURL = URL(string: "http://api.guitarparty.com\(miniArtistURL)")!
                                break
                            }
                        }
                        
                        print(songId.intValue)
                        print(songTitle)
                        print(songArtist)
                        print(songArtistURL)
                        //self.insertNewObject(songTitle)
                        
                        DispatchQueue.main.sync {
                            
                            self.songs.append((songTitle, songId.intValue))
                            self.SongTableView.reloadData()
                        }
                        
                        
                    }
                    
                } catch let error as NSError {
                    print(error)
                }
            }
            
            }.resume()
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let (songName, _) = songs[indexPath.row]
        cell.textLabel?.text = songName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (songName, id) = self.songs[indexPath.item]
        
        print("USER SELECTED \(songName) - \(id)")
    }

}
    

