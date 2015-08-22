//
//  SensorReadingParser.m
//  WagnerDMiOS
//
//  Created by Igor Ishchenko on 12/20/13.
//
//

#define COMPANYID_DATA  @"1235"
#define DATETIME_FORMAT @"yyyy-MM-dd HH:mm:ss"

#import "SensorReadingParser.h"
#import "Constant.h"
#import "Common.h"

NSString * const kSensorDataCompanyIDKey = @"companyId";
NSString * const kSensorDataModeKey = @"mode";
NSString * const kSensorDataSequenceKey = @"sequence";
NSString * const kSensorDataAddressKey = @"address";
NSString * const kSensorDataHumidityKey = @"humidity";
NSString * const kSensorDataTemperatureKey = @"battery";
NSString * const kSensorDataLightKey = @"light";
NSString * const kSensorDataUVIndexKey = @"uvindex";
NSString * const kSensorDataVoltageKey = @"voltage";
NSString * const kSensorDataHRMStateKey = @"hrmstate";
NSString * const kSensorDataHRMRateKey = @"hrmrate";
NSString * const kSensorDataHRMSampleKey = @"hrmsample";

NSString * const kSensorDataTimestampKey = @"timestamp";

@interface SensorReadingParser ()

- (float)RHFromBytes:(int)rh;
- (float)temperatureFromBytes:(int)temp;
//- (NSString*)serialNumberFromData:(NSData*)data withOffset:(NSInteger) offset;

@end

@implementation SensorReadingParser

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^
                  {
                      sharedInstance = [self new];
                  });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initOffsets];
    }
    return self;
}

- (void)initOffsets {
    kCompanyIDValueOffset = 0;
    kModeValueOffset = 2;
    kSequenceValueOffset = 3;
    kAddressValueOffset = 4;
    
    kHumidityValueOffset = 6;
    kTempValueOffset = 8;
    kLightValueOffset = 10;
    kUVIndexValueOffset = 12;
    kVoltageValueOffset = 13;
    
    kHRMStateValueOffset = 6;
    kHRMRateValueOffset = 7;
    kHRMSampleValueOffset = 8;
}


#define CHANGE_ENDIAN(a) ((((a) & 0xFF00) >> 8) + (((a) & 0xFF) << 8))

- (BOOL)validSensor:(NSData*)manufactureData {
    NSString *companyId = [self companyIDFromData:manufactureData withOffset:0];
    return [companyId isEqualToString:COMPANYID_DATA];
}

- (UInt8)getSensorDataMode:(NSData*)manufactureData {
    UInt8 mode = 0;
    mode = *(UInt8*)[[manufactureData subdataWithRange:NSMakeRange(kModeValueOffset, 1)] bytes];
    
    return mode;
}

- (NSString *)getSensorDataAddress:(NSData*)manufactureData {
    return [self addressFromData:manufactureData withOffset:0];
}

- (NSDictionary*)parseEnvironmentData:(NSData*)manufactureData {
    NSMutableDictionary *sensorData = [NSMutableDictionary dictionary];
    
//    NSLog(@"%@", manufactureData);
    
    NSString *companyId = [self companyIDFromData:manufactureData withOffset:0];
    UInt8 mode = *(UInt8*)[[manufactureData subdataWithRange:NSMakeRange(kModeValueOffset, 1)] bytes];
    UInt8 sequence = *(UInt8*)[[manufactureData subdataWithRange:NSMakeRange(kSequenceValueOffset, 1)] bytes];
    NSString *address = [self addressFromData:manufactureData withOffset:0];
    
    UInt16 humidity = *(UInt16*)[[manufactureData subdataWithRange:NSMakeRange(kHumidityValueOffset, 2)] bytes];
//    humidity = CHANGE_ENDIAN(humidity);
    UInt16 temp = *(UInt16*)[[manufactureData subdataWithRange:NSMakeRange(kTempValueOffset, 2)] bytes];
//    temp = CHANGE_ENDIAN(temp);
    UInt16 light = *(UInt16*)[[manufactureData subdataWithRange:NSMakeRange(kLightValueOffset, 2)] bytes];
//    light = CHANGE_ENDIAN(light) * 2;
    UInt32 realLight = light * 2;
    UInt8 uvIndex = *(UInt8*)[[manufactureData subdataWithRange:NSMakeRange(kUVIndexValueOffset, 1)] bytes];
    UInt8 voltage = *(UInt8*)[[manufactureData subdataWithRange:NSMakeRange(kVoltageValueOffset, 1)] bytes];
    if (TEST_MODE) {
        if (uvIndex > 0) {
            voltage = 25;
        }
    }
    
    NSDateFormatter * dFormatter = [[NSDateFormatter alloc] init];
    [dFormatter setDateFormat:DATETIME_FORMAT];
    NSString * readingTimeStamp = [dFormatter stringFromDate:[NSDate date]];
    
    [sensorData setObject:readingTimeStamp forKey:kSensorDataTimestampKey];
    [sensorData setObject:companyId forKey:kSensorDataCompanyIDKey];
    [sensorData setObject:[NSNumber numberWithInt:mode] forKey:kSensorDataModeKey];
    [sensorData setObject:[NSNumber numberWithFloat:sequence] forKey:kSensorDataSequenceKey];
    [sensorData setObject:address forKey:kSensorDataAddressKey];
    [sensorData setObject:[NSNumber numberWithFloat:humidity/10.0f] forKey:kSensorDataHumidityKey];
    [sensorData setObject:[NSNumber numberWithFloat:temp/10.0f] forKey:kSensorDataTemperatureKey];
    [sensorData setObject:[NSNumber numberWithInt:realLight] forKey:kSensorDataLightKey];
    [sensorData setObject:[NSNumber numberWithInt:uvIndex] forKey:kSensorDataUVIndexKey];
    [sensorData setObject:[NSNumber numberWithInt:voltage/10.0f] forKey:kSensorDataVoltageKey];
    
//    NSLog(@"Environment data : Sequence:%d, Humidity:%d, Temperature:%d, Light:%d, UVIndex:%d, Voltage:%d", sequence, humidity, temp, light, uvIndex, voltage);
    
    return [NSDictionary dictionaryWithDictionary:sensorData];
}

