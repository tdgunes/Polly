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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    var timer: Timer!
    var locationManager = CLLocationManager()
    var routerService = RouterService()
    var areas:[Area] = []
    // MARK: UIView functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpLocationServices()
        
        self.progressView.setProgress(0, animated: false)
        timer = Timer(interval: 2, operation: self.sendCurrentLocation, tickOperation: self.updateProgressBar)
        // timer.start()
        
        routerService.onSuccessCallback = self.onNewAreas
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: Router Service Callback
    
    func onNewAreas(areas:[Area]) {
        self.areas = areas
        self.tableView.reloadData()
        self.timer.stop()
        self.progressLabel.text = "Fetching policies from polservers"
        self.progressView.setProgress(0, animated: true)
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
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let area = self.areas[section]
        return "\(area.name) - \(area.url)"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.areas.count
    }
}