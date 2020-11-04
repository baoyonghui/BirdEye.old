//
//  MissionViewController.swift
//  Zond
//
//  Created by Evgeny Agamirzov on 4/6/19.
//  Copyright © 2019 Evgeny Agamirzov. All rights reserved.
//

import os.log
import SwiftHTTP
import DJISDK
import MobileCoreServices
import UIKit

enum FlyLineState {
    case managing
    case editing
}

struct Misson : Codable {
    struct Feature : Codable {
        struct Properties : Codable {
            let distance: Float
            let angle: Float
            let shoot: Float
            let altitude: Float
            let speed: Float
        }

        struct Geometry : Codable {
            let type: String
            let coordinates: [[[Double]]]
        }

        let properties: Properties
        let geometry: Geometry
    }

    let features: [Feature]
}

fileprivate var missionData = TableData([
    SectionData(
        id: .editor,
        rows: [
            RowData(id: .gridDistance,  type: .slider,  value: Float(10.0),          isEnabled: true) ,
            RowData(id: .gridAngle,     type: .slider,  value: Float(0.0),           isEnabled: true) ,
            RowData(id: .shootDistance, type: .slider,  value: Float(10.0),          isEnabled: true) ,
            RowData(id: .altitude,      type: .slider,  value: Float(50.0),          isEnabled: true) ,
            RowData(id: .flightSpeed,   type: .slider,  value: Float(10.0),          isEnabled: true)
        ]),
])

class MissionViewController : UIViewController {
    // Stored properties
    private var missionView: MissionView!
    private var tableData: TableData = missionData

    // Observer properties
    private var flyLineState: FlyLineState? {
        didSet {
            for listener in stateListeners {
                listener?(flyLineState)
            }
        }
    }

    // Notyfier properties
    var stateListeners: [((_ state: FlyLineState?) -> Void)?] = []
    var logConsole: ((_ message: String, _ type: OSLogType) -> Void)?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    let dummyData = ["Stark", "Targaeryan", "Boratheon", "Martell", "Lannister", "Tyrell", "Walder Frey"]

    init() {
        super.init(nibName: nil, bundle: nil)
        setUp()
    }
    
    func setUp(){
        missionView = MissionView(tableData.contentHeight)
        missionView.tableView.dataSource = self
        missionView.tableView.delegate = self
        missionView.tableView.register(TableSection.self, forHeaderFooterViewReuseIdentifier: SectionType.spacer.reuseIdentifier)
        missionView.tableView.register(TableCommandCell.self, forCellReuseIdentifier: RowType.command.reuseIdentifier)
        missionView.tableView.register(TableSliderCell.self, forCellReuseIdentifier: RowType.slider.reuseIdentifier)
        //missionView.tableView.register(DoubleButtonTableViewCell.self, forCellReuseIdentifier: identifier)
        registerListeners()
        view = missionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// Private methods
extension MissionViewController {
    
    private func registerListeners() {
        missionView.missionButtonPressed = {
            if self.flyLineState == nil {
                self.flyLineState = FlyLineState.editing
            } else if self.flyLineState == .editing {
                self.flyLineState = nil
            }
        }
        
        Environment.connectionService.listeners.append({ model in
            if model == nil {
                self.tableData.enableRow(at: IdPath(.command, .command), false)
                if self.flyLineState == .managing {
                    self.flyLineState = FlyLineState.editing
                }
            } else {
                self.tableData.enableRow(at: IdPath(.command, .command), true)
                self.tableData.updateRow(at: IdPath(.command, .command), with: FlyLineState.editing)
            }
        })
        stateListeners.append({ state in
            self.missionView.expand(for: state)
            if state != nil {
                self.tableData.updateRow(at: IdPath(.command, .command), with: state!)
            }
        })
    }

    private func sliderMoved(at idPath: IdPath, to value: Float) {
        tableData.updateRow(at: idPath, with: value)
        switch idPath{
            case IdPath(.editor, .gridDistance):
                Environment.mapViewController.flyLinePolygon?.gridDistance = CGFloat(value)
                Environment.commandService.missionParameters.turnRadius = (Float(value) / 2) - 10e-6
            case IdPath(.editor, .gridAngle):
                Environment.mapViewController.flyLinePolygon?.gridAngle = CGFloat(value)
            case IdPath(.editor, .altitude):
                Environment.commandService.missionParameters.altitude = Float(value)
            case IdPath(.editor, .shootDistance):
                Environment.commandService.missionParameters.shootDistance = Float(value)
            case IdPath(.editor, .flightSpeed):
                Environment.commandService.missionParameters.flightSpeed = Float(value)
            default:
                break
        }
    }

    private func buttonPressed(with id: CommandButtonId) {

    }

    private func commandCell(for rowData: RowData<Any>, at indexPath: IndexPath, in tableView: UITableView) -> TableCommandCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rowData.type.reuseIdentifier, for: indexPath) as! TableCommandCell
        cell.buttonPressed = { id in
            self.buttonPressed(with: id)
        }
        rowData.updated = {
            cell.updateData(rowData)
        }
        //cell.buttonDelegate = self
        return cell
    }

