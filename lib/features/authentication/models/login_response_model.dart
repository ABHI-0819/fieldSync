import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) => LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) => json.encode(data.toJson());

class LoginResponseModel {
  String status;
  String message;
  Data data;

  LoginResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) => LoginResponseModel(
    status: json["status"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  User user;
  Tokens tokens;

  Data({
    required this.user,
    required this.tokens,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    user: User.fromJson(json["user"]),
    tokens: Tokens.fromJson(json["tokens"]),
  );

  Map<String, dynamic> toJson() => {
    "user": user.toJson(),
    "tokens": tokens.toJson(),
  };
}

class Tokens {
  String access;
  String refresh;

  Tokens({
    required this.access,
    required this.refresh,
  });

  factory Tokens.fromJson(Map<String, dynamic> json) => Tokens(
    access: json["access"],
    refresh: json["refresh"],
  );

  Map<String, dynamic> toJson() => {
    "access": access,
    "refresh": refresh,
  };
}

class User {
  String id;
  String uid;
  String email;
  String? phoneNumber; // Changed from phone to phoneNumber to match JSON key
  String role;
  String? organization;
  String? organizationName;
  bool isActive;
  bool isVerified; // Changed from a few other bools to match JSON keys
  DateTime createdAt;
  DateTime updatedAt;
  Profile? profile;

  User({
    required this.id,
    required this.uid,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.organization,
    this.organizationName,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    uid: json["uid"],
    email: json["email"],
    phoneNumber: json["phone_number"], // Corrected key name
    role: json["role"],
    organization: json["organization"],
    organizationName: json["organization_name"],
    isActive: json["is_active"],
    isVerified: json["is_verified"], // Corrected key name
    createdAt: DateTime.parse(json["created_at"]), // JSON field is a date string
    updatedAt: DateTime.parse(json["updated_at"]),
    profile: json["profile"] != null ? Profile.fromJson(json["profile"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "uid": uid,
    "email": email,
    "phone_number": phoneNumber,
    "role": role,
    "organization": organization,
    "organization_name": organizationName,
    "is_active": isActive,
    "is_verified": isVerified,
    "created_at": "${createdAt.year.toString().padLeft(4, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}", // Format to match original JSON structure if necessary, though ISO is common
    "updated_at": updatedAt.toIso8601String(),
    "profile": profile?.toJson(),
  };
}

class Profile {
  String id;
  String firstName;
  String middleName;
  String lastName;
  String? dateOfBirth;
  String gender;
  String? profilePicture;
  String addressLine1;
  String addressLine2;
  String city;
  String state;
  String country;
  String postalCode;
  String? panNumber;
  String? aadharNumber;
  String bankAccountNumber;
  String bankName;
  String ifscCode;
  bool isProfileComplete;
  int profileCompletionPercentage;
  String fullName;
  String fullAddress;
  DateTime createdAt;
  DateTime updatedAt;

  Profile({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    this.dateOfBirth,
    required this.gender,
    this.profilePicture,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.panNumber,
    this.aadharNumber,
    required this.bankAccountNumber,
    required this.bankName,
    required this.ifscCode,
    required this.isProfileComplete,
    required this.profileCompletionPercentage,
    required this.fullName,
    required this.fullAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json["id"],
    firstName: json["first_name"],
    middleName: json["middle_name"],
    lastName: json["last_name"],
    dateOfBirth: json["date_of_birth"], // Can be null
    gender: json["gender"],
    profilePicture: json["profile_picture"], // Can be null
    addressLine1: json["address_line_1"],
    addressLine2: json["address_line_2"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    postalCode: json["postal_code"],
    panNumber: json["pan_number"], // Can be null
    aadharNumber: json["aadhar_number"], // Can be null
    bankAccountNumber: json["bank_account_number"],
    bankName: json["bank_name"],
    ifscCode: json["ifsc_code"],
    isProfileComplete: json["is_profile_complete"],
    profileCompletionPercentage: json["profile_completion_percentage"],
    fullName: json["full_name"],
    fullAddress: json["full_address"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "middle_name": middleName,
    "last_name": lastName,
    "date_of_birth": dateOfBirth,
    "gender": gender,
    "profile_picture": profilePicture,
    "address_line_1": addressLine1,
    "address_line_2": addressLine2,
    "city": city,
    "state": state,
    "country": country,
    "postal_code": postalCode,
    "pan_number": panNumber,
    "aadhar_number": aadharNumber,
    "bank_account_number": bankAccountNumber,
    "bank_name": bankName,
    "ifsc_code": ifscCode,
    "is_profile_complete": isProfileComplete,
    "profile_completion_percentage": profileCompletionPercentage,
    "full_name": fullName,
    "full_address": fullAddress,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}