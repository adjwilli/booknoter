class Work {
  final String title;
  final String? firstPublishDate;
  final String key;
  final String? description;

  Work({
    required this.title,
    this.firstPublishDate,
    required this.key,
    this.description,
  });

  factory Work.fromJson(Map<String, dynamic> json) {
    String? descriptionText;

    if (json['description'] != null) {
      if (json['description'] is String) {
        descriptionText = json['description'] as String;
      } else if (json['description'] is Map) {
        // Handle case where description is an object with 'value' field
        descriptionText = json['description']['value'] as String?;
      }
    }

    return Work(
      title: json['title'] ?? 'Unknown Title',
      firstPublishDate: json['first_publish_date'],
      key: json['key'] ?? '',
      description: descriptionText,
    );
  }

  @override
  String toString() {
    return 'Work(title: $title, firstPublishDate: $firstPublishDate, key: $key)';
  }
}
