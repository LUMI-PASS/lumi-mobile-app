import 'dart:async';

import 'package:dio/dio.dart';

import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/service/interest_source.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/domain/repo/interests/interests_api.dart';

// ignore: avoid_print
void _log(String msg) => print('[Interest] $msg');

/// Matches the server's `MAX_BATCH_SIZE`; a larger batch is rejected whole.
const _maxBatch = 50;

/// Older than this and the server drops the event, so there is no point
/// carrying it — it also bounds the queue for a user who is offline for weeks.
const _maxAge = Duration(days: 7);

/// Reports booking intent that never became a purchase.
///
/// This is the ONLY thing the app tells the backend about interest. Views,
/// searches and category browsing are recorded server-side from the catalog
/// requests the app already makes, which is why they work on builds that will
/// never be updated and cannot be inflated by a modified client. A booking
/// sheet opened and abandoned makes no request at all, so it has to be sent.
///
/// Queued and persisted, because the signal is by definition a user who lost
/// interest and left: the send has to survive the app being closed on a bad
/// connection. Every method is best-effort and never throws — this must not be
/// the reason a booking sheet fails to open.
@lazySingleton
class InterestReporter {
  InterestReporter(this._api, this._storage);

  final InterestsApi _api;
  final Storage _storage;

  /// Guards against two flushes racing and posting the same event twice.
  bool _flushing = false;

  /// Records that a booking sheet was opened, and tries to send it.
  ///
  /// [source] defaults to the screen the user is on, which for a booking sheet
  /// is the class detail page it was opened from.
  Future<void> bookTapped(String activityId, {String? source}) async {
    try {
      if (activityId.isEmpty) return;
      _enqueue({
        'kind': 'book_tapped',
        'activity_id': activityId,
        if ((source ?? InterestSourceTracker.instance.current) != null)
          'source': source ?? InterestSourceTracker.instance.current,
        'queued_at': DateTime.now().toUtc().toIso8601String(),
      });
      unawaited(flush());
    } catch (e) {
      _log('bookTapped failed (ignored): $e');
    }
  }

  /// Sends whatever is queued. Safe to call on app start and after login.
  ///
  /// A signed-out user's events wait: the endpoint needs a token to know whose
  /// history they are.
  ///
  /// Retries are for failures that a retry can fix. A 4xx is the server saying
  /// the batch itself is wrong, and re-sending it will fail identically every
  /// time — so it is DROPPED. Kept, it would sit at the head of the queue and
  /// block every later event behind it, because `ValidationPipe` rejects the
  /// whole request if any one element is invalid. Losing an abandoned booking
  /// is a rounding error; losing all of them for a week is not.
  Future<void> flush() async {
    if (_flushing) return;
    _flushing = true;
    List<Map<String, dynamic>> batch = const [];
    try {
      final pending = _readQueue();
      if (pending.isEmpty) return;
      if (_storage.tokens() == null) return;

      batch = pending.take(_maxBatch).toList();
      await _api.report(batch.map(_toPayload).toList());
      _drop(batch);
      _log('flushed ${batch.length}');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // 401 is the exception among 4xx: the token expired mid-flush, which the
      // next sign-in fixes. That one is worth keeping.
      if (status != null && status >= 400 && status < 500 && status != 401) {
        _drop(batch);
        _log('flush rejected ($status), dropped ${batch.length}');
      } else {
        _log('flush failed (kept for retry): $e');
      }
    } catch (e) {
      _log('flush failed (kept for retry): $e');
    } finally {
      _flushing = false;
    }
  }

  /// Removes exactly what was sent. Anything queued while the request was in
  /// flight stays for the next flush.
  void _drop(List<Map<String, dynamic>> batch) {
    if (batch.isEmpty) return;
    final sent = batch.map((e) => e['queued_at']).toSet();
    _writeQueue(
      _readQueue().where((e) => !sent.contains(e['queued_at'])).toList(),
    );
  }

  /// Turns a queued event into what the endpoint takes.
  ///
  /// The age goes over as MINUTES AGO rather than as a timestamp: the queue can
  /// sit for days, so the event has to carry its age — but a phone's clock is
  /// its owner's to set, and an absolute time could place the event in the
  /// future. An offset the server clamps cannot.
  Map<String, dynamic> _toPayload(Map<String, dynamic> event) {
    final queuedAt = DateTime.tryParse('${event['queued_at']}');
    final minutesAgo = queuedAt == null
        ? 0
        : DateTime.now().toUtc().difference(queuedAt).inMinutes;
    return {
      'kind': event['kind'],
      'activity_id': event['activity_id'],
      if (event['source'] != null) 'source': event['source'],
      if (minutesAgo > 0) 'minutes_ago': minutesAgo,
    };
  }

  void _enqueue(Map<String, dynamic> event) {
    final queue = _readQueue()..add(event);
    // Keep the newest if it ever runs away — an old abandoned sheet is the
    // least interesting row in the report.
    _writeQueue(
      queue.length > _maxBatch * 4
          ? queue.sublist(queue.length - _maxBatch * 4)
          : queue,
    );
  }

  List<Map<String, dynamic>> _readQueue() {
    final raw = _storage.pendingInterestEvents();
    if (raw == null) return [];
    final cutoff = DateTime.now().toUtc().subtract(_maxAge);
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .where((e) {
          final queuedAt = DateTime.tryParse('${e['queued_at']}');
          return queuedAt == null || queuedAt.isAfter(cutoff);
        })
        .toList();
  }

  void _writeQueue(List<Map<String, dynamic>> events) {
    unawaited(_storage.pendingInterestEvents.set(events));
  }
}
