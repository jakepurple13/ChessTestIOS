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

extension String {
    func regexed(pat: String) -> [String] {
        if let regex = try? NSRegularExpression(pattern: pat, options: .caseInsensitive) {
            let string = self as NSString

            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).replacingOccurrences(of: "#", with: "").lowercased()
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

public func track(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    print("\(message) called from \(function) \(file):\(line)")
}

func getUrl(url: String) -> String {
    let myURLString = url
    guard let myURL = URL(string: myURLString as String) else {
        //print("Error: \(myURLString) doesn't seem to be a valid URL")
        return myURLString as String
    }

    do {
        let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
        //print("HTML : \(myHTMLString)")
        return myHTMLString as String
    } catch let error {
        //print("Error: \(error)")
        return error.localizedDescription as String
    }
}

public enum Source {
    case RECENT_ANIME, RECENT_CARTOON, ANIME, CARTOON, DUBBED, ANIME_MOVIES, CARTOON_MOVIES

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
        if (source.movie && source == Source.ANIME_MOVIES) {
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
        if (url.contains("gogoanime")) {
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

class EpisodeInfo {

    var link: String
    var name: String

    public init(name: String, link: String) {
        self.link = link
        self.name = name
    }

    public func getVideo() -> String {
        if (link.contains("gogoanime")) {
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

public class EpisodeApi: NSObject {

    var name: String = ""
    var imageUrl: String = ""
    var des: String = ""
    var episodeList: [EpisodeInfo] = [EpisodeInfo]()
    //var vc: EpisodeViewController? = nil

    init(url: String) {
        super.init()
        do {
            if (url.contains("gogoanime")) {

                let html: String = getUrl(url: url) as String;
                let doc: Document = try SwiftSoup.parse(html)

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

                let html: String = getUrl(url: url) as String;
                let doc: Document = try SwiftSoup.parse(html)
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

        } catch Exception.Error(_, let message
        ) {
            print(message)
        } catch {
            print("error")
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
