class PigeonUserInfo {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final bool isAnonymous;
  final bool isEmailVerified;

  PigeonUserInfo({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.phoneNumber,
    required this.photoUrl,
    required this.isAnonymous,
    required this.isEmailVerified,
  });
}

class PigeonUserDetails {
  final PigeonUserInfo userInfo;
  final List<Map<Object?, Object?>?> providerData;

  PigeonUserDetails({
    required this.userInfo,
    required this.providerData,
  });
}