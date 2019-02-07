//
//  ShowTableViewController.swift
//  Fun
//
//  Created by Jake Rein on 12/22/18.
//  Copyright © 2018 Jake Rein. All rights reserved.
//

import UIKit
import SimpleCheckbox
import JGProgressHUD
class ShowTableViewCell: UITableViewCell {
    @IBOutlet weak var nameToShow: UILabel!
    @IBOutlet weak var checkFavorite: Checkbox!
}

class ShowTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var titleBar: UINavigationItem!
    
    @IBAction func goBack(_ segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - Table view data source
    var list = [NameAndLink]()
    var url = ""
    var source: Source? = nil
    var shows: ShowApi? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    func backAction(){
        //print("Back Button Clicked")
        dismiss(animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        track("hello")
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading..."
        hud.show(in: self.view)
        
        //self.tableView.register(UINib(nibName: "NAME_OF_THE_CELL_CLASS", bundle: nil), forCellReuseIdentifier: "REUSE_IDENTIFIER");
        //track(self.source.url)
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                self.shows = ShowApi(source: self.source!)
                self.list = (self.shows?.showList)!
                self.titleBar.title = self.source!.rawValue
                self.tableView.dataSource = self
                self.tableView.delegate = self
                self.tableView.reloadData()
                hud.dismiss(animated: true)
            }
        }

        /*DispatchQueue.main.async {
            DispatchQueue.main.async{
                let shows = ShowApi(source: Source.RECENT_ANIME)
                let s = shows.showList
                //for i in s {
                //  track(i.name)
                //}
                self.list = s
            }
        }*/
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //track("here")
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //track("here")
        // Table view cells are reused and should be dequeued using a cell identifier.
        //let cellIdentifier = "ShowViewCell"
        
        tableView.register(ShowTableViewCell.self, forCellReuseIdentifier: "ShowViewCell")
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "ShowViewCell")! as! ShowTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowViewCell", for:indexPath) as! ShowTableViewCell

        
        // Fetches the appropriate meal for the data source layout.
        let show = list[indexPath.row]
        
        cell.textLabel?.text = show.name
        cell.accessoryType = indexPath.row%2==0 ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
        cell.tag = indexPath.row
        //cell.nameToShow?.text = show.name
        //cell.checkFavorite?.isChecked = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        track("here")
        track("section: \(indexPath.section)")
        track("row: \(indexPath.row)")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "episodeactivity") as! EpisodeViewController
        
        nextViewController.url = list[indexPath.row].url
        
        self.present(nextViewController, animated:true, completion:nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
