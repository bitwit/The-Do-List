//
//  SplitContainerViewController.swift
//  TheDoList
//
//  Created by Kyle Newsome on 5/31/18.
//  Copyright © 2018 Bitwit. All rights reserved.
//

import UIKit

class SplitContainerViewController: UISplitViewController {

    var viewModel: ToDoListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let viewModel = ToDoListViewModel(resourceManager: AppEnv.current.toDoItemsManager)
        self.viewModel = viewModel
        
        if let historyVC = viewControllers.first?.childViewControllers.first as? HistoryTableViewController {
            historyVC.viewModel = viewModel
        }
        if let listVC = viewControllers.last?.childViewControllers.first as? ListViewController {
            listVC.viewModel = viewModel
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
