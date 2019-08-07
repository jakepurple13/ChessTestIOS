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
class EpisodeTableCell: UITableViewCell {
    @IBOutlet weak var episodeNumber: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
}

class EpisodeViewController: UIViewController, UITableViewDataSource, URLSessionDownloadDelegate {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var descriptionOfShow: UILabel!
    @IBOutlet weak var episodeList: UITableView!
    
    @IBOutlet weak var titleItem: UINavigationItem!
    
    var defaultSession: URLSession!
    var downloadTask: URLSessionDownloadTask!
    
    var url: String = ""
    var list = [EpisodeInfo]()
    var shows: EpisodeApi? = nil
    //let hud = JGProgressHUD(style: .dark)
    var videoTitle = ""
    var videoDes = ""
    var videoImage = ""
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        descriptionOfShow.textColor = UIColor.white
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
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
                self.descriptionOfShow.text = self.videoDes
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
        cell.downloadButton.addTarget(self, action: #selector(downloadVideo(_:)), for: .touchUpInside)

        cell.episodeNumber.textColor = UIColor.white
        cell.backgroundColor = UIColor.black
        return cell //4.
    }

    @objc func downloadVideo(_ sender: UIButton) {
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
                        
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "castactivity") as! CastViewController
                
                nextViewController.videoUrl = link
                nextViewController.videoDes = self.videoDes
                nextViewController.videoImage = self.videoImage
                nextViewController.videoTitle = self.videoTitle
                
                self.present(nextViewController, animated:true, completion:nil)
                
            }
        //}
    }
    
    // MARK:- URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //self.hud.dismiss(animated: true)
        print(downloadTask)
        print("File download succesfully")
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
        let percentage = String(format: "%.2f %", (Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)))
        track("\(percentage) and \(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite))")
        //self.incrementHUD(hud, progress: Int(progress*100))
        //self.hud.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        //self.hud.detailTextLabel.text = "\(percentage)% Complete"
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        downloadTask = nil
        //progress.setProgress(0.0, animated: true)
        if (error != nil) {
            print("didCompleteWithError \(error?.localizedDescription ?? "no value")")
        }
        else {
            print("The task finished successfully")
        }
    }
    
}
