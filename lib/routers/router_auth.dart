import 'dart:convert';

import 'package:backend_websocket/utils/jwt.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:backend_websocket/var.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

late Connection conn;

class RouterAuth {
  Future<Response> authorization(Request request) async {
    final requestBody = await request.readAsString();
    final requestData = json.decode(requestBody);

    if (requestData == null) {
      return Response(
        400,
        body: jsonEncode({'message': 'request body is required'}),
      );
    }

    if (requestData['email'] == null) {
      return Response(
        400,
        body: jsonEncode({'message': 'title is required'}),
      );
    }

    if (requestData['password'] == null) {
      return Response(
        400,
        body: jsonEncode({'message': 'body is required'}),
      );
    }

    //TODO AUTH IN DB
    final result = await conn.execute(
      Sql.named(
          'SELECT email FROM users WHERE email = @email AND password = crypt(@password, password_hash)'),
      parameters: {
        'email': requestData['email'],
        'password': requestData['password'],
      },
    );

    if (result.affectedRows <= 0) {
      if (requestData['password'] == null) {
        return Response(
          400,
          body: jsonEncode({'message': 'password and email are incorrect'}),
        );
      }
    }

    //CREATE JWT
    var token = jwt.getToken(email: requestData['email']);
    vr.jwtToken[requestData['email']] = token;

    return Response.ok(
      jsonEncode({
        'message': 'Authorization successfully',
        'email': requestData['email'],
        'token': token,
      }),
    );
  }

  Handler get router {
    final router = Router();
    router.post(
        '/sign-in',
        Pipeline()
            .addMiddleware(corsHeaders())
            .addMiddleware(logRequests())
            .addHandler(authorization));

    return router.call;
  }
}
