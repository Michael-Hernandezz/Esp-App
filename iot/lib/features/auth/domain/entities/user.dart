class User {
  final String deviceId;
  final String organization;
  final String bucket;
  final DateTime loginTime;
  final bool isTokenValid;

  const User({
    required this.deviceId,
    required this.organization,
    required this.bucket,
    required this.loginTime,
    this.isTokenValid = true,
  });

  User copyWith({
    String? deviceId,
    String? organization,
    String? bucket,
    DateTime? loginTime,
    bool? isTokenValid,
  }) {
    return User(
      deviceId: deviceId ?? this.deviceId,
      organization: organization ?? this.organization,
      bucket: bucket ?? this.bucket,
      loginTime: loginTime ?? this.loginTime,
      isTokenValid: isTokenValid ?? this.isTokenValid,
    );
  }

  @override
  String toString() {
    return 'User(deviceId: $deviceId, organization: $organization, bucket: $bucket, loginTime: $loginTime, isTokenValid: $isTokenValid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.deviceId == deviceId &&
        other.organization == organization &&
        other.bucket == bucket &&
        other.loginTime == loginTime &&
        other.isTokenValid == isTokenValid;
  }

  @override
  int get hashCode {
    return deviceId.hashCode ^
        organization.hashCode ^
        bucket.hashCode ^
        loginTime.hashCode ^
        isTokenValid.hashCode;
  }
}
