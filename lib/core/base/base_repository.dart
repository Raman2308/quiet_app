import 'package:dartz/dartz.dart';
import '../errors/failures.dart';
import '../errors/failure_mapper.dart';

import '../logger/logger.dart';

abstract class BaseRepository {
  final Logger logger;
  BaseRepository(this.logger);
  Future<Either<Failure, T>> executeSafely<T>(
    Future<T> Function() action, {
    String? methodName,
    Map<String, dynamic>? data,
  }) async {
    final m = methodName ?? 'unknown';
    // log entry with optional data payload
    logger.info('[$m] start. data: ${data ?? {}}');

    try {
      final result = await action();
      // successful result can be logged for debugging
      logger.info('[$m] success. result: $result');
      return Right(result);
    } catch (e, stackTrace) {
      // include error details and stack trace
      logger.error('[$m] exception', error: e, stackTrace: stackTrace);
      return Left(FailureMapper.mapException(e, stackTrace));
    }
  }
}
