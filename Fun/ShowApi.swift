//
//  ShowApi.swift
//  Fun
//
//  Created by Jake Rein on 12/22/18.
//  Copyright © 2018 Jake Rein. All rights reserved.
//

import Foundation
import SwiftSoup
import SDDownloadManager
import MZDownloadManager
import Digger
import Photos
import UIKit
import Alamofire
import JGProgressHUD
import UserNotifications
import AudioToolbox
import SwiftyJSON
import Kanna
import WebKit

extension String {
    func regexed(pat: String, modify: @escaping (String) -> String = { s in
        s.lowercased()
    }) -> [String] {
        if let regex = try? NSRegularExpression(pattern: pat, options: .caseInsensitive) {
            let string = self as NSString
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                modify(string.substring(with: $0.range).replacingOccurrences(of: "#", with: ""))
            }
        }

        return []
    }

    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

extension Substring {
    func toString() -> String {
        return String(self)
    }
}

func getUrl(url: String) -> String {
    let myURLString = url
    guard let myURL = URL(string: myURLString) else {
        //print("Error: \(myURLString) doesn't seem to be a valid URL")
        return myURLString// as String
    }

    do {
        let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
        //print("HTML : \(myHTMLString)")
        return myHTMLString// as String
    } catch let error {
        //print("Error: \(error)")
        return error.localizedDescription as String
    }
}

public enum Source {
    case RECENT_ANIME, RECENT_CARTOON, ANIME, CARTOON, DUBBED, ANIME_MOVIES, CARTOON_MOVIES, LIVE_ACTION, FAVORITES

    var url: String {
        switch self {
        case .RECENT_ANIME:
            return "https://www.gogoanime1.com/home/latest-episodes"
        case .RECENT_CARTOON:
            return "http://www.animetoon.org/updates"
        case .ANIME:
            return "https://www.gogoanime1.com/home/anime-list"
        case .CARTOON:
            return "http://www.animetoon.org/cartoon"
        case .DUBBED:
            return "http://www.animetoon.org/dubbed-anime"
        case .ANIME_MOVIES:
            return "https://www.gogoanime1.com/home/anime-list"
        case .CARTOON_MOVIES:
            return "http://www.animetoon.org/movies"
        case .LIVE_ACTION:
            return "https://www.putlocker.fyi/a-z-shows/"
        case .FAVORITES:
            return "Favorite"
        }
    }
    var recent: Bool {
        switch self {
        case .RECENT_ANIME:
            return true
        case .RECENT_CARTOON:
            return true
        default:
            return false
        }
    }

    var movie: Bool {
        switch self {
        case .ANIME_MOVIES, .CARTOON_MOVIES:
            return true
        default:
            return false
        }
    }

    var rawValue: String {
        switch self {
        case .RECENT_ANIME:
            return "Recent Anime"
        case .RECENT_CARTOON:
            return "Recent Cartoon"
        case .ANIME:
            return "Anime"
        case .CARTOON:
            return "Cartoon"
        case .DUBBED:
            return "Dubbed"
        case .ANIME_MOVIES:
            return "Anime Movies"
        case .CARTOON_MOVIES:
            return "Cartoon Movies"
        case .LIVE_ACTION:
            return "Live Action"
        case .FAVORITES:
            return "Favorites"
        }
    }

}

public struct NameAndLink {
    let name: String
    let url: String

    public init(name: String, url: String) {
        self.name = name
        self.url = url
    }
}

public class ShowApi: NSObject {

    var showList: [NameAndLink] = [NameAndLink]()

    init(source: Source) {
        super.init()
        showList = source.recent ? self.getRecentVideoList(url: source.url) : self.getMovieOrVideo(source: source)
    }

