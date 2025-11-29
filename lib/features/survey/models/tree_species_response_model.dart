/*
{
  "status": "success",
  "message": "Data Fetched successfully",
  "data": [
    {
      "id": "0b2400e5-16c7-439c-ab71-fee7072efde7",
      "tid": "TMAN430813",
      "scientific_name": "Magnifera Indica",
      "common_name": "Mango",
      "local_name": "Mango",
      "marathi_name": "अंबा",
      "family": "Magnifera",
      "genus": "Indica",
      "species_code": "MI-1104",
      "thumbnail": {
        "url": "/media/tree-species/bcfa8f31-37e0-4888-b506-6bd8613b3743.jpg"
      },
      "growth_rate": "moderate",
      "conservation_status": "LC",
      "is_native": true,
      "is_active": true
    }
  ]
}
*/

import 'dart:convert';

// Helper functions for easy conversion
TreeSpeciesResponseModel treeSpeciesResponseModelFromJson(String str) =>
    TreeSpeciesResponseModel.fromJson(json.decode(str));

String treeSpeciesResponseModelToJson(TreeSpeciesResponseModel data) =>
    json.encode(data.toJson());

// Main Model for the entire API response
class TreeSpeciesResponseModel {
  String status;
  String message;
  List<TreeSpeciesData> data;

  TreeSpeciesResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TreeSpeciesResponseModel.fromJson(Map<String, dynamic> json) =>
      TreeSpeciesResponseModel(
        status: json["status"],
        message: json["message"],
        // The 'data' field is a list, so we map each item to a TreeSpeciesData object
        data: List<TreeSpeciesData>.from(
            json["data"].map((x) => TreeSpeciesData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

// Model for a single tree species item inside the 'data' array
class TreeSpeciesData {
  String id;
  String tid;
  String scientificName;
  String commonName;
  String localName;
  String marathiName;
  String family;
  String genus;
  String speciesCode;
  Thumbnail thumbnail;
  String growthRate;
  String conservationStatus;
  bool isNative;
  bool isActive;

  TreeSpeciesData({
    required this.id,
    required this.tid,
    required this.scientificName,
    required this.commonName,
    required this.localName,
    required this.marathiName,
    required this.family,
    required this.genus,
    required this.speciesCode,
    required this.thumbnail,
    required this.growthRate,
    required this.conservationStatus,
    required this.isNative,
    required this.isActive,
  });

  factory TreeSpeciesData.fromJson(Map<String, dynamic> json) => TreeSpeciesData(
    id: json["id"],
    tid: json["tid"],
    scientificName: json["scientific_name"],
    commonName: json["common_name"],
    localName: json["local_name"],
    marathiName: json["marathi_name"],
    family: json["family"],
    genus: json["genus"],
    speciesCode: json["species_code"],
    thumbnail: Thumbnail.fromJson(json["thumbnail"]),
    growthRate: json["growth_rate"],
    conservationStatus: json["conservation_status"],
    isNative: json["is_native"],
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "tid": tid,
    "scientific_name": scientificName,
    "common_name": commonName,
    "local_name": localName,
    "marathi_name": marathiName,
    "family": family,
    "genus": genus,
    "species_code": speciesCode,
    "thumbnail": thumbnail.toJson(),
    "growth_rate": growthRate,
    "conservation_status": conservationStatus,
    "is_native": isNative,
    "is_active": isActive,
  };
}

// Model for the nested 'thumbnail' object
class Thumbnail {
  String url;

  Thumbnail({
    required this.url,
  });

  factory Thumbnail.fromJson(Map<String, dynamic> json) => Thumbnail(
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
  };
}