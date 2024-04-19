import 'package:codey/models/entities/app_user.dart';

class EndOfLessonResponse{
  final AppUser appUser;
  final int awardedXP;

  EndOfLessonResponse({
    required this.appUser,
    required this.awardedXP,
  });

  factory EndOfLessonResponse.fromJson(Map<String, dynamic> json){
    return EndOfLessonResponse(
      appUser: AppUser.fromJson(json['user']),
      awardedXP: json['awardedXP'],
    );
  }
}