/// FileFacade — compile‑ready (no SDK logic)
library;

abstract class FileFacade {
  const FileFacade();

  Future<bool> exists(final String path) async => false;
  Future<String?> readAsString(final String path) async => null;
}
