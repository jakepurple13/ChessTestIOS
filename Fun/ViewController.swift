//
//  ViewController.swift
//  Fun
//
//  Created by Jake Rein on 12/19/18.
//  Copyright © 2018 Jake Rein. All rights reserved.
//

import UIKit
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
class ViewController: UIViewController {
    
    public func track(_ message: String, file: String = #file, function: String = #function, line: Int = #line ) {
        print("\(message) called from \(function) \(file):\(line)")
    }

    @IBOutlet weak var labelView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSLog("Hello world");
        print("Hello world");
        
        self.labelView.text = "Hello";
                
        DispatchQueue.main.async{
            //get recent list
            do {
                let html: String = self.getUrl(url: "http://www.animeplus.tv/anime-updates") as String;
                let doc: Document = try SwiftSoup.parse(html)
                let link: Elements = try doc.select("div.left_col").select("table#updates").select("a[href^=http]")
                
                for elem in link.array() {
                    self.track(try elem.attr("abs:href"))
                }
                
            } catch Exception.Error( _, let message) {
                print(message)
            } catch {
                print("error")
            }
            //get video url
            //"(http|https):\\/\\/([\\w+?\\.\\w+])+([a-zA-Z0-9\\~\\%\\&\\-\\_\\?\\.\\=\\/])+(part[0-9])+.(\\w*)"
            let videoUrl = self.getUrl(url: "http://www.animeplus.tv/otona-no-bouguya-san-episode-11-online")
            let urled = videoUrl.regexed(pat: "<iframe src=\"([^\"]+)\"[^<]+<\\/iframe>")
            self.track(urled[0])
            let halfUrl = urled[0].regexed(pat: "[(http(s)?):\\/\\/(www\\.)?a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*)")
            self.track(halfUrl[0])
            //let secondUrl = halfUrl[0].regexed(pat: "(http|https):\\/\\/([\\w+?\\.\\w+])+([a-zA-Z0-9\\~\\%\\&\\-\\_\\?\\.\\=\\/])+(part[0-9])+.(\\w*)")
            let tPart = self.getUrl(url: halfUrl[0])
            let nextUrled = tPart.regexed(pat: "var video_links = (\\{.*?\\});")
            self.track(nextUrled[0])
            let vidUrl = nextUrled[0]
            let start = vidUrl.index(vidUrl.startIndex, offsetBy: 18)
            let end = vidUrl.index(vidUrl.endIndex, offsetBy: -1)
            let range = start..<end
            let mySubstring = String(vidUrl[range])
            self.track(mySubstring)
            let welcome = try? JSONDecoder().decode(Welcome.self, from: mySubstring.data(using: .utf8)!)
            self.track(welcome?.normal.storage[0].link ?? "Nope")
            /*
            let link = welcome?.normal.storage[0].link
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            SDDownloadManager.shared.dowloadFile(withRequest: URLRequest.init(url: URL.init(string: link!)!), inDirectory: documentsDirectory, withName: "test1.mp4", onProgress: SDDownloadManager.DownloadProgressBlock {
                
                }, onCompletion: <#T##SDDownloadManager.DownloadCompletionBlock##SDDownloadManager.DownloadCompletionBlock##(Error?, URL?) -> Void#>)
            */
        }
        
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

}


