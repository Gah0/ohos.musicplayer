import log from "../log"
import {AudioDemo,Music} from "../pm"

const TAG:string = 'Index: '
@Entry
@Component
struct Index {
  @State isPlaying: boolean = false
  @State isLike: boolean = false
  @State isLoop: boolean = false

  private turntableTimer: number
  @State pointerAngle: number = 0
  @State turntableAngle: number = 0
  @State currentProgress: number = 0

  @State currTime: number = 0
  @State TotalTime: number = 0
  @State currentTimeText: string = '00:00'
  @State totalTimeText: string = '00:00'

  @State message: string = 'Hello World'

  private av:AudioDemo=new AudioDemo(this)
  private currentMusic: Music = new Music()

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
        .aspectRatio(1.56)
        .rotate({
          x: 0,
          y: 0,
          z: 1,
          centerX: '50%',
          centerY: '50%',
          angle: this.turntableAngle
        })
    }
  }

  playAnimation() {
    if (this.turntableTimer) {
      return
    }
    let fun = () => {
      animateTo({ duration: 1500, curve: Curve.Linear, playMode: PlayMode.Normal },
        () => {
          this.turntableAngle = this.turntableAngle + 90;
        })
    }
    fun()
    this.turntableTimer = setInterval(fun, 1600)

    animateTo({ duration: 1500, curve: Curve.Linear, playMode: PlayMode.Normal },
      () => {
        this.pointerAngle = 39;
      })
  }

  pauseAnimation() {
    if (this.turntableTimer) {
      clearInterval(this.turntableTimer)
      this.turntableTimer = undefined
    }

    animateTo({ duration: 1500, curve: Curve.Linear, playMode: PlayMode.Normal },
      () => {
        this.pointerAngle = 0;
      })
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
        value: this.currentProgress,
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
          if (mode == 2) {
            //this.onChangeMusicIndicator(value)
          }
        })
    }.width('100%').height(18)

    Row() {
      Text(this.currentTimeText).fontSize(12).fontColor("ff000000").width(40).margin({ left: 30 })
      Text(this.totalTimeText).fontSize(12).fontColor("ff000000").width(40).margin({ left: 346 })
    }.margin({ top: 8 })
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
    if(this.isPlaying==false){
      this.av.playing(-1,this)
      this.playEvent(this.av.getCurrentMusic());
    }else{
      let seekTo=-1
      this.av.pauseing(seekTo);
      this.pauseEvent();
    }
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
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
    this.playAnimation()
  }

  pauseEvent() {
    this.isPlaying = false
    this.pauseAnimation()
  }

}