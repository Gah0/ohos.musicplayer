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
    public player: media.AudioPlayer
    public isPlaying: boolean = false

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
            console.info('audio play success');
        });
        this.player.on('error', () => { // 设置'finish'事件回调，播放完成触发
            console.info('audio play finish');
            this.player.release(); // audioPlayer资源被销毁
            this.player = undefined;
        });
        console.info(TAG, 'initAudioPlayer end')
    }
}

export default new PlayerModel()