// Web stub — replaces dart:io types so the RTI system can resolve them on web
// without crashing. None of these methods should be called on web.

class File {
  final String path;
  const File(this.path);
  Future<List<int>> readAsBytes() async => [];
}
