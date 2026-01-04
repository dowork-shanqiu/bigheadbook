import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart' as pkg_ffi;

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
    final notePtr = (note ?? '')
        .toNativeUtf8(allocator: pkg_ffi.malloc);
    final result = _addTransaction(amount, currencyPtr, notePtr);
    pkg_ffi.malloc.free(currencyPtr);
    pkg_ffi.malloc.free(notePtr);
    return result;
  }

  CrossCoreSummary querySummary() {
    final summary = pkg_ffi.malloc<SummaryStruct>();
    final code = _querySummary(summary);
    try {
      if (code != 0) {
        throw StateError('querySummary failed with code $code');
      }
      return CrossCoreSummary(
        balance: summary.ref.balance,
        totalCount: summary.ref.totalCount,
      );
    } finally {
      ffi.malloc.free(summary);
    }
  }

  static ffi.DynamicLibrary _openDefaultLibrary() {
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
}

class CrossCoreSummary {
  const CrossCoreSummary({required this.balance, required this.totalCount});

  final double balance;
  final int totalCount;
}

final class SummaryStruct extends ffi.Struct {
  @ffi.Double()
  external double balance;

  @ffi.Int32()
  external int totalCount;
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
  ffi.Pointer<SummaryStruct> summary,
);
typedef _QuerySummaryDart = int Function(ffi.Pointer<SummaryStruct> summary);
