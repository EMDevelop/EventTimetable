//
//  LandingPageViewController.swift
//  EventTimes
//
//  Created by Edward Martin on 06/11/2018.
//  Copyright © 2018 Edward Martin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase



class LandingPageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var selectedItem = ""
    var eventTitles = [String] ()
    var filteredResults = [String]()
    var searching = false
    
    
//--------------------------------------------------------------------------------------------------
//                                     [[ OUTLET PROPERTIES ]]
//--------------------------------------------------------------------------------------------------
    

    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var eventSearchBar: UISearchBar!
    
    
//--------------------------------------------------------------------------------------------------
//                                     [[ View Did Load ]]
//--------------------------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        fetchTitles()
        eventTableView.reloadData()
        
    }
    
    
    
//--------------------------------------------------------------------------------------------------
//                                     [[ FUNCTIONS ]]
//--------------------------------------------------------------------------------------------------
    
    
    // Fetch Event Titles to display in Search
    func fetchTitles() {
        
    
        let DBRef:DatabaseReference?
        var emptyArray = [String]()
        
        DBRef = Database.database().reference().child("EVENTS").child("EVENTS")
        
        DBRef!.observe(DataEventType.childAdded, with: {(snapshot) in
            
            let something = snapshot.value! as? [String: AnyObject]
            
            let name = something?["name"] as! String
            
            emptyArray.append(name)
            
            self.eventTitles = emptyArray
            
            self.eventTableView.reloadData()
        
        })
        
    }

    
    
    // decides how many rows there are going to be
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // If Searching is true,show filtered results, else show all
        if searching {
            return filteredResults.count
        } else {
            return eventTitles.count
        }
        
    }
    
    // Decides what to display on each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = eventTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        // If Searching is true,show filtered results, else show all
        if searching {
            cell.textLabel!.text = filteredResults[indexPath.row]
        } else {
            cell.textLabel!.text = eventTitles[indexPath.row]
        }
        
        
        return cell
    }
    
    // Click on a Table View, this will send the other View Controller.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        
        selectedItem = String(eventTitles[indexPath.row])
        
        findEventCode(eventName: selectedItem)
        
        eventName = selectedItem
        dayOfView = "DAY001"
        
    }
    
    //find the code for the Chosen Event, set to chosenEvent Global.
    func findEventCode(eventName:String){
        
        print("Function Run")
        print(eventName)
        
        let nameIs = eventName
 
        var DBRef:DatabaseReference?
        
        DBRef = Database.database().reference().child("EVENTS").child("EVENTCODE").child(nameIs)
            
        DBRef!.observe(DataEventType.value, with: {(snapshot) in
            
            chosenEvent = snapshot.value as! String
            
        })

    }
    
    // Needed, this will instruct the view controller to reload when the text has changed, and also will turn 'searching' on, when searching is on, we'll see the filtered array and not the full Array.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        filteredResults = eventTitles.filter({$0.prefix(searchText.count).uppercased() == searchText.uppercased()})
        
        //Reload Table View
        searching = true
        eventTableView.reloadData()
    }
    
    // This will ensure the cancel button removes the text in the search bar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        eventTableView.reloadData()
    }
    
    
    
}






