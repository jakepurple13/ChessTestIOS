//
//  ShowTableViewController.swift
//  Fun
//
//  Created by Jake Rein on 12/22/18.
//  Copyright © 2018 Jake Rein. All rights reserved.
//

import UIKit
import SimpleCheckbox

class ShowTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameToShow: UILabel!
    @IBOutlet weak var checkFavorite: Checkbox!
    
}

class ShowTableViewController: UITableViewController {
    
    // MARK: - Table view data source
    var list = [NameAndLink]()
    var url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        track("hello")
        track("\(list.count)")
        tableView.register(ShowTableViewCell.self, forCellReuseIdentifier: "ShowViewCell")
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //track("here")
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ShowViewCell"
        
        //tableView.register(ShowTableViewCell.self, forCellReuseIdentifier: "ShowTableViewCell")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for:indexPath)// as! ShowTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let show = list[indexPath.row]
        
        cell.textLabel?.text = show.name
        cell.accessoryType = indexPath.row%2==0 ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
        //cell.nameToShow?.text = show.name
        //cell.checkFavorite?.isChecked = true
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("section: \(indexPath.section)")
        print("row: \(indexPath.row)")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "episodeactivity") as! EpisodeViewController
        
        nextViewController.url = list[indexPath.row].url
        
        self.present(nextViewController, animated:true, completion:nil)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
