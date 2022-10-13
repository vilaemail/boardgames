// TODO: Consider if we want to avoid using this class
// ignore_for_file: discarded_futures
class FutureValue<T> {
  T? _result;
  Object? _error;
  bool _isCompleted = false;
  bool _hadError = false;
  final Future<T> _future;
  bool get isCompleted => _isCompleted;
  bool get hadError => _hadError;
  Future<T> get future => _future;
  
  FutureValue(this._future) {
    _future.then(complete).catchError(completeError);
  }

  void complete(final T value) {
    _isCompleted = true;
    _result = value;
  }

  void completeError(final Object error, [final StackTrace? stackTrace]) {
    _isCompleted = true;
    _hadError = true;
    _error = error;
  }

  T get result {
    if(!isCompleted) {
      throw Exception('Not completed');
    }
    if(_result == null) {
      throw Exception('Result unassigned');
    }
    return _result as T;
  }

  Object get error {
    if(!isCompleted) {
      throw Exception('Not completed');
    }
    final result = _error;
    if(result == null) {
      throw Exception('Error unassigned');
    }
    return result;
  }
}
