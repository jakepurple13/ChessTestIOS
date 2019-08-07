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

//@objc(ViewController)
class CastViewController: UIViewController, GCKSessionManagerListener, GCKRemoteMediaClientListener, GCKRequestDelegate {
    
    
    @IBOutlet weak var castingButton: GCKUICastButton!
    @IBOutlet weak var castVButton: UIButton!
    @IBOutlet weak var castILabel: UILabel!
    
    
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
        self.view.backgroundColor = UIColor.black
        self.castILabel.backgroundColor = UIColor.black
        self.castILabel.textColor = UIColor.white
        
        // Initially hide the cast button until a session is started.
        showLoadVideoButton(showButton: false)
        
        sessionManager = GCKCastContext.sharedInstance().sessionManager
        sessionManager.add(self)
        
        // Add cast button.
        //castButton = GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        
        // Used to overwrite the theme in AppDelegate.
        //castButton.tintColor = .darkGray
        castingButton.tintColor = .darkGray
        //navigationItem.rightBarButtonItem = UIBarButtonItem(customView: castButton)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(castDeviceDidChange(notification:)),
                                               name: NSNotification.Name.gckCastStateDidChange,
                                               object: GCKCastContext.sharedInstance())
    }
    
    @objc func castDeviceDidChange(notification _: Notification) {
        if GCKCastContext.sharedInstance().castState != GCKCastState.noDevicesAvailable {
            // Display the instructions for how to use Google Cast on the first app use.
//            GCKCastContext.sharedInstance().presentCastInstructionsViewControllerOnce(with: castButton)
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
        mediaInfoBuilder.streamType = GCKMediaStreamType.none
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
