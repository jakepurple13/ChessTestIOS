//
//  EpisodeViewController.swift
//  Fun
//
//  Created by Jake Rein on 12/22/18.
//  Copyright © 2018 Jake Rein. All rights reserved.
//

import UIKit
import Kingfisher
import JGProgressHUD
import WebKit
import AVFoundation
import AVKit
import Photos

class EpisodeTableCell: UITableViewCell {
    @IBOutlet weak var episodeNumber: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var streamButton: UIButton!
    @IBOutlet weak var castButton: UIButton!
}

class EpisodeViewController: UIViewController, UITableViewDataSource, URLSessionDownloadDelegate {

    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var descriptionOfShow: UITextView!
    @IBOutlet weak var episodeList: UITableView!

    @IBOutlet weak var titleItem: UINavigationItem!

    var defaultSession: URLSession!
    var downloadTask: URLSessionDownloadTask!

    var url: String = ""
    var list = [EpisodeInfo]()
    var shows: EpisodeApi? = nil
    let hud = JGProgressHUD(style: .dark)
    var videoTitle = ""
    var videoDes = ""
    var videoImage = ""

    let t = RepeatingTimer(timeInterval: 1)
    var counter = 0
    var start = NSDate.timeIntervalSinceReferenceDate

    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        descriptionOfShow.textColor = UIColor.white
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        //self.episodeList.rowHeight = UITableView.automaticDimension
        //self.episodeList.estimatedRowHeight = 75

        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        defaultSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)

        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading..."
        hud.show(in: self.view)

        // Do any additional setup after loading the view.
        self.titleItem.title = "Loading"

        DispatchQueue.main.async {
            DispatchQueue.main.async {
                self.shows = EpisodeApi(url: self.url)
                track("Name: \(self.shows!.name)")
                track("ImageURL: \(self.shows!.imageUrl)")
                track("Des: \(self.shows!.des)")
                track("Episode Count: \(self.shows!.episodeList.count)")
                self.videoTitle = self.shows!.name
                self.titleItem.title = self.videoTitle
                self.videoDes = self.shows!.des
                self.descriptionOfShow.text = "\(self.url)\n\(self.videoDes)"
                self.videoImage = self.shows!.imageUrl
                self.coverImage.kf.setImage(with: URL(string: self.videoImage))
                self.list = self.shows!.episodeList
                self.episodeList.dataSource = self
                self.episodeList.reloadData()
                hud.dismiss(animated: true)
            }
        }

    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "episode_number")! as! EpisodeTableCell //1.

        let text = list[indexPath.row] //2.

        //cell.textLabel?.text = text //3.
        cell.episodeNumber.text = text.name
        cell.downloadButton.tag = indexPath.row
        cell.streamButton.tag = indexPath.row
        cell.castButton.tag = indexPath.row
        cell.downloadButton.addTarget(self, action: #selector(downloadVideo(_:)), for: .touchUpInside)
        cell.castButton.addTarget(self, action: #selector(castVideo(_:)), for: .touchUpInside)
        cell.streamButton.addTarget(self, action: #selector(streamVideo(_:)), for: .touchUpInside)

        cell.episodeNumber.textColor = UIColor.white
        cell.backgroundColor = UIColor.black
        return cell //4.
    }

    @objc func streamVideo(_ sender: UIButton) {
        //DispatchQueue.main.async {
        DispatchQueue.main.async {
            let link = self.list[sender.tag].getVideo()
            guard let url = URL(string: link) else {
                return
            }
            // Create an AVPlayer, passing it the HTTP Live Streaming URL.
            let player = AVPlayer(url: url)

            // Create a new AVPlayerViewController and pass it a reference to the player.
            let controller = AVPlayerViewController()
            controller.player = player

            // Modally present the player and call the player's play() method when complete.
            self.present(controller, animated: true) {
                player.play()
            }
        }
    }

    @objc func downloadVideo(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.counter = 0
            self.t.eventHandler = {
                //print("Timer Fired")
                self.counter += 1
                DispatchQueue.main.async {
                    self.hud.textLabel.text = "Downloading...\n\(self.counter) seconds have passed"
                }
                if (false) {   //I know this makes no sense, but it works. Go figure...
                    self.t.suspend()
                }
            }
            self.start = NSDate.timeIntervalSinceReferenceDate
            //self.hud.detailTextLabel.text = "0% Complete"
            self.hud.detailTextLabel.text = "Please Wait"
            self.hud.textLabel.text = "Downloading..."
            self.hud.indicatorView = JGProgressHUDPieIndicatorView()
            self.hud.show(in: self.view)
            self.t.resume()
            let link = self.list[sender.tag].getVideo()
            //self.downloadVid(urlString: link)
            self.downloadVideoLinkAndCreateAsset(link)
            //self.shows!.getVideo(url: self.list[sender.tag].url)
        }
    }

    private func downloadVid(urlString: String) {
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: urlString),
               let urlData = NSData(contentsOf: url) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath = "\(documentsPath)/tempFile.mp4"
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }) { completed, error in
                        if completed {
                            print("Video is saved!")
                        }
                    }
                }
            }
        }
    }

    func downloadVideoLinkAndCreateAsset(_ videoLink: String) {
        // use guard to make sure you have a valid url
        guard let videoURL = URL(string: videoLink) else {
            return
        }
        /*guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }*/
        // set up your download task
        defaultSession.downloadTask(with: videoURL)/* { (location, response, error) -> Void in
            // use guard to unwrap your optional url
            guard let location = location else {
                return
            }
            // create a destination url with the server response suggested file name
            let destinationURL = documentsDirectoryURL.appendingPathComponent(response?.suggestedFilename ?? videoURL.lastPathComponent)

            do {
                try FileManager.default.moveItem(at: location, to: destinationURL)
                PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in

                    // check if user authorized access photos for your app
                    if authorizationStatus == .authorized {
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)
                        }) { completed, error in
                            if completed {
                                print("Video asset created")
                            } else {
                                print(error?.localizedDescription)
                            }
                        }
                    }
                })
            } catch {
                print(error)
            }
        }*/.resume()
    }

    @objc func castVideo(_ sender: UIButton) {
        //DispatchQueue.main.async {
        DispatchQueue.main.async {
            /*
            self.hud.detailTextLabel.text = "0% Complete"
            self.hud.textLabel.text = "Downloading"
            self.hud.indicatorView = JGProgressHUDPieIndicatorView()
            self.hud.show(in: self.view)
            */
            //self.shows!.getVideo(url: self.list[sender.tag].url)
            let link = self.list[sender.tag].getVideo()
            track(link)

            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "castactivity") as! CastViewController

            nextViewController.videoUrl = link
            nextViewController.videoDes = self.videoDes
            nextViewController.videoImage = self.videoImage
            nextViewController.videoTitle = self.videoTitle

            self.present(nextViewController, animated: true, completion: nil)

        }
        //}
    }

    // MARK:- URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        self.t.suspend()
        self.hud.textLabel.text = "Completed\n\(self.counter) seconds have passed"
        self.hud.dismiss(afterDelay: 2.5, animated: true)
        //print(downloadTask)
        print("File download successfully")
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        // create a destination url with the server response suggested file name
        let destinationURL = documentsDirectoryURL.appendingPathComponent(downloadTask.response?.suggestedFilename ?? location.lastPathComponent)

        do {
            try FileManager.default.moveItem(at: location, to: destinationURL)
            PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in

                // check if user authorized access photos for your app
                if authorizationStatus == .authorized {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)
                    }) { completed, error in
                        if completed {
                            print("Video asset created")
                        } else {
                            print(error?.localizedDescription ?? "Whelp!")
                        }
                    }
                }
            })
        } catch {
            print(error)
        }
        /*
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let fileManager = FileManager()
        let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.appendingFormat("/file.pdf"))
        
        if fileManager.fileExists(atPath: destinationURLForFile.path){
            //showFileWithPath(path: destinationURLForFile.path)
            print(destinationURLForFile.path)
        } else {
            do {
                try fileManager.moveItem(at: location, to: destinationURLForFile)
                // show file
                //showFileWithPath(path: destinationURLForFile.path)
            }catch{
                print("An error occurred while moving file to destination url")
            }
        }
        */
        //self.shows!.saveVideoTo(URL.init(string: location.path)!)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        //progress.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
        let speed = Double(bytesWritten) / (NSDate.timeIntervalSinceReferenceDate - self.start);

        let percentage = String(format: "%.2f %", (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)) * 100)
        self.hud.detailTextLabel.text = "\(percentage)% Complete\n\(self.getDownloadSpeedString(downloadedBytes: speed))"
        track("\(percentage) and \(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))")
        //self.incrementHUD(hud, progress: Int(progress*100))
        self.hud.setProgress(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite), animated: true)
        //self.hud.detailTextLabel.text = "\(percentage)% Complete"
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        downloadTask = nil
        //progress.setProgress(0.0, animated: true)
        if (error != nil) {
            print("didCompleteWithError \(error?.localizedDescription ?? "no value")")
        } else {
            print("The task finished successfully")
        }
    }

    private func getDownloadSpeedString(downloadedBytes: Double) -> String {
        if (downloadedBytes < 0) {
            return ""
        }
        let kb = downloadedBytes / 1000
        let mb = kb / 1000
        let gb = mb / 1000
        let tb = gb / 1000

        var s = ""

        if (tb >= 1) {
            s = String(format: "%.2f tb/s", tb)
        } else if (gb >= 1) {
            s = String(format: "%.2f gb/s", gb)
        } else if (mb >= 1) {
            s = String(format: "%.2f mb/s", mb)
        } else if (kb >= 1) {
            s = String(format: "%.2f kb/s", kb)
        } else {
            s = String(format: "%.2f b/s", downloadedBytes)
        }

        return s
    }

}

/// RepeatingTimer mimics the API of DispatchSourceTimer but in a way that prevents
/// crashes that occur from calling resume multiple times on a timer that is
/// already resumed (noted by https://github.com/SiftScience/sift-ios/issues/52
class RepeatingTimer {

    let timeInterval: TimeInterval

    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }

    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()

    var eventHandler: (() -> Void)?

    private enum State {
        case suspended
        case resumed
    }

    private var state: State = .suspended

    deinit {
        timer.setEventHandler {
        }
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }

    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }

    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
}
