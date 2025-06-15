sealed class AppInitState {
  const AppInitState();
}

class AuthorizedState extends AppInitState {
  const AuthorizedState();
}

class UnauthorizedState extends AppInitState {
  const UnauthorizedState();
}

class AppInitLoadingState extends AppInitState {
  const AppInitLoadingState();
}

class NeedForceUpdateState extends AppInitState {
  const NeedForceUpdateState();
}
