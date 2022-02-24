// To parse this JSON data, do
//
//     final dataModel = dataModelFromJson(jsonString);
import 'dart:convert';

List<DataModel> dataModelFromJson(String str) => List<DataModel>.from(json.decode(str).map((x) => DataModel.fromJson(x)));

String dataModelToJson(List<DataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataModel {
  DataModel({
    required this.id,
    required this.workNote,
  });

  String id;
  String workNote;

  factory DataModel.fromJson(Map<String, dynamic> json) => DataModel(
    id: json["id"],
    workNote: json["workNote"],
  );

  Map<String, dynamic> toJson() => {
    "id": id.toString(),
    "workNote": workNote,
  };
}
