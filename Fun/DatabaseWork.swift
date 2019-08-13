//
// Created by Jacob Rein on 2019-08-13.
// Copyright (c) 2019 Jake Rein. All rights reserved.
//

import Foundation
import SQLite

class DatabaseWork {
    private var db: Connection!
    private let shows = Table("show_table")
    private let showLink = Expression<String>("show_link")
    private let showName = Expression<String>("show_name")

    init() {
        let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
        ).first!
        db = try! Connection("\(path)/fun.sqlite3")
        //db = try! Connection()
        try! db.run(shows.create(ifNotExists: true) { t in
            t.column(showName, primaryKey: true)
            t.column(showLink)
        })
    }

    @discardableResult
    func insert(_ name: String, _ link: String) -> Int64 {
        let insert = shows.insert(showName <- name, showLink <- link)
        let rowid = try! db.run(insert)
        return rowid
    }

    @discardableResult
    func delete(_ link: String) -> Int {
        let show = shows.filter(showLink == link)
        return try! db.run(show.delete())
    }

    func count() -> Int {
        return try! db.scalar(shows.count)
    }

    func getAll() -> Array<Row> {
        return Array(try! db.prepare(shows))
    }

    func getAllShows() -> Array<ShowInfo> {
        var show = [ShowInfo]()
        for s in try! db.prepare(shows) {
            show.append(ShowInfo(name: s[showName], link: s[showLink]))
        }
        return show
    }

    func findShowByLink(_ link: String) -> ShowInfo? {
        var show: ShowInfo? = nil
        for s in try! db.prepare(shows) {
            if (s[showLink] == link) {
                show = ShowInfo(name: s[showName], link: s[showLink])
                break
            }
        }
        return show
    }

    func findShowByName(_ name: String) -> ShowInfo? {
        var show: ShowInfo? = nil
        for s in try! db.prepare(shows) {
            if (s[showName] == name) {
                show = ShowInfo(name: s[showName], link: s[showLink])
                break
            }
        }
        return show
    }

}

class ShowInfo: Codable {
    var name: String? = ""
    var link: String? = ""
    var showNum: Int = 0

    init(name: String?, link: String?) {
        self.name = name
        self.link = link
    }
}