import media from '@ohos.multimedia.media'
import fileIo from '@ohos.fileio'
import Logger from '../HiLog/Logger'

const TAG: string = 'PlayerModel'

class PlayList {
    public audioFiles: Array<Song> = []

    constructor() {
    }
}

class Song {
    public name: string
    public fileUri: string
    public duration: number

    constructor(name, fileUri, duration) {
        this.name = name
        this.fileUri = fileUri
        this.duration = duration
    }
}

class PlayerModel {
    public playlist: PlayList = new PlayList()
    public index: number=0

    public player: media.AudioPlayer
    public isPlaying: boolean = false
    public isStop: boolean = false
    public statusChangedListener

    //构造函数
    constructor() {
        console.info(TAG, `createAudioPlayer start`)
        this.player = media.createAudioPlayer()
        console.info(TAG, `createAudioPlayer end and initAudioPlayer`)
        this.initAudioPlayer()
        console.info(TAG, `createAudioPlayer= ${this.player}`)
    }

    //初始化
    initAudioPlayer() {
        this.player.on('finish', () => { // 设置'play'事件回调
            this.isPlaying=false;
            console.info('audio play success');
        });
        this.player.on('error', () => { // 设置'finish'事件回调，播放完成触发
            console.info('audio play finish');
            this.player.release(); // audioPlayer资源被销毁
            this.player = undefined;
        });
        console.info(TAG, 'initAudioPlayer end')
    }

    preLoad(index,callback){
        this.index = index
        this.playlist.audioFiles[index] = new Song('dynamic.wav', 'system/etc/dynamic.wav', index)
        Logger.info(TAG,`index=${index},this.index=${this.index}`)

        let uri = this.playlist.audioFiles[index].fileUri
        Logger.info(TAG,`uri=${uri}}`)
        fileIo.open(uri, (err, fdNumber) => {
            let fdPath = 'fd://'

            let source = fdPath + '' + fdNumber
            this.player.src = source
            Logger.info(TAG, `preLoad ${source} begin`)
            Logger.info(TAG, `这里state= ${this.player.state}`)
            if (source === this.player.src && this.player.state==='idle') {
                Logger.info(TAG, 'preLoad finished. src not changed')
                Logger.info(TAG, `idle->现在state= ${this.player.state}`)
                callback()
                Logger.info(TAG, `idle2->现在state= ${this.player.state}`)
            } else if (typeof (source) === 'undefined') {
                console.error(TAG, `preLoad ignored source= ${source}`)
                return
            }else {
                Logger.info(TAG, 'player.reset')
                this.player.reset()
                Logger.info(TAG, `player.reset done, state= ${this.player.state}`)
                this.player.on('dataLoad', () => {
                    Logger.info(TAG, `dataLoad callback, state= ${this.player.state}`)
                    callback()
                })
                Logger.info(TAG, `player.src= ${source}`)
            this.player.src = source
            }
            Logger.info(TAG, `fileopen ${source} end`)
        })
    }

    play(startPlay) {
        if (startPlay){
            let self = this
            this.player.on('play', () => {
                console.info(TAG, `play() callback entered, player.state= ${self.player.state}`)
            })
        }
        console.info(TAG, 'call player.play')
        this.player.play()
        console.info(TAG, `player.play called player.state= ${this.player.state}`)
        this.isPlaying=true
    }

    pause() {
        console.info(TAG, 'call player.pause')
        this.player.pause()
        console.info(TAG, `player.pause called, player.state= ${this.player.state}`)
        this.isPlaying=false//
    }

    stop() {
        if (!this.isPlaying) {
            Logger.info(TAG, `stop ignored, isPlaying= ${this.isPlaying}`)
            return
        }
        Logger.info(TAG, 'call player.stop')
        this.player.stop()
        Logger.info(TAG, `player.stop called, player.state= ${this.player.state}`)
    }

}
export default new PlayerModel()