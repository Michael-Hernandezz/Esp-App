import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.deviceId,
    required super.organization,
    required super.bucket,
    required super.loginTime,
    super.isTokenValid,
  });

  factory UserModel.fromEntity(User user) {
    return UserModel(
      deviceId: user.deviceId,
      organization: user.organization,
      bucket: user.bucket,
      loginTime: user.loginTime,
      isTokenValid: user.isTokenValid,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      deviceId: json['deviceId'] as String,
      organization: json['organization'] as String,
      bucket: json['bucket'] as String,
      loginTime: DateTime.parse(json['loginTime'] as String),
      isTokenValid: json['isTokenValid'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'organization': organization,
      'bucket': bucket,
      'loginTime': loginTime.toIso8601String(),
      'isTokenValid': isTokenValid,
    };
  }

  User toEntity() {
    return User(
      deviceId: deviceId,
      organization: organization,
      bucket: bucket,
      loginTime: loginTime,
      isTokenValid: isTokenValid,
    );
  }
}
