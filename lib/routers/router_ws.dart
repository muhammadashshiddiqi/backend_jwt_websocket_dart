import 'dart:convert';

import 'package:backend_websocket/utils/jwt.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';

late Connection conn;

class RouterWs {
  var handleWs = webSocketHandler((webSocket) async {
    webSocket.sink.add('CONNECTED TO WEBSOCKET');
    /* connection database */
    conn = await Connection.open(
      Endpoint(
        host: 'localhost',
        database: 'crud',
        username: 'postgres',
        password: 'root',
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );
    webSocket.sink.add('CONNECTING ....');
    final checkDB = await conn.execute('SELECT version();');
    webSocket.sink.add(jsonEncode(checkDB));
  });

  var insertWs = webSocketHandler((webSocket) async {
    webSocket.stream.listen((message) async {
      var listData = message.toString().split(' ');
      await conn.execute(
        Sql.named('INSERT INTO posts (title, body) VALUES (@title, @body)'),
        parameters: {
          'title': listData[0],
          'body': listData[1],
        },
      );
    });
  });

  var deleteWs = webSocketHandler((webSocket) async {
    webSocket.stream.listen((message) async {
      await conn.execute('DELETE FROM posts WHERE id=$message');
    });
  });

  var updateWs = webSocketHandler((webSocket) async {
    webSocket.stream.listen((message) async {
      var listData = message.toString().split(' ');

      await conn.execute(
        Sql.named(
            'UPDATE posts SET title = @title, body = @body WHERE uid = @uid'),
        parameters: {
          'uid': listData[0],
          'title': listData[1],
          'body': listData[2],
        },
      );
    });
  });

  Handler get router {
    final router = Router()
      ..get('/select', handleWs)
      ..get('/insert', insertWs)
      ..get('/delete', deleteWs)
      ..get('/update', updateWs);

    final handler = Pipeline()
        .addMiddleware(jwt.authorizationMiddleware())
        .addMiddleware(corsHeaders())
        .addMiddleware(logRequests())
        .addHandler(router.call);

    return handler;
  }
}

/* void main(List<String> args) async {
  //loop();
  final router = Router()
    ..get('/ws', handleWs)
    ..get('/insert', insertWs)
    ..get('/delete', deleteWs)
    ..get('/update', updateWs);

  final handler = Pipeline()
      .addMiddleware(jwt.authorizationMiddleware())
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(router.call);
  final server = await shelf_io.serve(handler, 'localhost', 4000);
  print('Server listening at ws://${server.address.host}:${server.port}');
} */