    private func getRecentVideoList(url: String) -> [NameAndLink] {
        if (url.contains("gogoanime")) {
            var list = [NameAndLink]()
            do {
                let html: String = getUrl(url: url) as String
                let doc: Document = try SwiftSoup.parse(html)
                let listOfStuff = try doc.getAllElements().select("div.dl-item")
                for element in listOfStuff.array() {
                    let tempUrl = try element.select("div.name").select("a[href^=http]").attr("abs:href")
                    if let endIndex = tempUrl.range(of: "/episode")?.lowerBound {
                        print(tempUrl[..<endIndex])
                        try list.append(NameAndLink(name: element.select("div.name").text(), url: tempUrl[..<endIndex].toString()))
                    }
                    //try list.append(NameAndLink(name: element.select("div.name").text(), url: tempUrl[..<endIndex]))
                }
                return list
            } catch Exception.Error(_, let message) {
                print(message)
            } catch {
                print("error")
            }
        } else {
            //get recent list
            var list = [NameAndLink]()
            do {
                let html: String = getUrl(url: url) as String;
                let doc: Document = try SwiftSoup.parse(html)
                var link: Elements = try doc.select("div.left_col").select("table#updates").select("a[href^=http]")
                if (link.size() == 0) {
                    link = try doc.select("div.s_left_col").select("table#updates").select("a[href^=http]")
                }
                for elem in link.array() {
                    let linked = try elem.attr("abs:href")
                    let named = try elem.text()
                    //track("\(linked) and \(named)")
                    if (!named.contains("Episode")) {
                        list.append(NameAndLink(name: named, url: linked))
                    }
                }
            } catch Exception.Error(_, let message) {
                print(message)
            } catch {
                print("error")
            }
            return list
        }
        return [NameAndLink]()
    }

    private func getMovieOrVideo(source: Source) -> [NameAndLink] {
        if (source == Source.FAVORITES) {
            let db = DatabaseWork()
            let all = db.getAllShows()
            var list = [NameAndLink]()
            for s in all {
                list.append(NameAndLink(name: s.name!, url: s.link!))
            }
            return list
        } else if (source.movie && source == Source.ANIME_MOVIES) {
            let list = getVideoList(url: source.url)
            let filtered = list.filter {
                $0.name.range(of: "movie", options: .caseInsensitive) != nil
            }
            return filtered
        } else {
            return getVideoList(url: source.url)
        }
    }

    private func getVideoList(url: String) -> [NameAndLink] {
        if (url.contains("putlocker")) {
            var list = [NameAndLink]()
            do {
                let html: String = getUrl(url: url) as String
                let doc: Document = try SwiftSoup.parse(html)
                let d = try doc.select("a.az_ls_ent")
                for element in d.array() {
                    try list.append(NameAndLink(name: element.text(), url: "https://www.putlocker.fyi" + element.attr("href")))
                }
                return list
            } catch Exception.Error(_, let message) {
                print(message)
            } catch {
                print("error")
            }
        } else if (url.contains("gogoanime")) {
            var list = [NameAndLink]()
            do {
                let html: String = getUrl(url: url) as String
                let doc: Document = try SwiftSoup.parse(html)
                let listOfStuff = try doc.getAllElements().select("ul.arrow-list").select("li")
                for element in listOfStuff.array() {
                    try list.append(NameAndLink(name: element.text(), url: element.select("a[href^=http]").attr("abs:href")))
                }
                list.sort(by: {
                    $0.name > $1.name
                })
                return list
            } catch Exception.Error(_, let message) {
                print(message)
            } catch {
                print("error")
            }
        } else {
            //get list
            var list = [NameAndLink]()
            do {

                let html: String = getUrl(url: url) as String;
                let doc: Document = try SwiftSoup.parse(html)
                let link: Elements = try doc.select("td").select("a[href^=http]")
                for elem in link.array() {
                    let linked = try elem.attr("abs:href")
                    let named = try elem.text()
                    //track("\(linked) and \(named)")
                    if (!named.contains("Episode")) {
                        list.append(NameAndLink(name: named, url: linked))
                    }
                }
            } catch Exception.Error(_, let message) {
                print(message)
            } catch {
                print("error")
            }
            list.sort(by: {
                $0.name > $1.name
            })
            return list
        }
        return [NameAndLink]()
    }

}

public class EpisodeApi: NSObject {

    var name: String = ""
    var imageUrl: String = ""
    var des: String = ""
    var episodeList: [EpisodeInfo] = [EpisodeInfo]()

    static func getName(url: String) -> String {
        do {
            let html: String = getUrl(url: url) as String;
            let doc: Document = try SwiftSoup.parse(html)

            if (url.contains("putlocker")) {
                return try doc.select("li.breadcrumb-item").last()!.text()
            } else if (url.contains("gogoanime")) {
                return try doc.select("div.anime-title").text()
            } else {
                return try doc.select("div.right_col h1").text()
            }
        } catch Exception.Error(_, let message) {
            print(message)
        } catch {
            print("error")
        }
        return ""
    }

