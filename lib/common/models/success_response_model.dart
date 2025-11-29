import 'dart:convert';

SuccessResponseModel successResponseModelFromJson(String str) =>
    SuccessResponseModel.fromJson(json.decode(str));

String successResponseModelToJson(SuccessResponseModel data) =>
    json.encode(data.toJson());

class SuccessResponseModel {
  String status;
  String message;

  SuccessResponseModel({
    this.status = '',
    this.message = '',
  });

  factory SuccessResponseModel.fromJson(Map<String, dynamic> json) {
    String parseString(dynamic value) {
      try {
        if (value == null) return '';
        return value.toString();
      } catch (_) {
        return '';
      }
    }

    return SuccessResponseModel(
      status: parseString(json['status']),
      message: parseString(json['message']),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };
}
