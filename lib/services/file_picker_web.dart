import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

/// A file the visitor chose.
typedef PickedFile = ({String name, Uint8List bytes});

@JS('document')
external _Document get _document;

extension type _Document._(JSObject _) implements JSObject {
  external _Input createElement(String tag);
}

extension type _Input._(JSObject _) implements JSObject {
  external set type(String value);
  external set accept(String value);
  external _FileList? get files;
  external void click();
  external void addEventListener(String type, JSFunction listener);
}

extension type _FileList._(JSObject _) implements JSObject {
  external int get length;
  external _File? item(int index);
}

extension type _File._(JSObject _) implements JSObject {
  external String get name;
  external JSPromise<JSArrayBuffer> arrayBuffer();
}

/// Opens the browser's file dialog for one file with one of [extensions]
/// (without the dot). Completes with null if the visitor cancels.
Future<PickedFile?> pickFile({required List<String> extensions}) {
  final completer = Completer<PickedFile?>();
  final input = _document.createElement('input')
    ..type = 'file'
    ..accept = extensions.map((e) => '.$e').join(',');
  input.addEventListener(
    'change',
    ((JSAny _) {
      final file = input.files?.item(0);
      if (file == null) {
        if (!completer.isCompleted) completer.complete(null);
        return;
      }
      file.arrayBuffer().toDart.then(
        (buffer) {
          if (!completer.isCompleted) completer.complete((name: file.name, bytes: buffer.toDart.asUint8List()));
        },
        onError: (Object _) {
          if (!completer.isCompleted) completer.complete(null);
        },
      );
    }).toJS,
  );
  input.addEventListener(
    'cancel',
    ((JSAny _) {
      if (!completer.isCompleted) completer.complete(null);
    }).toJS,
  );
  input.click();
  return completer.future;
}
