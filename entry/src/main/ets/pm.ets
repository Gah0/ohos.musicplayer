import media from '@ohos.multimedia.media'
import fs from '@ohos.file.fs'
import log from '../ets/log'
const TAG:string = 'PM '

export class AudioDemo {
  private avPlayer
  private totalTimeMs: number = 0
  public currentTimeMs:number = 0

  constructor(){
    this.init(this);
  }

  async init(callback){
    this.avPlayer = await media.createAVPlayer(); // 创建一个音频播放实例
    await this.setAVPlayerCallback();
    if(this.avPlayer==null){
      this.avPlayer.reset();
      callback();
    }else{
      log.info(TAG + `createAVPlayer() success, after init now state=${this.avPlayer.state}`)
    }
  }

  // 设置播放器回调函数
  // 注册avplayer回调函数
  setAVPlayerCallback() {
    // 状态机变化回调函数
    this.avPlayer.on('stateChange', async (state) => {
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          log.info(TAG + 'state idle called')
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          log.info(TAG + 'state initialized called ')
          //this.avPlayer.surfaceId = this.surfaceID // 设置显示画面，当播放的资源为纯音频时无需设置
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          log.info(TAG + 'state prepared called')
          //this.avPlayer.play() // 调用播放接口开始播放
          break;
        case 'playing': // play成功调用后触发该状态机上报
          log.info(TAG + 'state playing called')
          break;
        case 'paused': // pause成功调用后触发该状态机上报
          log.info(TAG + 'state paused called')
          break;
        case 'completed': // 播放结束后触发该状态机上报
          log.info(TAG + 'state completed called')
          this.avPlayer.stop() //调用播放结束接口
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          log.info(TAG + 'state stopped called')
          this.avPlayer.release() // 调用reset接口初始化avplayer状态
          break;
        case 'released':
          log.info(TAG + 'state released called')
          break;
        case 'error':
          log.info(TAG + 'state error called')
          break;
        default:
          log.info(TAG + 'unkown state :' + state)
          break;
      }
    })
    this.avPlayer.on('timeUpdate', (time:number) => {
      log.info(TAG + 'timeUpdate success,and new time is :' + time)
      this.currentTimeMs = time;
      this.totalTimeMs = this.avPlayer.duration;
      log.info(TAG+`[${this.avPlayer.duration}]`)
    })
    this.avPlayer.on('seekDone', (seekDoneTime:number) => {
      log.info(TAG + 'seekDone success,and seek time is:' + seekDoneTime)
      this.avPlayer.setVolume(0.5) // 设置音量为0.5，并触发volumeChange回调函数
    })
    this.avPlayer.on('endOfStream', () => {
      log.info('endOfStream success')
    })
  }

  async preinitialized(){
    let fdPath = 'fd://'
    let pathDir = "/system/etc"
    let path = pathDir  + '/demo.wav'
    let file = await fs.open(path);
    fdPath = fdPath + '' + file.fd;
    this.avPlayer.url = fdPath;
  }

  async playing(seekTo,callback) {
    await this.preinitialized()
    await this.avPlayer.prepare()
    this.avPlayer.on('prepared',()=> {
      if (seekTo > this.avPlayer.duration) {
        seekTo = -1
      }
      this.avPlayer.on('playing', () => {
        if (seekTo > 0) {
          this.avPlayer.seek(seekTo)
        }
      })
    })
    await this.avPlayer.play()
  }

  async pauseing(seekTo){
    await this.avPlayer.pause();
    this.avPlayer.seek(seekTo)
    log.info(`pause success, now state = [${this.avPlayer.state}]`)
  }
}