import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_model.freezed.dart';

part 'route_model.g.dart';

@freezed
class RouteResponse with _$RouteResponse {
  const factory RouteResponse({
    List<List<double>>? route,
    @JsonKey(name: 'toll_segments') List<List<List<double>>>? tollSegments,
  }) = _RouteResponse;

  factory RouteResponse.fromJson(Map<String, dynamic> json) =>
      _$RouteResponseFromJson(json);
}
