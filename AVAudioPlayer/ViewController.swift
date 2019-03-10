import UIKit
import AVFoundation

class Singleton: NSObject {
    
    static let sharedInstance: Singleton = Singleton()
    private override init() {}
    
    var player:AVAudioPlayer = AVAudioPlayer()
    
    var sliderTimer: Timer?
    var durationTimer: Timer?
    
    var audioPath: String?
    var audioFile: AVAudioFile?
    var sampleRate: Double?
    var duration: Double?
    
    var maxMin: Double?
    var maxSec: Double?
    var currentMin: Double?
    var currentSec: Double?
    
    var volume: UISlider?
    var playSlider:  UISlider?
    var audioDurationLabel: UILabel?
    var audioDurationProgressLabel: UILabel?
    
    var volumeLastValue: Float?
}

class ViewController: UIViewController {
    
    let singleton :Singleton =  Singleton.sharedInstance
    
    //再生ボタン
    @IBAction func playButtonPressed(_ sender: UIButton) {
        singleton.player.play()
    }
    //一時停止ボタン
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        singleton.player.pause()
    }
    //停止ボタン
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        singleton.player.stop()
        //停止後、AudioPlayerをクリア、再定義
        audioPlayerDif()
    }
    
    //ボリューム

    @objc func playSliderController(_ sender: UISlider) {
        singleton.player.currentTime = TimeInterval(singleton.playSlider!.value)
    }
    
    @objc func volumeController(_ sender: UISlider) {
        singleton.player.volume = singleton.volume!.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        singleton.playSlider = UISlider()
        singleton.playSlider?.frame = CGRect(x: 72, y: 415, width: 232, height: 30)
        singleton.playSlider?.addTarget(self, action: #selector(playSliderController), for: .allEvents)
        self.view.addSubview(singleton.playSlider!)
        
        singleton.volume = UISlider()
        singleton.volume?.frame = CGRect(x: 72, y: 147, width: 232, height: 30)
        singleton.volume?.addTarget(self, action: #selector(volumeController), for: .allEvents)
        self.view.addSubview(singleton.volume!)
        
        singleton.audioDurationLabel = UILabel()
        singleton.audioDurationLabel?.frame = CGRect(x: 270, y: 452, width: 50, height: 25)
        self.view.addSubview(singleton.audioDurationLabel!)
        
        singleton.audioDurationProgressLabel = UILabel()
        singleton.audioDurationProgressLabel?.frame = CGRect(x: 74, y: 452, width: 50, height: 25)
        self.view.addSubview(singleton.audioDurationProgressLabel!)
        
        if singleton.sliderTimer == nil {
            //AvAudioPlayer呼び出し
            audioPlayerDif()
            //再生スライドバー用のタイマー。１秒ごとにsliderCount()を実行する
            singleton.sliderTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(slideCount(_:)), userInfo: nil, repeats: true)
            //再生時間更新用のタイマー。0.1秒ごとにtimeCount()を実行する
            singleton.durationTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timeCount(_:)), userInfo: nil, repeats: true)
            //初期値設定
            singleton.audioDurationProgressLabel!.text = "00:00"
            singleton.volume?.value = (singleton.volume?.maximumValue)! / 2
        } else {
            singleton.playSlider!.maximumValue = Float(singleton.player.duration)
            setDurationTitle()
            singleton.volume?.value = singleton.volumeLastValue!
        }
    }
    
    // 音楽コントローラ AVAudioPlayerを定義(変数定義、定義実施、クリア）
    func audioPlayerDif(){

        // 音声ファイルのパスを定義 ファイル名, 拡張子を定義
        singleton.audioPath = Bundle.main.path(forResource: "sky", ofType: "mp3")!
        
        //ファイルが存在しない、拡張子が誤っている、などのエラーを防止するために実行テスト(try)する。
        do{
            //再生時間取得のためのaudioFileを用意する
            singleton.audioFile = try AVAudioFile(forReading: URL(fileURLWithPath: singleton.audioPath!))
            //再生時間計算用サンプルレートを取得
            singleton.sampleRate = singleton.audioFile!.fileFormat.sampleRate

            //tryで、ファイルが問題なければ player変数にaudioPathを定義
            try singleton.player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: singleton.audioPath!))

            singleton.duration = floor(Double(singleton.audioFile!.length) / singleton.sampleRate!)

            setDurationTitle()

            //スライダーの最大値と音楽ファイルの長さを同期させる
            singleton.playSlider!.maximumValue = Float(singleton.player.duration)

        }catch{
            print("error")
        }
    }
    
    //スライドバーを音楽ファイルの現在時間の位置にする
    @objc func slideCount(_ timer: Timer!) {
        singleton.playSlider!.value = Float(singleton.player.currentTime)
    }

    //現在再生時間を計算して表示する
    @objc func timeCount(_ timer: Timer!) {
        singleton.currentMin = floor(singleton.player.currentTime / 60)
        singleton.currentSec = singleton.player.currentTime - (singleton.currentMin! * 60)
        if singleton.currentSec! < 10 {
            singleton.audioDurationProgressLabel!.text = "0\(Int(singleton.currentMin!)):0\(Int(singleton.currentSec!))"
        } else if singleton.currentSec! >= 10 && singleton.currentMin! < 10 {
            singleton.audioDurationProgressLabel!.text = "0\(Int(singleton.currentMin!)):\(Int(singleton.currentSec!))"
        } else {
            singleton.audioDurationProgressLabel!.text = "\(Int(singleton.currentMin!)):\(Int(singleton.currentSec!))"
        }
        print(singleton.player.currentTime)
    }
    
    func setDurationTitle() {
        singleton.maxMin = floor(singleton.duration! / 60)
        singleton.maxSec = singleton.duration! - (singleton.maxMin! * 60)
        singleton.audioDurationLabel?.text = "\(Int(singleton.maxMin!)):\(Int(singleton.maxSec!))"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        singleton.volumeLastValue = singleton.volume?.value
    }
    
    @IBAction func unwindToTop(segue: UIStoryboardSegue) {
    }
}
