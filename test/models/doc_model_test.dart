import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:booknoter/models/doc_model.dart';

void main() {
  group('Doc Model Tests', () {
    test('should create a Doc instance from constructor', () {
      // Arrange
      final doc = Doc(
        key: '/works/OL123456W',
        title: 'Test Book',
        authorName: ['Author One', 'Author Two'],
        coverId: 12345,
        firstPublishYear: 2020,
      );

      // Assert
      expect(doc.key, '/works/OL123456W');
      expect(doc.title, 'Test Book');
      expect(doc.authorName, ['Author One', 'Author Two']);
      expect(doc.coverId, 12345);
      expect(doc.firstPublishYear, 2020);
      expect(doc.coverImage, null);
    });

    test('should create a Doc instance from JSON', () {
      // Arrange
      final json = {
        'key': '/works/OL123456W',
        'title': 'Test Book',
        'author_name': ['Author One', 'Author Two'],
        'cover_i': 12345,
        'first_publish_year': 2020,
      };

      // Act
      final doc = Doc.fromJson(json);

      // Assert
      expect(doc.key, '/works/OL123456W');
      expect(doc.title, 'Test Book');
      expect(doc.authorName, ['Author One', 'Author Two']);
      expect(doc.coverId, 12345);
      expect(doc.firstPublishYear, 2020);
      expect(doc.coverImage, null);
    });

    test('should handle empty values in JSON', () {
      // Arrange
      final json = {
        'key': '/works/OL123456W',
      };

      // Act
      final doc = Doc.fromJson(json);

      // Assert
      expect(doc.key, '/works/OL123456W');
      expect(doc.title, null);
      expect(doc.authorName, null);
      expect(doc.coverId, null);
      expect(doc.firstPublishYear, null);
      expect(doc.coverImage, null);
    });

    test('should store and retrieve cover image', () {
      // Arrange
      final doc = Doc(
        key: '/works/OL123456W',
      );
      final Uint8List imageData = Uint8List.fromList([1, 2, 3, 4, 5]);

      // Act
      doc.coverImage = imageData;

      // Assert
      expect(doc.coverImage, imageData);
    });
  });
}
