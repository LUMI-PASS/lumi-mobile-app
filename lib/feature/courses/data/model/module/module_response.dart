import 'package:founders_academy/feature/courses/data/model/module/module_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'module_response.g.dart';

@JsonSerializable()
class ModulesResponse {
  @JsonKey(name: 'data')
  final List<ModuleData>? modules;

  const ModulesResponse({
    this.modules,
  });

  factory ModulesResponse.fromJson(Map<String, dynamic> json) =>
      _$ModulesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ModulesResponseToJson(this);
}
