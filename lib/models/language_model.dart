class LanguageModel {
  final String code;
  final String name;
  final String nativeName;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'nativeName': nativeName,
      };

  factory LanguageModel.fromJson(Map<String, dynamic> json) => LanguageModel(
        code: json['code'] as String,
        name: json['name'] as String,
        nativeName: json['nativeName'] as String,
      );
}
