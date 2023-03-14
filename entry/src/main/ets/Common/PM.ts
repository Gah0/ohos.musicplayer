import media from '@ohos.multimedia.media'
import Logger from '../HiLog/Logger'
import fileIO from '@ohos.fileio'
const TAG: string = 'PlayerModel'

class PlayList {
    public audioFiles: Array<Song> = []

    constructor() {
    }
}

class Song {
    public name: string
    public author:string
    public fileUri: string
    public duration: number

    constructor(name, author, fileUri, duration) {
        this.name = name
        this.author = author
        this.fileUri = fileUri
        this.duration = duration
    }
}

class PlayerModel {
    public playlist: PlayList = new PlayList()
    public player: media.AudioPlayer
    public isPlaying: boolean = false

    //总播放时间
    public currentTimeMs: number = 0
    public totalTimeMs: number = 0
    public index: number=0
    public anthor:string = 'name'
    public playingProgressListener
    public statusChangedListener

    //构造函数
    constructor() {
        console.info(TAG, `createAudioPlayer start`)
        this.player = media.createAudioPlayer()
        console.info(TAG, `createAudioPlayer end and initAudioPlayer`)
        this.initAudioPlayer()
        console.info(TAG, `createAudioPlayer= ${this.player}`)
    }

    setOnStatusChangedListener(callback) {
        this.statusChangedListener = callback
    }

    setOnPlayingProgressListener(callback) {
        this.playingProgressListener = callback
    }

    //初始化
    initAudioPlayer() {
        Logger.info(TAG, 'initAudioPlayer begin')
        this.player.on('error', () => {
            Logger.error(TAG, `player error`)
        })
        this.player.on('finish', () => { // 设置'play'事件回调
            Logger.info(TAG, 'finish() callback is called')
            this.seek(0)
            Logger.info('finish play success');
        });
        this.player.on('error', () => { // 设置'finish'事件回调，播放完成触发
            Logger.info('audio play finish');
            this.player.release(); // audioPlayer资源被销毁
            this.player = undefined;
        });
        console.info(TAG, 'initAudioPlayer end')
    }

    getCurrentMs() {
        return this.currentTimeMs
    }

    getDuration() {
        Logger.info(TAG, `getDuration index= ${this.index}`)
        if (this.playlist.audioFiles[this.index].duration > 0) {
            return this.playlist.audioFiles[this.index].duration
        }
        Logger.info(TAG, `getDuration state= ${this.player.state}`)
        this.playlist.audioFiles[this.index].duration = Math.min(this.player.duration, 97615)
        Logger.info(TAG, `getDuration player.src= ${this.player.src} player.duration= ${this.playlist.audioFiles[this.index].duration} `)
        return this.playlist.audioFiles[this.index].duration
    }

    restorePlayingStatus(status, callback) {
        Logger.info(TAG, `restorePlayingStatus ${JSON.stringify(status)}`)
        for (let i = 0; i < this.playlist.audioFiles.length; i++) {
            if (this.playlist.audioFiles[i].fileUri === status.uri) {
                Logger.info(TAG, `restore to index ${i}`)
                this.preload(i, () => {
                    this.play(status.seekTo, status.isPlaying)
                    Logger.info(TAG, 'restore play status')
                    callback(i)
                })
                return
            }
        }
        Logger.info(TAG, 'restorePlayingStatus failed')
        callback(-1)
    }

    getPlaylist(callback) {
        // generate play list
        Logger.info(TAG, 'generatePlayList')
        Logger.info(TAG, 'getAudioAssets begin')
        this.playlist = new PlayList()
        this.playlist.audioFiles = []
        this.playlist.audioFiles[0] = new Song('dynamic.wav','author', 'system/etc/dynamic.wav', 0)
        this.playlist.audioFiles[1] = new Song('demo.wav','author', 'system/etc/demo.wav', 0)
        callback()
        Logger.info(TAG, 'getAudioAssets end')
    }

    seek(ms) {
        this.currentTimeMs = ms
        if (this.isPlaying) {
            Logger.info(TAG, `player.seek= ${ms}`)
            this.player.seek(ms)
        } else {
            Logger.info(TAG, `stash seekTo= ${ms}`)
        }
    }

    preload(index,callback){
        Logger.info(TAG, `preLoad ${index}/${this.playlist.audioFiles.length}`)
        if (index < 0 || index >= this.playlist.audioFiles.length) {
            Logger.error(TAG, 'preLoad ignored')
            return 0
        }
        this.index = index
        let uri = this.playlist.audioFiles[index].fileUri
        //declare function open(path: string, callback: AsyncCallback<number>): void;
        fileIO.open(uri, (err, fdNumber) => {
            let fdPath = 'fd://'
            let source = fdPath + '' + fdNumber
            if (typeof (source) === 'undefined') {
                console.error(TAG, `preLoad ignored source= ${source}`)
                return
            }

            //非idle状态下，source判断一般为真
            if (source === this.player.src && this.player.state !== 'idle') {
                callback()
            } else {
                //src为真，idle状态下
                this.player.reset()
                this.player.on('dataLoad', () => {
                    callback()
                })
                this.player.src = source
            }
        })
        Logger.info(`fileIO music url ${this.player.src} end`)
    }

    //播放功能
    play(settime,startPlay) {
        if(startPlay){
            Logger.info(`play() begin settime=${settime}`)
            this.player.on('play', () => {
                Logger.info('audio play success');
                /*进度条seek
                if (seekTo > 0) {
                    self.seek(seetime)
                }
                * */
            })
            Logger.info(TAG, 'call player.play')
            this.player.play()
            Logger.info(TAG, `player.play called player.state= ${this.player.state}`)
        }else if (settime > 0) {
            //播放中
            //this.playingProgressListener(seekTo)
            this.currentTimeMs = settime
            Logger.info(TAG, `stash seekTo= ${this.currentTimeMs}`)
        }
    }

    pause(isPlaying){
        if (!this.isPlaying) {
            Logger.info(TAG, `pause ignored, isPlaying= ${this.isPlaying}`)
            return
        }

        this.isPlaying = isPlaying
        if (this.isPlaying) {
            let timeMs = this.player.currentTime
            this.currentTimeMs = timeMs
            if (typeof (timeMs) === 'undefined') {
                timeMs = 0
            }
        }else{
           //this.cancelTimer()
        }
        Logger.info(TAG, 'call player.pause')
        this.player.pause()
        Logger.info(TAG, `player.pause called, player.state= ${this.player.state}`)
    }

    stop(isPlaying) {
        if (!this.isPlaying) {
            Logger.info(TAG, `stop ignored, isPlaying= ${this.isPlaying}`)
            return
        }

        this.isPlaying = isPlaying
        if (this.isPlaying) {
            let timeMs = this.player.currentTime
            this.currentTimeMs = timeMs
            if (typeof (timeMs) === 'undefined') {
                timeMs = 0
            }
        }else{
            //this.cancelTimer()
        }
        Logger.info(TAG, 'call player.stop')
        this.player.stop()
        Logger.info(TAG, `player.stop called, player.state= ${this.player.state}`)
    }
}

export default new PlayerModel()