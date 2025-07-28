import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/search_result_model.dart';
import '../models/work_model.dart';
import '../models/note_model.dart';

class BookService {
  final String baseUrl = 'https://openlibrary.org/search.json';
  final String coverBaseUrl = 'https://covers.openlibrary.org/b/id/';
  final http.Client _client;
  final Map<String, List<Note>> _notesMap = {};

  BookService({http.Client? client}) : _client = client ?? http.Client();

  Future<SearchResult?> searchBooks(String query) async {
    if (query.isEmpty) {
      return null;
    }

    try {
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'q': query,
          'fields': 'key,title,author_name,cover_i,first_publish_year',
          'limit': '10',
        },
      );
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return SearchResult.fromJson(jsonData);
      } else {
        throw Exception('Failed to search books: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in searchBooks: $e');
      rethrow;
    }
  }

  Future<Uint8List?> loadCoverImage(int coverId, {String size = 'M'}) async {
    try {
      final uri = Uri.parse('$coverBaseUrl$coverId-$size.jpg');
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        debugPrint('Failed to load cover image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error loading cover image: $e');
      return null;
    }
  }

  Future<Work?> getWorkDetails(String workKey) async {
    if (!workKey.startsWith('/works/')) {
      if (workKey.startsWith('OL') && workKey.endsWith('W')) {
        workKey = '/works/$workKey';
      } else if (workKey.contains('/works/')) {
        final parts = workKey.split('/works/');
        if (parts.length > 1) {
          workKey = '/works/${parts[1]}';
        }
      } else {
        return null;
      }
    }

    try {
      final uri = Uri.parse('https://openlibrary.org$workKey.json');
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Work.fromJson(jsonData);
      } else {
        debugPrint('Failed to get work details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting work details: $e');
      return null;
    }
  }

  Note addNote(String workKey, String content) {
    final note = Note(
      workKey: workKey,
      content: content,
      createdAt: DateTime.now(),
    );

    if (!_notesMap.containsKey(workKey)) {
      _notesMap[workKey] = [];
    }

    _notesMap[workKey]!.add(note);

    return note;
  }

  List<Note> getNotesForWork(String workKey) {
    return _notesMap[workKey] ?? [];
  }

  int get totalNotesCount {
    int count = 0;
    _notesMap.forEach((key, notes) {
      count += notes.length;
    });
    return count;
  }

  Future<SearchResult?> searchBooksWithOffset(
    String query, {
    int offset = 0,
    int limit = 10,
  }) async {
    if (query.isEmpty) {
      return null;
    }

    try {
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'q': query,
          'fields': 'key,title,author_name,cover_i,first_publish_year',
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return SearchResult.fromJson(jsonData);
      } else {
        throw Exception('Failed to search books: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in searchBooksWithOffset: $e');
      rethrow;
    }
  }
}
