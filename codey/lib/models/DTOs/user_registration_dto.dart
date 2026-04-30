class UserRegistrationDTO {
  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final String email;
  final String password;
  final String school;
  final int courseId;
  final bool consentedToTerms;

  UserRegistrationDTO({
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    required this.email,
    required this.password,
    required this.school,
    required this.courseId,
    required this.consentedToTerms,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'email': email,
        'password': password,
        'school': school,
        'courseId': courseId,
        'consentedToTerms': consentedToTerms,
      };
}
