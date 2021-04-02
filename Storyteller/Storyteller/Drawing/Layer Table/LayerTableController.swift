//
//  LayerTableController.swift
//  Storyteller
//
//  Created by TFang on 30/3/21.
//

import UIKit

class LayerTableController: UIViewController {
    var selectedLayerIndex = 0 {
        didSet {
            delegate?.didSelectLayer(at: selectedLayerIndex)
        }
    }
    weak var delegate: LayerTableDelegate?

    @IBOutlet private var tableView: UITableView!

    // should be intialized via segue
    var modelManager: ModelManager!
    var shotLabel: ShotLabel!

    var layerSelection = [Bool]()

    @IBOutlet private var editButton: UIButton!
    @IBOutlet private var duplicateLayerButton: UIButton!
    @IBOutlet private var mergeButton: UIButton!
    @IBOutlet private var deleteButton: UIButton!
    @IBOutlet private var addButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
//        tableView.allowsSelectionDuringEditing = true

        modelManager.observers.append(self)
        setUpLayerSelection()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let indexPath = IndexPath(row: selectedLayerIndex, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
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
            guard indexPath.section == 0 else {
                // TODO: add background cell
                return UITableViewCell()
            }

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
        guard indexPath.section == 0 else {
            // TODO: add changing background
            return
        }
        guard selectedLayerIndex != indexPath.row else {
            // TODO: rename layer name process
            return
        }
        selectedLayerIndex = indexPath.row
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else {
            return
        }
        // TODO: remove this
        if editingStyle == .delete {
            modelManager.removeLayers(at: [indexPath.row], of: shotLabel)
            delegate?.didRemoveLayers(at: [indexPath.row])
        } else if editingStyle == .insert {
            modelManager.addLayer(to: shotLabel)
            delegate?.didAddLayer()
        }
    }

    func tableView(_ tableView: UITableView,
                   moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        guard sourceIndexPath.section == 0 else {
            return
        }
        modelManager.moveLayer(from: sourceIndexPath.row,
                               to: destinationIndexPath.row, of: shotLabel)
        delegate?.didMoveLayer(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
}
// MARK: - Actions
extension LayerTableController {
    @IBAction private func toggleEditMode(_ sender: UIButton) {
        let isEditing = tableView.isEditing
        if isEditing {
            tableView.setEditing(false, animated: true)
            sender.setTitle("Edit", for: .normal)
        } else {
            tableView.setEditing(true, animated: true)
            sender.setTitle("Done", for: .normal)
        }
    }
    @IBAction private func duplicateLayers(_ sender: Any) {
    }

    @IBAction private func mergeLayers(_ sender: Any) {
    }

    @IBAction private func deleteLayers(_ sender: Any) {

    }

    @IBAction private func addLayer(_ sender: Any) {
        modelManager.addLayer(to: shotLabel)
        delegate?.didAddLayer()
    }
}
// MARK: - ModelManagerObserver
extension LayerTableController: ModelManagerObserver {
    func modelDidChanged() {
        tableView.reloadData()

        setUpLayerSelection()

        let indexPath = IndexPath(row: selectedLayerIndex, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
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
    func didAddLayer()
    func didMoveLayer(from oldIndex: Int, to newIndex: Int)
}
