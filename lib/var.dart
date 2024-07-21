import 'package:postgres/postgres.dart';

final vr = _Var._();

class _Var {
  _Var._();

  Map<String, String> jwtToken = {};
  String secretKey = 'S3CR3TK3Y5';
  Connection? conn;
  int jwtIntervalTimeoutInMinutes = 10;
}
