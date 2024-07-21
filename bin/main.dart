import 'package:backend_websocket/routers/router_auth.dart';
import 'package:backend_websocket/routers/router_ws.dart';
import 'package:backend_websocket/routers/routers.dart';
import 'package:backend_websocket/var.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

void main() async {
  /* connection database */
  final connection = await Connection.open(
    Endpoint(
      host: 'localhost',
      database: 'crud',
      username: 'postgres',
      password: 'root',
    ),
    settings: ConnectionSettings(sslMode: SslMode.disable),
  );
  print('CONNECTING .....');
  final checkDB = await connection.execute('SELECT version();');
  print('CONNECTED TO DATABASE ${checkDB[0][0]}');
  vr.conn = connection;
  /* connection database */

  /* router all */
  final routers = Routers(
    routerWs: RouterWs(),
    routerAuth: RouterAuth(),
  ).router;

  final handler = Pipeline().addHandler(routers);
  /* router all */

  final server = await shelf_io.serve(handler, 'localhost', 9000);
  print('Serving listening at ${server.address.host}:${server.port}');

  /* await connection.close();
  print('CONNECT CLOSED .....');
  await server.close(); */
}
