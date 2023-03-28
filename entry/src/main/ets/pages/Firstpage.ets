import log from "../log";
import {AudioDemo} from "../pm";
import router from '@ohos.router';

const TAG:string = 'Setting: '
@Entry
@Component
struct Firstpage {
  @State fontColor: string = '#182431'
  @State selectedFontColor: string = '#007DFF'
  @State currentIndex: number = 0
  private newimg:Resource
  private controller: TabsController = new TabsController()

  @Builder TabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.currentIndex === index ? this.selectedFontColor : this.fontColor)
        .fontSize(18)
        .fontWeight(this.currentIndex === index ? 500 : 400)
        .lineHeight(22)
        .margin({ top: 17, bottom: 7 })
      Divider()
        .lineCap(5)
        .strokeWidth(4)
        .color('#007DFF')
        .opacity(this.currentIndex === index ? 1 : 0)
    }.width('100%')
  }

  @Builder IconAndSetting(image: Resource) {
    Column() {
      Image(image).borderRadius(32).width(54).height(54)
    }
  }

  @Builder tabandContent() {
    Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
      TabContent() {
        Column().width('100%').height('100%').backgroundColor('#00CB87')
      }.tabBar(this.TabBuilder(0, '主页'))

      TabContent() {
        Column().width('100%').height('100%').backgroundColor('#007DFF')
      }.tabBar(this.TabBuilder(1, '推荐'))

      TabContent(){
        Column().width('100%').height('100%').backgroundColor('#FFBF00')
      }.tabBar(this.TabBuilder(2, '社区'))

      TabContent(){
        Column().width('100%').height('100%').backgroundColor('#E67C92')
      }.tabBar(this.TabBuilder(3, '播放'))
    }
    .vertical(false)
    .barMode(BarMode.Fixed)
    .barWidth('100%')
    .barHeight(56)
    .animationDuration(400)
    .onChange((index: number) => {
      this.currentIndex = index
    })
    .width('100%')
    .height('35%')
    .backgroundColor('#F1F3F5')
  }

  build() {
      Column() {
        this.tabandContent()
        //image
        Button('Play')
          .width(64)
          .height(64)
          .margin({ top: 378, left:264 })
          .onClick(() => {
          router.pushUrl({ url: 'pages/Index' })
        })
    }.width('100%')
  }
}