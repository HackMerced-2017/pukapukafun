//
//  ViewTwo.swift
//  InteractiveSlideoutMenu
//
//  Created by Krysia O on 2/11/17.
//  Copyright © 2017 Thorn Technologies, LLC. All rights reserved.
//


import Foundation
import UIKit

class ViewTwo : UIViewController{
    

    
    @IBOutlet weak var chordsLyricsLbl: UILabel!
    
    @IBOutlet weak var userSongTitleLbl: UILabel!
    
    
    var LabelText = String()

    override func viewDidLoad() {
     super.viewDidLoad()
    }
    
    
    @IBAction func goSearchBtn(_ sender: UIButton) {
     
        
        chordsLyricsLbl.text = "hiii"
        
        // Song Identification
        // For testing purposes, 1024 is "Come Together" by the Beatles
        let songID = 1024
        let songURL = URL(string: "http://api.guitarparty.com/v2/songs/\(songID)/")
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
                     let songTitle = parsedData["title"] as! String
                     let songBody = parsedData["body"] as! String
                     var songArtist = ""
                     var songArtistURL = URL(fileURLWithPath: "")
                    
                
                    
                    // Getting the artist from an over-detailed list of authors
                    let authors = parsedData["authors"] as! [[String: Any]]
                    for contributor in authors {
                        let types = contributor["types"] as! [String]
                        if types.contains("cover") {
                            songArtist = contributor["name"] as! String
                            let miniArtistURL = contributor["uri"] as! String
                            songArtistURL = URL(string: "http://api.guitarparty.com\(miniArtistURL)")!
                            break
                        }
                    }
                    
                    
                    self.chordsLyricsLbl.text = songBody
                    self.userSongTitleLbl.text = songTitle + " by " + songArtist
                    
                
                    
                    print("THE SONG TITLE IS "+songTitle)
                    print(songArtist)
                    print(songArtistURL)
                    print(songBody)
                    
                    
                } catch let error as NSError {
                    print(error)
                }

            }
            }.resume()
        
    }
    
}
