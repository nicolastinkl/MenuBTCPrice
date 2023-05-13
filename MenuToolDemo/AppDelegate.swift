//
//  AppDelegate.swift
//  MenuToolDemo
//
//  Created by 5km on 2019/10/22.
//  Copyright © 2019 5km. All rights reserved.
//

import Cocoa
import SwiftUI

protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
    */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
}

extension URL {
    /**
     Creates a new URL by adding the given query parameters.
     @param parametersDictionary The query parameter dictionary to add.
     @return A new URL.
    */
    func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString)!
    }
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var menu: NSMenu!
    
    var prtxt:NSTextField?
    
    let statusItem = NSStatusBar.system.statusItem(withLength: 80)
    //NSStatusItem.squareLength
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusItem.menu = menu
        var mStatusBackgroundView:NSView?
        if let _ = statusItem.button {
            //button.image = NSImage(named: "StatusIcon")
            let DEFAULT_W = 80+80
            let DEFAULT_H = 20
            let txt = NSTextField(frame: NSMakeRect(0, 0, CGFloat(DEFAULT_W), CGFloat(DEFAULT_H)))
            txt.stringValue = "BTC 行情数据"
                
            mStatusBackgroundView = NSView(frame: NSMakeRect(0, 0, CGFloat(DEFAULT_W), CGFloat(DEFAULT_H)))
            
            mStatusBackgroundView?.addSubview(txt)
            prtxt = txt
            //mStatusItem = NSStatusBar.system.statusItem(withLength: CGFloat(DEFAULT_W))
            statusItem.button?.addSubview(txt)//or mStatusItem?.button?.title = "Hellow world!"
            
            
        }
        
        //每10s更新 btc 数据
        
        
        //self.log(log: "349   3秒 轮询 \n" )
        let timer = Timer(timeInterval: 10.0, target: self, selector: #selector(sendRequest349), userInfo: nil, repeats:true);
        //timer.fire()
        RunLoop.current.add(timer, forMode: .default)
        
        sendRequest349()
        
        
        
    }
    
     @objc func sendRequest349(){
            /* Configure session, choose between:
                      * defaultSessionConfiguration
                      * ephemeralSessionConfiguration
                      * backgroundSessionConfigurationWithIdentifier:
                    And set session-wide properties, such as: HTTPAdditionalHeaders,
                    HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
                    */
                   let sessionConfig = URLSessionConfiguration.default

                   /* Create session, and optionally set a URLSessionDelegate. */
                   let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

                   /* Create the Request:
                      349 (POST http://349assistant.com/getLatestOrder)
                    */
    //
            guard var URL = URL(string: "https://www.heyuegendan.com/getprice.php?symbol=BTCUSDT") else {return}
                   //guard var URL = URL(string: "http://349assistant.com/getLatestOrder") else {return}
//                   let URLParams = [
//                       "id": "24",
//                       "tradeTime": "12938129",
//                       "symbol": "ETHUSDT",
//                   ]
                   //URL = URL.appendingQueryParameters(URLParams)
                   var request = URLRequest(url: URL)
                   request.httpMethod = "POST"

                   // Headers

                   /* Start a new Task */
                   let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                       if (error == nil) {
                           // Success
                           let statusCode = (response as! HTTPURLResponse).statusCode
                           print("URL Session Task Succeeded: HTTP \(statusCode)")
                        
                           // self.log(log: "URL Session Task Succeeded: HTTP \(statusCode)")
                        if let data = data{
                                let newStr = String(data: data, encoding: String.Encoding.utf8)
                                //self.log(log: newStr ?? "")
                                
                                do {
                                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                                        if let jsonDict = jsonObject as? [String: Any] {
                                            let newStr = jsonDict["markPrice"] as? String ?? ""
                                            
                                            DispatchQueue.main.async {
                                                self.prtxt?.stringValue = "$\(newStr)"
                                            }
                                            
                                            
                                        }
                                    } catch {
                                        print("Error parsing JSON: \(error.localizedDescription)")
                                    }
                                
                            
                        }
                        
                        
                       }
                       else {
                           // Failure
                           print("URL Session Task Failed: %@", error!.localizedDescription);
                       }
                   })
                   task.resume()
                   session.finishTasksAndInvalidate()
               
        }
    

    @IBAction func quitApp(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

