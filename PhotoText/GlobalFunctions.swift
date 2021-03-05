//
//  GlobalFunctions.swift
//  PhotoText
//
//  Created by Joshua Laurence on 08/10/2020.
//

import Foundation
import CoreData
import UIKit

class GlobalFunctions: NSObject {
    func fetchData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        request.returnsObjectsAsFaults = false
        var titleTemp = String()
        var contentTemp = String()
        var pinnedTemp = String()
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "title") as? String  {
                        titleTemp = title
                    }
                    if let content = result.value(forKey: "photoText") as? String {
                        contentTemp = content
                    }
                    if let pinned = result.value(forKey: "pinned") as? String {
                        pinnedTemp = pinned
                    }
                    Notes.append([titleTemp, contentTemp, pinnedTemp])
                }
            }
        } catch {
            print("Error")
        }
    }
    
    func saveData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let DelAllReqVarNote = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "Note"))
        do {
            try context.execute(DelAllReqVarNote)
        }
        catch {
            print(error)
        }
        
        for a in 0..<Notes.count {
            let newNote = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context)
            newNote.setValue(Notes[a][0], forKey: "title")
            newNote.setValue(Notes[a][1], forKey: "photoText")
            newNote.setValue(Notes[a][2], forKey: "pinned")
            
            do {
                try context.save()
            } catch {
                print("Error")
            }
        }
    }
}
