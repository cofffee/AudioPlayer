//
//  ViewController.swift
//  FirstAudioPlayer
//
//  Created by Kevin Remigio on 7/22/17.
//  Copyright © 2017 Kevin Remigio. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {
    var audioPlayer = AVAudioPlayer()
    
    var playButton: UIButton? = nil
    var stopButton: UIButton? = nil
    
    var backgroundImage: UIImageView? = nil
    var logoImage: UIImageView? = nil
    
    var volumeSlider: UISlider? = nil
    var songSlider: UISlider? = nil
    
    var songCurrentTime: UILabel = {
        return UILabel()
    }()
    
    var songTime: UILabel = {
        return UILabel()
    }()
    
    var timer: Timer? = nil
    var seconds: Float = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.clear

        setupImages()
        
        
        applyMotionEffect(toView: backgroundImage!, magnitude: 40)
        applyMotionEffect(toView: logoImage!, magnitude: -80)
        
        setupAVPlayer()
        setupButtons()
        

        let timeSliderFrame = CGRect(x: (view.frame.width / 2) - (view.frame.width - 140) / 2, y: 370, width: view.frame.width - 140, height: 40)
        songSlider                          = UISlider(frame: timeSliderFrame)
        songSlider?.minimumValue            = 0
        songSlider?.maximumValue            = Float(audioPlayer.duration)
        songSlider?.isContinuous            = false
        songSlider?.minimumTrackTintColor   = UIColor.yellow
        songSlider?.maximumTrackTintColor   = UIColor.yellow.withAlphaComponent(0.5)
        songSlider?.addTarget(self, action: #selector(ViewController.changeSongPosition(_:)), for: .valueChanged)
        
        let sliderFrame = CGRect(x: (songSlider?.frame.width)! + 15, y: 330, width: 200, height: 40)
        
        volumeSlider = UISlider(frame: sliderFrame)
        volumeSlider?.addTarget(self, action: #selector(ViewController.changeVolume(_:)), for: .valueChanged)
        volumeSlider?.minimumValue = 0
        volumeSlider?.maximumValue = 100
        // Set default value to whatever is coming on player by default.
        volumeSlider?.setValue(audioPlayer.volume * 100, animated: false)
        // make it vertical
        volumeSlider?.transform = CGAffineTransform(rotationAngle: CGFloat(-(Double.pi / 2)))
        view.addSubview(volumeSlider!)

        view.addSubview(songSlider!)
        view.addSubview(songCurrentTime)
        view.addSubview(songTime)
    }
    
    func startSongSliderTimer() {
        if timer ==  nil {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateSlider), userInfo: nil, repeats: true)
        }
        
    }
    func updateSlider() {
        if seconds < Float(audioPlayer.duration) {
            seconds += 1
            songSlider?.value = seconds
        } else {
            songSlider?.value = 0
            seconds = 0
            timer?.invalidate()
            timer = nil
        }

    }
    func changeVolume(_ sender: UISlider) {
        audioPlayer.volume = sender.value / 100.0
        print(audioPlayer.volume)
    }
    
    func changeSongPosition(_ sender: UISlider) {
        print(sender.value)
        
        audioPlayer.currentTime     = TimeInterval(sender.value)
        songSlider?.value           = sender.value
        seconds                     = sender.value
        
        if audioPlayer.isPlaying {
            startSongSliderTimer()
            audioPlayer.play()
        }
        
    }
    func setupImages() {
        let bgFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        backgroundImage = UIImageView(frame: bgFrame)
        backgroundImage?.image = UIImage(named: "a")
        backgroundImage?.contentMode = .scaleAspectFill
        view.addSubview(backgroundImage!)
        
        
        let logoFrame = CGRect(x: (view.frame.width / 2) - 75, y: view.frame.height / 2 + 120, width: 150, height: 150)
        logoImage = UIImageView(frame: logoFrame)
        logoImage?.image = UIImage(named: "b")
        logoImage?.contentMode = .scaleAspectFit
        logoImage?.layer.cornerRadius = logoImage!.frame.size.width / 2
        view.addSubview(logoImage!)
    }
    func applyMotionEffect(toView view: UIView, magnitude: Float) {
    
        let xMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = -magnitude
        xMotion.maximumRelativeValue = magnitude
        
        let yMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        yMotion.minimumRelativeValue = -magnitude
        yMotion.maximumRelativeValue = magnitude
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [xMotion, yMotion]
        view.addMotionEffect(group)
    }
    func setupButtons() -> Void {
        let playButtonFrame = CGRect(x: 0, y: 28, width: view.frame.width, height: 32)
        playButton = UIButton(frame: playButtonFrame)
        playButton?.setTitle("Play", for: .normal)
        playButton?.setTitleColor(UIColor.blue, for: .normal)
        playButton?.addTarget(self, action: (#selector(ViewController.playPause(_:))), for: .touchUpInside)
        
        let stopButtonFrame = CGRect(x: 0, y: 56, width: view.frame.width, height: 32)
        stopButton = UIButton(frame: stopButtonFrame)
        stopButton?.setTitle("Stop", for: .normal)
        stopButton?.setTitleColor(UIColor.blue, for: .normal)
        stopButton?.addTarget(self, action: (#selector(ViewController.stop(_:))), for: .touchUpInside)
        
        view.addSubview(playButton!)
        view.addSubview(stopButton!)
    }
    
    func setupAVPlayer() -> Void {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource:"a", ofType:"mp3")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay
            
            let audioSession = AVAudioSession.sharedInstance()
            
            do{
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            }
            catch {
                print(error)
            }
        } catch {
            print(error)
        }
    
    }
    func playPause(_ sender: AnyObject) {
        
        if audioPlayer.isPlaying != true {
            audioPlayer.play()
            startSongSliderTimer()
            playButton?.setTitle("Resume", for: .normal)
        } else {
            audioPlayer.pause()
            timer?.invalidate()
            timer = nil
            playButton?.setTitle("Play", for: .normal)
        }
        
    }
    
    func stop(_ sender: AnyObject) {
        if audioPlayer.isPlaying {
            audioPlayer.stop()
            audioPlayer.currentTime = 0
            timer?.invalidate()
            timer = nil
            songSlider?.value = 0
            seconds = 0
            
        }
    }

}

