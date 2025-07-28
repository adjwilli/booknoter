import 'doc_model.dart';

class SearchResult {
  final int numFound;
  final int start;
  final bool numFoundExact;
  final int numFoundField;
  final String q;
  final int? offset;
  final List<Doc> docs;

  SearchResult({
    required this.numFound,
    required this.start,
    required this.numFoundExact,
    required this.numFoundField,
    required this.q,
    this.offset,
    required this.docs,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    List<Doc> docsList = [];
    if (json['docs'] != null) {
      docsList =
          List<Doc>.from(json['docs'].map((docJson) => Doc.fromJson(docJson)));
    }

    return SearchResult(
      numFound: json['numFound'] ?? 0,
      start: json['start'] ?? 0,
      numFoundExact: json['numFoundExact'] ?? false,
      numFoundField: json['num_found'] ?? 0,
      q: json['q'] ?? '',
      offset: json['offset'],
      docs: docsList,
    );
  }

  @override
  String toString() {
    return 'SearchResults(numFound: $numFound, start: $start, q: $q, docs: ${docs.length} items)';
  }
}
