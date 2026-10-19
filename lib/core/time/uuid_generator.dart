import 'package:uuid/uuid.dart';

abstract class UuidGenerator {
  String v4();
}

class DefaultUuidGenerator implements UuidGenerator {
  final Uuid _uuid = const Uuid();

  @override
  String v4() => _uuid.v4();
}

class SequentialUuidGenerator implements UuidGenerator {
  SequentialUuidGenerator(this._ids);
  final List<String> _ids;
  var _index = 0;

  @override
  String v4() {
    if (_index >= _ids.length) {
      return 'fallback-uuid-$_index';
    }
    return _ids[_index++];
  }
}
