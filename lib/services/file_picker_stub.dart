import 'dart:typed_data';

/// A file the visitor chose.
typedef PickedFile = ({String name, Uint8List bytes});

/// No file dialog outside the browser.
Future<PickedFile?> pickFile({required List<String> extensions}) async => null;
