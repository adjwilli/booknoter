import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/book_service.dart';
import 'models/doc_model.dart';
import 'models/search_result_model.dart';
import 'bookpage.dart';

class BookScreen extends StatefulWidget {
  // Make these fields private
  final List<Doc> _books = [];

  BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  final TextEditingController searchController =
      TextEditingController(text: "");
  final ScrollController scrollController = ScrollController();

  static const int itemsPerPage = 10;

  SearchResult? searchResult;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasSearched = false;
  int currentPage = 1;

  List<Doc> get books => widget._books;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMoreResults();
    }
  }

  void loadMoreResults() async {
    if (searchResult == null ||
        isLoading ||
        isLoadingMore ||
        books.length >= searchResult!.numFound) {
      return;
    }

    setState(() {
      isLoadingMore = true;
    });

    try {
      final bookService = Provider.of<BookService>(context, listen: false);
      currentPage++;
      final offset = (currentPage - 1) * itemsPerPage;
      final nextPageResults = await bookService.searchBooksWithOffset(
        searchController.text,
        offset: offset,
        limit: itemsPerPage,
      );

      if (nextPageResults != null && nextPageResults.docs.isNotEmpty) {
        setState(() {
          books.addAll(nextPageResults.docs);
        });

        for (int i = books.length - nextPageResults.docs.length;
            i < books.length;
            i++) {
          final doc = books[i];
          if (doc.coverId != null) {
            final coverData = await bookService.loadCoverImage(doc.coverId!);
            if (coverData != null && mounted) {
              setState(() {
                doc.coverImage = coverData;
              });
            }
          }
        }
      }
    } catch (e) {
      print("Error loading more books: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading more books: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingMore = false;
        });
      }
    }
  }

  void searchBooks() async {
    if (searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a title or author to search."),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
      currentPage = 1;
    });

    try {
      final bookService = Provider.of<BookService>(context, listen: false);
      final searchResults =
          await bookService.searchBooks(searchController.text);

      books.clear();

      if (searchResults != null) {
        setState(() {
          searchResult = searchResults;
          if (searchResults.docs.isNotEmpty) {
            books.addAll(searchResults.docs);
          }
        });

        for (var doc in books) {
          if (doc.coverId != null) {
            final coverData = await bookService.loadCoverImage(doc.coverId!);
            if (coverData != null && mounted) {
              setState(() {
                doc.coverImage = coverData;
              });
            }
          }
        }
      }
    } catch (e) {
      print("Error searching books: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error searching books: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasSearched = true;
        });
      }
    }
  }

  void resetSearch() {
    searchController.clear();
    books.clear();
    setState(() {
      searchResult = null;
      hasSearched = false;
      currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          !hasSearched ? searchWidget() : resultsHeaderWidget(),
          Expanded(
            child: !isLoading
                ? books.isEmpty
                    ? Center(
                        child: Text(
                          hasSearched
                              ? "No books found"
                              : "Search for books to begin",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: books.length,
                              itemBuilder: (context, index) {
                                return bookWidget(
                                    book: books[index], context: context);
                              },
                            ),
                            if (isLoadingMore)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.black45,
                                    strokeWidth: 2.0,
                                  ),
                                ),
                              ),
                            if (hasSearched &&
                                books.isNotEmpty &&
                                !isLoadingMore)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  "Showing ${books.length} of ${searchResult?.numFound ?? books.length} books",
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      )
                : const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black87,
                    ),
                  ),
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text("Booknoter"),
        backgroundColor: Colors.blue,
        actions: [
          if (hasSearched)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: resetSearch,
            ),
        ],
      ),
    );
  }

  Widget searchWidget() {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 7,
              child: TextField(
                controller: searchController,
                cursorColor: Colors.black45,
                style: const TextStyle(color: Colors.black87),
                decoration: const InputDecoration(
                  label: Text("Search books:"),
                  labelStyle: TextStyle(color: Colors.black45),
                  focusColor: Colors.black45,
                ),
              ),
            ),
            SizedBox(
              width: 16.0,
            ),
            ElevatedButton(
              onPressed: searchBooks,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.search)],
              ),
            ),
          ],
        ));
  }

  Widget resultsHeaderWidget() {
    final int totalResults = searchResult?.numFound ?? 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Results ($totalResults found)",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (searchController.text != '')
                filterOptionWidget(
                  controller: searchController,
                  label: "Query: ",
                ),
            ],
          ),
        ),
        const Divider(
          color: Colors.black26,
          thickness: 1.0,
        ),
      ],
    );
  }

  Widget filterOptionWidget(
      {required TextEditingController controller, required String label}) {
    void onPressed() {
      controller.clear();

      if (searchController.text.isEmpty) {
        books.clear();
        setState(() {
          hasSearched = false;
        });
      } else {
        searchBooks();
      }
    }

    Widget child = Text(
      "$label ${controller.text}",
      style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
    );

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.close, color: Colors.white),
      label: child,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  Widget bookWidget({required Doc book, required BuildContext context}) {
    String author = '';

    if (book.authorName != null && book.authorName!.isNotEmpty) {
      author = book.authorName!.first.trim();
    }

    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookPage(book: book),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 80.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 4.0, bottom: 4.0, left: 20.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Text(
                          book.title ?? 'Unknown Title',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 4.0, bottom: 4.0, left: 20.0),
                      child: Text(
                        author,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: SizedBox(
                    height: book.coverImage != null ? 64.0 : 0,
                    child: book.coverImage != null
                        ? Image.memory(book.coverImage!)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
