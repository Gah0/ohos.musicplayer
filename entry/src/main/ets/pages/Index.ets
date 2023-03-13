import router from '@ohos.router'
import Logger from '../HiLog/Logger'
import PM from '../Common/PM'
import Song from '../Common/PM'
const TAG: string = 'Index'

@Entry
@Component
struct Index {
  @State isPlaying:Boolean =false
  @State turntableAngle: number = 0
  @State isLike: boolean = false
  @State isModexchange: boolean = false
  @State currentProgress: number = 0
  @State currentTimeText: string = '00:00'
  @State totalTimeText: string = '00:00'

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
      Text(PM.isPlaying ? ('正在播放') : ('没有播放')).fontSize(25).height(150).flexShrink(2).flexBasis('auto')
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
          Text('2315').fontSize(32)
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
            this.isModexchange != this.isModexchange;
        })
      Image($r("app.media.privious")).width(48).height(48).onClick(() => {
        //this.onPreviousMusic()
      })
      Image(PM.isPlaying ? $r("app.media.pause") : $r("app.media.play") )
        .width(72)
        .height(72)
        .onClick(() => {
          Logger.info(TAG,`onClick Index.isplaying = ${this.isPlaying}`)
          Logger.info(TAG,`onPlayOrPauseMusic() begin`)
          this.onPlayOrPauseMusic()
          this.isPlaying!=this.isPlaying;
          Logger.info(TAG,`onPlayOrPauseMusic() end`)
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
    Logger.info(TAG, `onPlayClick isPlaying= ${PM.isPlaying}`)
    if (PM.isPlaying) {
      //正在播放->暂停
      PM.pause()
      Logger.info(TAG, `------pause end----= ${PM.isPlaying}`)
    }else {
      //finish->播放,PM.index=0
      PM.preLoad(PM.index,()=>{
        PM.play(-1)
        this.isPlaying=PM.isPlaying;
        Logger.info(TAG, `------play end----= ${PM.isPlaying}`)
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