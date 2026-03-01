import '../logger/app_logger.dart';
import '../errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class BaseController {
  void handleResult<T>(
    Either<Failure, T> result, {
    required String methodName,
    Function(T value)? onSuccess,
    Function(Failure failure)? onFailure,
  }) {
    result.fold(
      (failure) {
        AppLogger.appError('$methodName failed', error: failure.message);

        if (onFailure != null) {
          onFailure(failure);
        }
      },
      (value) {
        AppLogger.appInfo('$methodName success');

        if (onSuccess != null) {
          onSuccess(value);
        }
      },
    );
  }
}
