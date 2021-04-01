//
//  LayerTableController.swift
//  Storyteller
//
//  Created by TFang on 30/3/21.
//

import UIKit

class LayerTableController: UITableViewController {
    var selectedLayerIndex = 0 {
        didSet {
            delegate?.didSelectLayer(at: selectedLayerIndex)
        }
    }
    weak var delegate: LayerTableDelegate?

    // should be intialized via segue
    var modelManager: ModelManager!
    var shotLabel: ShotLabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        modelManager.observers.append(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let indexPath = IndexPath(row: selectedLayerIndex, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    }
}

extension LayerTableController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let layerCount = modelManager.getLayers(of: shotLabel)?.count else {
            fatalError("Failed to get the number of layers")
        }

        return layerCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard selectedLayerIndex != indexPath.row else {
            // TODO: rename layer name process
            return
        }
        selectedLayerIndex = indexPath.row
    }
}

// MARK: - ModelManagerObserver
extension LayerTableController: ModelManagerObserver {
    func modelDidChanged() {
        tableView.reloadData()
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
}
