//
//  ViewController.swift
//  EventTimes
//
//  Created by Edward Martin on 05/11/2018.
//  Copyright © 2018 Edward Martin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

//----------------------------------------------------------------------------------------------
//                                     [[ GLOBAL PROPERTIES ]]
//------------------------------------------------------------------------------------------------
var chosenEvent = "READ001" // taken from previous page.
var dayOfView = "DAY001"
var stageCount:CGFloat? // used for width of sections D & C
var CDWidth:CGFloat?
var columnWidth = 150
var eventName = ""

class ViewController: UIViewController , UIScrollViewDelegate, UIScrollViewAccessibilityDelegate {
    
//----------------------------------------------------------------------------------------------
//                                     [[ OUTLET PROPERTIES ]]
//------------------------------------------------------------------------------------------------
    //A ---------- Title
    @IBOutlet weak var titleViewMain: UIView!
    @IBOutlet weak var eventTitle: UILabel!
    
    //B ---------- buyTickets
    @IBOutlet weak var buyTicketsScroll: UIScrollView!
    @IBOutlet weak var buyTicketsOutlet: UIButton!
    @IBAction func buyTickets(_ sender: Any) {
    }
    
    //C ---------- STAGES
    @IBOutlet weak var stageStack: UIStackView!
    @IBOutlet weak var scrollView2: UIScrollView!
    //D ---------- Timings
    @IBOutlet weak var timeStack: UIStackView!
    @IBOutlet weak var scrollView3: UIScrollView!
    //E ---------- PERFORMERS
    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var scrollView1: UIScrollView!
    //F ---------- Days
    @IBOutlet weak var dayScroll: UIScrollView!
    @IBOutlet weak var dayStack: UIStackView!
    
    //----------------------------------------------------------------------------------------------
//                                     [[ PROPERTIES ]]
//------------------------------------------------------------------------------------------------
    
    var stageRefInt = 1 // need this to incriment the Stage loop on [E] for the 'first' and 'last' data fetch
    var stageRef = "1" // need this to use within a Firebase Datafetch
    var mainStackSpacing = CGFloat(10)
    
    
    
//----------------------------------------------------------------------------------------------
//                                    [[ VIEW DID LOAD ]]
//----------------------------------------------------------------------------------------------

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        scrollView1.delegate  = self
        scrollView2.delegate  = self
        scrollView3.delegate  = self
        
        // This will make sure the stages and performers are the correct width (and the stack they are contained in will have the appropriate width to hold them (+200 pixels so you can scroll the furthest stage close to the times.
        getEventTitle()
        addTimes()
        showStages()
        insertStackViews()
        addDayButtons()
        resetFrames()
        makeThingsPretty()
        
    }
    
    
    
