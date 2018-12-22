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
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

public func track(_ message: String, file: String = #file, function: String = #function, line: Int = #line ) {
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
            return "http://www.animeplus.tv/anime-updates"
        case .RECENT_CARTOON:
            return "http://www.animetoon.org/updates"
        case .ANIME:
            return "http://www.animeplus.tv/anime-list"
        case .CARTOON:
            return "http://www.animetoon.org/cartoon"
        case .DUBBED:
            return "http://www.animetoon.org/dubbed-anime"
        case .ANIME_MOVIES:
            return "http://www.animeplus.tv/anime-movies"
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
        showList = source.recent ? self.getRecentVideoList(url: source.url) : self.getVideoList(url: source.url)
    }
    
    private func getRecentVideoList(url: String) -> [NameAndLink] {
        //get recent list
        var list = [NameAndLink]()
        do {
            let html: String = getUrl(url: url) as String;
            let doc: Document = try SwiftSoup.parse(html)
            let link: Elements = try doc.select("div.left_col").select("table#updates").select("a[href^=http]")
            for elem in link.array() {
                let linked = try elem.attr("abs:href")
                let named = try elem.text()
                //track("\(linked) and \(named)")
                if(!named.contains("Episode")) {
                    list.append(NameAndLink(name: named, url: linked))
                }
            }
        } catch Exception.Error( _, let message) {
            print(message)
        } catch {
            print("error")
        }
        return list
    }
    
    private func getVideoList(url: String) -> [NameAndLink] {
        //get recent list
        var list = [NameAndLink]()
        do {
            
            let html: String = getUrl(url: url) as String;
            let doc: Document = try SwiftSoup.parse(html)
            let link: Elements = try doc.select("td").select("a[href^=http]")
            for elem in link.array() {
                let linked = try elem.attr("abs:href")
                let named = try elem.text()
                //track("\(linked) and \(named)")
                if(!named.contains("Episode")) {
                    list.append(NameAndLink(name: named, url: linked))
                }
            }
        } catch Exception.Error( _, let message) {
            print(message)
        } catch {
            print("error")
        }
        list.sort(by: { $0.name > $1.name })
        return list
    }
}

public class EpisodeApi: NSObject {
    
    var name: String = ""
    var imageUrl: String = ""
    var des: String = ""
    var episodeList: [NameAndLink] = [NameAndLink]()
    
    init(url: String) {
        super.init()
        do {
            let html: String = getUrl(url: url) as String;
            let doc: Document = try SwiftSoup.parse(html)
            //name setting
            self.name = try doc.select("div.right_col h1").text()
            //image url setting
            self.imageUrl = try doc.select("div.left_col").select("img[src^=http]#series_image").attr("abs:src")
            //description setting
            if(try doc.getAllElements().select("div#series_details").select("span#full_notes").hasText()) {
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
            
        } catch Exception.Error( _, let message) {
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
                episodeList.append(NameAndLink(name: try i.text(), url: try i.attr("abs:href")))
            }
        } catch Exception.Error( _, let message) {
            print(message)
        } catch {
            print("error")
        }
    }
    
    public func getVideo(url: String) {
        //get video url
        let videoUrl = getUrl(url: url)
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
        
        downloadVideo(welcome: welcome!)
    }
    
    private func downloadVideo(welcome: Welcome) {
        let link = welcome.normal.storage[0].link
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let key = SDDownloadManager.shared.dowloadFile(withRequest: URLRequest.init(url: URL.init(string: link)!), inDirectory: documentsDirectory, withName: welcome.normal.storage[0].filename, onProgress: {
            (progress) in
            let percentage = String(format: "%.1f %", (progress * 100))
            track(percentage)
        }, onCompletion: { (error, url) in
            if let error = error {
                print("Error is \(error as NSError)")
            } else {
                if let url = url {
                    print("Downloaded file's url is \(url.path)")
                }
            }
        }
        )
        track(key ?? "No Keyia")
    }
}
