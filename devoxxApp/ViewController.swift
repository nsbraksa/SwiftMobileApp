//
//  ViewController.swift
//  MDRotatingPieChart
//
//  Created by Maxime DAVID on 2015-04-03.
//  Copyright (c) 2015 Maxime DAVID. All rights reserved.
//

import UIKit
import CoreData



class ViewController: UIViewController, SelectionWheelDatasource, SelectionWheelDelegate {
    
    var slicesData:NSArray!
  
    let wheelView = SelectionWheel()
    
    var serviceGroup = dispatch_group_create()
    
    let color = UIColor(red: 255/255, green: 152/255, blue: 0/255, alpha: 1)
    let customTabController = UITabBarController()
    var currentSelectedIndex = 0
    var imgView:UIImageView!
    var numberView:HomeNumberView!
    var goView:HomeGoButtonView!
    var globeView:UIView!
    var eventLocation:UILabel!
    var rotating = false

    
  
    
    
    
    
    func run_on_background_thread(code: () -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), code)
    }
    
    func run_on_main_thread(code: () -> Void) {
        dispatch_async(dispatch_get_main_queue(), code)
    }
    
    

    
    func rotateOnce() {
        
        if self.globeView == nil {
            return
        }
      
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            options: .CurveLinear,
            animations: {
                self.globeView.transform = CGAffineTransformRotate(self.globeView.transform, 3.1415926)
            },
            completion: {finished in self.rotateAgain()})
    }
    
    func rotateAgain() {
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            options: .CurveLinear,
            animations: {
                                    self.globeView.transform = CGAffineTransformRotate(self.globeView.transform, 3.1415926)
            },
            completion: {finished in if self.rotating { self.rotateOnce() }})
    }
    
    

    
    func loadIsFinihsed() {
    
        
        
        
        let scheduleController = ScheduleController<SchedulerTableViewController<Talk>>()
        
        
        let trackController = TrackController<TrackTableViewController<Talk>>()
        
        let speakerController = SpeakerTableController()
        let mapController = MapTabController()
        let settingsController = SettingsController()
        
        let scheduleTabImage = UIImage(named: "tabIconSchedule.png")
        let trackTabImage = UIImage(named: "tabIconTracks.png")
        let speakerTabImage = UIImage(named: "tabIconSpeaker.png")
        let mapTabImage = UIImage(named: "tabIconMap.png")
        let settingsTabImage = UIImage(named: "tabIconSettings.png")
        
        scheduleController.tabBarItem = UITabBarItem(title: "Schedule", image: scheduleTabImage, tag:0)
        trackController.tabBarItem = UITabBarItem(title: "Tracks", image: trackTabImage, tag:1)
        speakerController.tabBarItem = UITabBarItem(title: "Speakers", image: speakerTabImage, tag:2)
        mapController.tabBarItem = UITabBarItem(title: "Map", image: mapTabImage, tag:3)
        settingsController.tabBarItem = UITabBarItem(title: "Settings", image: settingsTabImage, tag:4)
        
        //let scheduleNavigationController = UINavigationController(rootViewController: scheduleController)
        let speakerNavigationController = UINavigationController(rootViewController: speakerController)
        
        
        
        let settingsNavigationController = UINavigationController(rootViewController: settingsController)
        
        
        
        
        //let scroll = GenericPageScrollController<MapController>(generator:generate)
        
        let mapNavigationController = UINavigationController(rootViewController: mapController)
        
        
        self.customTabController.viewControllers = [scheduleController, trackController, speakerNavigationController, mapNavigationController, settingsNavigationController]
        self.customTabController.tabBar.translucent = false
        self.customTabController.view.backgroundColor = UIColor.whiteColor()
        //TODO BACK BUTTON
        //self.navigationController?.navigationBarHidden = false
        
        
        
        self.rotating = false
        
        self.customTabController.selectedIndex = 0
        
        self.navigationController?.pushViewController(self.customTabController, animated: true)
        
        self.showStaticView(false)
        
        self.addChildViewController(self.customTabController)
        self.view.addSubview(self.customTabController.view)
    
    }
    
    
    func fetchFirst() {
        print("enter fetch first")
        dispatch_group_enter(serviceGroup)
        
        self.updateIndex(self.currentSelectedIndex)
        
        APIDataManager.loadDataFromURL(CfpService.sharedInstance.getEntryPoint(), service: DayService.sharedInstance, helper : DayHelper(), isCritical : true, onSuccess: self.successGroup, onError: self.onError)
        
        dispatch_group_notify(serviceGroup,dispatch_get_main_queue(), {
            self.serviceGroup = dispatch_group_create()
            self.fetchSecond("GO")
        })
        
    }
    
    
    
    func fetchSecond(value : String) {
        
       
        
       
        //APIDataManager.updateCurrentEvent()
       
     
        
        
        //if APIManager.currentEvent!.days.count == 0 {
            //onError("toto")
            //return
        //}
        
        
        dispatch_group_enter(serviceGroup)
        dispatch_group_enter(serviceGroup)
        
        //dispatch_group_enter(serviceGroup)
      
        for _ in 0...(SlotService.sharedInstance.getCfp()?.days.count)!-1 {
            dispatch_group_enter(serviceGroup)
        }
        
        
        
        
        APIDataManager.loadDataFromURL(SpeakerService.sharedInstance.getSpeakerUrl(), service: SpeakerService.sharedInstance, helper : SpeakerHelper(), isCritical : true, onSuccess: self.successGroup, onError: self.onError)
        
        APIDataManager.loadDataFromURL(AttributeService.sharedInstance.getTracksUrl(), service: AttributeService.sharedInstance, helper : TrackHelper(), isCritical: true, onSuccess: self.successGroup, onError: onError)
        
        //APIDataManager.loadDataFromURL(AttributeService.sharedInstance.getTracksUrl(), service: AttributeService.sharedInstance, helper : TalkTypeHelper(), isCritical: true, onSuccess: self.successGroup, onError: onError)
               
        
        
        
        //print(APIManager.currentEvent.floors.count)
        
        
        
        
        
        
        
        APIDataManager.loadDataFromURLS(SlotService.sharedInstance.getCfp()?.days, dataHelper: SlotHelper(), isCritical : true, onSuccess: self.successGroup, onError: self.onError)
        
        dispatch_group_notify(serviceGroup,dispatch_get_main_queue(), {
                print("OK EVERYTHING IS LOADED FROM GROUP1")
                self.rotating = false
                self.loadIsFinihsed()
        })
    }
    
    func successGroup(ok : String) {
        print("block finished \(ok)")
        dispatch_group_leave(serviceGroup)
    }
    
  
    
    
    func prepareNext() {
        
       rotating = true
       rotateOnce()
        
        
        
        
        
        run_on_background_thread
            {
                
                
                
                
               
                self.fetchFirst()
                
                
                
                
                
                
                
                
               
                
                
                self.run_on_main_thread
                    {
                    self.rotateOnce()
                }
        }
        
        
        
        
        
        
        
        
        
        //selectedEvent
        

    }
    
    
    func onSuccess(value : String) {
      //  print("OnSucess = \(value)")
    }
    
    func onError(value : String) {
        
        showStaticView(false)
        
       // print("OnError = \(value)")
        
        if(APIManager.isCurrentEventEmpty()) {
            let alert = UIAlertController(title: "No data", message: "No data for this event, select Belgium to test", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Go", style: UIAlertActionStyle.Default, handler: nil))
            self.rotating = false
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
    }
    
    func showStaticView(show : Bool) {
        self.wheelView.userInteractionEnabled = !show
        self.goView.hidden = show
    }
    
    func remove() {
        customTabController.view.removeFromSuperview()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    let cfpService = CfpService.sharedInstance
    let storedResourceService = StoredResourceService.sharedInstance
    
    func loadWheel(msg : String) {
        print("cfp has been fed")
        cfpService.fetchCfps(callBack)
    }
    
    func callBack(cfps :[Cfp], error : CfpStoreError?) {
        slicesData = cfps
        
       
        
        wheelView.datasource = self
        wheelView.delegate = self

        shouldByPass()
        
        //wheelView.setup()
        //wheelView.click(0)
    }
    
    
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        
      

        APIManager.firstFeed(loadWheel, service: cfpService)
        
        
        
        
        
        imgView = UIImageView()
        imgView.contentMode = .ScaleAspectFit
        
        
        
        self.view.addSubview(imgView)
        
        let headerView = HomeHeaderView()
        
        goView = HomeGoButtonView()
        numberView = HomeNumberView()

        
        eventLocation = headerView.eventLocation
        
        self.showStaticView(true)
        
        view.addSubview(headerView)
        view.addSubview(wheelView)
        view.addSubview(goView)
        view.addSubview(numberView)
        
        
        let viewsDictionary = ["headerView":headerView, "wheelView":wheelView, "goView":goView, "numberView":numberView]
        
        let layout = NSLayoutFormatOptions(rawValue: 0)
        
        let horizontalContraint0:[NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[headerView]-0-|", options: layout, metrics: nil, views: viewsDictionary)
        let horizontalContraint1:[NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[wheelView]-0-|", options: layout, metrics: nil, views: viewsDictionary)
        let horizontalContraint2:[NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[goView]-0-|", options: layout, metrics: nil, views: viewsDictionary)
        let horizontalContraint3:[NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[numberView]-0-|", options: layout, metrics: nil, views: viewsDictionary)
        
        
        let v1 = NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: 0.15, constant: 0)
        let v2 = NSLayoutConstraint(item: wheelView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: 0.6, constant: 0)
        let v3 = NSLayoutConstraint(item: goView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: 0.1, constant: 0)
        let v4 = NSLayoutConstraint(item: numberView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Height, multiplier: 0.15, constant: 0)
      
        
        let verticalContraint:[NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[headerView]-0-[wheelView]-0-[goView]-0-[numberView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        
        
        self.view.addConstraints(horizontalContraint0)
        self.view.addConstraints(horizontalContraint1)
        self.view.addConstraints(horizontalContraint2)
        self.view.addConstraints(horizontalContraint3)
        
        self.view.addConstraints(verticalContraint)
        
        
        self.view.addConstraint(v1)
        self.view.addConstraint(v2)
        self.view.addConstraint(v3)
        self.view.addConstraint(v4)
        
    
        numberView.applyConstraint()
        
        
        
        
        
        
        
        
        
        
        
      //  wheelView.setConstraints()
        
               
        //wheelView.pieChart.datasource = self
        //wheelView.pieChart.delegate = self
        
        
        view.layoutIfNeeded()
        wheelView.layoutIfNeeded()
        
        
        
        
        
        
        
        
        
       
       // print(wheelView.pieChart.frame)
      //  let point = self.wheelView.convertPoint(wheelView.pieChart.center, toView: wheelView)
       // print(point)
       // let point2 = CGPointMake(point.x-wheelView.pieChart.frame.origin.x, point.y-wheelView.pieChart.frame.origin.y)
       // print(point2)
        
       // wheelView.pieChart.build(point2)
        
      

               
        goView.goButton.addTarget(self, action: Selector("prepareNext"), forControlEvents: .TouchUpInside)
        
        
        
        
        globeView = wheelView.globe
        
      

        goView.hidden = false
        
        
    }

    func shouldByPass() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        
        if let currentEventIndex = NSUserDefaults.standardUserDefaults().objectForKey("currentEvent") as? Int {
            if currentEventIndex == -1 {
                self.showStaticView(false)
                return
            }
            else {
                currentSelectedIndex = currentEventIndex
                prepareNext()
            }
        }
        else {
            self.showStaticView(false)
            defaults.setInteger(-1, forKey: "currentEvent")
            return
        }
    }
 
    
    //Delegate
    //some sample messages when actions are triggered (open/close slices)
    func didOpenSliceAtIndex(index: Int) {
      
    }
    
    func didCloseSliceAtIndex(index: Int) {
      
    }
    
    func willOpenSliceAtIndex(index: Int) {
        
        
    }
    
    func willCloseSliceAtIndex(index: Int) {
       
    }
    
    //Datasource
    func colorForSliceAtIndex(index:Int) -> UIColor {
        return color
    }
    
    func valueForSliceAtIndex(index:Int) -> CGFloat {
        return CGFloat(100/slicesData.count)
    }
    
    func labelForSliceAtIndex(index:Int) -> String {
        if let currentData = slicesData[index] as? EventProtocol {
            return currentData.title()
        }
        return ""
    }
    
    func imageForSliceAtIndex(index:Int) -> UIImage {
        if let currentData = slicesData[index] as? EventProtocol {
            return UIImage(named: currentData.splashImageName())!
        }
        //TODO
        return UIImage(named: "sample.png")!
    }
    
    func numberOfSlices() -> Int {
        return slicesData.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateIndex(index:Int) {
        currentSelectedIndex = index
        if let currentData = slicesData[index] as? EventProtocol {
            let img = UIImage(data: currentData.backgroundImage())
            let tmpImageView = UIImageView(image: img)
            imgView.image = img
            imgView.frame = tmpImageView.frame
            eventLocation.text = currentData.title()
            
            numberView.number1.text = currentData.daysLeft()
            numberView.number2.text = currentData.sessionsCount()
            numberView.number3.text = currentData.capacityCount()
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(currentData.identifier(), forKey: "currentEvent")
            
        }

    }
}


