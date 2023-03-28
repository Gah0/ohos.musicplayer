import log from "../log"
import {AudioDemo,Music} from "../pm"
import router from '@ohos.router';

const TAG:string = 'Index: '

@Entry
@Component
struct Index {
  @State isPlaying: boolean = false
  @State isLike: boolean = false
  @State isLoop: boolean = false

  @State turntableAngle: number = 0
  @State currentProgress: number = 0

  @State currTime: number = 0
  @State TotalTime: number = 0
  @State currentTimeText: string = '00:00'
  @State totalTimeText: string = '00:00'

  private currentMusic: Music = new Music()
  private av:AudioDemo=new AudioDemo(this)

  @Builder HeadPanel(){
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
          //router.pushUrl({ url: 'pages/Firstpage'})
        })
      Text(this.isPlaying ? ('正在播放') : ('没有播放')).fontSize(25).height(150).flexShrink(2).flexBasis('auto')
      Image($r("app.media.distribute"))
        .width(38)
        .height(38)
        .onClick(() => {
        })
    }.padding(16).margin({top: 16, bottom: 16})
  }

  @Builder DiscoPanel(){
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceEvenly}) {
      Image($r("app.media.img_turntable"))
        .objectFit(ImageFit.Contain)
        .aspectRatio(1.36)
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

  @Builder Indicator() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Slider({
        value: this.AcurrProgress,
        min: 0,
        max: 100,
        step: 1,
        style: SliderStyle.InSet
      })
        .blockColor('#191970')
        .trackColor('#ADD8E6')
        .selectedColor('#4169E1')
        .showSteps(false)
        .flexGrow(1)
        .margin({ left: 24, right: 24 })
        .onChange((value: number, mode: SliderChangeMode) => {
            //this.onChangeMusicIndicator(value)
        })
    }.width('100%').height(18)
  }

  @Builder PlayPanel() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      Image(this.isLoop ? $r("app.media.icon_music_sequence") : $r("app.media.icon_music_mode1"))
        .width(22).height(22)
        .onClick(() => {
            this.isLoop =! this.isLoop;
        })
      Image($r("app.media.privious")).width(48).height(48).onClick(() => {
        //this.onPreviousMusic()
      })
      Image(this.isPlaying ? $r("app.media.pause") : $r("app.media.play"))
        .width(72)
        .height(72)
        .onClick(() => {
            this.PlayorPause()
        })
      Image($r("app.media.next")).width(48).height(48).onClick(() => {
        //this.onNextMusic()
      })
      Image($r("app.media.list")).width(24).height(24).onClick(() => {
        //this.onShowMusicList()
      })
    }.width('100%').height(150).padding(32)
  }

  PlayorPause(){
    log.info(TAG + `1按了一下 => show PlayerModel.isPlaying =${this.isPlaying}`)
    if(this.isPlaying==true && (this.av.stoppedsignal==false && this.av.pausedsignal==false)){
      let seekTo=-1
      this.av.pauseing(seekTo);
    }else{
      this.av.playing(-1,this)
    }
  }
/*
  ProgressEvent(currentTimeMs: number, totalTimeMs: number) {
    //刷新currentTimeText
    this.currentTimeText = this.ms2TimeText(currentTimeMs)
    //获得音频时间条滑动系数
    this.AcurrProgress = Math.floor(currentTimeMs / totalTimeMs * 100)
    //渲染totaltimetext
    if (this.totalTimeText == '00:00') {
      this.totalTimeText = this.ms2TimeText(totalTimeMs)
    }
  }
*/
  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start }) {
        //第一行控件，返回，文字，分布式
        this.HeadPanel()
        //第二层控件，圆盘+歌名+//歌曲信息，竖向歌词进度条（待做）
        Flex({direction: FlexDirection.Column}) {
          this.DiscoPanel()
          //this.MusicShowPanel()
        }
        //底下面板
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.End }) {
          this.Indicator()
          this.PlayPanel()
        }
      }
    }
  }
  playEvent(music: Music) {
    this.currentMusic.name = music.name
    this.currentMusic.author = music.author

    this.isPlaying = true
  }

  pauseEvent() {
    this.isPlaying = false
  }
}