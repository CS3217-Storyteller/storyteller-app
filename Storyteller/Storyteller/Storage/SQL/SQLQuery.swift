//
//  SQLQuery.swift
//  Storyteller
//
//  Created by mmarcus on 25/4/21.
//

import Foundation

protocol SQLQuery {
    var table: SQLTable { get }
    var statement: String { get }
}

struct SQLInsertQuery: SQLQuery {
    let table: SQLTable
    let values: [String]
    var statement: String {
        SQLQueryParser().getStatement(query: self)
    }
}

struct SQLUpdateQuery: SQLQuery {
    let rowId: UUID
    let table: SQLTable
    let updates: [String: String] // columnName: value
    var statement: String {
        SQLQueryParser().getStatement(query: self)
    }
}

struct SQLDeleteQuery: SQLQuery {
    let rowId: UUID
    let table: SQLTable
    var statement: String {
        SQLQueryParser().getStatement(query: self)
    }
}

struct SQLCreateTableQuery: SQLQuery {
    let table: SQLTable
    let columns: [String: String] // columnName: dataType
    var statement: String {
        SQLQueryParser().getStatement(query: self)
    }
}
