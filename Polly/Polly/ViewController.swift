//
//  ViewController.swift
//  Polly
//
//  Created by Taha Doğan Güneş on 17/06/15.
//  Copyright (c) 2015 Taha Doğan Güneş. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let cellIdentifier = "policyCell"
    
    let urlAttributes = [NSForegroundColorAttributeName: UIColor.grayColor(),  NSFontAttributeName: UIFont.italicSystemFontOfSize(13)]
    let nameAttributes = [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont.boldSystemFontOfSize(15)]

    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    var timer: Timer!
    var locationManager = CLLocationManager()
    var routerService = RouterService()
    var policyService = PolicyService()
    var beaconService = BeaconService()
    
    var areas:[Area] = [] //with policies
    // MARK: UIView functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpLocationServices()
        
        self.progressView.setProgress(0, animated: false)
        timer = Timer(interval: 2, operation: self.sendCurrentLocation, tickOperation: self.updateProgressBar)
        // timer.start()
        
        routerService.onSuccessCallback = self.onNewAreas
        beaconService.onSuccessCallback = self.onNewBeacons
        policyService.onSuccessCallback = self.onNewPolicies
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    
    // MARK: Policy Service Callback
    
    func onNewPolicies(areas:[Area]){
        self.areas = areas
        self.tableView.reloadData()
        self.progressLabel.text = "Succesfully got policies of this region"
        
    }
    
    
    // MARK: Beacon Service Callback
    
    func onNewBeacons(beacons:[Beacon]){
        println("Got \(beacons.count) beacon(s), registering...")
        
        self.progressLabel.text = "Got \(beacons.count) beacon(s), fetching policies..."
        sleep(1)
        if (beacons.count > 0) {
            policyService.closestBeaconUUID = beacons[0].uuid
        }
        
        policyService.setURL(beaconService.nkit.baseURL)
        policyService.fetchPolicies()
    }
    
    
    // MARK: Router Service Callback
    
    func onNewAreas(routedArea:Area) {


        self.timer.stop()
        self.progressLabel.text = "Fetching beacons from \(routedArea.name)"
        self.progressView.setProgress(0, animated: true)
        sleep(1)
        
        
        beaconService.setURL(routedArea.url)
        beaconService.fetchBeacons()
        
    }
    
    
    // MARK: Location Services
    
    func setUpLocationServices(){
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.startUpdatingLocation()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: Operations
    
    func updateProgressBar() {
        let timeLeft = self.timer.interval-self.timer.elapsedTime
        self.progressLabel.text = "Location update will be sent in \(timeLeft) seconds"
        self.progressView.setProgress(Float(timer.elapsedTime)/Float(timer.interval), animated: true)
    }
    
    func sendCurrentLocation() {
        self.progressLabel.text = "Sending current location"
        if let location = self.locationManager.location {
            routerService.sendLocation(location)
        }
        else {
            self.progressLabel.text = "LocationManager couldn't return a location"
        }
    }
    
    // MARK: User Interface callbacks
    @IBAction func refreshBarButtonTouched(sender: AnyObject) {
        self.progressLabel.text = "Continuous location updates are now enabled."
        self.timer.start()
    }
    
    @IBAction func stopBarButtonTouched(sender: AnyObject) {
        self.timer.stop()
        self.progressLabel.text = "Continuous location updates are disabled."
        self.progressView.setProgress(0, animated: true)
    }

    // MARK: TableView callbacks
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! UITableViewCell
        let area = self.areas[indexPath.section]
        let policy = area.policies[indexPath.row]
        cell.textLabel?.text = policy.text
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let area = self.areas[section]
        return "\(area.name) - \(area.url)"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let area = self.areas[section]
        return area.policies.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.areas.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let area = self.areas[section]

        let string = self.tableView(self.tableView, titleForHeaderInSection: section)! as NSString
        var attributedString = NSMutableAttributedString(string: string as String )
        
        attributedString.addAttributes(nameAttributes, range: string.rangeOfString(area.name))
        attributedString.addAttributes(urlAttributes, range: string.rangeOfString(area.url))

        
        var label = UILabel()
        label.frame = CGRectMake(20, 8, 320, 18)
        label.attributedText = attributedString
        var headerView = UIView()
        headerView.tintColor = UIColor(red: 189/255.0, green: 195/255.0, blue: 199/255.0, alpha: 1.0)
        headerView.addSubview(label)
        return headerView
    }
    

    
}