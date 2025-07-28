import 'package:flutter_test/flutter_test.dart';
import 'package:booknoter/models/search_result_model.dart';
import 'package:booknoter/models/doc_model.dart';

void main() {
  group('SearchResult Model Tests', () {
    test('should create a SearchResult instance from constructor', () {
      // Arrange
      final docs = [
        Doc(key: '/works/OL1W', title: 'Book 1'),
        Doc(key: '/works/OL2W', title: 'Book 2'),
      ];

      final searchResult = SearchResult(
        numFound: 2,
        start: 0,
        numFoundExact: true,
        docs: docs,
        numFoundField: 0,
        q: '',
      );

      // Assert
      expect(searchResult.numFound, 2);
      expect(searchResult.start, 0);
      expect(searchResult.numFoundExact, true);
      expect(searchResult.docs.length, 2);
      expect(searchResult.docs[0].title, 'Book 1');
      expect(searchResult.docs[1].title, 'Book 2');
    });

    test('should create a SearchResult instance from JSON', () {
      // Arrange
      final json = {
        'numFound': 2,
        'start': 0,
        'numFoundExact': true,
        'docs': [
          {
            'key': '/works/OL1W',
            'title': 'Book 1',
            'author_name': ['Author 1'],
          },
          {
            'key': '/works/OL2W',
            'title': 'Book 2',
            'author_name': ['Author 2'],
          },
        ],
      };

      // Act
      final searchResult = SearchResult.fromJson(json);

      // Assert
      expect(searchResult.numFound, 2);
      expect(searchResult.start, 0);
      expect(searchResult.numFoundExact, true);
      expect(searchResult.docs.length, 2);
      expect(searchResult.docs[0].key, '/works/OL1W');
      expect(searchResult.docs[0].title, 'Book 1');
      expect(searchResult.docs[1].key, '/works/OL2W');
      expect(searchResult.docs[1].title, 'Book 2');
    });

    test('should handle empty docs array in JSON', () {
      // Arrange
      final json = {
        'numFound': 0,
        'start': 0,
        'numFoundExact': true,
        'docs': [],
      };

      // Act
      final searchResult = SearchResult.fromJson(json);

      // Assert
      expect(searchResult.numFound, 0);
      expect(searchResult.start, 0);
      expect(searchResult.numFoundExact, true);
      expect(searchResult.docs.length, 0);
    });

    test('should handle missing fields in JSON', () {
      // Arrange
      final json = {
        'docs': [
          {
            'key': '/works/OL1W',
            'title': 'Book 1',
          },
        ],
      };

      // Act
      final searchResult = SearchResult.fromJson(json);

      // Assert
      expect(searchResult.numFound, 0);
      expect(searchResult.start, 0);
      expect(searchResult.numFoundExact, false);
      expect(searchResult.docs.length, 1);
      expect(searchResult.docs[0].key, '/works/OL1W');
    });
  });
}
