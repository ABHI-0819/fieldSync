import 'dart:convert';

// --- Top Level Functions ---

ProfileResponseModel profileResponseModelFromJson(String str) => ProfileResponseModel.fromJson(json.decode(str));

String profileResponseModelToJson(ProfileResponseModel data) => json.encode(data.toJson());

// --- Response Model ---

class ProfileResponseModel {
  final String status;
  final String message;
  final Profile data;

  ProfileResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) => ProfileResponseModel(
    status: json["status"],
    message: json["message"],
    data: Profile.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

// --- Profile Data Model ---

class Profile {
  final String id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String? dateOfBirth;
  final String gender;
  final String? profilePicture;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String? panNumber;
  final String? aadharNumber;
  final String bankAccountNumber;
  final String bankName;
  final String ifscCode;
  final bool isProfileComplete;
  final int profileCompletionPercentage;
  final String fullName;
  final String fullAddress;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.email,
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
    email: json['email'],
    dateOfBirth: json["date_of_birth"],
    gender: json["gender"],
    profilePicture: json["profile_picture"],
    addressLine1: json["address_line_1"],
    addressLine2: json["address_line_2"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    postalCode: json["postal_code"],
    panNumber: json["pan_number"],
    aadharNumber: json["aadhar_number"],
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
    "email":email,
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