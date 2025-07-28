import 'package:flutter_test/flutter_test.dart';
import 'package:booknoter/models/work_model.dart';

void main() {
  group('Work Model Tests', () {
    test('should create a Work instance from constructor', () {
      // Arrange
      final work = Work(
        title: 'Test Work',
        key: '/works/OL123456W',
        firstPublishDate: '2020-01-01',
        description: 'This is a test work description',
      );

      // Assert
      expect(work.title, 'Test Work');
      expect(work.key, '/works/OL123456W');
      expect(work.firstPublishDate, '2020-01-01');
      expect(work.description, 'This is a test work description');
    });

    test('should create a Work instance from JSON with string description', () {
      // Arrange
      final json = {
        'title': 'Test Work',
        'key': '/works/OL123456W',
        'first_publish_date': '2020-01-01',
        'description': 'This is a test work description',
      };

      // Act
      final work = Work.fromJson(json);

      // Assert
      expect(work.title, 'Test Work');
      expect(work.key, '/works/OL123456W');
      expect(work.firstPublishDate, '2020-01-01');
      expect(work.description, 'This is a test work description');
    });

    test('should create a Work instance from JSON with object description', () {
      // Arrange
      final json = {
        'title': 'Test Work',
        'key': '/works/OL123456W',
        'first_publish_date': '2020-01-01',
        'description': {
          'value': 'This is a test work description in an object',
          'type': '/type/text'
        },
      };

      // Act
      final work = Work.fromJson(json);

      // Assert
      expect(work.title, 'Test Work');
      expect(work.key, '/works/OL123456W');
      expect(work.firstPublishDate, '2020-01-01');
      expect(work.description, 'This is a test work description in an object');
    });

    test('should handle empty values in JSON', () {
      // Arrange
      final json = {
        'key': '/works/OL123456W',
      };

      // Act
      final work = Work.fromJson(json);

      // Assert
      expect(work.title, 'Unknown Title');
      expect(work.key, '/works/OL123456W');
      expect(work.firstPublishDate, null);
      expect(work.description, null);
    });
  });
}
