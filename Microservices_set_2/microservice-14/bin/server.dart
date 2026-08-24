import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

Response _hello(Request request) => Response.ok('Hello from Microservice 14 (Dart Shelf)');

void main(List<String> args) async {
  final router = Router()
    ..get('/', _hello);

  final handler = Pipeline().addMiddleware(logRequests()).addHandler(router);

  final server = await serve(handler, InternetAddress.anyIPv4, 3014);

  print('Server listening on port ${server.port}');
}