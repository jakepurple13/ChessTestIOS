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

class EpisodeViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var descriptionOfShow: UILabel!
    @IBOutlet weak var episodeList: UITableView!
    
    @IBOutlet weak var titleItem: UINavigationItem!
    
    
    var url: String = ""
    var list = [NameAndLink]()
    var shows: EpisodeApi? = nil
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading..."
        hud.show(in: self.view)
        
        // Do any additional setup after loading the view.
        self.titleItem.title = "Loading"
        
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                self.shows = EpisodeApi(url: self.url, vc: self)
                track("Name: \(self.shows!.name)")
                track("ImageURL: \(self.shows!.imageUrl)")
                track("Des: \(self.shows!.des)")
                track("Episode Count: \(self.shows!.episodeList.count)")
                    self.titleItem.title = self.shows!.name
                self.descriptionOfShow.text = self.shows!.des
                self.coverImage.kf.setImage(with: URL(string: self.shows!.imageUrl))
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
        
        return cell //4.
    }

    @objc func downloadVideo(_ sender: UIButton) {
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                self.shows!.getVideo(url: self.list[sender.tag].url)
            }
        }
    }
    
}