    private func sliderCell(for rowData: RowData<Any>, at indexPath: IndexPath, in tableView: UITableView) -> TableSliderCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rowData.type.reuseIdentifier, for: indexPath) as! TableSliderCell

        // Slider default values in the data source should be delivered to the
        // respective components upon creation, thus simulate slider "move" to the
        // initial value which will notify a subscriber of the respective parameter.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.sliderMoved(at: IdPath(.editor, rowData.id), to: rowData.value as! Float)
        }

        cell.sliderMoved = { id , value in
            self.sliderMoved(at: id, to: value)
        }
        rowData.updated = {
            cell.updateData(rowData)
        }
        return cell
    }
}

// Table view data source
extension MissionViewController : UITableViewDataSource {
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.sections.count
    }

    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.sections[section].rows.count
    }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        let rowData = tableData.rowData(at: indexPath)
        switch rowData.type {
            case .command:
                cell = commandCell(for: rowData, at: indexPath, in: tableView)
                /*
                let result = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                if let cell2 = result as? DoubleButtonTableViewCell {
                    
                    var text = "No Title"
                    if indexPath.row < dummyData.count {
                        text = dummyData[indexPath.row]
                        cell2.color = indexPath.row % 3 == 0 ? UIColor.lightGray : UIColor.darkGray
                        cell2.load(text: text, indexPath: indexPath, buttonDelegate: self, leftButtonImage: UIImage(named:"clearButton"), rightButtonImage: UIImage(named:"rightCircleCarat"))
                        
                    }
                    return cell2
                }*/
            case .slider:
                cell = sliderCell(for: rowData, at: indexPath, in: tableView)
        }
        rowData.updated?()
        return cell
    }

}

// Table view apperance
extension MissionViewController : UITableViewDelegate {
    internal func tableView(_ tableView: UITableView, heightForRowAt: IndexPath) -> CGFloat {
        return tableData.rowHeight
    }

    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableData.sections[section].id.headerHeight
    }

    internal func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableData.sections[section].id.footerHeight
    }

    internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return missionView.tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionType.spacer.reuseIdentifier) as! TableSection
    }

    internal func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return missionView.tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionType.spacer.reuseIdentifier) as! TableSection
    }
}

// Document picker updates
extension MissionViewController : UIDocumentPickerDelegate {
    internal func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let jsonUrl = urls.first {
            do {
                let jsonFile = try String(contentsOf: jsonUrl, encoding: .utf8)
                do {
                    let jsonData = jsonFile.data(using: .utf8)!
                    let decoder = JSONDecoder()
                    let mission = try decoder.decode(Misson.self, from: jsonData).features[0]

                    sliderMoved(at: IdPath(.editor, .gridDistance), to: mission.properties.distance)
                    sliderMoved(at: IdPath(.editor, .gridAngle), to: mission.properties.angle)
                    sliderMoved(at: IdPath(.editor, .shootDistance), to: mission.properties.shoot)
                    sliderMoved(at: IdPath(.editor, .altitude), to: mission.properties.altitude)
                    sliderMoved(at: IdPath(.editor, .flightSpeed), to: mission.properties.speed)

                    if mission.geometry.type == "Polygon"  && !mission.geometry.coordinates.isEmpty {
                        // First element of the geometry is always the outer polygon
                        var rawCoordinates = mission.geometry.coordinates[0]
                        rawCoordinates.removeLast()
                        Environment.mapViewController.showMissionPolygon(rawCoordinates)
                    }
                } catch {
                    logConsole?("JSON parse error: \(error)", .error)
                }
            } catch {
                logConsole?("JSON read error: \(error)", .error)
            }
        }
    }
}
