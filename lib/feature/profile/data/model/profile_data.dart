import 'package:founders_academy/feature/profile/data/model/address/address_data.dart';
import 'package:founders_academy/feature/profile/data/model/education/education_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_data.g.dart';

@JsonSerializable()
class ProfileData {
  @JsonKey(name: 'user')
  final String? userId;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(name: 'address')
  final AddressData? address;
  @JsonKey(name: 'education')
  EducationData? education;
  @JsonKey(name: 'image')
  String? image;
  @JsonKey(name: 'points')
  int? points;

  ProfileData({
    this.userId,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.address,
    this.education,
    this.image,
    this.points,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) =>
      _$ProfileDataFromJson(json["data"] ?? json);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    if (firstName != null) data.addAll({'first_name': firstName});
    if (lastName != null) data.addAll({'last_name': lastName});
    if (education != null) data.addAll({'education': education?.toJson()});
    if (address != null) data.addAll({'address': address?.toJson()});
    if (image != null) data.addAll({'image': image});

    return data;
  }

  set imageUrl(String url) {
    image = url;
  }

  bool get isEmpty =>
      firstName == null &&
      lastName == null &&
      phoneNumber == null &&
      address == null &&
      education == null &&
      image == null;
}
