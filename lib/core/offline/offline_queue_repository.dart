import 'package:nova/core/offline/offline_action_status.dart';
import 'package:nova/core/offline/offline_queue_item.dart';
import 'package:nova/core/services/local_storage_service.dart';

abstract class OfflineQueueRepositoryInterface {
  Future<List<OfflineQueueItem>> getAllItems();
  Future<List<OfflineQueueItem>> getPendingItems();
  Future<List<OfflineQueueItem>> getFailedItems();
  Future<int> sumActiveQueueAmountKobo();
  Future<void> recoverStaleProcessing();
  Future<void> enqueue(OfflineQueueItem item);
  Future<void> update(OfflineQueueItem item);
  Future<void> remove(String id);
  Future<OfflineQueueItem?> findById(String id);
  Future<OfflineQueueItem?> findByIdempotencyKey(String key);
  Future<void> retryFailed(String id);
}

class OfflineQueueRepository implements OfflineQueueRepositoryInterface {
  OfflineQueueRepository({required LocalStorageService storage}) : _storage = storage;

  final LocalStorageService _storage;
  static const String _listKey = 'queue_items';

  List<OfflineQueueItem> _readAll() {
    final raw = _storage.queueBox.get(_listKey, defaultValue: <dynamic>[]) as List;
    return raw.map((e) => OfflineQueueItem.fromJson(Map<dynamic, dynamic>.from(e as Map))).toList();
  }

  Future<void> _writeAll(List<OfflineQueueItem> items) async {
    await _storage.queueBox.put(_listKey, items.map((e) => e.toJson()).toList());
  }

  int _amountFromItem(OfflineQueueItem item) => item.payload['amountKobo'] as int;

  @override
  Future<List<OfflineQueueItem>> getAllItems() async => _readAll();

  @override
  Future<List<OfflineQueueItem>> getPendingItems() async {
    return _readAll()
        .where((i) => i.status == OfflineActionStatus.pending || i.status == OfflineActionStatus.processing)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<List<OfflineQueueItem>> getFailedItems() async {
    return _readAll().where((i) => i.status == OfflineActionStatus.failed).toList();
  }

  @override
  Future<int> sumActiveQueueAmountKobo() async {
    final items = await getPendingItems();
    return items.fold<int>(0, (sum, item) => sum + _amountFromItem(item));
  }

  @override
  Future<void> recoverStaleProcessing() async {
    final all = _readAll();
    var changed = false;
    for (var i = 0; i < all.length; i++) {
      if (all[i].status == OfflineActionStatus.processing) {
        all[i] = all[i].copyWith(status: OfflineActionStatus.pending);
        changed = true;
      }
    }
    if (changed) {
      await _writeAll(all);
    }
  }

  @override
  Future<void> enqueue(OfflineQueueItem item) async {
    final all = _readAll();
    all.add(item);
    await _writeAll(all);
  }

  @override
  Future<void> update(OfflineQueueItem item) async {
    final all = _readAll();
    final index = all.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      all[index] = item;
      await _writeAll(all);
    }
  }

  @override
  Future<void> remove(String id) async {
    final all = _readAll().where((e) => e.id != id).toList();
    await _writeAll(all);
  }

  @override
  Future<OfflineQueueItem?> findById(String id) async {
    return _readAll().where((e) => e.id == id).firstOrNull;
  }

  @override
  Future<OfflineQueueItem?> findByIdempotencyKey(String key) async {
    return _readAll().where((e) => e.idempotencyKey == key).firstOrNull;
  }

  @override
  Future<void> retryFailed(String id) async {
    final item = await findById(id);
    if (item == null || item.status != OfflineActionStatus.failed) return;
    await update(item.copyWith(status: OfflineActionStatus.pending, errorMessage: null));
  }
}
