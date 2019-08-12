//
//  CastViewController.swift
//  Fun
//
//  Created by Jacob Rein on 8/1/19.
//  Copyright © 2019 Jake Rein. All rights reserved.
//

import Foundation

import UIKit
import GoogleCast
import Casty

//@objc(ViewController)
class CastViewController: UIViewController, GCKSessionManagerListener, GCKRemoteMediaClientListener, GCKRequestDelegate {

    @IBOutlet weak var castingButton: GCKUICastButton!
    @IBOutlet weak var castVButton: UIButton!
    @IBOutlet weak var castILabel: UILabel!

    var castButton: GCKUICastButton!


    //@IBOutlet var castVideoButton: UIButton!
    //@IBOutlet var castInstructionLabel: UILabel!

    //private var castButton: GCKUICastButton!
    private var mediaInformation: GCKMediaInformation?
    private var sessionManager: GCKSessionManager!

    var videoUrl: String!
    var videoTitle: String!
    var videoDes: String!
    var videoImage: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor.black
        //self.castILabel.backgroundColor = UIColor.black
        //self.castILabel.textColor = UIColor.white

        Casty.shared.initialize()

        // Initially hide the cast button until a session is started.
        showLoadVideoButton(showButton: false)

        sessionManager = GCKCastContext.sharedInstance().sessionManager
        sessionManager.add(self)

