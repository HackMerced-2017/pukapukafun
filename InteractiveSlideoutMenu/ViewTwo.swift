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
        
                
    }
    
}
