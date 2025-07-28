import 'package:flutter_test/flutter_test.dart';
import 'package:booknoter/models/note_model.dart';

void main() {
  group('Note Model Tests', () {
    test('should create a Note instance from constructor', () {
      // Arrange
      final now = DateTime.now();
      final note = Note(
        workKey: '/works/OL123456W',
        content: 'This is a test note',
        createdAt: now,
      );

      // Assert
      expect(note.workKey, '/works/OL123456W');
      expect(note.content, 'This is a test note');
      expect(note.createdAt, now);
    });
  });
}
