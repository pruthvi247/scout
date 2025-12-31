import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../storage/secure_storage_service.dart';
import '../network/dio_client.dart';
import '../network/auth_api_service.dart';

// Secure Storage Provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

// Secure Storage Service Provider
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return SecureStorageService(storage);
});

// Dio Client Provider
final dioClientProvider = Provider<DioClient>((ref) {
  final storageService = ref.watch(secureStorageServiceProvider);
  return DioClient(storageService);
});

// Dio Provider (for direct Dio access)
final dioProvider = Provider((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return dioClient.dio;
});

// Auth API Service Provider
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthApiService(dioClient);
});
