//
//  ShowTableViewController.swift
//  Fun
//
//  Created by Jake Rein on 12/22/18.
//  Copyright © 2018 Jake Rein. All rights reserved.
//

import UIKit
import JGProgressHUD
import SimpleCheckbox
import SwipeTransition

extension ShowTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {

    }
}

class ShowTableViewCell: UITableViewCell {
    @IBOutlet weak var nameToShow: UILabel!
    @IBOutlet weak var favorite: UISwitch!
}

class ShowTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var titleBar: UINavigationItem!

    @IBOutlet weak var searchBar: UISearchBar!

    @IBAction func goBack(_ segue: UIStoryboardSegue) {

    }

    // MARK: - Table view data source
    var list = [NameAndLink]()
    var url = ""
    var source: Source? = nil
    var shows: ShowApi? = nil
    var filteredShows = [NameAndLink]()

    let db = DatabaseWork()

    @IBOutlet weak var tableView: UITableView!

    func backAction() {
        //print("Back Button Clicked")
        dismiss(animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        track("hello")

        self.searchBar.showsCancelButton = false
        self.searchBar.delegate = self

        definesPresentationContext = true
        self.navigationController?.swipeBack?.isEnabled = false
        self.swipeToDismiss?.isEnabled = true

        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading..."
        hud.show(in: self.view)

        //self.tableView.register(UINib(nibName: "NAME_OF_THE_CELL_CLASS", bundle: nil), forCellReuseIdentifier: "REUSE_IDENTIFIER");
        //track(self.source.url)
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                self.shows = ShowApi(source: self.source!)
                self.list = (self.shows?.showList)!
                //self.filteredShows = self.list
                self.titleBar.title = self.source!.rawValue
                if (!(self.source?.recent)!) {
                    self.list.sort {
                        $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending
                    }
                    track("here")
                    //self.filteredShows = self.list.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending }
                    //self.filteredShows.reverse()
                }
                self.filteredShows = self.list
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

    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        searchBar.showsCancelButton = false
        if let searchText = searchBar.text {
            filteredShows = searchText.isEmpty ? list : list.filter({ (dataString: NameAndLink) -> Bool in
                return dataString.name.range(of: searchText, options: .caseInsensitive) != nil
            })
            tableView.reloadData()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Stop doing the search stuff
        // and clear the text in the search bar
        searchBar.text = ""
        // Hide the cancel button
        searchBar.showsCancelButton = false
        // You could also change the position, frame etc of the searchBar
        self.filteredShows = self.list
        self.tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //track("here")
        //return list.count
        return filteredShows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //track("here")
        // Table view cells are reused and should be dequeued using a cell identifier.
        //let cellIdentifier = "ShowViewCell"

        //tableView.register(ShowTableViewCell.self, forCellReuseIdentifier: "ShowTableViewCell")

        //let cell = tableView.dequeueReusableCell(withIdentifier: "ShowViewCell")! as! ShowTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowTableViewCell", for: indexPath) as! ShowTableViewCell


        // Fetches the appropriate meal for the data source layout.
        let show = filteredShows[indexPath.row]

        //cell.textLabel?.text = show.name
        cell.nameToShow?.text = show.name
        let f: ShowInfo? = self.db.findShowByLink(show.url) ?? nil
        //cell.accessoryType = indexPath.row%2==0 ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
        //track("\(String(describing: f))")

        cell.tag = indexPath.row

        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.black

        //cell.accessoryType = f != nil ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
        
        cell.favorite?.isOn = f != nil
        cell.favorite?.tag = indexPath.row
        cell.favorite?.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)

        //cell.nameToShow?.text = show.name/
        //cell.checkFavorite?.isChecked = true
        /*cell.favCheck?.isChecked = f != nil
        cell.favCheck?.valueChanged = { b in
            if(b) {
                self.db.insert(show.name, show.url)
            } else {
                self.db.delete(show.url)
            }
        }*/

        return cell
    }

    @objc func switchChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        let show = filteredShows[mySwitch.tag]
        // Do something
        if(value) {
            self.db.insert(show.name, show.url)
        } else {
            self.db.delete(show.url)
        }
        let s = self.db.getAll()
        track("\(s)")
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        track("here")
        track("section: \(indexPath.section)")
        track("row: \(indexPath.row)")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "episodeactivity") as! EpisodeViewController

        nextViewController.url = filteredShows[indexPath.row].url

        self.present(nextViewController, animated: true, completion: nil)
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
