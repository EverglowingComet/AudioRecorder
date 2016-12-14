//
//  ViewController.swift
//  RecordAudio
//
//  Created by Com on 4/14/16.
//  Copyright © 2016 Jin. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

	@IBOutlet var _btnRecord: UIButton!
	@IBOutlet var _btnPlay: UIButton!
	@IBOutlet var _btnNotification: UIButton!
	
	
	var _recordSession: AVAudioSession!
	var _audioRecorder: AVAudioRecorder!
	var _player: AVAudioPlayer!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		do {
			_recordSession = AVAudioSession.sharedInstance()
			
			try _recordSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
			try _recordSession.setActive(true)
			
		} catch {
			// failed to record!
			NSLog("prepare to record failed!")
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


	// MARK: - button action
	
	@IBAction func onRecord(sender: UIButton) {
		if _audioRecorder == nil {
			startRecording()
		} else {
			finishRecording(success: true)
		}
	}
	
	@IBAction func onPlay(sender: AnyObject) {
		if _player == nil {
			playAudio()
			
		} else {
			stopPlayAudio()
		}
	}
	
	@IBAction func onNotification(sender: AnyObject) {
		let notification = UILocalNotification()
		
		if _audioRecorder != nil { // recording audio
			notification.alertBody = "Recording Audio Now"
			notification.alertAction = "Stop Record"
			notification.soundName = UILocalNotificationDefaultSoundName
			notification.fireDate = NSDate(timeIntervalSinceNow: 5)
			notification.userInfo = ["type": "record"]
			
		} else if (_player != nil && _player.playing == true) {
			notification.alertBody = "Playing Audio Now"
			notification.alertAction = "Stop Play"
			notification.soundName = UILocalNotificationDefaultSoundName
			notification.fireDate = NSDate(timeIntervalSinceNow: 5)
			notification.userInfo = ["type": "play"]
			
		} else {
			notification.alertBody = "Nothing"
			notification.alertAction = "Open"
			notification.soundName = UILocalNotificationDefaultSoundName
			notification.fireDate = NSDate(timeIntervalSinceNow: 5)
			notification.userInfo = ["type": "nothing"]
		}
		
		UIApplication.sharedApplication().scheduleLocalNotification(notification)
	}
	
	
	// MARK: - Audio Record
	
	func startRecording() {
		UIView.animateWithDuration(0.5, animations: {
			AudioServicesPlayAlertSound(1110)
			self._btnRecord.alpha = 0.9
			
			}, completion: { (Bool) in
				self._btnRecord.alpha = 1.0
				
				let audioURL = (self.getDocumentsDirectory()).URLByAppendingPathComponent("recording.caf")
				
				self._recordSession = AVAudioSession.sharedInstance()
				
				let settings = [
					AVFormatIDKey: Int(kAudioFormatAppleIMA4),
					AVSampleRateKey: 44100.0,
					AVLinearPCMBitDepthKey: 16 as NSNumber,
					AVEncoderBitRateKey: 12800,
					AVNumberOfChannelsKey: 2 as NSNumber,
					AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
				]
				
				do {
					self._audioRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
					self._audioRecorder.record()
					
					self._btnRecord.setTitle("Stop Record", forState: .Normal)
					self._btnPlay.enabled = false
				} catch {
					self.finishRecording(success: false)
				}
		})
	}
	
	func finishRecording(success success: Bool) {
		if _audioRecorder != nil {
			_audioRecorder.stop()
			_audioRecorder = nil
		}
		
		if success {
			_btnRecord.setTitle("Record", forState: .Normal)
			NSLog("Recorded successfully")
			
		} else {
			_btnRecord.setTitle("Record", forState: .Normal)
			NSLog("Record failed")
		}
		
		_btnPlay.enabled = true
		
		AudioServicesPlayAlertSound(1111)
	}
	
	
	// MARK: - Audio Play
	
	func playAudio() {
		let url = (getDocumentsDirectory()).URLByAppendingPathComponent("recording.caf")
		
		do {
			_player = try AVAudioPlayer(contentsOfURL: url)
			
			_player.delegate = self;
			_player.prepareToPlay()
			_player.play()
			
			_btnRecord.enabled = false
			_btnPlay.setTitle("Stop Play", forState: .Normal)
			
		} catch let error as NSError {
			NSLog(error.description)
		}
	}
	
	func stopPlayAudio() {
		_player.stop()
		_player = nil
		_btnRecord.enabled = true
		_btnPlay.setTitle("Play", forState: .Normal)
	}
	
	
	// MARK: - private method
	
	func getDocumentsDirectory() -> NSURL {
		let fileManager = NSFileManager.defaultManager()
		let paths = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		let documentsDirectory = paths[0] as NSURL
		return documentsDirectory
	}
	
	
	// MARK: - AVAudioPlayer delegate
	
	func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
		NSLog("playing finished")
		
		stopPlayAudio()
	}
	
}