    init(url: String) {
        super.init()
        do {

            let html: String = getUrl(url: url) as String;
            let doc: Document = try SwiftSoup.parse(html)

            if (url.contains("putlocker")) {
                self.name = try doc.select("li.breadcrumb-item").last()!.text()
                self.imageUrl = try doc.select("div.thumb").select("img[src^=http]").attr("abs:src")
                //"https://raw.githubusercontent.com/scinfu/SwiftSoup/master/swifsoup.png"
                let infoUrl = "http://www.omdbapi.com/?t=\(self.name.replacingOccurrences(of: " ", with: "+"))&plot=full&apikey=e91b86ee"

                self.des = "None right now"

                let response = AF.request(infoUrl, method: .get, encoding: JSONEncoding.default).responseJSON()

                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let year = json["Year"]
                    let released = json["Released"]
                    let plot = json["Plot"]
                    self.des = "Years Active: \(year)\nReleased: \(released)\n\(plot)"
                case .failure(let error):
                    print(error)
                    do {
                        track("\(error.localizedDescription)")
                        var textToReturn = ""
                        let dest = try doc.select(".mov-desc")
                        let para = try dest.select("p")
                        var count = 1
                        for i in para.enumerated() {
                            let text = try i.element.text()
                            textToReturn += text + "\n"
                            count += 1
                        }
                        self.des = textToReturn
                    } catch {
                        self.des = "Unable to Retrieve"
                    }
                }

                let rowList = try doc.select("div.col-lg-12").select("div.row")
                let episodes = try rowList.select("a.btn-episode")
                for i in episodes.array() {
                    let vidLink = "https://www.putlocker.fyi/embed-src/\(try i.attr("data-pid"))"
                    episodeList.append(EpisodeInfo(name: try i.text(), link: vidLink))
                }
            } else if (url.contains("gogoanime")) {

                self.name = try doc.select("div.anime-title").text()
                self.imageUrl = try doc.select("div.animeDetail-image").select("img[src^=http]").attr("abs:src")
                let desc = try doc.select("p.anime-details").text()
                if (desc.isEmpty) {
                    self.des = "Sorry, an error has occurred"
                } else {
                    self.des = desc
                }

                let stuffList = try doc.select("ul.check-list").select("li")
                var showList = [EpisodeInfo]()
                for i in stuffList.array() {
                    let urlInfo = try i.select("a[href^=http]")
                    var epName = try urlInfo.text()
                    if (epName.contains(name)) {
                        epName = epName[..<name.endIndex].toString()
                    }
                    showList.append(EpisodeInfo(name: epName, link: try urlInfo.attr("abs:href")))
                }

                episodeList = showList//showList.distinctBy { it.name }

            } else {
                //name setting
                self.name = try doc.select("div.right_col h1").text()
                //image url setting
                self.imageUrl = try doc.select("div.left_col").select("img[src^=http]#series_image").attr("abs:src")
                //description setting
                if (try doc.getAllElements().select("div#series_details").select("span#full_notes").hasText()) {
                    let d = try doc.getAllElements().select("div#series_details").select("span#full_notes").text()
                    let vidUrl = d
                    let start = vidUrl.index(vidUrl.startIndex, offsetBy: 0)
                    let end = vidUrl.index(vidUrl.endIndex, offsetBy: -4)
                    let range = start..<end
                    self.des = String(vidUrl[range])
                    //dont forget to remove suffix "less"
                } else {
                    let d = try doc.getAllElements().select("div#series_details").select("div:contains(Description:)").select("div").text()
                    /*do {
                        let vidUrl = d
                        let start = vidUrl.index(vidUrl.startIndex, offsetBy: 13)
                        let end = vidUrl.index(vidUrl.endIndex, offsetBy: 0)
                        let range = start..<end
                        self.des = String(vidUrl[range])
                        //self.des = d.substring(d.indexOf("Description: ") + 13, d.indexOf("Category: "))
                    } catch Exception.Error( _, _) {
                        self.des = d
                    }*/
                    self.des = d
                    //return if (des.isNullOrBlank()) "Sorry, an error has occurred" else des
                }

                //episode list setting
                getStuff(url: url)
                let stuffLists = try doc.getAllElements().select("ul.pagination").select(" button[href^=http]")
                for i in stuffLists {
                    getStuff(url: try i.attr("abs:href"))
                }
            }

        } catch Exception.Error(_, let message) {
            print(message)
        } catch {
            print("error")
        }
    }

    private func getJsonStuff(url: String, errors: @escaping (Error?) -> Void, action: @escaping (SwiftyJSON.JSON) -> Void) {
        AF.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                action(json)
            case .failure(let error):
                print(error)
                errors(error)
            }
        }
    }

    private func getStuff(url: String) {
        do {
            let html: String = getUrl(url: url) as String;
            let doc: Document = try SwiftSoup.parse(html)
            let stuffList = try doc.getAllElements().select("div#videos").select("a[href^=http]")
            for i in stuffList {
                episodeList.append(EpisodeInfo(name: try i.text(), link: try i.attr("abs:href")))
            }
        } catch Exception.Error(_, let message) {
            print(message)
        } catch {
            print("error")
        }
    }

}

