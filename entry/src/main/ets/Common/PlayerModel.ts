import media from '@ohos.multimedia.media'
import {Music} from '../datamodel/Music'
import Logger from '../HiLog/Logger'
import fs from '@ohos.file.fs'

const TAG: string = 'PlayerModel'

export interface IPlayerEvent {
    playEvent(music:Music): void
    pauseEvent(music:Music): void
    progressEvent(currentTimeMs: number, totalTimeMs: number): void
}

export class PlayerModel {
    // 是否在播放
    public isPlaying: boolean = false
    public intervalID = undefined

    private musiclist: Music[] = [
        {
            name: "Dynamic",
            author: "网络歌手1",
            url: "system/etc/dynamic.wav",
            file: "dynamic.wav"
        },
        {
            name: "Demo",
            author: "网络歌手2",
            url: "system/etc",
            file: "demo.wav"
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
    private avplayer

    init(){
        Logger.info(TAG, `createAudioPlayer start`)
        this.avplayer = media.createAVPlayer()
        this.avplayer.on('stateChange', async (state, reason) => {
            switch (state) {
                case 'idle:':
                    Logger.info('state idle called')
                    break;
                case 'released':
                    Logger.info(TAG + 'state released called')
                    break;
                case 'error':
                    Logger.info(TAG + 'state error called')
                    break;
                default:
                    Logger.info(TAG + 'unkown state :' + state)
                    break;
            }
        })
    }
}