import media from '@ohos.multimedia.media'
import fs from '@ohos.file.fs'
import log from '../ets/log'
const TAG:string = 'PM '

export class Music {
  name: string
  author: string
  url: string
}

export class AudioDemo {
  private avPlayer:media.AVPlayer
  public totalTimeMs: number = 0
  public currentTimeMs:number = 0
  public stoppedsignal:Boolean=false
  public pausedsignal:Boolean=false
  public  index:number=0
  // 是否在播放
  public isPlaying: boolean = false
  private progressIntervalID: number = 0
  public currentMusic: Music = new Music()
  public currentMusicIndex: number = 0
  // 音乐列表
  public musicList: Music[] = [
    {
      name: "dynamic.wav",
      author: "网络歌手1",
      //      url: "file://system/etc/dynamic.wav",
      url: "/system/etc",
    },
    {
      name: "demo.wav",
      //      url: "file://system/etc/demo.wav",
      author: "网络歌手2",
      url: "/system/etc",
    }]

  constructor(){
    this.init(this);
  }

  async init(callback){
    this.avPlayer = await media.createAVPlayer(); // 创建一个音频播放实例
    //await this.setAVPlayerCallback();
    if(this.avPlayer==null){
      this.avPlayer.reset();
      callback();
    }else{
      log.info(TAG + `createAVPlayer() success, after init now state=${this.avPlayer.state}`)
      await this.preinitialized()
      log.info(TAG + `preinitialized() success, after initialized now state=${this.avPlayer.state}`)
      await this.prepared(this.index,callback)
      log.info(TAG + `prepared() success, after prepared now state=${this.avPlayer.state}`)
    }
  }
/*
  // 设置播放器回调函数
  // 注册avplayer回调函数
  setAVPlayerCallback() {
    // 状态机变化回调函数
    this.avPlayer.on('stateChange', async (state,callback) => {
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          log.info(TAG + 'state idle called')
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          log.info(TAG + 'state initialized called ')
          //this.prepared(this.index,callback);
          //this.avPlayer.surfaceId = this.surfaceID // 设置显示画面，当播放的资源为纯音频时无需设置
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          log.info(TAG + 'state prepared called')
          //this.avPlayer.play() // 调用播放接口开始播放
          this.pausedsignal=false
          break;
        case 'playing': // play成功调用后触发该状态机上报
          log.info(TAG + 'state playing called')
          log.info(`now the totaltime is ${this.totalTimeMs}`)
          break;
        case 'paused': // pause成功调用后触发该状态机上报
          log.info(TAG + 'state paused called')
          this.pausedsignal=!this.pausedsignal;
          break;
        case 'completed': // 播放结束后触发该状态机上报
          log.info(TAG + 'state completed called')
          //this.stop() //调用播放结束接口
          this.stoppedsignal=!this.stoppedsignal;//stoppedsignal=true
          log.info(TAG + `stoppedsignal = [${this.stoppedsignal}]`)
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          log.info(TAG + 'state stopped called')
          this.stoppedsignal=!this.stoppedsignal; //stoppedsignal=false
          log.info(TAG + `stoppedsignal = [${this.stoppedsignal}]`)
          //await this.avPlayer.reset()
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
      //log.info(TAG + 'timeUpdate success,and new time is :' + time)
      this.currentTimeMs = time;
    })
    this.avPlayer.on('seekDone', (seekDoneTime:number) => {
      log.info(TAG + 'seekDone success,and seek time is:' + seekDoneTime)
      this.avPlayer.setVolume(0.5) // 设置音量为0.5，并触发volumeChange回调函数
    })
    this.avPlayer.on('endOfStream', () => {
      log.info('endOfStream success')
    })

  }
*/
  getCurrentMusic() {
    return this.musicList[this.currentMusicIndex]
  }

  async preinitialized(){
    let fdPath = 'fd://'
    let pathDir = this.getCurrentMusic().url
    let MusicName = this.getCurrentMusic().name
    let path = pathDir  + '/' + MusicName
    let file = await fs.open(path);
    fdPath = fdPath + '' + file.fd;
    this.avPlayer.url=fdPath;
  }

