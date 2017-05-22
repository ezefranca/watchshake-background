//
//  InterfaceController.swift
//  WatchShake-Background WatchKit Extension
//
//  Created by Ezequiel on 21/05/17.
//  Copyright © 2017 Ezequiel. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    // MARK: Properties
    
    @IBOutlet var shakeDisplayLabel: WKInterfaceLabel!
    var shaker:WatchShaker = WatchShaker(shakeSensibility: .shakeSensibilityNormal, delay: 0.2)
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .long
        
        return formatter
    }()
    
    // MARK: WKInterfaceController
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        WKExtension.shared().delegate = self
        updateDateLabel()
    }
    
    override func willActivate() {
        
        super.willActivate()
        shaker.delegate = self
    }
    
    override func didDeactivate() {
        
        super.didDeactivate()
        shaker.stop()
        
    }
    
    
    // MARK: Snapshot and UI updating
    
    func scheduleSnapshot() {
        // fire now, we're ready
        let fireDate = Date()
        WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate: fireDate, userInfo: nil) { error in
            if (error == nil) {
                print("successfully scheduled snapshot.  All background work completed.")
            }
        }
    }
    
    func updateDateLabel() {
        let currentDate = Date()
        shakeDisplayLabel.setText(dateFormatter.string(from: currentDate))
    }
    
    
    // MARK: IB actions
    
    @IBAction func ScheduleRefreshButtonTapped() {
        // fire in 20 seconds
        let fireDate = Date(timeIntervalSinceNow: 20.0)
        // optional, any SecureCoding compliant data can be passed here
        let userInfo = ["reason" : "background update"] as NSDictionary
        
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: fireDate, userInfo: userInfo) { (error) in
            if (error == nil) {
                print("successfully scheduled background task, use the crown to send the app to the background and wait for handle:BackgroundTasks to fire.")
            }
        }
    }
    
}

extension InterfaceController: WKExtensionDelegate {
    
    // MARK: WKExtensionDelegate
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task : WKRefreshBackgroundTask in backgroundTasks {
            print("received background task: ", task)
            print(">>>>> teste funcionou colocar delegate <<<<")
            if (WKExtension.shared().applicationState == .background) {
                if task is WKApplicationRefreshBackgroundTask {
                    // this task is completed below, our app will then suspend while the download session runs
                    print("application task received, start shake")
                    shaker.start()
                }
            }
            else if task is WKURLSessionRefreshBackgroundTask {
                
                print("Rejoining")
            }
            
            task.setTaskCompleted()
        }
    }

    
}

extension InterfaceController: WatchShakerDelegate
{
    func watchShakerDidShake(_ watchShaker: WatchShaker) {
        print("YOU HAVE SHAKEN YOUR ⌚️⌚️⌚️")
    }
    
    func watchShaker(_ watchShaker: WatchShaker, didFailWith error: Error) {
        print(error.localizedDescription)
    }
}
