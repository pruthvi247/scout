import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String? username;
  final String email;
  final String? phone;
  @JsonKey(name: 'full_name')
  final String fullName;
  @JsonKey(name: 'profile_photo')
  final String? profilePhoto;
  final String role;
  @JsonKey(name: 'post_type')
  final String? postType;
  @JsonKey(name: 'organization_level')
  final String? organizationLevel;
  @JsonKey(name: 'organization_path')
  final List<String>? organizationPath;
  @JsonKey(name: 'parent_incharge_id')
  final int? parentInchargeId;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'last_login')
  final DateTime? lastLogin;

  User({
    required this.id,
    this.username,
    required this.email,
    this.phone,
    required this.fullName,
    this.profilePhoto,
    required this.role,
    this.postType,
    this.organizationLevel,
    this.organizationPath,
    this.parentInchargeId,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String username;
  final String email;
  final String password;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String role;
  final String? phone;
  @JsonKey(name: 'post_type')
  final String? postType;
  @JsonKey(name: 'organization_level')
  final String? organizationLevel;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
    this.phone,
    this.postType,
    this.organizationLevel,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class UpdateUserRequest {
  @JsonKey(name: 'full_name')
  final String? fullName;
  final String? phone;
  @JsonKey(name: 'profile_photo')
  final String? profilePhoto;
  @JsonKey(name: 'organization_level')
  final String? organizationLevel;

  UpdateUserRequest({
    this.fullName,
    this.phone,
    this.profilePhoto,
    this.organizationLevel,
  });

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateUserRequestToJson(this);
}
