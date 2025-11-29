/// Models for user accounts and identity
import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

/// User profile model
@JsonSerializable()
class UserProfile {
  final String id;
  final String? email;
  final String? stripeCustomerId;

  const UserProfile({required this.id, this.email, this.stripeCustomerId});

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
