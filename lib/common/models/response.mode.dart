/*

import 'dart:convert';

ResponseModel? responseModelFromJson(String str) =>
    ResponseModel?.fromJson(json.decode(str));

String responseModelToJson(ResponseModel data) => json.encode(data.toJson());

class ResponseModel {
  String? status;
  String? message;

  ResponseModel({
    this.status,
    this.message,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) => ResponseModel(
    status: json["status"] as String?,
    message: json["message"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };
}

 */

import 'dart:convert';

ResponseModel  responseModelFromJson(String str) =>
    ResponseModel .fromJson(json.decode(str));

String responseModelToJson(ResponseModel data) => json.encode(data.toJson());

class ResponseModel {
  String? status;
  String? message;
  String? data; // Added the 'data' field

  ResponseModel({
    this.status,
    this.message,
    this.data, // Initialize the 'data' field
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) => ResponseModel(
    status: json["status"] as String?,
    message: json["message"].toString(),
    data: json["data"] ??'', // Parse the 'data' field
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data??'', // Include 'data' in the JSON output
  };
}

