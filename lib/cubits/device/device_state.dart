part of 'device_cubit.dart';

class DeviceState extends Equatable {
  final bool isDarkTheme;
  // final Size deviceDimensions;
  final String deviceId;
  final String token;

  const DeviceState({
    required this.deviceId,
    required this.isDarkTheme,
    required this.token,
  });

  @override
  List<Object?> get props => [
        deviceId,
        isDarkTheme,
        token,
      ];

  factory DeviceState.initial() {
    return DeviceState(
      deviceId: '',
      isDarkTheme: false,
      token: '',
    );
  }

  DeviceState copyWith({
    bool? isDarkTheme,
    String? deviceId,
    String? token,
  }) {
    return DeviceState(
      deviceId: deviceId ?? this.deviceId,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      token: token ?? this.token,
    );
  }

  factory DeviceState.fromJson(Map<String, dynamic> json) {
    print('devState fromJson');
    String devId = json['deviceId'] == null || json['deviceId'] == ''
        // || json['deviceId'] == "Instance of 'UuidV4'"
        ? UuidV4().generate()
        : json['deviceId'];
    // print(json);
    print('devId: $devId');

    return DeviceState(
      deviceId: devId,
      isDarkTheme: json['isDarkTheme'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'isDarkTheme': isDarkTheme,
      'token': token,
    };
  }
}
