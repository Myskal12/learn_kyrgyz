class WordModel {
final String id;
final String english;
final String kyrgyz;
final String transcription;
final String example;


WordModel({required this.id, required this.english, required this.kyrgyz, this.transcription = '', this.example = ''});


factory WordModel.fromJson(Map<String, dynamic> json) => WordModel(
id: json['id'] as String,
english: json['english'] as String,
kyrgyz: json['kyrgyz'] as String,
transcription: json['transcription'] as String? ?? '',
example: json['example'] as String? ?? '',
);


Map<String, dynamic> toJson() => {
'id': id,
'english': english,
'kyrgyz': kyrgyz,
'transcription': transcription,
'example': example,
};
}