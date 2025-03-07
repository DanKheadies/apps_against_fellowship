part of 'device_cubit.dart';

class DeviceState extends Equatable {
  final String deviceId;
  final String token;

  const DeviceState({
    required this.deviceId,
    required this.token,
  });

  @override
  List<Object?> get props => [
        deviceId,
        token,
      ];

  factory DeviceState.initial() {
    return DeviceState(
      deviceId: '',
      token: '',
    );
  }

  DeviceState copyWith({
    String? deviceId,
    String? token,
  }) {
    return DeviceState(
      deviceId: deviceId ?? this.deviceId,
      token: token ?? this.token,
    );
  }

  factory DeviceState.fromJson(Map<String, dynamic> json) {
    print('devState fromJson');
    String devId = json['deviceId'] == null ||
            json['deviceId'] == '' ||
            json['deviceId'] == "Instance of 'UuidV4'"
        ? UuidV4().generate()
        : json['deviceId'];
    print(json);
    print(devId);

    return DeviceState(
      deviceId: devId,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'token': token,
    };
  }
}