//----------------------------------------------------------------------------------------------
//                                    [[ FUNCTIONS ]]
//----------------------------------------------------------------------------------------------
    
    
    
    // ALL
    func makeThingsPretty() {
        
        // [A]
        self.titleViewMain.backgroundColor = UIColor.init(red: 216/255.0, green: 228/255.0, blue: 188/225.0, alpha:  1)
        
        // B
        self.buyTicketsOutlet.backgroundColor = UIColor.init(red: 196/255.0, green: 215/255.0, blue: 155/225.0, alpha:  1)
        self.buyTicketsOutlet.titleLabel?.textColor = .black
        self.buyTicketsOutlet.titleLabel?.textAlignment = .center
        
        
    }
    
    
    // [A] Need to do this
    func getEventTitle() {
        eventTitle.text = eventName
    }
    
    // [F] This will retrieve the Days of the festival from the DB, and create a button for each
    func addDayButtons () {
        
        var button:UIButton?
        
        var DBMain:DatabaseReference?
        
        DBMain = Database.database().reference().child("EVENTS").child("DAYS").child(chosenEvent)
        
        DBMain!.observe(DataEventType.childAdded, with: {(snapshot) in
            
            
            let something = snapshot.value as? [String: AnyObject]
            
            
              let code = something?["code"] as! String
              let date = something?["date"] as! String
            
            // convert date to date function
            let convertedDate = self.convertStringDateToStringDay(string: date)
            
            // create button
            let button = self.createDayButton(dayCode: code, date: convertedDate)
            // add button to view
            
            self.dayStack.addArrangedSubview(button)
        })
        
    }
    
    // [F] Button Template, maybe use the below
    
    func createDayButton (dayCode: String?, date:String?) -> UIButton {
        
        let button = DayButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(date, for: .normal) // sets title
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.dayRef = dayCode
        button.accessibilityLabel = dayCode // random String field i found....??
        button.addTarget(self, action: #selector(actionEd(_:)), for: .touchUpInside)
        button.backgroundColor = UIColor.init(red: 0/255.0, green: 32/255.0, blue: 96/225.0, alpha:  1)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15) // bold
        button.layer.cornerRadius = button.layer.frame.size.width / 2
        //then make a action method :
        
        return button
    }
    
    
    // [F] Function When Day Button clicked, need to reload view with other stages
    @IBAction func actionEd(_ sender:UIButton!) {
       
        var dayCode = sender.accessibilityLabel
        changeDay(string: dayCode!)
        
        
        for subview in mainStack.subviews {
            subview.removeFromSuperview()
        }
        
        self.stageRefInt = 1
        self.stageRef = "1"
        
        insertStackViews()
        
        
        
    }
    
    



    // [F] Change date
    func changeDay (string: String) {
        
        dayOfView = string
        print ("done")
      //  mainStack.subviews.forEach({ $0.removeFromSuperview() })

        
    }
    
    
    // [F] Converts 11.11.2018 to Thu or Fri or whatever it is
    func convertStringDateToStringDay(string:String) -> String {
        
        // Convert String to Date
        let dateBefore = string
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "dd.mm.yyyy"
        let dateAfter = dateFormatter1.date(from: dateBefore)
        
        
        // show date as
        let date = dateAfter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.mm.yyyy"
        dateFormatter.dateFormat = "EEE" // options here were"EEEE, MMMM dd, yyyy"
        let currentDateString: String = dateFormatter.string(from: date!)
      
        return currentDateString
    }
    
    
    // [E] 1 - Main
    
    func insertStackViews() {
        
        var DBRef:DatabaseReference?

        DBRef = Database.database().reference().child("EVENTS").child("LINEUP").child(chosenEvent).child(dayOfView)
        DBRef!.observe(DataEventType.value, with: { (snapshot) in
            
            // This will loop through the number of Stages available
            for item in snapshot.children.allObjects as! [DataSnapshot] {
             

                // i      // ADD A UI Stack View
                    
                var mainInnerStack = UIStackView()
                    mainInnerStack.widthAnchor.constraint(equalToConstant: CGFloat(columnWidth))
                    mainInnerStack.heightAnchor.constraint(equalToConstant: 1470)
                    mainInnerStack.axis = .vertical
                
                // ii    // Function to Create All Stage Buttons
               
                var button:UIButton?
                var DBMain:DatabaseReference?
                
                DBMain = Database.database().reference().child("EVENTS").child("LINEUP").child(chosenEvent).child(dayOfView).child(self.stageRef)
                
                DBMain!.observe(DataEventType.childAdded, with: {(snapshot) in

                    let something = snapshot.value! as? [String: AnyObject]
                    let name = something?["name"] as! String
                    let end = something?["end"] as! Int
                    let start = something?["start"] as! Int
        
                    button =  self.createMainButton(Performer: name, Start: start, End: end)
                    
                    mainInnerStack.addArrangedSubview(button!)
                  
                })
                
                // iii   // Append StackView to mainStack

                self.mainStack.addArrangedSubview(mainInnerStack)
                    
                // Incriment the Stage every time so we know which stage we're looking at!
                self.stageRefInt += 1
                self.stageRef = String(self.stageRefInt)
                
            }
        })
        
    }

    

    
    
    // [E]  iii - Create a Button, return it.
    
    func createMainButton(Performer:String, Start:Int, End:Int ) -> UIButton {   /// may need to change to UIInt

        // main button
        let button = UIButton()
        let buttonSize = CGFloat(End - Start) // calculated based on the pixels of the End and the Start (1 min = 1 pixel, 1470 pixels = minutes per day (-15 each side)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        button.setTitle(Performer, for: .normal) // sets title
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 0 // Dynamic number of lines
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.minimumScaleFactor = 1
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.backgroundColor = .clear
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.gray.cgColor
        button.backgroundColor = UIColor.init(red: 255/255.0, green: 242/255.0, blue: 204/225.0, alpha:  1)
        
        
        // no performer button (keep the text the same as it's used elsewhere)
        if Performer == "No Performer" {
            button.backgroundColor = .gray
            button.layer.cornerRadius = 0
            button.layer.borderWidth = 0
            button.setTitleColor(.gray, for: .normal)
        }
        else {
            button.backgroundColor = UIColor.init(red: 228/255.0, green: 223/255.0, blue: 236/225.0, alpha:  1)
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 0.5
        }
        
        return button
    
    }
    
    
    

    // [C] Loops through all items in the STAGE section of the DB for the Selected Event, then calls another Function which actually creates the button
    func showStages () {
        
        var DBRef:DatabaseReference?
        
        DBRef = Database.database().reference().child("EVENTS").child("STAGE").child(chosenEvent)
        DBRef!.observe(DataEventType.value, with: {(snapshot) in
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                
                var designType = "one"
                let stageName = item.value as? String
                let button = self.createEventTitleButton(stageName!,designType)
                
                self.stageStack.addArrangedSubview(button)
                // ERROR: This doesn't seem to work
                if designType == "one" {
                    designType = "two"
                } else {
                    designType = "one"
                }
                
                
            }
        })
        
    }
    
    // [C] This is where the button is created for the Stage Section
    func createEventTitleButton(_ label: String, _ type: String) -> UIButton {
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: CGFloat(columnWidth)).isActive = true
        button.setTitle(label, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor.init(red: 183/255.0, green: 205/255.0, blue: 220/225.0, alpha: 1)
        button.layer.borderColor = UIColor.gray.cgColor
        button.titleLabel?.lineBreakMode = .byWordWrapping // wrap text
        button.layer.cornerRadius = 5 // border edges
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15) // bold
        return button
    }
    
  

    
    
    // [D] Works with CreateTimeButtons
    func addTimes() {
        
        let timeButtonsArray = createTimeButtons("00:00 -","00:30 -","01:00 -","01:30 -","02:00 -","02:30 -","03:00 -","03:30 -","04:00 -","04:30 -","05:00 -","05:30 -","06:00 -","06:30 -","07:00 -","07:30 -","08:00 -","08:30 -","09:00 -","09:30 -","10:00 -","10:30 -","11:00 -","11:30 -","12:00 -","12:30 -","13:00 -","13:30 -","14:00 -","14:30 -","15:00 -","15:30 -","16:00 -","16:30 -","17:00 -","17:30 -","18:00 -","18:30 -","19:00 -","19:30 -","20:00 -","20:30 -","21:00 -","21:30 -","22:00 -","22:30 -","23:00 -","23:30 -","00:00 -")
        for button in timeButtonsArray {
            timeStack.addArrangedSubview(button)
        }
      
    }
    
    
    // [D] Function that Returns an Array of UI Buttons, thiis eill get added to addTimes()
    func createTimeButtons(_ named: String...) -> [UIButton] {
        
        return named.map { name in
            
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 30).isActive = true
            button.setTitle(name, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 12)
            return button
            
        }
    }
    
    
    // [C, D, E] Allows Symultanious Scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //Stop Scroll Views Bouncing (think it slows things down? could cause inaccuracies...
        scrollView1.bounces = false
        scrollView2.bounces = false
        scrollView3.bounces = false
        
        scrollView3.contentOffset.y = scrollView1.contentOffset.y
        scrollView2.contentOffset.x = scrollView1.contentOffset.x
        
    }
    
    //[C & D] Resize width based on stage count
    func resetFrames(){
        
        let DBRef:DatabaseReference?
        
        // Find Number of Stages
        DBRef = Database.database().reference().child("EVENTS").child("STAGE").child(chosenEvent)
        
        DBRef!.observe(DataEventType.value, with: {(snapshot) in
            
            
           
            
            stageCount = CGFloat(snapshot.childrenCount)
            // Each Stage takes 100 pixels, have to cast to a CGFloat to be used within Constraints
            CDWidth = CGFloat(stageCount! * CGFloat(columnWidth))
            
            
            // Add Stack Space
            self.mainStack.spacing = self.mainStackSpacing
            self.stageStack.spacing = self.mainStackSpacing
            let stackSpacing = (stageCount! - CGFloat(1)) * self.mainStackSpacing
            
            
            // [C & E] Stack Views width
            self.stageStack.widthAnchor.constraint(equalToConstant: CDWidth! + stackSpacing ).isActive = true
            self.mainStack.widthAnchor.constraint(equalToConstant: CDWidth! + stackSpacing ).isActive = true
            
            // [C & E ] Set Scrollable Size
            self.scrollView2.contentSize = CGSize(width: CDWidth! + 200 + stackSpacing, height: 0)
            self.scrollView1.contentSize = CGSize(width: CDWidth! + 200 + stackSpacing, height: 1470)
            
            
            // Sort Landscape View
            if UIDevice.current.orientation.isLandscape {
                
               // self.buyTicketsScroll.frame.size.height =
                self.buyTicketsScroll.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.1).isActive = true
                self.scrollView2.frame.size.height = self.view.frame.height * 0.1
                
            }
    
        })
    }
    
    
    
    
    
    
}