- (NSDictionary*)parseBiometricData:(NSData*)manufactureData {
    NSMutableDictionary *sensorData = [NSMutableDictionary dictionary];
    
    NSString *companyId = [self companyIDFromData:manufactureData withOffset:0];
    UInt8 mode = *(UInt8*)[[manufactureData subdataWithRange:NSMakeRange(kModeValueOffset, 1)] bytes];
    UInt8 sequence = *(UInt8*)[[manufactureData subdataWithRange:NSMakeRange(kSequenceValueOffset, 1)] bytes];
    NSString *address = [self addressFromData:manufactureData withOffset:0];
    
    UInt8 hrmState = *(UInt8*)[[manufactureData subdataWithRange:NSMakeRange(kHRMStateValueOffset, 1)] bytes];
    UInt8 hrmRate = *(UInt8*)[[manufactureData subdataWithRange:NSMakeRange(kHRMRateValueOffset, 1)] bytes];
    NSMutableArray *arraySample = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < HRM_SAMPLE_COUNT; i++) {
        UInt16 sampleData = *(UInt16*)[[manufactureData subdataWithRange:NSMakeRange(kHRMSampleValueOffset+(i*2), 2)] bytes];
        [arraySample addObject:[NSNumber numberWithInt:sampleData]];
    }
    
    [sensorData setObject:companyId forKey:kSensorDataCompanyIDKey];
    [sensorData setObject:[NSNumber numberWithInt:mode] forKey:kSensorDataModeKey];
    [sensorData setObject:[NSNumber numberWithFloat:sequence] forKey:kSensorDataSequenceKey];
    [sensorData setObject:address forKey:kSensorDataAddressKey];
    [sensorData setObject:[NSNumber numberWithInt:hrmState] forKey:kSensorDataHRMStateKey];
    [sensorData setObject:[NSNumber numberWithInt:hrmRate] forKey:kSensorDataHRMRateKey];
    [sensorData setObject:arraySample forKey:kSensorDataHRMSampleKey];
    
    return [NSDictionary dictionaryWithDictionary:sensorData];
}

- (float)RHFromBytes:(int)rh {
    // There is a problem with this method and the temperature method;
    // The value calculated should be to 0.1 precision, so the calculation and return value
    // should be a floating point (float) value, and when displayed on screen the
    // value should be something like 72.4, etc...
    // as it is, since you are casting to a UInt16 value, the "tenths" place gets rounded to nearest "ones" unit
    // with no 0.1 precision (i.e. precision = 0 in your case, but should equal 1
    
    // bytes need to be swapped
    /*
    if(CFByteOrderGetCurrent() == CFByteOrderLittleEndian) {
        rh = CFSwapInt16BigToHost(rh);
    }
     */
    float convrh = (-6.0f + (125.0f * rh / 65536.0f));
    //  rh = (UInt16)roundf(-6.0f + (125.0f * (rh/256 + (rh & 0xff) * 256) / 65536.0f));
    return convrh;
}

- (float)temperatureFromBytes:(int)temp {
    float temperature = temp;
    // bytes need to be swapped
    /*
    if(CFByteOrderGetCurrent() == CFByteOrderLittleEndian) {
        temperature = CFSwapInt16BigToHost(temperature);
    }
     */
    temperature = (-46.85f + (175.72f * temperature / 65536.0f));  // celsius
    //temperature = temperature * 1.8f + 32.0f;  // convert to fahrenheit
    return temperature;
}

- (NSString*)companyIDFromData:(NSData *)data withOffset:(NSInteger)offset {
    
    NSMutableString* companyIdString = [NSMutableString string];
    
    int companyIdOffset = kCompanyIDValueOffset + (int)offset;
    
    for(int i = 0; i < 2;++i)
    {
        UInt8 temp;
        [data getBytes:&temp range:NSMakeRange((i*1)+companyIdOffset, 1)];
        [companyIdString insertString:[NSString stringWithFormat:@"%02X",temp] atIndex:0];
    }
    
    return [NSString stringWithString:companyIdString];
}

- (NSString*)addressFromData:(NSData *)data withOffset:(NSInteger)offset {
    
    NSMutableString* addressString = [NSMutableString string];
    
    int companyIdOffset = kAddressValueOffset + (int)offset;
    
    for(int i = 0; i < 2;++i)
    {
        UInt8 temp;
        [data getBytes:&temp range:NSMakeRange((i*1)+companyIdOffset, 1)];
        [addressString insertString:[NSString stringWithFormat:@"%02X",temp] atIndex:0];
    }
    
    return [NSString stringWithString:addressString];
}

@end
