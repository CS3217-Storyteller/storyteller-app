//
//  LayerTableController.swift
//  Storyteller
//
//  Created by TFang on 30/3/21.
//

import UIKit

class LayerTableController: UIViewController {
    var numOfRows: Int {
        tableView.numberOfRows(inSection: 0)
    }
    var selectedLayerIndex = 0 {
        didSet {
            guard tableView != nil else {
                return
            }
            guard selectedLayerIndex < numOfRows else {
                selectedLayerIndex = numOfRows - 1
                return
            }
            tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .none)
            delegate?.didSelectLayer(at: selectedLayerIndex)
        }
    }
    var selectedIndexPath: IndexPath {
        IndexPath(row: selectedLayerIndex, section: 0)
    }
    weak var delegate: LayerTableDelegate?

    @IBOutlet private var tableView: UITableView!

    // should be intialized via segue
    var modelManager: ModelManager!
    var shotLabel: ShotLabel!

    var layerSelection = [Bool]()
    var multipleSelectionIndices: [Int] {
        layerSelection.indices.filter({ layerSelection[$0] })
    }

    @IBOutlet private var editButton: UIButton!
    @IBOutlet private var duplicateLayerButton: UIButton!
    @IBOutlet private var mergeButton: UIButton!
    @IBOutlet private var deleteButton: UIButton!
    @IBOutlet private var addButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelectionDuringEditing = true

        modelManager.observers.append(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpLayerSelection()
        reselect()
    }
    private func reselect() {
        let selected = selectedLayerIndex
        selectedLayerIndex = selected
    }
    func setUpLayerSelection() {
        let count = modelManager.getLayers(of: shotLabel)?.count ?? 0
        layerSelection = Array(repeating: false, count: count)
    }

}

// MARK: - UITableViewDataSource
extension LayerTableController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let layerCount = modelManager.getLayers(of: shotLabel)?.count else {
            fatalError("Failed to get the number of layers")
        }

        return layerCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: LayerTableViewCell.identifier,
                for: indexPath) as? LayerTableViewCell else {
            fatalError("Cannot get reusable cell.")
        }

        guard let layer = modelManager.getLayer(at: indexPath.row, of: shotLabel) else {
            fatalError("Failed to get the layer at \(indexPath.row)")
        }

        cell.setUp(thumbnail: layer.thumbnail, name: layer.name,
                   isLocked: layer.isLocked, isVisible: layer.isVisible)
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension LayerTableController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView.isEditing else {
            selectSingleLayer(at: indexPath)
            return
        }
        selectLayerDuringEditing(at: indexPath)
    }
    private func selectSingleLayer(at indexPath: IndexPath) {
        guard selectedLayerIndex != indexPath.row else {
            // TODO: rename layer name process
            return
        }
        selectedLayerIndex = indexPath.row
    }
    private func selectLayerDuringEditing(at indexPath: IndexPath) {
        layerSelection[indexPath.row] = true
        selectedLayerIndex = indexPath.row
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.isEditing else {
            return
        }
        layerSelection[indexPath.row] = false
    }
    func tableView(_ tableView: UITableView,
                   moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        delegate?.didMoveLayer(from: sourceIndexPath.row, to: destinationIndexPath.row)
        modelManager.moveLayer(from: sourceIndexPath.row,
                               to: destinationIndexPath.row, of: shotLabel)
        selectedLayerIndex = destinationIndexPath.row
    }
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
}
// MARK: - Actions
extension LayerTableController {
    @IBAction private func toggleEditMode(_ sender: Any) {
        let isEditing = tableView.isEditing
        if isEditing {
            exitEditingMode()
        } else {
            enterEditingMode()
        }
    }
    private func enterEditingMode() {
        tableView.setEditing(true, animated: true)
        editButton.setTitle("Done", for: .normal)
        addButton.isHidden = true
    }
    private func exitEditingMode() {
        tableView.setEditing(false, animated: true)
        editButton.setTitle("Edit", for: .normal)
        addButton.isHidden = false

        reselect()
        setUpLayerSelection()
    }
    @IBAction private func changeBackgroundColor() {
    }

    @IBAction private func prevOnionSkin() {
    }

    @IBAction private func nextOnionSkin() {
    }

    // MARK: - Layers Actions
    @IBAction private func duplicateLayers(_ sender: Any) {
    }

    @IBAction private func mergeLayers(_ sender: Any) {
    }

    @IBAction private func deleteLayers(_ sender: Any) {
        guard tableView.isEditing else {
            deleteSingleLayer()
            return
        }
        deleteMultipleLayer()
    }
    private func deleteSingleLayer() {
        guard numOfRows > 1 else {
            Alert.presentAtLeastOneLayerAlert(controller: self)
            selectedLayerIndex = 0
            return
        }
        delegate?.didRemoveLayers(at: [selectedLayerIndex])
        modelManager.removeLayers(at: [selectedLayerIndex], of: shotLabel)
    }
    private func deleteMultipleLayer() {
        guard numOfRows > multipleSelectionIndices.count else {
            Alert.presentAtLeastOneLayerAlert(controller: self)
            return
        }
        delegate?.didRemoveLayers(at: multipleSelectionIndices)
        modelManager.removeLayers(at: multipleSelectionIndices, of: shotLabel)
    }
    @IBAction private func addLayer(_ sender: Any) {
        modelManager.addLayer(to: shotLabel)
        selectedLayerIndex = numOfRows - 1
    }

}
// MARK: - ModelManagerObserver
extension LayerTableController: ModelManagerObserver {
    func modelDidChange() {
        tableView.reloadData()

        setUpLayerSelection()

        guard !tableView.isEditing else {
            return
        }
        reselect()
    }
}

// MARK: - LayerCellDelegate
extension LayerTableController: LayerCellDelegate {

    func didToggleLayerLock(cell: LayerTableViewCell) {
        guard let index = tableView.indexPath(for: cell)?.row else {
            return
        }
        delegate?.didToggleLayerLock(at: index)
    }

    func didToggleLayerVisibility(cell: LayerTableViewCell) {
        guard let index = tableView.indexPath(for: cell)?.row else {
            return
        }
        delegate?.didToggleLayerVisibility(at: index)
    }

    func didChangeLayerName(cell: LayerTableViewCell, newName: String) {
        guard let index = tableView.indexPath(for: cell)?.row else {
            return
        }
        delegate?.didChangeLayerName(at: index, newName: newName)
    }
}

protocol LayerTableDelegate: AnyObject {
    func didSelectLayer(at index: Int)
    func didToggleLayerLock(at index: Int)
    func didToggleLayerVisibility(at index: Int)
    func didChangeLayerName(at index: Int, newName: String)
    func didRemoveLayers(at indices: [Int])
    func didMoveLayer(from oldIndex: Int, to newIndex: Int)
}
