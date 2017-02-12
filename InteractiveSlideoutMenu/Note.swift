//
//  Note.swift
//  InteractiveSlideoutMenu
//
//  Created by Krysia O on 2/12/17.
//  Copyright © 2017 Thorn Technologies, LLC. All rights reserved.
//

import Foundation

struct Note : CustomStringConvertible {
    
    
    //MARK: - Parse
    
    static var list: [Note] = {
        let csv = Bundle.main.url(forResource: "Notes", withExtension: "csv")!
        let text = try! String(contentsOf: csv)
        let lines = text.components(separatedBy: "\r\n")
        
        
        var notes = [Note]()
        
        for line in lines {
            let split = line.components(separatedBy: ",")
            let name = split[0]
            let frequency = (split[1] as NSString).doubleValue
            
            func parsedNote(from nameString: String) -> Note {
                //note name is in format "D#0"
                var characters = nameString.characters.map { "\($0)" }
                let octave = (characters.popLast()! as NSString).integerValue
                let noteName = characters.reduce("", { partial, next in return partial + next })
                
                return Note(name: noteName, octave: octave, frequency: frequency)
            }
            
            // note name is either in format "C#0" or "D#0/Eb0"
            if name.contains("/") {
                let names = name.components(separatedBy: "/")
                for splitNoteName in names {
                    notes.append(parsedNote(from: splitNoteName))
                }
            }
                
            else {
                notes.append(parsedNote(from: name))
            }
            
        }
        
        return notes
    }()
    
    
    //MARK: - Detection
    
    static func possibleNotes(for frequency: Double) -> [Note] {
        let noteDistances = Note.list.map{ note -> (note: Note, distanceToFrequency: Double) in
            let distanceToFrequency = abs(note.frequency - frequency)
            return (note, distanceToFrequency)
        }
        
        let sortedNotes = noteDistances.sorted { note1, note2 in
            return note1.distanceToFrequency < note2.distanceToFrequency
        }
        
        let first = sortedNotes[0]
        let second = sortedNotes[1]
        
        //if the two notes are the same (ex: D# and Eb), return both
        if first.distanceToFrequency == second.distanceToFrequency {
            return [first.note, second.note]
        } else {
            return [first.note]
        }
    }
    
    
    //MARK: - Note Object
    
    let name: String
    let octave: Int
    let frequency: Double
    
    var description: String {
        return "\(name)"
    }
    
    
}
