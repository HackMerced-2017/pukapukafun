//
//  ViewController.swift
//  AcessabilityScroller
//
//  Created by Craig on 2/11/17.
//  Copyright © 2017 Craig. All rights reserved.
//


import UIKit
import AudioKit

import Foundation

func matches(for regex: String, in text: String) -> [String] {
    
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let nsString = text as NSString
        let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        return results.map { nsString.substring(with: $0.range)}
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}


class LyricsViewController: UIViewController {
    
    
    //MARK: - Presentation
    
    static func present(from source: UIViewController, for id: Int) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "lyrics") as! LyricsViewController
        
        controller.songId = id
        
        source.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    //MARK: - Setup
    
    var songId: Int!
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.textView.text = "Loading lyrics..."
        
        // Song Identification
        // For testing purposes, 1024 is "Come Together" by the Beatles
        let songURL = URL(string: "http://api.guitarparty.com/v2/songs/\(1024)/")
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
                    
                    print(String(data: data!, encoding: .utf8))
                    
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: [.allowFragments]) as! [String:Any]
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
                    
                    DispatchQueue.main.sync {
                        self.textView.text = songBody
                        self.startListening()
                    }
                    
                    
                    
                } catch let error as NSError {
                    print(error)
                }
                
            }
        }.resume()

    }
    
    
    
    var noteArray = Array<[Note]!>(repeating: nil, count: 10)
    var songNotes = Array<String>()
    var microphoneNotes = Array<String>()
    @IBOutlet weak var textView: UITextView!
    var y = 0;
    let mic = AKMicrophone()
    
    var counter = 0;
    
    
    @IBAction func buttonPress(_ sender: Any) {
        UIView.animate(withDuration: 2.0, animations: {
            self.textView.contentOffset = CGPoint(x: 0, y: self.y)
        }, completion: nil)
        y += 10
        let yMax = self.textView.contentSize
        if(Int(yMax.height/1.5) < y){
            y -= 10
        }
    }
    
    func startScroll(_ animated: Bool)
    {
        songNotes = matches (for: "\\[[A-z0-9]{1,2}\\]", in: textView.text )
        for var j in songNotes {
            if( j.contains("m")){
                j = j.replacingOccurrences(of: "m", with: "")
            }
            else if (j.contains("7"))
            {
                j = j.replacingOccurrences(of: "7", with: "")
            }
            microphoneNotes.append(j)
        }
        
        print(microphoneNotes)
    }
    
    
    func startListening() {
        
        let tracker = AKFrequencyTracker(mic, hopSize: 20, peakCount: 2000)
        AudioKit.output = tracker
        AudioKit.start()
        
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true, block: { _ in
                let possibleNotes = Note.possibleNotes(for: tracker.frequency)
                print(possibleNotes)
                self.noteArray.removeLast()
                self.noteArray.insert(possibleNotes, at: 0)
                
                for i in self.microphoneNotes {
                    
                    if (i == possibleNotes.description)
                    {
                        self.buttonPress(self)
                    }
                }
                
                
            })
        } else {
            // Fallback on earlier versions
        }
        self.startScroll(true);
    }
    
    override func viewDidLoad() {
        super.loadView()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
