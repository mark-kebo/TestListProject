//
//  ViewController.swift
//  TestProject
//
//  Created by Dmitry Vorozhbicki on 07/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var items: Items?
    @IBOutlet private weak var tableView: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.register(cellType: ChannelTableViewCell.self)
        tableView.dataSource = self
        loadData()
    }

    private func loadData() {
        APIManager.sharedInstance.getChannels { [weak self] (result, error) in
            self?.items = result
            self?.tableView.reloadData()
        }
    }

}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = items?.all.count {
            return items
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(for: indexPath, cellType: ChannelTableViewCell.self)
        cell.selectionStyle = .none
        cell.set(item: items?.all[indexPath.row])
        return cell
    }
}
