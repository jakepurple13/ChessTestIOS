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
class ViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    var lists = [NameAndLink]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSLog("Hello world");
        print("Hello world");
        
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                let shows = ShowApi(source: Source.RECENT_ANIME)
                let s = shows.showList
                //for i in s {
                  //  track(i.name)
                //}
                self.lists = s
                
                //track("size is \(s.count)")
                /*
                let e = EpisodeApi(url: s[0].url)
                
                track("Name: \(e.name)")
                track("ImageURL: \(e.imageUrl)")
                track("Des: \(e.des)")
                track("Episode Count: \(e.episodeList.count)")
                */
                self.button.titleLabel?.text = "Done"
            }
            DispatchQueue.main.async{
                //self.getVideo(url: "http://www.animeplus.tv/otona-no-bouguya-san-episode-11-online")
            }
        
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //retrieve the destination view controller for free
        if let myDestincationViewController = (segue.destination as? ShowTableViewController) {
            track("We are here")
            myDestincationViewController.list = lists
            myDestincationViewController.url = Source.RECENT_ANIME.url
        }
    }
    
}


