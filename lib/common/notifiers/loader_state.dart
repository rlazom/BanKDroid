import 'package:flutter/foundation.dart';

enum LoaderState {
  NORMAL,
  LOADING,
  FAILED,
  SUCCESS,
}

class LoaderViewModel extends ChangeNotifier {
  LoaderState _state = LoaderState.NORMAL;
  bool _disposed = false;

  bool get disposed => _disposed;

  bool get loading => _state == LoaderState.LOADING;

  bool get notLoading => !this.loading;

  bool get success => _state == LoaderState.SUCCESS;

  bool get failed => _state == LoaderState.FAILED;

  bool get normal => _state == LoaderState.NORMAL;

  LoaderState get state => _state;

  @protected
  void updateState(LoaderState state, {bool emitEvent = true}) {
    emitEvent ??= true;

    _state = state;
    if (!this.disposed && emitEvent) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> load(Future<void> Function() loader) async {
    try {
      this.markAsLoading();
      await loader();
      this.markAsSuccess();
    } on Exception catch (error) {
      this.markAsFailed(error: error);
      rethrow;
    }
  }

  void markAsLoading() {
    this.updateState(LoaderState.LOADING);
  }

  void markAsSuccess({dynamic arguments}) {
    this.updateState(LoaderState.SUCCESS);
  }

  void markAsFailed({Exception error}) {
    this.updateState(LoaderState.FAILED);
  }

  void markAsNormal({bool emitEvent = true}) {
    this.updateState(LoaderState.NORMAL, emitEvent: emitEvent);
  }
}
