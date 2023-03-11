import router from '@ohos.router'

@Entry
@Component
struct layout {
  @State SearchText: string = ''

  build() {
    Column() {
      Flex({direction: FlexDirection.Column, wrap: FlexWrap.NoWrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center}){
        Search({ value: this.SearchText, placeholder: '推荐：Dynamic' })
          .searchButton('搜索')
          .backgroundColor('#E7E7E7')
          .placeholderColor(Color.Grey)
          .placeholderFont({ size: 18, weight: 10, family: 'serif', style: FontStyle.Normal })
          .textFont({ size: 18, weight: 10, family: 'serif', style: FontStyle.Normal })
          .height(42)
        //use stack() make a silde banner, text cover image
        Column() {
          Text("最喜爱的音乐").fontSize(27)
          Button('播放页')
            .margin({top:128,left:64})
            .onClick(() => {
            router.pushUrl({ url: 'pages/Index'})
          })
        }.margin({right:128,top:48})
      }.height('72%').margin({ top: 21,left:32 }).width('82%')
    }
  }
}