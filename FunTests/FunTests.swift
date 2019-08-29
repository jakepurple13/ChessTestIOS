//
//  FunTests.swift
//  FunTests
//
//  Created by Jake Rein on 12/19/18.
//  Copyright © 2018 Jake Rein. All rights reserved.
//

import XCTest
import Alamofire
import HTMLKit
@testable import Fun

extension String {
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    func slices(from: String, to: String) -> [Substring] {
        let pattern = "(?<=" + from + ").*?(?=" + to + ")"
        return ranges(of: pattern, options: .regularExpression)
                .map{ self[$0] }
    }

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
}

class FunTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        //let s = try! NSString.init(contentsOf: NSURL(string: Source.LIVE_ACTION.url)! as URL, encoding: String.Encoding.ascii.rawValue)

        //print(s)

        /*let s = try! HTMLParser.init(string: NSString.init(contentsOf: NSURL(string: Source.LIVE_ACTION.url)! as URL, encoding: String.Encoding.ascii.rawValue) as String)

        //track(s.document.innerHTML)

        let d = s.parseDocument().querySelectorAll("a.az_ls_ent")

        for i in d {
            track("\(i.textContent) with \(i.attributes)")
        }*/

        track("Here")

        let itemListURL = URL(string: Source.LIVE_ACTION.url)!
        let itemListHTML = try! String(contentsOf: itemListURL, encoding: .utf8)
        let result = itemListHTML.slices(from: "az_ls_ent\" href=\"", to: "\"")
        //result.forEach({print($0)})
        //href="/show/100-things-to-do-before-high-school/" data-post-id="149310">100 Things To Do Before High School
        let result1 = itemListHTML.slices(from: "az_ls_ent\")*?(\">", to: "<")
        result1.forEach({track(String($0))})
        let res2 = itemListHTML.regexed(pat: "(?<=az_ls_ent\")*?(\">).*?(?=<)")
        res2.forEach({track($0)})

        /*print(NSURL(string: Source.LIVE_ACTION.url)?.absoluteString)

        let response = AF.request(Source.LIVE_ACTION.url, method: .get, encoding: JSONEncoding.default).responseString()

        switch response.result {
        case .success(let value):
            print(value)
        case .failure(let error):
            print(error)
        }*/
        
//        let s = ShowApi(source: Source.LIVE_ACTION).showList
//        let rando = s[0]//.randomElement()!
//        track("\(rando.name) with \(rando.url)")
//        let a = EpisodeApi(url: rando.url)
//        let z = a.episodeList[0]
//        track("\(z.getVideo())")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
