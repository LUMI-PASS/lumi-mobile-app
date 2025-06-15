import 'package:founders_academy/feature/home/data/model/live_stream/live_stream_data.dart';

sealed class LiveStreamItemState {
  const LiveStreamItemState();
}

class LiveStreamItemInitState extends LiveStreamItemState {
  const LiveStreamItemInitState();
}

class LiveStreamItemLoadingState extends LiveStreamItemState {
  const LiveStreamItemLoadingState();
}

class LiveStreamItemLoadedState extends LiveStreamItemState {
  final LiveStreamData liveStreamData;
  const LiveStreamItemLoadedState(this.liveStreamData);
}

class LiveStreamItemErrorState extends LiveStreamItemState {
  const LiveStreamItemErrorState();
}
