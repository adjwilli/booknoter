import 'dart:typed_data';

class Doc {
  final String key;
  final List<String>? authorName;
  final int? coverId;
  final String? title;
  final int? firstPublishYear;
  Uint8List? coverImage;

  Doc({
    required this.key,
    this.authorName,
    this.coverId,
    this.title,
    this.firstPublishYear,
    this.coverImage,
  });

  factory Doc.fromJson(Map<String, dynamic> json) {
    return Doc(
      key: json['key'] ?? '',
      authorName: json['author_name'] != null
          ? List<String>.from(json['author_name'])
          : null,
      coverId: json['cover_i'],
      title: json['title'],
      firstPublishYear: json['first_publish_year'],
    );
  }

  @override
  String toString() {
    return 'Doc(key: $key, title: $title, authors: $authorName, firstPublishYear: $firstPublishYear)'; // Updated toString
  }
}
