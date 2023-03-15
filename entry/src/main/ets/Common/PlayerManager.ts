import media from '@ohos.multimedia.media'
import Logger from '../HiLog/Logger'

const TAG: string = 'PlayerModel'


export class Music {
    name: string
    author: string
    url: string
}

export interface IPlayerEvent {
    playEvent(music: Music): void
    pauseEvent(music: Music): void
    progressEvent(currentTimeMs: number, totalTimeMs: number): void
}

export class PlayerManager {
    // 是否在播放
    public isPlaying: boolean = false
    public intervalID = undefined
    public playingProgressListener
    public statusChangedListener

    private musicList: Music[] = [
        {
            name: "Dynamic",
            author: "网络歌手1",
            //      url: "file://system/etc/dynamic.wav",
            url: "system/etc/dynamic.wav",
        },
        {
            name: "Demo",
            //      url: "file://system/etc/demo.wav",
            author: "网络歌手2",
            url: "system/etc/demo.wav",
        }]

    //当前播放时间
    private currentTimeMs: number = 0
    //总播放时间
    private totalTimeMs: number = 0
    // 进度条定时器
    private progressIntervalID: number = 0

    // 当前播放的音乐
    private currentMusicIndex: number = 0

    // OH media对象
    public player: media.AudioPlayer

    constructor() {
        Logger.info(TAG, `createAudioPlayer start`)
            this.player = media.createAudioPlayer()
        Logger.info(TAG, `createAudioPlayer end and initAudioPlayer`)
            this.initAudioPlayer()
        Logger.info(TAG, `createAudioPlayer= ${this.player}`)

        this.player.on('finish', () => { // 设置'play'事件回调
            Logger.info('audio play success');
        });
        this.player.on('error', () => { // 设置'finish'事件回调，播放完成触发
            Logger.info('audio play finish');
            this.player.release(); // audioPlayer资源被销毁
            this.player = undefined;
        });
    }
    //初始化播放器，使用api8+的audiomedia
    initAudioPlayer() {
        //Logger.info(TAG, 'initAudioPlayer begin')
        this.player.on('error', () => {
            Logger.error(TAG, `player error`)
        })
        this.player.on('finish', () => {
            Logger.info(TAG, 'finish() callback is called')
        })
        this.player.on('timeUpdate', () => {
            Logger.info(TAG, `timeUpdate() callback is called`)
        })
        Logger.info(TAG, 'initAudioPlayer end')
    }

}