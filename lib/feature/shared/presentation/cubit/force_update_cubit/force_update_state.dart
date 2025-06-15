sealed class ForceUpdateState {
  const ForceUpdateState();
}

class ForceUpdateInitialState extends ForceUpdateState {
  const ForceUpdateInitialState();
}

class ForceUpdateLoadingState extends ForceUpdateState {
  const ForceUpdateLoadingState();
}

class ForceUpdateLoadedState extends ForceUpdateState {
  const ForceUpdateLoadedState();
}
