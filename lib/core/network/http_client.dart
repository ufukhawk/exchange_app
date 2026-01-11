import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../constants/error_messages.dart';
import '../error/failures.dart';

class HttpClientWrapper {
  HttpClientWrapper({required http.Client client}) : _client = client;
  final http.Client _client;

  Future<Either<Failure, String>> get(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      final http.Response response =
          await _client.get(uri, headers: headers).timeout(
                timeout ?? AppConstants.requestTimeout,
              );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // TCMB XML encoding sorununu çözmek için manuel decode
        final String decodedBody = _decodeResponseBody(response);
        return right(decodedBody);
      } else if (response.statusCode == 404) {
        return left(
          ServerFailure(
            message: DefaultErrorMessages.dataNotFound,
            statusCode: response.statusCode,
          ),
        );
      } else if (response.statusCode >= 500) {
        return left(
          ServerFailure(
            message: DefaultErrorMessages.serverNotResponding,
            statusCode: response.statusCode,
          ),
        );
      } else {
        return left(
          ServerFailure(
            message: DefaultErrorMessages.dataCouldNotBeRetrieved,
            statusCode: response.statusCode,
          ),
        );
      }
    } on SocketException catch (_, stackTrace) {
      return left(
        ConnectionFailure(
          message: DefaultErrorMessages.checkInternetConnection,
          stackTrace: stackTrace,
        ),
      );
    } on TimeoutException catch (_, stackTrace) {
      return left(
        TimeoutFailure(
          message: DefaultErrorMessages.connectionTimeout,
          stackTrace: stackTrace,
        ),
      );
    } on http.ClientException catch (_, stackTrace) {
      return left(
        ConnectionFailure(
          message: DefaultErrorMessages.connectionFailed,
          stackTrace: stackTrace,
        ),
      );
    } catch (_, stackTrace) {
      return left(
        ServerFailure(
          message: DefaultErrorMessages.unexpected,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// TCMB XML response'unu doğru encoding ile decode eder
  /// Önce UTF-8 dener, başarısız olursa ISO-8859-9 (Latin-5) kullanır
  String _decodeResponseBody(http.Response response) {
    try {
      // Response headers'dan encoding'i kontrol et
      final String? contentType = response.headers['content-type'];
      if (contentType != null && contentType.contains('charset=')) {
        final String charset =
            contentType.split('charset=')[1].split(';')[0].trim().toLowerCase();
        if (charset.contains('utf-8') || charset.contains('utf8')) {
          return utf8.decode(response.bodyBytes, allowMalformed: true);
        } else if (charset.contains('iso-8859-9') ||
            charset.contains('latin-5') ||
            charset.contains('latin5')) {
          return latin1.decode(response.bodyBytes, allowInvalid: true);
        }
      }
      // XML declaration'dan encoding'i kontrol et
      final String bodyString =
          utf8.decode(response.bodyBytes, allowMalformed: true);
      if (bodyString.startsWith('<?xml')) {
        final int encodingIndex = bodyString.indexOf('encoding=');
        if (encodingIndex != -1) {
          final String encodingPart = bodyString.substring(encodingIndex);
          final int quoteStart = encodingPart.indexOf('"');
          final int quoteEnd = encodingPart.indexOf('"', quoteStart + 1);
          if (quoteStart != -1 && quoteEnd != -1) {
            final String xmlEncoding =
                encodingPart.substring(quoteStart + 1, quoteEnd).toLowerCase();
            if (xmlEncoding.contains('iso-8859-9') ||
                xmlEncoding.contains('latin-5') ||
                xmlEncoding.contains('latin5')) {
              return latin1.decode(response.bodyBytes, allowInvalid: true);
            }
          }
        }
      }
      // Varsayılan olarak UTF-8 dene
      return utf8.decode(response.bodyBytes, allowMalformed: true);
    } catch (e) {
      // UTF-8 başarısız olursa ISO-8859-9 dene
      try {
        return latin1.decode(response.bodyBytes, allowInvalid: true);
      } catch (_) {
        // Her ikisi de başarısız olursa orijinal body'yi döndür
        return response.body;
      }
    }
  }

  void dispose() {
    _client.close();
  }
}
