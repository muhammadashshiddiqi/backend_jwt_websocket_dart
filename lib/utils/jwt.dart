import 'package:backend_websocket/var.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';

final jwt = _JWT._();

class _JWT {
  _JWT._();

  String getToken({required String email}) {
    var jwt = JWT({
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now()
              .add(Duration(minutes: vr.jwtIntervalTimeoutInMinutes))
              .millisecondsSinceEpoch ~/
          1000,
      'email': email,
    });

    return jwt.sign(SecretKey(vr.secretKey));
  }

  Middleware authorizationMiddleware() {
    return (Handler handler) {
      return (Request request) async {
        Map<String, String> authorization = request.url.queryParameters;

        if (authorization.isNotEmpty) {
          var auth = authorization['auth'] ?? '';
          if (auth.isNotEmpty) {
            try {
              final jwt = JWT.verify(auth, SecretKey(vr.secretKey));
              var req = request.change(context: {'jwt': jwt});
              return handler(req);
            } catch (e) {
              return Response.forbidden('Invalid Token');
            }
          } else {
            return Response.forbidden('Missing Authorization Header');
          }
        } else {
          return Response.forbidden('Missing Authorization Header');
        }
      };
    };
  }
}
