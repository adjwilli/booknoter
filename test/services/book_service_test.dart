import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:booknoter/services/book_service.dart';
import 'package:booknoter/models/search_result_model.dart';
import 'package:booknoter/models/work_model.dart';

import 'book_service_test.mocks.dart';

// Generate mock HTTP client
@GenerateMocks([http.Client])
void main() {
  group('BookService Tests', () {
    late BookService bookService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      bookService = BookService(client: mockClient);
    });

    group('searchBooks', () {
      test('should return SearchResult when request is successful', () async {
        // Arrange
        final query = 'harry potter';
        final responseJson = {
          'numFound': 2,
          'start': 0,
          'numFoundExact': true,
          'docs': [
            {
              'key': '/works/OL1W',
              'title': 'Harry Potter 1',
              'author_name': ['J.K. Rowling'],
              'cover_i': 12345,
              'first_publish_year': 1997,
            },
            {
              'key': '/works/OL2W',
              'title': 'Harry Potter 2',
              'author_name': ['J.K. Rowling'],
              'cover_i': 67890,
              'first_publish_year': 1998,
            },
          ],
        };

        when(mockClient.get(any)).thenAnswer(
            (_) async => http.Response(json.encode(responseJson), 200));

        // Act
        final result = await bookService.searchBooks(query);

        // Assert
        expect(result, isA<SearchResult>());
        expect(result!.numFound, 2);
        expect(result.docs.length, 2);
        expect(result.docs[0].title, 'Harry Potter 1');
        expect(result.docs[1].title, 'Harry Potter 2');

        // Verify correct URL was called
        verify(mockClient.get(
          Uri.parse('https://openlibrary.org/search.json').replace(
            queryParameters: {
              'q': query,
              'fields': 'key,title,author_name,cover_i,first_publish_year',
              'limit': '10',
            },
          ),
        )).called(1);
      });

      test('should return null when query is empty', () async {
        // Arrange
        final query = '';

        // Act
        final result = await bookService.searchBooks(query);

        // Assert
        expect(result, isNull);
        verifyNever(mockClient.get(any));
      });

      test('should throw exception when request fails', () async {
        // Arrange
        final query = 'harry potter';
        when(mockClient.get(any))
            .thenAnswer((_) async => http.Response('Server error', 500));

        // Act & Assert
        expect(
          () => bookService.searchBooks(query),
          throwsException,
        );
      });
    });

    group('searchBooksWithOffset', () {
      test('should add pagination parameters to request', () async {
        // Arrange
        final query = 'harry potter';
        final offset = 10;
        final limit = 5;
        final responseJson = {
          'numFound': 15,
          'start': 10,
          'numFoundExact': true,
          'docs': [
            {
              'key': '/works/OL11W',
              'title': 'Harry Potter 11',
            },
          ],
        };

        when(mockClient.get(any)).thenAnswer(
            (_) async => http.Response(json.encode(responseJson), 200));

        // Act
        final result = await bookService.searchBooksWithOffset(
          query,
          offset: offset,
          limit: limit,
        );

        // Assert
        expect(result, isA<SearchResult>());
        expect(result!.start, 10);

        // Verify correct URL was called with pagination
        verify(mockClient.get(
          Uri.parse('https://openlibrary.org/search.json').replace(
            queryParameters: {
              'q': query,
              'fields': 'key,title,author_name,cover_i,first_publish_year',
              'limit': limit.toString(),
              'offset': offset.toString(),
            },
          ),
        )).called(1);
      });
    });

    group('loadCoverImage', () {
      test('should return image data when request is successful', () async {
        // Arrange
        final coverId = 12345;
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        when(mockClient.get(any))
            .thenAnswer((_) async => http.Response.bytes(imageBytes, 200));

        // Act
        final result = await bookService.loadCoverImage(coverId);

        // Assert
        expect(result, imageBytes);

        // Verify correct URL was called
        verify(mockClient.get(
          Uri.parse('https://covers.openlibrary.org/b/id/12345-M.jpg'),
        )).called(1);
      });

      test('should return null when request fails', () async {
        // Arrange
        final coverId = 12345;
        when(mockClient.get(any))
            .thenAnswer((_) async => http.Response('Not found', 404));

        // Act
        final result = await bookService.loadCoverImage(coverId);

        // Assert
        expect(result, isNull);
      });

      test('should use specified size parameter', () async {
        // Arrange
        final coverId = 12345;
        final size = 'L';
        final imageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        when(mockClient.get(any))
            .thenAnswer((_) async => http.Response.bytes(imageBytes, 200));

        // Act
        await bookService.loadCoverImage(coverId, size: size);

        // Verify correct URL with size was called
        verify(mockClient.get(
          Uri.parse('https://covers.openlibrary.org/b/id/12345-L.jpg'),
        )).called(1);
      });
    });

    group('getWorkDetails', () {
      test('should return Work when request is successful', () async {
        // Arrange
        final workKey = '/works/OL1234W';
        final responseJson = {
          'key': '/works/OL1234W',
          'title': 'Test Work',
          'first_publish_date': '2020-01-01',
          'description': 'This is a test work',
        };

        when(mockClient.get(any)).thenAnswer(
            (_) async => http.Response(json.encode(responseJson), 200));

        // Act
        final result = await bookService.getWorkDetails(workKey);

        // Assert
        expect(result, isA<Work>());
        expect(result!.key, '/works/OL1234W');
        expect(result.title, 'Test Work');
        expect(result.firstPublishDate, '2020-01-01');
        expect(result.description, 'This is a test work');

        // Verify correct URL was called
        verify(mockClient.get(
          Uri.parse('https://openlibrary.org/works/OL1234W.json'),
        )).called(1);
      });

      test('should normalize different work key formats', () async {
        // Arrange
        final responseJson = {
          'key': '/works/OL1234W',
          'title': 'Test Work',
        };

        when(mockClient.get(any)).thenAnswer(
            (_) async => http.Response(json.encode(responseJson), 200));

        // Test different key formats
        final formats = [
          'OL1234W', // Plain ID
          '/works/OL1234W', // Standard format
          '/books/OL1234M/works/OL1234W', // Nested in book path
        ];

        for (final format in formats) {
          // Act
          await bookService.getWorkDetails(format);

          // Verify normalized URL was called each time
          verify(mockClient.get(
            Uri.parse('https://openlibrary.org/works/OL1234W.json'),
          )).called(1);
        }
      });

      test('should return null for invalid work key', () async {
        // Arrange
        final invalidKey = 'invalid-key';

        // Act
        final result = await bookService.getWorkDetails(invalidKey);

        // Assert
        expect(result, isNull);
        verifyNever(mockClient.get(any));
      });
    });

    group('Note Management', () {
      test('should add note to correct work', () {
        // Arrange
        final workKey = '/works/OL1234W';
        final content = 'Test note content';
        bookService.addNote(workKey, content);

        // Act
        final notes = bookService.getNotesForWork(workKey);

        // Assert
        expect(notes.length, 1);
        expect(notes[0].workKey, workKey);
        expect(notes[0].content, content);
        expect(notes[0].createdAt, isNotNull);
      });

      test('should return empty list for work with no notes', () {
        // Act
        final notes = bookService.getNotesForWork('/works/nonexistent');

        // Assert
        expect(notes, isEmpty);
      });

      test('should count total notes correctly', () {
        // Arrange
        bookService.addNote('/works/OL1W', 'Note 1');
        bookService.addNote('/works/OL1W', 'Note 2');
        bookService.addNote('/works/OL2W', 'Note 3');

        // Act & Assert
        expect(bookService.totalNotesCount, 3);
      });
    });
  });
}
