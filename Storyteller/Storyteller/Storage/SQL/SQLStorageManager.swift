//
//  SQLStorageManager.swift
//  Storyteller
//
//  Created by mmarcus on 25/4/21.
//

import Foundation
import SQLite3

class SQLStorageManager: StorageManager {
    var db: OpaquePointer?

    init?() {
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK {
            print("Error opening database")
            return nil
        }
        let projectsTableQuery =
            SQLCreateTableQuery(
                table: .projects,
                columns: ["id": "INTEGER PRIMARY KEY", "title": "TEXT", "value": "TEXT"]
            )
        let scenesTableQuery =
            SQLCreateTableQuery(
                table: .scenes,
                columns: ["id": "INTEGER PRIMARY KEY", "title": "TEXT", "value": "TEXT"]
            )
        let shotsTableQuery =
            SQLCreateTableQuery(
                table: .shots,
                columns: ["id": "INTEGER PRIMARY KEY", "title": "TEXT", "value": "TEXT"]
            )
        let layersTableQuery =
            SQLCreateTableQuery(
                table: .shots,
                columns: ["id": "INTEGER PRIMARY KEY", "title": "TEXT", "value": "TEXT"]
            )
        if sqlite3_exec(db, projectsTableQuery.statement, nil, nil, nil) != SQLITE_OK {
            print("cannot create / open projects table")
            return nil
        }
        if sqlite3_exec(db, scenesTableQuery.statement, nil, nil, nil) != SQLITE_OK {
            print("cannot create / open scenes table")
            return nil
        }
        if sqlite3_exec(db, shotsTableQuery.statement, nil, nil, nil) != SQLITE_OK {
            print("cannot create / open shots table")
            return nil
        }
        if sqlite3_exec(db, layersTableQuery.statement, nil, nil, nil) != SQLITE_OK {
            print("cannot create / open layers table")
            return nil
        }
        print("SQLStorageManager DB successfully initialized, all tables created!")
    }

    func delete(layer: Layer) {
        let deleteQuery = SQLDeleteQuery(rowId: layer.id, table: .layers)
        sqlite3_exec(db, deleteQuery.statement, nil, nil, nil)
    }

    func delete(shot: Shot) {
        let deleteQuery = SQLDeleteQuery(rowId: shot.id, table: .shots)
        sqlite3_exec(db, deleteQuery.statement, nil, nil, nil)
    }

    func delete(scene: Scene) {
        let deleteQuery = SQLDeleteQuery(rowId: scene.id, table: .scenes)
        sqlite3_exec(db, deleteQuery.statement, nil, nil, nil)
    }

    func delete(project: Project) {
        let deleteQuery = SQLDeleteQuery(rowId: project.id, table: .projects)
        sqlite3_exec(db, deleteQuery.statement, nil, nil, nil)
    }

    func save(layer: Layer) {
        let codableLayer = PersistedLayer(layer)
        let jsonData = try! JSONEncoder().encode(codableLayer)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        let updateQuery = SQLUpdateQuery(rowId: layer.id,
                                         table: .layers,
                                         updates: ["value": jsonString])
        if sqlite3_exec(db, updateQuery.statement, nil, nil, nil) == SQLITE_OK {
            return
        }
        let insertQuery = SQLInsertQuery(table: .layers,
                                         values: [layer.id.uuidString, layer.name, jsonString])
        sqlite3_exec(db, insertQuery.statement, nil, nil, nil)
    }

    func save(shot: Shot) {
        let values = shot.layers.map({ $0.id.uuidString })
        let valuesString = values.joined(separator: "_")
        let updateQuery = SQLUpdateQuery(rowId: shot.id,
                                         table: .shots,
                                         updates: ["value": valuesString])
        if sqlite3_exec(db, updateQuery.statement, nil, nil, nil) == SQLITE_OK {
            return
        }
        let insertQuery = SQLInsertQuery(table: .shots,
                                         values: [shot.id.uuidString, "shotTitle", valuesString])
        sqlite3_exec(db, insertQuery.statement, nil, nil, nil)
    }

    func save(scene: Scene) {
        let values = scene.shots.map({ $0.id.uuidString })
        let valuesString = values.joined(separator: "_")
        let updateQuery = SQLUpdateQuery(rowId: scene.id,
                                         table: .scenes,
                                         updates: ["value": valuesString])
        if sqlite3_exec(db, updateQuery.statement, nil, nil, nil) == SQLITE_OK {
            return
        }
        let insertQuery = SQLInsertQuery(table: .scenes,
                                         values: [scene.id.uuidString, "sceneTitle", valuesString])
        sqlite3_exec(db, insertQuery.statement, nil, nil, nil)
    }

    func save(project: Project) {
        let values = project.scenes.map({ $0.id.uuidString })
        let valuesString = values.joined(separator: "_")
        let updateQuery = SQLUpdateQuery(rowId: project.id,
                                         table: .projects,
                                         updates: ["value": valuesString])
        if sqlite3_exec(db, updateQuery.statement, nil, nil, nil) == SQLITE_OK {
            return
        }
        let insertQuery = SQLInsertQuery(table: .projects,
                                         values: [project.id.uuidString, project.title, valuesString])
        sqlite3_exec(db, insertQuery.statement, nil, nil, nil)
    }

}