        // Add cast button.
        castButton = GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))

        // Used to overwrite the theme in AppDelegate.
        castButton.tintColor = .blue
        castingButton.tintColor = .darkGray
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: castButton)
        let button = Casty.castButton
        button.tintColor = .blue
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButton

        //this image will show up in expanded controller as well as video thumb
        //let image = GCKImage(url: URL(string: self.videoImage)!, width: 480, height: 360)

        /*Casty.didStartSession = { _ in
            //Casty.shared.loadMedia(url: self.videoUrl, title: self.videoTitle, image: image, streamType: .buffered)
            Casty.shared.loadMedia(mediaInformation: self.getMediaInfo())
            Casty.shared.presentExpandedController()
            Casty.shared.addMiniController(toParentViewController: self)
        }*/

        /*let bbb = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        bbb.titleLabel?.text = "asdf"
        bbb.setImage(UIImage(named: "notification"), for: .normal)
        bbb.tintColor = .blue
        bbb.addGesture(setup: { (easy: EasyTapGesture) in }, actions: { view, gesture in
            self.showToast(message: "Hello!") {
                track("Hiding it now")
            }
            track("Hello!")
        })
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: bbb)*/
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Button!", style: .done, target: self, action: #selector(addTapped))
        //navigationItem.setRightBarButton(UIBarButtonItem(customView: castButton), animated: true)
        //navigationController?.isNavigationBarHidden = false

        title = videoTitle

        NotificationCenter.default.addObserver(self,
                selector: #selector(castDeviceDidChange(notification:)),
                name: NSNotification.Name.gckCastStateDidChange,
                object: GCKCastContext.sharedInstance())
    }

    func getMediaInfo() -> GCKMediaInformation {
        // Define media metadata.
        let metadata = GCKMediaMetadata()
        metadata.setString(self.videoTitle, forKey: kGCKMetadataKeyTitle)
        metadata.setString(self.videoDes, forKey: kGCKMetadataKeySubtitle)
        metadata.addImage(GCKImage(url: URL(string: self.videoImage)!,
                width: 480,
                height: 360))

        let mediaInfoBuilder = GCKMediaInformationBuilder(contentURL: URL(string: self.videoUrl)!)
        mediaInfoBuilder.streamType = GCKMediaStreamType.buffered//none
        mediaInfoBuilder.contentType = "video/mp4"
        mediaInfoBuilder.metadata = metadata
        return mediaInfoBuilder.build()
    }

    @objc func addTapped(_ sender: UIButton) {
        self.showToast(message: "Hello!")
    }

    @objc func castDeviceDidChange(notification _: Notification) {
        if GCKCastContext.sharedInstance().castState != GCKCastState.noDevicesAvailable {
            // Display the instructions for how to use Google Cast on the first app use.
            //GCKCastContext.sharedInstance().presentCastInstructionsViewControllerOnce(with: castButton)
            GCKCastContext.sharedInstance().presentCastInstructionsViewControllerOnce(with: castingButton)
        }
    }

    // MARK: Cast Actions
    func playVideoRemotely() {
        GCKCastContext.sharedInstance().presentDefaultExpandedMediaControls()

        // Define media metadata.
        let metadata = GCKMediaMetadata()
        metadata.setString(videoTitle, forKey: kGCKMetadataKeyTitle)
        metadata.setString(videoDes, forKey: kGCKMetadataKeySubtitle)
        metadata.addImage(GCKImage(url: URL(string: videoImage)!,
                width: 480,
                height: 360))

        let mediaInfoBuilder = GCKMediaInformationBuilder(contentURL: URL(string: videoUrl)!)
        mediaInfoBuilder.streamType = GCKMediaStreamType.buffered//none
        mediaInfoBuilder.contentType = "video/mp4"
        mediaInfoBuilder.metadata = metadata
        mediaInformation = mediaInfoBuilder.build()

        let mediaLoadRequestDataBuilder = GCKMediaLoadRequestDataBuilder()
        mediaLoadRequestDataBuilder.mediaInformation = mediaInformation

        // Send a load request to the remote media client.
        if let request = sessionManager.currentSession?.remoteMediaClient?.loadMedia(with: mediaLoadRequestDataBuilder.build()) {
            request.delegate = self
        }
    }


    @IBAction func loadVideo(sender _: Any) {
        print("Load Video")

        if sessionManager.currentSession == nil {
            print("Cast device not connected")
            return
        }

        playVideoRemotely()
    }

    func showLoadVideoButton(showButton: Bool) {
        castVButton.isHidden = !showButton
        // Instructions should always be the opposite visibility of the video button.
        castILabel.isHidden = !castVButton.isHidden
    }

    // MARK: GCKSessionManagerListener
    func sessionManager(_: GCKSessionManager,
                        didStart session: GCKSession) {
        print("sessionManager didStartSession: \(session)")

        // Add GCKRemoteMediaClientListener.
        session.remoteMediaClient?.add(self)

        showLoadVideoButton(showButton: true)

        Casty.didStartSession = { _ in
            //Casty.shared.loadMedia(url: self.videoUrl, title: self.videoTitle, image: image, streamType: .buffered)
            Casty.shared.loadMedia(mediaInformation: self.getMediaInfo())
            Casty.shared.presentExpandedController()
            Casty.shared.addMiniController(toParentViewController: self)
        }

        /*//this image will show up in expanded controller as well as video thumb
        let image = GCKImage(url: URL(string: self.videoImage)!,
                width: 480,
                height: 360)

        Casty.didStartSession = { _ in
            Casty.shared.loadMedia(url: self.videoUrl, title: self.videoTitle, image: image)
            Casty.shared.presentExpandedController()
        }

        Casty.shared.addMiniController(toParentViewController: self)*/
    }

    func sessionManager(_: GCKSessionManager,
                        didResumeSession session: GCKSession) {
        print("sessionManager didResumeSession: \(session)")

        // Add GCKRemoteMediaClientListener.
        session.remoteMediaClient?.add(self)

        showLoadVideoButton(showButton: true)
    }

    func sessionManager(_: GCKSessionManager,
                        didEnd session: GCKSession,
                        withError error: Error?) {
        print("sessionManager didEndSession: \(session)")

        // Remove GCKRemoteMediaClientListener.
        session.remoteMediaClient?.remove(self)

        if let error = error {
            showError(error)
        }

        showLoadVideoButton(showButton: false)
    }

    func sessionManager(_: GCKSessionManager,
                        didFailToStart session: GCKSession,
                        withError error: Error) {
        print("sessionManager didFailToStartSessionWithError: \(session) error: \(error)")

        // Remove GCKRemoteMediaClientListener.
        session.remoteMediaClient?.remove(self)

        showLoadVideoButton(showButton: false)
    }

    // MARK: GCKRemoteMediaClientListener
    func remoteMediaClient(_: GCKRemoteMediaClient,
                           didUpdate mediaStatus: GCKMediaStatus?) {
        if let mediaStatus = mediaStatus {
            mediaInformation = mediaStatus.mediaInformation
        }
    }

    // MARK: - GCKRequestDelegate
    func requestDidComplete(_ request: GCKRequest) {
        print("request \(Int(request.requestID)) completed")
    }

    func request(_ request: GCKRequest,
                 didFailWithError error: GCKError) {
        print("request \(Int(request.requestID)) didFailWithError \(error)")
    }

    func request(_ request: GCKRequest,
                 didAbortWith abortReason: GCKRequestAbortReason) {
        print("request \(Int(request.requestID)) didAbortWith reason \(abortReason)")
    }

    // MARK: Misc
    func showError(_ error: Error) {
        let alertController = UIAlertController(title: "Error",
                message: error.localizedDescription,
                preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alertController.addAction(action)

        present(alertController, animated: true, completion: nil)
    }
}