class EpisodeInfo {

    var link: String
    var name: String

    public init(name: String, link: String) {
        self.link = link
        self.name = name
    }

    func getUrl2(url: String) -> String {
        let myURLString = url
        guard let myURL = URL(string: myURLString) else {
            //print("Error: \(myURLString) doesn't seem to be a valid URL")
            return myURLString// as String
        }

        do {
            let myHTMLString = try String(contentsOf: myURL, encoding: .utf8)
            //print("HTML : \(myHTMLString)")
            return myHTMLString// as String
        } catch let error {
            //print("Error: \(error)")
            return error.localizedDescription as String
        }
    }

    public func getVideo() -> String {
        if (link.contains("putlocker")) {
            let d = getUrl2(url: link).regexed(pat: "<iframe[^>]+src=\"([^\"]+)\"[^>]*><\\/iframe>") { s in
                s
            }
            let s = try! SwiftSoup.parse(d[0]).select("iframe").attr("src")
            let a = try! String(contentsOf: URL(string: s)!)
            let a1 = a.regexed(pat: "<p[^>]+id=\"videolink\">([^>]*)<\\/p>") { s in
                s
            }
            let a2 = try! SwiftSoup.parse(a1[0]).select("p#videolink").text()
            return "https://verystream.com/gettoken/\(a2)?mime=true"
        } else if (link.contains("gogoanime")) {
            let html: String = getUrl(url: link) as String;
            do {
                let doc: Document = try SwiftSoup.parse(html)
                return try doc.select("a[download^=http]").attr("abs:download")
            } catch {
            }
        } else {
            //get video url
            let videoUrl = getUrl(url: link)
            let urled = videoUrl.regexed(pat: "<iframe src=\"([^\"]+)\"[^<]+<\\/iframe>")
            //track(urled[0])
            let halfUrl = urled[0].regexed(pat: "[(http(s)?):\\/\\/(www\\.)?a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*)")
            //track(halfUrl[0])
            let tPart = getUrl(url: halfUrl[0])
            let nextUrled = tPart.regexed(pat: "var video_links = (\\{.*?\\});")
            //track(nextUrled[0])
            let vidUrl = nextUrled[0]
            let start = vidUrl.index(vidUrl.startIndex, offsetBy: 18)
            let end = vidUrl.index(vidUrl.endIndex, offsetBy: -1)
            let range = start..<end
            let mySubstring = String(vidUrl[range])
            //track(mySubstring)
            let welcome = try? JSONDecoder().decode(Welcome.self, from: mySubstring.data(using: .utf8)!)
            //track(welcome?.normal.storage[0].link ?? "Nope")

            //downloadVideo(welcome: welcome!)
            return welcome!.normal.storage[0].link
        }
        return "Error"
    }

    func saveVideoTo(_ videoUrl: URL?) {

        if videoUrl != nil {
            PHPhotoLibrary.shared().performChanges({ () -> Void in

                let createAssetRequest: PHAssetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl!)!
                createAssetRequest.placeholderForCreatedAsset

            }) { (success, error) -> Void in
                if success {
                    //saved successfully
                    track("Success \(videoUrl!.absoluteString)")
                } else {
                    //error occured
                    track(error!.localizedDescription)
                }
            }

        }

    }

}