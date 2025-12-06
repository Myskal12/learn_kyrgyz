class CategoryModel {
final String id;
final String title;
final String description;
final String imageUrl;
final int wordsCount;


CategoryModel({required this.id, required this.title, this.description = '', this.imageUrl = '', this.wordsCount = 0});


factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
id: json['id'] as String,
title: json['title'] as String,
description: json['description'] as String? ?? '',
imageUrl: json['imageUrl'] as String? ?? '',
wordsCount: json['wordsCount'] as int? ?? 0,
);


Map<String, dynamic> toJson() => {
'id': id,
'title': title,
'description': description,
'imageUrl': imageUrl,
'wordsCount': wordsCount,
};
}