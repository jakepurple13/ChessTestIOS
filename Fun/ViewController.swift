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
class ViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var AnimeButton: UIButton!
    @IBOutlet weak var RecentCartoonButton: UIButton!
    @IBOutlet weak var CartoonButton: UIButton!
    @IBOutlet weak var CartoonMovieButton: UIButton!
    @IBOutlet weak var AnimeMovieButton: UIButton!
    
    var lists = [NameAndLink]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSLog("Hello world");
        print("Hello world");
        
        
        
    }
    
    @IBAction func cartoonMovieSend(_ sender: Any) {
        loadInfo(sourced: Source.CARTOON_MOVIES)
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
                 */
                self.button.titleLabel?.text = "Done"
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "showactivity") as! ShowTableViewController
                
                //nextViewController.url = list[indexPath.row].url
                //nextViewController.list = self.lists
                nextViewController.url = sourced.url
                nextViewController.source = sourced
                
                self.present(nextViewController, animated:true, completion:nil)
            }
            */
            self.button.titleLabel?.text = "Done"
            
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


