abstract interface class BasePushNotifiactionRepository {
  Future<void> subscribe({required String token});
}
