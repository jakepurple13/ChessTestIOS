//
//  CustomDownloadManager.swift
//  Fun
//
//  Created by Jake Rein on 2/7/19.
//  Copyright © 2019 Jake Rein. All rights reserved.
//

import Foundation

class CustomDownloadManager : NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
    static var shared = CustomDownloadManager()
    
    func downloadFile(link: String) {
        let config = URLSessionConfiguration.background(withIdentifier: "\(link)")
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        let url = URL(string: link)!
        let task = session.downloadTask(with: url)
        task.resume()
    }
    
    var session : URLSession {
        get {
            let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
            
            // Warning: If an URLSession still exists from a previous download, it doesn't create
            // a new URLSession object but returns the existing one with the old delegate object attached!
            return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            debugPrint("Progress \(downloadTask) \(progress)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        debugPrint("Download finished: \(location)")
        try? FileManager.default.removeItem(at: location)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        debugPrint("Task completed: \(task), error: \(error.debugDescription)")
    }
    
}