  async prepared(index,callback){
/*    if (index < 0 || index >= this.avPlayer.duration) {
      log.info('MusicPlayer[PlayerModel] preLoad ignored');
      return 0;
    }*/

    this.index=index;
    this.preinitialized();
    let src = this.avPlayer.url

    if (typeof (src) === 'undefined') {
      log.info('MusicPlayer[PlayerModel] initialized ignored, source=' + src);
      return;
    }

    this.avPlayer.prepare()
    if(src === this.avPlayer.url && this.avPlayer.state!='prepared'){
      log.info('MusicPlayer[PlayerModel] initialized finished. src not changed');
      callback();
    }else if(this.avPlayer.state==='prepared'){
      log.info(TAG+`prepared, please press play`);
      this.totalTimeMs=this.getTotalTimeMs()
      callback();
    }else{
      this.avPlayer.release();
      this.avPlayer.reset();
      this.init(this);
      //this.no
      //this.cancelTimer();
      log.info(TAG+`not prepared state, reinit`)
    }
  }

  playing(seekTo,callback) {
    log.info(TAG+'play seekTo=' + seekTo);
    //this.notifyPlayingStatus(startPlay);
    log.info(TAG+'call avPlayer.play()');
    this.avPlayer.play();
    this.setProgressTimer();
    this.isPlaying=!this.isPlaying;
/*
    //暂停后再次播放
    if (seekTo < 0 && this.currentTimeMs > 0) {
      log.info(TAG+`seekTo= ${seekTo}`)
      log.info(TAG + `pop seekTo= ${this.currentTimeMs}`)
      seekTo = this.currentTimeMs
    }
    let self = this;
    //进度条
    if (seekTo > 0) {
      log.info(TAG+`seekTo= ${seekTo}`)
      this.avPlayer.seek(seekTo)
    }
*/
    //this.playerEvent.playEvent(this.getCurrentMusic());
  }

  getTotalTimeMs() {
    return this.avPlayer.duration
  }

  pauseing(seekTo){
    if (!this.isPlaying) {
      //this.playerEvent.pauseEvent(this.getCurrentMusic())
      log.info(TAG+'pause ignored, isPlaying=' + this.isPlaying);
      return;
    }
    //this.notifyPlayingStatus(false);
    this.avPlayer.pause();
    this.isPlaying=!this.isPlaying;
    //this.avPlayer.seek(seekTo)
    log.info(TAG+`pause success, now state = [${this.avPlayer.state}]`)
    log.info(TAG+`${this.isPlaying}`)
  }

  seek(seekToMs){
    if(this.isPlaying){
      this.avPlayer.seek(seekToMs);
      log.info(TAG + `已经设置进度条到[${seekToMs}]`)
    }
  }

  stop(){
    if(!this.isPlaying){
      return;
    }
    this.avPlayer.stop();
  }

  cancelProgressTimer() {
    if (typeof (this.progressIntervalID) != 'undefined') {
      clearInterval(this.progressIntervalID);
      this.progressIntervalID = undefined;
    }
  }

  setProgressTimer() {
    this.cancelProgressTimer()

    this.progressIntervalID = setInterval(() => {
      let timeMs = this.avPlayer.currentTime;
      this.currentTimeMs = timeMs;
      if (typeof (timeMs) === 'undefined') {
        timeMs = 0;
      }

      log.info(TAG+`${timeMs}, ${this.totalTimeMs}`)
      this.avPlayer.on('endOfStream', () => {
        log.info('endOfStream success')
        this.cancelProgressTimer()
        this.pauseing(-1)
      })
    }, 500)
  }
/*
  notifyPlayingStatus(isPlaying){
    this.isPlaying=isPlaying;
    this.statusChangedListener(this.isPlaying);
    console.log('MusicPlayer[PlayerModel] notifyPlayingStatus isPlaying=' + isPlaying + ' intervalId=' + this.intervalID);
  }*/
}