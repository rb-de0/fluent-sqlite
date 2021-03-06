import Async
import Debugging
import Foundation
import Fluent
import Service
import SQLite

extension DatabaseIdentifier {
    /// The main SQLite database identifier.
    public static var sqlite: DatabaseIdentifier<SQLiteDatabase> {
        return .init("sqlite")
    }
}

extension SQLiteDatabase: Database, Service {
    public typealias Connection = SQLiteConnection

    /// See `Database.makeConnection`
    public func makeConnection(
        using config: SQLiteConfig,
        on worker: Worker
    ) -> Future<SQLiteConnection> {
        return self.makeConnection(on: worker)
    }
}

func id(_ type: Any.Type) -> ObjectIdentifier {
    return ObjectIdentifier(type)
}

extension SQLiteDatabase: JoinSupporting {}

public struct SQLiteConfig: Service {
    public init() {}
}

extension SQLiteConnection: DatabaseConnection {
    public typealias Config = SQLiteConfig
    
    public func connect<D>(to database: DatabaseIdentifier<D>?) -> Future<D.Connection> {
        return Future.map(on: self) {
            guard let conn = self as? D.Connection else {
                throw FluentSQLiteError(identifier: "connect", reason: "Could not convert \(self) to \(D.self) connection", source: .capture())
            }
            return conn
        }
    }
}

extension SQLiteDatabase: LogSupporting {
    /// See SupportsLogging.enableLogging
    public func enableLogging(using logger: DatabaseLogger) {
        self.logger = logger
    }
}

extension DatabaseLogger: SQLiteLogger {
    /// See SQLiteLogger.log
    public func log(query: SQLiteQuery) {
        let log = DatabaseLog(
            query: query.string,
            values: query.binds.map { $0.description }
        )
        record(log: log)
    }
}
