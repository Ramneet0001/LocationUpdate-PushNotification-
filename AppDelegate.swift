//
//  AppDelegate.swift
//
//  Created by Ramneet Singh    ramneet0001@yahoo.com
//  Copyright © 2018 Ramneet Singh. All rights reserved.
//

import UIKit
import GoogleMaps
import UserNotifications

var User_Lat : String = ""
var User_Lng : String = ""

protocol UPDATED_CORE_LOCATION {
    func updatedCoreLocation(cllocation: CLLocationCoordinate2D)
}

protocol COUNTINUE_UPDATED_CORE_LOCATION {
    func countinueLocation(cllocation: CLLocationCoordinate2D)
}

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate  {
    
    var window: UIWindow?
    
    //MARK:- Locations variables
    var locationManager:CLLocationManager!
    var CLL_Delegate : UPDATED_CORE_LOCATION? = nil
    var CLL_COUN_Delegate : COUNTINUE_UPDATED_CORE_LOCATION? = nil
    
    class func getAppdelegate()->AppDelegate
    {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(5)
        
        setupLocationManager()
        
        registerForRemoteNotification()
        
        locationManager.startUpdatingLocation()
      
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        locationManager!.allowsBackgroundLocationUpdates = true
        locationManager!.pausesLocationUpdatesAutomatically = false
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        
        
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
       
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
       
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
      
    }
    
   
    //MARK:-  SetupLocationManager
    func setupLocationManager(){
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        self.locationManager?.requestAlwaysAuthorization()
        locationManager?.desiredAccuracy = kCLDistanceFilterNone
        locationManager?.startUpdatingLocation()
        
    }
    
    //MARK:-  SetupLocationManager
    func stopLocationManager(){
        
        locationManager?.stopUpdatingLocation()
    }
    
    
    //MARK:-  customNevigationBar
    func customNevigationBar(isHidden: Bool, statusBarColor: UIColor){
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = statusBarColor
        }
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        if isHidden == false{
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.white
            navigationBarAppearace.barTintColor = UIColor.navigation_Bar_Color()
            
            let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
            navigationBarAppearace.titleTextAttributes = textAttributes
        }
    }
    
}





// MARK: - CLLocationManagerDelegate
extension AppDelegate {
    // 2
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 3
        guard status == .authorizedWhenInUse else {
            return
        }
        locationManager.startUpdatingLocation()
        
    }
    
    // 6
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        CLL_Delegate?.updatedCoreLocation(cllocation: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        
        CLL_COUN_Delegate?.countinueLocation(cllocation: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        
        //My location
        let myLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        //My buddy's location
        var myBuddysLocation = CLLocation()
        
        if User_Lat != ""{
         myBuddysLocation = CLLocation(latitude: Double(User_Lat)!, longitude: Double(User_Lng)!)
        }
        else{
            User_Lat = "\(location.coordinate.latitude)"
            User_Lng = "\(location.coordinate.longitude)"
          
        myBuddysLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
        
        //Measuring my distance to my buddy's (in km)
        let distance = myLocation.distance(from: myBuddysLocation)
        print(distance)
        if distance >= 16  {
            User_Lat = "\(location.coordinate.latitude)"
            User_Lng = "\(location.coordinate.longitude)"
            
            if DataManager.user_id != nil {
            self.UpdateDriverLocation()
            }
        }
       
    }
    
    
    
  //MARK:-  UpdateDriverLocation
    func UpdateDriverLocation()  {
        
        
        
    }
    
    
    
     //MARK:-  fetch Country And City from coordinate
    func fetchCountryAndCity(location: CLLocation, completion: @escaping (String, String, String, String,String, String) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            print(placemarks as Any)
            if let error = error {
                print(error)
            } else if let country = placemarks?.first?.country,
                let city = placemarks?.first?.locality,
                let area = placemarks?.first?.isoCountryCode,
                let name = placemarks?.first?.name,
                let postalCode = placemarks?.first?.postalCode,
                let subAdministrativeArea = placemarks?.first?.subLocality{
                completion(country, city, area, name, postalCode,subAdministrativeArea)
            }
        }
    }
    
}
  //*******CLLocationManagerDelegate *********




// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
        func registerForRemoteNotification() {
            if #available(iOS 10.0, *) {
                let center  = UNUserNotificationCenter.current()
                center.delegate = self
                center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                    if error == nil{
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                }
            }
            else {
                UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    
    
        func deactivateForRemoteNotification() {
           if #available(iOS 10.0, *) {
                DispatchQueue.main.async {
                UIApplication.shared.unregisterForRemoteNotifications()
              }
            
           }  else {
            UIApplication.shared.unregisterForRemoteNotifications()
          }
        }
    
    
        func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
            let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
            print(deviceTokenString)
        }

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([UNNotificationPresentationOptions.alert,UNNotificationPresentationOptions.sound,UNNotificationPresentationOptions.badge])
        
    }

    
     func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let message = userInfo as NSDictionary
        print(message)
        
         if let value = message.value(forKey: "aps") as? NSDictionary{
            
            if let ride_id = value.value(forKey: "ride_id"){
             
                let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "LogInVc") as! LogInVc
                
                let navigationController = UINavigationController.init(rootViewController: initialViewControlleripad)
                navigationController.navigationBar.barTintColor = UIColor.black
                navigationController.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
                
                UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true, completion: nil)
                
                 }
                }
        
         }
    
    
    

//    func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
//        self.contentHandler = contentHandler
//        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
//
//        // if let bestAttemptContent = bestAttemptContent {
//        // Modify the notification content here...
//        // //bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
//
//        // //contentHandler(bestAttemptContent)
//
//        // Get the custom data from the notification payload
//        if let notificationData = request.content.userInfo["data"] as? [String: String] {
//            // Grab the attachment
//            if let urlString = notificationData["attachment-url"], let fileUrl = URL(string: urlString) {
//                // Download the attachment
//                URLSession.shared.downloadTask(with: fileUrl) { (location, response, error) in
//                    if let location = location {
//                        // Move temporary file to remove .tmp extension
//                        let tmpDirectory = NSTemporaryDirectory()
//                        let tmpFile = "file://".appending(tmpDirectory).appending(fileUrl.lastPathComponent)
//                        let tmpUrl = URL(string: tmpFile)!
//                        try! FileManager.default.moveItem(at: location, to: tmpUrl)
//
//                        // Add the attachment to the notification content
//                        if let attachment = try? UNNotificationAttachment(identifier: "", url: tmpUrl) {
//                            self.bestAttemptContent?.attachments = [attachment]
//                        }
//                    }
//                    // Serve the notification content
//                    self.contentHandler!(self.bestAttemptContent!)
//                    }.resume()
//            }
//        }
//
//
//        //}
//    }
//
    
    
    
//    override func serviceExtensionTimeWillExpire() {
//        // Called just before the extension will be terminated by the system.
//        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
//        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
//            contentHandler(bestAttemptContent)
//        }
//    }

   
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
            print("Failed to register: \(error)")//print error in debugger console
    }
    
}
// *******UNUserNotificationCenterDelegate*****



@available(iOSApplicationExtension 10.0, *)
extension  UNNotificationAttachment {
    
    static func saveImageToDisk(fileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: folderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = folderURL?.appendingPathComponent(fileIdentifier)
            try data.write(to: fileURL!, options: [])
            let attachment = try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL!, options: options)
            return attachment
        } catch let error {
            print("error \(error)")
        }
        
        return nil
    }
}
