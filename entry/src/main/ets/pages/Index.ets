import { RiskLevel, SunExposureViewModel } from '../viewmodel/SunExposureViewModel';


@Entry
@Component
struct SunExposureTracker {

  @State vm: SunExposureViewModel = new SunExposureViewModel();

  aboutToAppear() {
    this.vm.startSensors();
  }

  aboutToDisappear() {
    this.vm.stopSensors();
  }

  build() {
    Stack() {
      Circle()
        .width('120%')
        .height('120%')
        .fill(this.vm.riskColor)
        .opacity(0.2)
        .animation({ duration: 500, curve: Curve.EaseInOut })

      Column({ space: 10 }) {
        Text('Sun Exposure')
          .fontSize(14)
          .fontColor(Color.White)
          .opacity(0.7)
          .margin({ top: 12 })

        Stack() {
          Gauge({ value: this.vm.ambientLight, min: 0, max: 60000 })
            .startAngle(210)
            .endAngle(150)
            .colors([[this.vm.riskColor, 1]])
            .strokeWidth(15)
            .width(160)
            .height(160)
            .animation({ duration: 500 })

          Column() {
            if (this.vm.currentRisk === RiskLevel.EXTREME) {
              Image($r('app.media.sun_alert'))
                .width(32)
                .height(32)
                .fillColor(Color.White)
            }

            Text(this.vm.currentRisk)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .textAlign(TextAlign.Center)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .padding({ left: 10, right: 10 })
          }
        }
        .margin({ top: 5 })
        Row() {
          Column() {
            Text('LIGHT (Lux)')
              .fontSize(10)
              .fontColor(Color.Gray)
            Text(this.vm.ambientLight.toFixed(0))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
          }
          .alignItems(HorizontalAlign.Center)

          Divider()
            .vertical(true)
            .height(20)
            .color(Color.Gray)
            .margin({ left: 15, right: 15 })

          Column() {
            Text('TEMP (°C)')
              .fontSize(10)
              .fontColor(Color.Gray)
            Text(this.vm.ambientTemp.toFixed(1) + '°')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
          }
          .alignItems(HorizontalAlign.Center)
        }
        .margin({ bottom: 20 })

      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}