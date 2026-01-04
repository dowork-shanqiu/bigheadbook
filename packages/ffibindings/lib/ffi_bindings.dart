import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart' as pkg_ffi;

final class CrossCoreSummary extends ffi.Struct {
  @ffi.Double()
  external double balance;

  @ffi.Int32()
  external int totalCount;
}

class CrossCoreSummaryData {
  const CrossCoreSummaryData({required this.balance, required this.totalCount});

  final double balance;
  final int totalCount;
}

/// Lightweight dart:ffi wrapper for the cross-platform core.
class CrossCoreBindings {
  CrossCoreBindings({ffi.DynamicLibrary? library})
      : _lib = library ?? _openDefaultLibrary() {
    _init = _lib.lookupFunction<_InitNative, _InitDart>('crosscore_init');
    _addTransaction = _lib.lookupFunction<_AddTxNative, _AddTxDart>(
      'crosscore_add_transaction',
    );
    _querySummary =
        _lib.lookupFunction<_QuerySummaryNative, _QuerySummaryDart>(
      'crosscore_query_summary',
    );
  }

  final ffi.DynamicLibrary _lib;
  late final _InitDart _init;
  late final _AddTxDart _addTransaction;
  late final _QuerySummaryDart _querySummary;

  int init() => _init();

  int addTransaction({
    required double amount,
    required String currency,
    String? note,
  }) {
    final currencyPtr =
        currency.toNativeUtf8(allocator: pkg_ffi.malloc);
    final notePtr = note == null
        ? ffi.Pointer<ffi.Utf8>.fromAddress(0)
        : note.toNativeUtf8(allocator: pkg_ffi.malloc);
    try {
      return _addTransaction(amount, currencyPtr, notePtr);
    } finally {
      pkg_ffi.malloc.free(currencyPtr);
      if (notePtr.address != 0) {
        pkg_ffi.malloc.free(notePtr);
      }
    }
  }

  CrossCoreSummaryData querySummary() {
    final summary = pkg_ffi.malloc<CrossCoreSummary>();
    final code = _querySummary(summary);
    try {
      if (code != 0) {
        throw StateError('querySummary failed with code $code');
      }
      return CrossCoreSummaryData(
        balance: summary.ref.balance,
        totalCount: summary.ref.totalCount,
      );
    } finally {
      pkg_ffi.malloc.free(summary);
    }
  }

  static ffi.DynamicLibrary _openDefaultLibrary() {
    final envPath = Platform.environment['CROSS_CORE_LIB_PATH'];
    if (envPath != null && envPath.isNotEmpty) {
      return ffi.DynamicLibrary.open(envPath);
    }
    if (Platform.isMacOS || Platform.isIOS) {
      return ffi.DynamicLibrary.open('libcross_core.dylib');
    }
    if (Platform.isAndroid || Platform.isLinux) {
      return ffi.DynamicLibrary.open('libcross_core.so');
    }
    if (Platform.isWindows) {
      return ffi.DynamicLibrary.open('cross_core.dll');
    }
    throw UnsupportedError('Unsupported platform ${Platform.operatingSystem}');
  }

typedef _InitNative = ffi.Int32 Function();
typedef _InitDart = int Function();

typedef _AddTxNative = ffi.Int32 Function(
  ffi.Double amount,
  ffi.Pointer<ffi.Utf8> currency,
  ffi.Pointer<ffi.Utf8> note,
);
typedef _AddTxDart = int Function(
  double amount,
  ffi.Pointer<ffi.Utf8> currency,
  ffi.Pointer<ffi.Utf8> note,
);

typedef _QuerySummaryNative = ffi.Int32 Function(
  ffi.Pointer<CrossCoreSummary> summary,
);
typedef _QuerySummaryDart = int Function(
  ffi.Pointer<CrossCoreSummary> summary,
);
