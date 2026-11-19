import 'dart:js_interop';

@JS('window.history.back')
external void _historyBack();

/// Whether [browserHistoryBack] can step the browser's history.
const bool browserHistoryAvailable = true;

void browserHistoryBack() => _historyBack();
