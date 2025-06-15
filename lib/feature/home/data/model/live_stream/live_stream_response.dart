import 'package:founders_academy/feature/home/data/model/live_stream/live_stream_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'live_stream_response.g.dart';

@JsonSerializable()
class LiveStreamResponse {
  @JsonKey(name: 'data')
  final LiveStreamData? liveStream;

  const LiveStreamResponse({this.liveStream});

  factory LiveStreamResponse.fromJson(Map<String, dynamic> json) =>
      _$LiveStreamResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LiveStreamResponseToJson(this);
}
