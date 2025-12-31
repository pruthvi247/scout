// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  fullName: json['full_name'] as String,
  profilePhoto: json['profile_photo'] as String?,
  role: json['role'] as String,
  postType: json['post_type'] as String?,
  organizationLevel: json['organization_level'] as String?,
  organizationPath: (json['organization_path'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  parentInchargeId: (json['parent_incharge_id'] as num?)?.toInt(),
  isActive: json['is_active'] as bool,
  isVerified: json['is_verified'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  lastLogin: json['last_login'] == null
      ? null
      : DateTime.parse(json['last_login'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'phone': instance.phone,
  'full_name': instance.fullName,
  'profile_photo': instance.profilePhoto,
  'role': instance.role,
  'post_type': instance.postType,
  'organization_level': instance.organizationLevel,
  'organization_path': instance.organizationPath,
  'parent_incharge_id': instance.parentInchargeId,
  'is_active': instance.isActive,
  'is_verified': instance.isVerified,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'last_login': instance.lastLogin?.toIso8601String(),
};

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  username: json['username'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      refreshToken: json['refresh_token'] as String?,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'refresh_token': instance.refreshToken,
    };

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      postType: json['post_type'] as String?,
      organizationLevel: json['organization_level'] as String?,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'full_name': instance.fullName,
      'role': instance.role,
      'phone': instance.phone,
      'post_type': instance.postType,
      'organization_level': instance.organizationLevel,
    };

UpdateUserRequest _$UpdateUserRequestFromJson(Map<String, dynamic> json) =>
    UpdateUserRequest(
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      organizationLevel: json['organization_level'] as String?,
    );

Map<String, dynamic> _$UpdateUserRequestToJson(UpdateUserRequest instance) =>
    <String, dynamic>{
      'full_name': instance.fullName,
      'phone': instance.phone,
      'profile_photo': instance.profilePhoto,
      'organization_level': instance.organizationLevel,
    };
