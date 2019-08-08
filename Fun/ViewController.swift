//
//  ViewController.swift
//  Fun
//
//  Created by Jake Rein on 12/19/18.
//  Copyright © 2018 Jake Rein. All rights reserved.
//

import UIKit
import SwiftSoup
import SDDownloadManager
import Digger
import ASPVideoPlayer
import VersaPlayer
import UserNotifications
import AudioToolbox
import Alamofire
import SwiftyJSON
class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var AnimeButton: UIButton!
    @IBOutlet weak var RecentCartoonButton: UIButton!
    @IBOutlet weak var CartoonButton: UIButton!
    @IBOutlet weak var CartoonMovieButton: UIButton!
    @IBOutlet weak var AnimeMovieButton: UIButton!
    @IBOutlet weak var liveActionButton: UIButton!
    @IBOutlet weak var dubbedButton: UIButton!
    
    var lists = [NameAndLink]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        // Do any additional setup after loading the view, typically from a nib.
        NSLog("Hello world");
        print("Hello world");
        
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound];
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                // Notifications not allowed
            }
        }
        
    }

    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    @IBAction func cartoonMovieSend(_ sender: Any) {
        loadInfo(sourced: Source.CARTOON_MOVIES)
        /*DispatchQueue.main.async {
            DispatchQueue.main.async {
                AF.request("https://api.musixmatch.com/ws/1.1/track.lyrics.get?track_id=36357901&apikey=67053f507ef88fc99c544f4d7052dfa8", method: .get, encoding: JSONEncoding.default).responseJSON { response in
                    //debugPrint(response)
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        //print("JSON: \(json)")
                        track("\(json["message"]["body"]["lyrics"]["lyrics_body"])")
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }*/
    }
    
    @IBAction func dubbedSend(_ sender: Any) {
        loadInfo(sourced: Source.DUBBED)
    }
    
    @IBAction func animemovieSend(_ sender: Any) {
        loadInfo(sourced: Source.ANIME_MOVIES)
    }
    
    @IBAction func recentAnimeSend(_ sender: Any) {
        loadInfo(sourced: Source.RECENT_ANIME)
    }
    
    @IBAction func animeSend(_ sender: Any) {
        loadInfo(sourced: Source.ANIME)
    }
    
    @IBAction func recentCartoonSend(_ sender: Any) {
        loadInfo(sourced: Source.RECENT_CARTOON)
    }
    @IBAction func cartoonSend(_ sender: Any) {
        loadInfo(sourced: Source.CARTOON)
    }
    @IBAction func liveActionSend(_ sender: Any) {
        loadInfo(sourced: Source.LIVE_ACTION)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //retrieve the destination view controller for free
        /*
        if let myDestincationViewController = (segue.destination as? ShowTableViewController) {
            track("We are here")
            myDestincationViewController.list = lists
            myDestincationViewController.url = Source.RECENT_ANIME.url
        }
         */
    }
    
    func loadInfo(sourced: Source) {
        /*
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                /*
                let shows = ShowApi(source: sourced)
                
                let s = shows.showList
                
                track("\(s.count) and \(sourced.url)")
                
                //for i in s {
                //  track(i.name)
                //}
                self.lists = s
                */
                //track("size is \(s.count)")
                /*
                 let e = EpisodeApi(url: s[0].url)
                 
                 track("Name: \(e.name)")
                 track("ImageURL: \(e.imageUrl)")
                 track("Des: \(e.des)")
                 track("Episode Count: \(e.episodeList.count)")
         @IBAction func freeButton(_ sender: Any) {
         }
         @IBAction func actoinButton(_ sender: UIButton) {
         }
         @IBAction func loadVideos(_ sender: Any) {
         }
         */
                self.button.titleLabel?.text = "Done"
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "showactivity") as! ShowTableViewController
                
                //nextViewController.url = list[indexPath.row].url
                //nextViewController.list = self.lists
         @IBAction func loadVideo(_ sender: Any) {
         }
         nextViewController.url = sourced.url
                nextViewController.source = sourced
                
                self.present(nextViewController, animated:true, completion:nil)
            }
            */
            //self.button.titleLabel?.text = "Done"
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "showactivity") as! ShowTableViewController
            
            //nextViewController.url = list[indexPath.row].url
            //nextViewController.list = self.lists
            nextViewController.url = sourced.url
            nextViewController.source = sourced
            
            self.present(nextViewController, animated:true, completion:nil)
            
            DispatchQueue.main.async{
                //self.getVideo(url: "http://www.animeplus.tv/otona-no-bouguya-san-episode-11-online")
            }
            
    }
    
}


