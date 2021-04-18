//
//  LayerTableController.swift
//  Storyteller
//
//  Created by TFang on 30/3/21.
//

import PencilKit

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
    var onionSkinRange: OnionSkinRange!

    var layerSelection = [Bool]()
    var multipleSelectionIndices: [Int] {
        layerSelection.indices.filter({ layerSelection[$0] })
    }

    @IBOutlet private var editButton: UIButton!
    @IBOutlet private var groupButton: UIButton!
    @IBOutlet private var ungroupButton: UIButton!
    @IBOutlet private var addButton: UIButton!
    @IBOutlet private var backgroundColorButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelectionDuringEditing = true

        modelManager.observers.append(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setBackgroundColor()
        setUpLayerSelection()
        reselect()
    }
    private func setBackgroundColor() {
        guard let color = modelManager.getBackgroundColor(of: shotLabel) else {
            backgroundColorButton.backgroundColor = .white
            return
        }
        backgroundColorButton.backgroundColor = color
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

        guard let layerOrder = modelManager.getLayers(of: shotLabel) else {
            fatalError("Failed to get the layer at \(indexPath.row)")
        }

        let layer = layerOrder[indexPath.row]
        cell.setUp(thumbnail: layer.defaultThumbnail, name: layer.name,
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

        guard let layers = modelManager.getLayers(of: shotLabel) else {
            return
        }
        let layer = layers[sourceIndexPath.row]
        modelManager.moveLayer(layer.label, to: destinationIndexPath.row)
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
        groupButton.isEnabled = true
        ungroupButton.isEnabled = false
    }
    private func exitEditingMode() {
        tableView.setEditing(false, animated: true)
        editButton.setTitle("Edit", for: .normal)
        addButton.isHidden = false
        groupButton.isEnabled = false
        ungroupButton.isEnabled = true

        reselect()
        setUpLayerSelection()
    }
    @IBAction private func changeBackgroundColor() {
        let picker = UIColorPickerViewController()
        picker.selectedColor = modelManager.getBackgroundColor(of: shotLabel) ?? .white
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }

    @IBAction private func increasePrevOnionSkin() {
        onionSkinRange.decreaseLowerBound()
        delegate?.onionSkinsDidChange()
    }

    @IBAction private func decreasePrevOnionSkin() {
        onionSkinRange.increaseLowerBound()
        delegate?.onionSkinsDidChange()
    }

    @IBAction private func increaseNextOnionSkin() {
        onionSkinRange.increaseUpperBound()
        delegate?.onionSkinsDidChange()
    }

    @IBAction private func decreaseNextOnionSkin() {
        onionSkinRange.decreaseUpperBound()
        delegate?.onionSkinsDidChange()
    }

    // MARK: - Layers Actions
    @IBAction private func duplicateLayers() {
        guard tableView.isEditing else {
            duplicateSingleLayer()
            return
        }
        duplicateMultipleLayer()
    }
    private func duplicateSingleLayer() {
        delegate?.willDuplicateLayers(at: [selectedLayerIndex])

        guard let layers = modelManager.getLayers(of: shotLabel) else {
            return
        }
        let layer = layers[selectedLayerIndex]
        modelManager.duplicateLayers(withIds: [layer.id], of: shotLabel)
    }
    private func duplicateMultipleLayer() {
        delegate?.willDuplicateLayers(at: multipleSelectionIndices)

        guard let layers = modelManager.getLayers(of: shotLabel) else {
            return
        }

        var layerIds = [UUID]()
        for index in multipleSelectionIndices {
            let layer = layers[index]
            layerIds.append(layer.id)
        }

        modelManager.duplicateLayers(withIds: layerIds, of: shotLabel)
    }
    @IBAction private func groupLayers() {
        delegate?.willGroupLayers(at: multipleSelectionIndices)

        guard let layers = modelManager.getLayers(of: shotLabel) else {
            return
        }

        var layerIds = [UUID]()
        for index in multipleSelectionIndices {
            let layer = layers[index]
            layerIds.append(layer.id)
        }

        modelManager.groupLayers(withIds: layerIds, of: shotLabel)
    }
    @IBAction private func ungroupLayers() {
        delegate?.willUngroupLayer(at: selectedLayerIndex)

        guard let layers = modelManager.getLayers(of: shotLabel) else {
            return
        }
        let layer = layers[selectedLayerIndex]
        modelManager.ungroupLayer(withId: layer.id, of: shotLabel)
    }
    @IBAction private func deleteLayers() {
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
        delegate?.willRemoveLayers(at: [selectedLayerIndex])

        guard let layers = modelManager.getLayers(of: shotLabel) else {
            return
        }
        let layer = layers[selectedLayerIndex]
        modelManager.removeLayers(withIds: [layer.id], of: shotLabel)
    }
    private func deleteMultipleLayer() {
        guard numOfRows > multipleSelectionIndices.count else {
            Alert.presentAtLeastOneLayerAlert(controller: self)
            return
        }
        delegate?.willRemoveLayers(at: multipleSelectionIndices)

        guard let layers = modelManager.getLayers(of: shotLabel) else {
            return
        }

        var layerIds = [UUID]()
        for index in multipleSelectionIndices {
            let layer = layers[index]
            layerIds.append(layer.id)
        }

        modelManager.removeLayers(withIds: layerIds, of: shotLabel)
    }
    @IBAction private func addLayer(_ sender: Any) {
        modelManager.addLayer(to: shotLabel)
        selectedLayerIndex = numOfRows - 1
    }
}
// MARK: - UIColorPickerViewControllerDelegate
extension LayerTableController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        backgroundColorButton.backgroundColor = color
        modelManager.setBackgroundColor(of: shotLabel, using: color)
        delegate?.backgroundColorDidChange()
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
    func willRemoveLayers(at indices: [Int])
    func didMoveLayer(from oldIndex: Int, to newIndex: Int)
    func willDuplicateLayers(at indices: [Int])
    func willGroupLayers(at indices: [Int])
    func willUngroupLayer(at index: Int)
    func onionSkinsDidChange()
    func backgroundColorDidChange()
}
