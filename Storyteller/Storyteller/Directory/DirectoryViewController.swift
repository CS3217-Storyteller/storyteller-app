//
//  FolderViewController.swift
//  Storyteller
//
//  Created by John Pan on 1/5/21.
//

import UIKit

class DirectoryViewController: UIViewController {

    static let navigationBarTitle = "Storyteller"
    static let addPopoverSegueIdentifier = "DirectoryAddPopoverSegue"
    static let moveModalSegueIdentifier = "DirectoryMoveModalSegue"

    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var moveButton: UIBarButtonItem!
    @IBOutlet weak var rearrangeButton: UIBarButtonItem!
    @IBOutlet weak var selectButton: UIBarButtonItem!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!

    var directoryManager: DirectoryManager = DirectoryManager()
    var observers: [DirectoryViewControllerObserver] = []
    var selectedIndexes: [Int] = []

    var currMode: DirectoryMode = .view {
        didSet {
            switch currMode {
            case .view:
                deleteButton.image = nil
                moveButton.title = nil
                rearrangeButton.title = "Rearrange"
                selectButton.title = "Select"
                sortButton.title = "Sort"
                searchButton.image = UIImage(systemName: "magnifyingglass")
                addButton.image = UIImage(systemName: "plus")
                doneButton.title = nil

                selectedIndexes = []
                observers.forEach({ $0.didModeChange(to: .view) })
            case .rearrange:
                deleteButton.image = nil
                moveButton.title = nil
                rearrangeButton.title = nil
                selectButton.title = nil
                sortButton.title = nil
                searchButton.image = nil
                addButton.image = nil
                doneButton.title = "Done"

                selectedIndexes = []
                self.observers.forEach({ $0.didModeChange(to: .rearrange) })
            case .select:
                deleteButton.image = UIImage(systemName: "trash")
                moveButton.title = "Move"
                rearrangeButton.title = nil
                selectButton.title = nil
                sortButton.title = nil
                searchButton.image = nil
                addButton.image = nil
                doneButton.title = "Done"

                selectedIndexes = []
                self.observers.forEach({ $0.didModeChange(to: .select) })
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = DirectoryViewController.navigationBarTitle

        /// Set the Table View
        self.tableView.register(
            DirectoryTableViewCell.nib(),
            forCellReuseIdentifier: DirectoryTableViewCell.identifier
        )
        self.tableView.delegate = self
        self.tableView.dataSource = self

        /// Set the Current Mode
        self.currMode = .view

        /// ModelManager
        self.directoryManager.observer = self
    }

    public func configure(directory: Directory) {
        self.directoryManager = DirectoryManager(current: directory, observer: self)
    }
    
    @IBAction func selectButtonPressed(_ sender: UIBarButtonItem) {
        self.currMode = .select
    }

    @IBAction func rearrangeButtonPressed(_ sender: UIBarButtonItem) {
        self.currMode = .rearrange
    }

    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.currMode = .view
    }

    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        if currMode == .select {
            directoryManager.deleteChildren(at: selectedIndexes)
            selectedIndexes = []
            currMode = .view
        }
    }

    @IBAction func moveButtonPressed(_ sender: UIBarButtonItem) {

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


extension DirectoryViewController: UITableViewDelegate {

}


extension DirectoryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch currMode {
        case .select:
            guard let selectedTableCell = tableView.cellForRow(at: indexPath)
                    as? DirectoryTableViewCell else {
                return
            }

            if selectedTableCell.isDirectorySelected {
                guard let index = selectedIndexes.first(where: { $0 == indexPath.row }) else {
                    return
                }
                selectedIndexes.removeAll(where: { $0 == index })
                selectedTableCell.isDirectorySelected = false
            } else {
                selectedIndexes.append(indexPath.row)
                selectedTableCell.isDirectorySelected = true
            }

        case .rearrange:
            return
        case .view:
            return
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return directoryManager.children.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let tableCell = tableView.dequeueReusableCell(withIdentifier: DirectoryTableViewCell.identifier, for: indexPath)
                as? DirectoryTableViewCell else {
            return UITableViewCell()
        }
        let directory = directoryManager.children[indexPath.row]
        let directoryType: DirectoryType = (directory is Project) ? .project : .folder

        tableCell.configure(
            directoryType: directoryType,
            name: directory.name,
            description: directory.description,
            dateUpdated: directory.dateUpdated,
            dateAdded: directory.dateAdded
        )
        self.observers.append(tableCell)
        return tableCell
    }


}

extension DirectoryViewController: UIPopoverPresentationControllerDelegate {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DirectoryViewController.addPopoverSegueIdentifier {
            let addPopoverViewController = segue.destination
            addPopoverViewController.modalPresentationStyle = .popover
            addPopoverViewController.preferredContentSize = CGSize(width: 200, height: 100)
        }

        if segue.identifier == DirectoryViewController.moveModalSegueIdentifier {
            guard let moveModalViewController = segue.destination as? DirectoryMoveModalViewController else {
                return
            }

            let parentFolder: Folder? = directoryManager.parent as? Folder
            var childrenFolders: [Folder] = []
            for (index, child) in directoryManager.children.enumerated() {
                if !selectedIndexes.contains(index) {
                    if let childFolder = child as? Folder {
                        childrenFolders.append(childFolder)
                    }
                }
            }
            moveModalViewController.configure(parentFolder: parentFolder, childrenFolders:childrenFolders, delegate: self)
        }

    }

}

extension DirectoryViewController: DirectoryViewControllerDelegate {

    func didSelectedDirectoriesMove(to folder: Folder) {
        directoryManager.moveChildren(indexes: selectedIndexes, to: folder)
        currMode = .view
    }

}

extension DirectoryViewController: DirectoryManagerObserver {
    func didChange() {
        tableView.reloadData()
    }
}

protocol DirectoryViewControllerDelegate {
    func didSelectedDirectoriesMove(to folder: Folder)
}

protocol DirectoryViewControllerObserver {
    func didModeChange(to mode: DirectoryMode)
}
