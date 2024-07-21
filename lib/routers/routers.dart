import 'package:backend_websocket/routers/router_auth.dart';
import 'package:backend_websocket/routers/router_ws.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class Routers {
  final RouterWs routerWs;
  final RouterAuth routerAuth;

  Routers({
    required this.routerWs,
    required this.routerAuth,
  });

  Handler get router {
    final router = Router();
    final prefixApi = '/api';
    final prefixWs = '/ws';

    router.mount(prefixWs, routerWs.router);
    router.mount(prefixApi, routerAuth.router);

    return Pipeline().addHandler(router.call);
  }
}
