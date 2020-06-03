//
//  BirthdaysTableViewController.swift
//  BirthdayTracker
//
//  Created by Arthur Kozik on 27/05/2020.
//  Copyright © 2020 Arthur Kozik. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class BirthdaysTableViewController: UITableViewController {
    
    var birthdays = [Birthday]()
    let dateFormatter = DateFormatter()
    
    private lazy var refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        self.tableView.refreshControl = self.refresher
        self.refresher.addTarget(self, action: #selector(reloadTableView), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = Birthday.fetchRequest() as NSFetchRequest<Birthday>
        let sortDescriptor1 = NSSortDescriptor(key: "lastName", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "firstName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        do {
            birthdays = try context.fetch(fetchRequest)
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        tableView.reloadData()
    }
    
    @objc private func reloadTableView() {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        let fetchRequest = Birthday.fetchRequest() as NSFetchRequest<Birthday>
        let sortDescriptor1 = NSSortDescriptor(key: "lastName", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "firstName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        
        do {
            guard let context = context else { return }
            self.birthdays = try context.fetch(fetchRequest)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refresher.endRefreshing()
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return birthdays.count
        // #warning Incomplete implementation, return the number of rows
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "birthdayCellIdentifier", for: indexPath)
        let birthday = birthdays[indexPath.row]
        let firstName = birthday.firstName ?? ""
        let lastName = birthday.firstName ?? ""
        cell.textLabel?.text = firstName + " " + lastName
        
        if let date = birthday.birthdate {
            cell.detailTextLabel?.text = dateFormatter.string(from: date)
        } else {
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if birthdays.count > indexPath.row {
            let birthday = birthdays[indexPath.row]
            if let identifier = birthday.birthdayId {
                let center = UNUserNotificationCenter.current()
                center.removePendingNotificationRequests(withIdentifiers:
                    [identifier])
            }
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            context.delete(birthday)
            birthdays.remove(at: indexPath.row)
            do {
                try context.save()
            } catch let error {
                print("Не удалось сохранить из-за ошибки \(error).")
            }
            tableView.deleteRows(at:[indexPath],with: .fade)
        }
    }
    
    
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
}
