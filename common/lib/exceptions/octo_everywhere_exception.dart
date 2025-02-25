/*
 * Copyright (c) 2023. Patrick Schmidt.
 * All rights reserved.
 */

import 'package:dio/dio.dart';

import 'mobileraker_exception.dart';

class OctoEverywhereException extends MobilerakerException {
  const OctoEverywhereException(String message, {super.parentException, super.parentStack}) : super(message);

  @override
  String toString() {
    return 'OctoEverywhereException{$message, parentException: $parentException}';
  }
}

class OctoEverywhereHttpException extends OctoEverywhereException {
  const OctoEverywhereHttpException(String message, this.statusCode, {super.parentException, super.parentStack})
      : super(message);

  final int statusCode;

  @override
  String toString() {
    return 'OctoEverywhereHttpException{$message, $statusCode, parentException: $parentException}';
  }
}

class OctoEverywhereDioException extends MobilerakerDioException implements OctoEverywhereException {
  OctoEverywhereDioException(
    String message,
    int statusCode, {
    required super.requestOptions,
  }) : super(type: DioExceptionType.badResponse, message: '$message - $statusCode');

  @override
  String toString() {
    return 'OctoEverywhereDioException [Bad Response]: $message';
  }
}
