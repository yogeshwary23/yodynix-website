// Picks a local file through the browser's file dialog. Off the web (tests,
// tooling) there is no dialog and nothing is picked.
export 'file_picker_stub.dart' if (dart.library.js_interop) 'file_picker_web.dart';
