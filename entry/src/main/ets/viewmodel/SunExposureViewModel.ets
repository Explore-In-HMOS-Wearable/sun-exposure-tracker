import { sensor, vibrator } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';

export enum RiskLevel {
  LOW = 'Low Risk',
  MEDIUM = 'Medium Risk',
  HIGH = 'High Risk',
  EXTREME = 'AVOID SUN'
}

export const COLOR_LOW = '#00CC66';
export const COLOR_MEDIUM = '#FFCC00';
export const COLOR_HIGH = '#FF6600';
export const COLOR_EXTREME = '#FF0033';

@Observed
export class SunExposureViewModel {
  public ambientLight: number = 0;
  public ambientTemp: number = 45;
  public currentRisk: RiskLevel = RiskLevel.LOW;
  public riskColor: string = COLOR_LOW;

  private lastVibrationTime: number = 0;

  public startSensors() {
    try {
      sensor.on(sensor.SensorId.AMBIENT_LIGHT, (data: sensor.LightResponse) => {
        this.ambientLight = data.intensity;
        this.calculateRisk();
      }, { interval: 1000000000 });

      sensor.on(sensor.SensorId.AMBIENT_TEMPERATURE, (data: sensor.AmbientTemperatureResponse) => {
        this.ambientTemp = data.temperature;
        this.calculateRisk();
      }, { interval: 1000000000 });

    } catch (error) {
      let e: BusinessError = error as BusinessError;
      console.error(`Sensor start error: Code: ${e.code}, message: ${e.message}`);
    }
  }

  public stopSensors() {
    try {
      sensor.off(sensor.SensorId.AMBIENT_LIGHT);
      sensor.off(sensor.SensorId.AMBIENT_TEMPERATURE);
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      console.error(`Sensor stop error: Code: ${e.code}, message: ${e.message}`);
    }
  }

  private calculateRisk() {
    let lux = this.ambientLight;
    let temp = this.ambientTemp;
    let newRisk: RiskLevel;
    let newColor: string;

    if (lux > 50000 || (lux > 30000 && temp > 35)) {
      newRisk = RiskLevel.EXTREME;
      newColor = COLOR_EXTREME;
    } else if (lux > 30000 || (lux > 10000 && temp > 30)) {
      newRisk = RiskLevel.HIGH;
      newColor = COLOR_HIGH;
    } else if (lux > 5000 || temp > 28) {
      newRisk = RiskLevel.MEDIUM;
      newColor = COLOR_MEDIUM;
    } else {
      newRisk = RiskLevel.LOW;
      newColor = COLOR_LOW;
    }

    this.currentRisk = newRisk;
    this.riskColor = newColor;

    if ((newRisk === RiskLevel.HIGH || newRisk === RiskLevel.EXTREME)) {
      this.triggerWarningVibration();
    }
  }

  private triggerWarningVibration() {
    let currentTime = new Date().getTime();
    if (currentTime - this.lastVibrationTime < 5000) {
      return;
    }

    try {
      vibrator.startVibration({
        type: 'time',
        duration: 1000,
      }, {
        id: 0,
        usage: 'alarm'
      }).then(() => {
        console.info('Warning vibration sent.');
        this.lastVibrationTime = currentTime;
      }, (error: BusinessError) => {
        console.error(`Vibration failed: ${error.code}, ${error.message}`);
      });
    } catch (err) {
      console.error(`Unexpected vibration error: ${err}`);
    }
  }
}