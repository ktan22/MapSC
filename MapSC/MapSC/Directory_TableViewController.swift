//
//  Directory_TableViewController.swift
//  MapSC
//
//  Created by Kyle Tan on 8/16/17.
//  Copyright © 2017 BITS. All rights reserved.
//

import UIKit


class Directory_TableViewController: UITableViewController {

    struct Location{
        let name : String
        let abbrev : String
    }
    var scope = "All"
    var unique = [String]()
    var array_objects = [Location]()
    var library_locations = [Location]()
    var athletic_locations = [Location]()
    var food_locations = [Location]()
    var filtered_locations = [Location]()
    let searchController = UISearchController(searchResultsController: nil)
    var search_string = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        for (key,value) in ConstantMap.usc_map{
            let n = value["name"]
            let loc = Location(name: n!, abbrev: key)
            
            if(!unique.contains(loc.name.lowercased()))
            {
                array_objects.append(loc)
                unique.append(loc.name.lowercased())
            }
        }
        
        for loc in ConstantMap.usc_dining{
            let n = loc["name"]
            var a = loc["code"]
            if (a == ""){
                a = String(describing: String(n!).characters.first!)
            }
            let loc = Location(name: n!, abbrev: a!)
            food_locations.append(loc)
            if(!unique.contains(loc.name.lowercased()))
            {
                array_objects.append(loc)
                unique.append(loc.name.lowercased())
            }
        }
        
        for loc in ConstantMap.usc_athletics{
            let n = loc["name"]
            var a = loc["code"]
            if (a == ""){
                a = String(describing: String(n!).characters.first!)
            }
            let loc = Location(name: n!, abbrev: a!)
            athletic_locations.append(loc)
            if(!unique.contains(loc.name.lowercased()))
            {
                array_objects.append(loc)
                unique.append(loc.name.lowercased())
            }
        }
        
        for loc in ConstantMap.usc_libraries{
            let n = loc["name"]
            var a = loc["code"]
            if (a == ""){
                a = String(describing: String(n!).characters.first!)
            }
            let loc = Location(name: n!, abbrev: a!)
            library_locations.append(loc)
            if(!unique.contains(loc.name.lowercased()))
            {
                array_objects.append(loc)
                unique.append(loc.name.lowercased())
            }
        }
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.contentInset = UIEdgeInsetsMake(20,0,0,0)
        tableView.scrollToRow( at: IndexPath( row: 0, section: 0), at: UITableViewScrollPosition.top, animated: false)
        searchController.searchBar.scopeButtonTitles = ["All","Libraries", "Athletics", "Food", "Village"]
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
        //view.addSubview(searchBar)

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isFiltering() {
            return filtered_locations.count
        }
        
        let size = ConstantMap.usc_map.count + ConstantMap.usc_dining.count
        return size
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "location_cell", for: indexPath)

        if isFiltering()
        {
            cell.textLabel?.text = "(\(filtered_locations[indexPath.row].abbrev)) \(filtered_locations[indexPath.row].name.uppercased())"
        }
        else
        {
            // Configure the cell...
            cell.textLabel?.text = "(\(array_objects[indexPath.row].abbrev)) \(array_objects[indexPath.row].name.uppercased())"
        }
        return cell
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    func isFiltering() -> Bool {
        return searchController.isActive //&& !searchBarIsEmpty()
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String) {
        //Search Functionality goes here
        if(scope == "Libraries")
        {
            filtered_locations = library_locations.filter {location in
                let isMatching = location.name.lowercased().contains(searchText.lowercased()) || location.abbrev.lowercased().contains(searchText.lowercased()) || searchText == "";
                return isMatching
            }
        }
        else if(scope == "Food")
        {
            filtered_locations = food_locations.filter {location in
                let isMatching = location.name.lowercased().contains(searchText.lowercased()) || location.abbrev.lowercased().contains(searchText.lowercased()) || searchText == "";
                return isMatching
            }
            
        }
        else if(scope == "Athletics")
        {
            filtered_locations = athletic_locations.filter {location in
                let isMatching = location.name.lowercased().contains(searchText.lowercased()) || location.abbrev.lowercased().contains(searchText.lowercased()) || searchText == "";
                return isMatching
            }
        }
        else
        {
            filtered_locations = array_objects.filter {location in
                let isMatching = location.name.lowercased().contains(searchText.lowercased()) || location.abbrev.lowercased().contains(searchText.lowercased()) || searchText == "";
                return isMatching
            }
        }
        
        tableView.reloadData()
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(isFiltering())
        {
            self.search_string = filtered_locations[indexPath.row].name
        }
        else
        {
            self.search_string = array_objects[indexPath.row].name
        }
        //self.performSegue(withIdentifier: "directory_search", sender: nil)
        
        self.tabBarController?.selectedIndex = 0
        let defaults : UserDefaults = UserDefaults.standard
        defaults.set(search_string, forKey: "directory_search")
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}

extension Directory_TableViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        scope = searchBar.scopeButtonTitles![selectedScope]
        filterContentForSearchText(searchController.searchBar.text!, scope: self.scope)
        //print(searchBar.scopeButtonTitles![selectedScope])
    }
}

extension Directory_TableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!,scope: scope)
    }
}




