class LoginCredentials {
  final String deviceId;
  final String influxdbToken;

  const LoginCredentials({required this.deviceId, required this.influxdbToken});

  @override
  String toString() {
    return 'LoginCredentials(deviceId: $deviceId, influxdbToken: [HIDDEN])';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LoginCredentials &&
        other.deviceId == deviceId &&
        other.influxdbToken == influxdbToken;
  }

  @override
  int get hashCode => deviceId.hashCode ^ influxdbToken.hashCode;
}
