//
//  SQLQueryParser.swift
//  Storyteller
//
//  Created by mmarcus on 25/4/21.
//

import Foundation

struct SQLQueryParser {
    func getStatement(query: SQLInsertQuery) -> String {
        let stringedValues = query.values
            .joined(separator: ", ")
        return "INSERT INTO \(query.table.rawValue) VALUES (\(stringedValues));"
    }

    func getStatement(query: SQLUpdateQuery) -> String {
        let stringedUpdates = query.updates
            .map { column, value in
                "\(column) = \(value)"
            }
        return "UPDATE \(query.table.rawValue) SET \(stringedUpdates) WHERE ID = \(query.rowId);"
    }

    func getStatement(query: SQLDeleteQuery) -> String {
        "DELETE FROM \(query.table.rawValue) WHERE ID = \(query.rowId.uuidString);"
    }

    func getStatement(query: SQLCreateTableQuery) -> String {
        let stringedColumns = query.columns
            .map{ column, datatype in
                "\(column) \(datatype)"
            }
            .joined(separator: ", ")
        return "CREATE TABLE IF NOT EXIST \(query.table.rawValue) (\(stringedColumns));"
    }
}
