import router from '@ohos.router'
import Logger from '../HiLog/Logger'
import PM from '../Common/PM'
const TAG: string = 'Index'

@Entry
@Component
struct Index {
  @State turntableAngle: number = 0
  @State isLike: boolean = false
  @State isModexchange: boolean = false
  @State currentProgress: number = 0
  @State currentTimeText: string = '00:00'
  @State totalTimeText: string = '00:00'
  @State totalMs: number = 0

  @State imageArrays: Array<Resource> = [$r('app.media.pause')]
  @State stringArrays: Array<string> = ['没有播放']
  @State title: string = ''


  @Builder headPanel(){
    Flex({
      direction: FlexDirection.Row,
      wrap: FlexWrap.NoWrap,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center
    }) {
      Image($r("app.media.back"))
        .width(48)
        .height(48)
        .onClick(() => {
          router.pushUrl({ url: 'pages/Firstpage'})
        })
      Text(this.stringArrays[0]).fontSize(25).height(150).flexShrink(2).flexBasis('auto')
      Image($r("app.media.distribute"))
        .width(38)
        .height(38)
        .onClick(() => {
          //this.onDistributeDevice()
        })
    }.padding(16).margin({top: 16, bottom: 16})
  }

  @Builder DiscoPanel(){
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween}) {
      Image($r("app.media.img_turntable"))
        .objectFit(ImageFit.Contain)
        .aspectRatio(2.0)
        .rotate({
          x: 0,
          y: 0,
          z: 1,
          centerX: '50%',
          centerY: '50%',
          angle: this.turntableAngle
        })
    }.backgroundColor(0xAFEEEE)
  }

  @Builder MusicShowPanel(){
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Image(this.isLike ? $r("app.media.addlike") : $r("app.media.unlike"))
          .width(32)
          .height(32)
          .onClick(() => {
          })

        Flex({ direction: FlexDirection.Column,justifyContent: FlexAlign.Center}) {
          Text('明日旅程').fontSize(32)
          Text('author').fontSize(16)
        }

        Image(this.isLike ? $r("app.media.addlike") : $r("app.media.unlike"))
          .width(32)
          .height(32)
          .onClick(() => {
          })

      }.padding(24)
  }

  @Builder sildeindicator() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Slider({
        value: this.currentProgress,
        min: 0,
        max: 100,
        step: 1,
        style: SliderStyle.OutSet
      })
        .blockColor(Color.Blue)
        .trackColor(Color.Gray)
        .selectedColor(Color.Black)
        .showSteps(true)
        .flexGrow(1)
        .margin({ left: 24, right: 24 })
        .onChange((value: number, mode: SliderChangeMode) => {
          if (mode == 2) {
            //this.onChangeMusicProgress(value)
          }
        })
    }.width('100%').height(18)

    Row() {
      Text(this.currentTimeText).fontSize(12).fontColor("ff000000").width(40).margin({ left: 30 })
      Text(this.totalTimeText).fontSize(12).fontColor("ff000000").width(40).margin({ left: 346 })
    }.margin({ top: 8 })
  }

  @Builder playPanel() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      Image(this.isModexchange ? $r("app.media.icon_music_exchangeplaymode") : $r("app.media.icon_music_mode1"))
        .width(22).height(22)
        .onClick(() => {
          if (this.isModexchange) {
            this.isModexchange = false
          } else {
            this.isModexchange = true
          }
        })
      Image($r("app.media.privious")).width(48).height(48).onClick(() => {
        //this.onPreviousMusic()
      })
      Image(this.imageArrays[0])
        .width(72)
        .height(72)
        .onClick(() => {
          Logger.info(TAG,`onclick play= ${PM.isPlaying}`)
          this.onPlayOrPauseMusic()
        })
      Image($r("app.media.next")).width(48).height(48).onClick(() => {
        //this.onNextMusic()
      })
      Image($r("app.media.list")).width(24).height(24).onClick(() => {
        //this.onShowMusicList()
      })
    }.width('100%').height(150).padding(32)
  }

  onPlayOrPauseMusic() {
    if (PM.isPlaying) {
      PM.pause(PM.isPlaying)
      this.imageArrays[0] = $r('app.media.play')
      this.stringArrays[0]= ('没有播放')
    } else {
      PM.preload(PM.index, () => {
        PM.play(-1, true)
        this.imageArrays[0] = $r('app.media.pause')
        this.stringArrays[0]= ('正在播放')
      })
    }
  }

  getShownTimer(ms) {
    let minStr: string
    let secStr: string
    let seconds = Math.floor(ms / 1000)
    let sec = seconds % 60
    Logger.info(TAG, `getShownTimer sec = ${sec}`)
    let min = (seconds - sec) / 60
    Logger.info(TAG, `getShownTimer min = ${min}`)
    if (sec < 10) {
      secStr = '0' + sec
    } else {
      secStr = sec.toString(10)
    }
    if (min < 10) {
      minStr = '0' + min
    } else {
      minStr = min.toString(10)
    }
    Logger.warn(TAG, `getShownTimer = ${minStr}:${secStr}`)
    return minStr + ':' + secStr
  }

  aboutToAppear(){
    this.currentTimeText = this.getShownTimer(0)
    PM.setOnStatusChangedListener((isPlaying) => {
      Logger.info(TAG, `on player status changed, isPlaying= ${PM.isPlaying} refresh ui`)
      PM.setOnPlayingProgressListener((currentTimeMs) => {
        this.currentTimeText = this.getShownTimer(currentTimeMs)
        this.currentProgress = Math.floor(currentTimeMs / this.totalMs * 100)
      })
      if (PM.isPlaying) {
        this.imageArrays[0] = $r('app.media.pause')
      } else {
        this.imageArrays[0] = $r('app.media.play')
      }
    })

    PM.getPlaylist(() => {
      Logger.info(TAG, 'on playlist generated, refresh ui')
      this.restoreFromWant()
    })
  }

  refreshSongInfo(index) {
    Logger.info(TAG, `refreshSongInfo ${index}/${PM.playlist.audioFiles.length}`)
    if (index >= PM.playlist.audioFiles.length) {
      Logger.warn(TAG, 'refreshSongInfo ignored')
      return
    }
    // update song title
    this.title = PM.playlist.audioFiles[index].name

    // update duration
    this.totalMs = PM.getDuration()
    this.totalTimeText = this.getShownTimer(this.totalMs)
    this.currentTimeText = this.getShownTimer(PM.getCurrentMs())
    Logger.info(TAG, `refreshSongInfo this.title= ${this.title}, this.totalMs= ${this.totalMs}, this.totalTimeText= ${this.totalTimeText},this.currentTimeText= ${this.currentTimeText}`)
  }

  restoreFromWant() {
    Logger.info(TAG, 'restoreFromWant')
    let status:any = AppStorage.Get('status')
    //dead
    if (status !== null && status.uri !== null) {
      Logger.info(TAG, 'restorePlayingStatus')
      PM.restorePlayingStatus(status, (index) => {
        Logger.info(TAG, `restorePlayingStatus finished, index= ${index}`)
        if (index >= 0) {
          this.refreshSongInfo(index)
        } else {
          PM.preload(0, () => {
            this.refreshSongInfo(0)
          })
        }
        Logger.info(TAG, `Index PlayerModel.restorePlayingStatus this.totalMs = ${this.totalMs}, status.seekTo = ${status.seekTo}`)
        this.currentProgress = Math.floor(status.seekTo / this.totalMs * 100)
      })
    } else {status.
      PM.preload(0, () => {
        this.refreshSongInfo(0)
      })
    }
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start }) {
        //第一行控件，返回，文字，分布式
        this.headPanel()
        //第二层控件，圆盘+歌名+//歌曲信息，竖向歌词进度条（待做）
        Flex({direction: FlexDirection.Column}) {
          this.DiscoPanel()
          this.MusicShowPanel()
        }
        //底下面板
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.End }) {
          this.sildeindicator()
          this.playPanel()
        }
      }
    }
  }
}