import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/health_status.dart';
import '../../domain/usecases/check_health_usecase.dart';

enum HealthStateStatus { initial, loading, success, error }

class HealthController extends ChangeNotifier {
  final CheckHealthUseCase checkHealthUseCase;

  HealthStateStatus _state = HealthStateStatus.initial;
  HealthStatus? _healthStatus;
  String? _errorMessage;

  HealthController({required this.checkHealthUseCase});

  HealthStateStatus get state => _state;
  HealthStatus? get healthStatus => _healthStatus;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == HealthStateStatus.loading;
  bool get isSuccess => _state == HealthStateStatus.success;
  bool get isError => _state == HealthStateStatus.error;

  Future<void> checkConnection() async {
    _state = HealthStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final status = await checkHealthUseCase();
      _healthStatus = status;
      _state = HealthStateStatus.success;
    } on Failure catch (failure) {
      _errorMessage = failure.message;
      _state = HealthStateStatus.error;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _state = HealthStateStatus.error;
    } finally {
      notifyListeners();
    }
  }
}
