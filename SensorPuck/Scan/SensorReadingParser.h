//
//  SensorReadingParser.h
//  WagnerDMiOS
//
//  Created by Igor Ishchenko on 12/20/13.
//
//

#import <Foundation/Foundation.h>

extern NSString * const kSensorDataCompanyIDKey;
extern NSString * const kSensorDataModeKey;
extern NSString * const kSensorDataSequenceKey;
extern NSString * const kSensorDataAddressKey;
extern NSString * const kSensorDataHumidityKey;
extern NSString * const kSensorDataTemperatureKey;
extern NSString * const kSensorDataLightKey;
extern NSString * const kSensorDataUVIndexKey;
extern NSString * const kSensorDataVoltageKey;
extern NSString * const kSensorDataHRMStateKey;
extern NSString * const kSensorDataHRMRateKey;
extern NSString * const kSensorDataHRMSampleKey;

extern NSString * const kSensorDataTimestampKey;


@interface SensorReadingParser : NSObject {
    int kCompanyIDValueOffset;
    int kModeValueOffset;
    int kSequenceValueOffset;
    int kAddressValueOffset;
    int kHumidityValueOffset;
    int kTempValueOffset;
    int kLightValueOffset;
    int kUVIndexValueOffset;
    int kVoltageValueOffset;
    int kHRMStateValueOffset;
    int kHRMRateValueOffset;
    int kHRMSampleValueOffset;
}

+ (instancetype)sharedInstance;

- (BOOL)validSensor:(NSData*)manufactureData;
- (UInt8)getSensorDataMode:(NSData*)manufactureData;
- (NSString *)getSensorDataAddress:(NSData*)manufactureData;
- (NSDictionary*)parseEnvironmentData:(NSData*)manufactureData;
- (NSDictionary*)parseBiometricData:(NSData*)manufactureData;

@end
