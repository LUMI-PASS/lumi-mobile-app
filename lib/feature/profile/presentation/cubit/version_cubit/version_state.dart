part of 'version_cubit.dart';

sealed class VersionState {
  const VersionState();
}

class VersionInitState extends VersionState {
  const VersionInitState();
}

class VersionLoadedState extends VersionState {
  final String version;
  const VersionLoadedState(this.version);
}

class VersionErrorState extends VersionState {
  final ChessException exception;
  const VersionErrorState(this.exception);
}
