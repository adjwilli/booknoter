import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/book_service.dart';
import 'models/doc_model.dart';
import 'models/work_model.dart';
import 'models/note_model.dart';

class BookPage extends StatefulWidget {
  final Doc book;
  const BookPage({super.key, required this.book});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  final TextEditingController noteController = TextEditingController();
  Work? workDetails;
  bool isLoading = false;
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    fetchWorkDetails();
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  void loadNotes() {
    if (workDetails == null) return;

    final bookService = Provider.of<BookService>(context, listen: false);

    setState(() {
      notes = bookService.getNotesForWork(workDetails!.key);
    });
  }

  Future<void> fetchWorkDetails() async {
    if (widget.book.key.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final bookService = Provider.of<BookService>(context, listen: false);

      String workKey = widget.book.key;

      if (!workKey.startsWith('/works/') && workKey.contains('/works/')) {
        final parts = workKey.split('/works/');
        if (parts.length > 1) {
          workKey = '/works/${parts[1]}';
        }
      }

      if (workKey.contains('/works/')) {
        final work = await bookService.getWorkDetails(workKey);

        if (mounted) {
          setState(() {
            workDetails = work;
            isLoading = false;
            loadNotes();
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching work details: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void addNote() {
    if (noteController.text.trim().isEmpty || workDetails == null) return;

    final bookService = Provider.of<BookService>(context, listen: false);
    bookService.addNote(workDetails!.key, noteController.text.trim());

    setState(() {
      notes = bookService.getNotesForWork(workDetails!.key);
      noteController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title ?? 'Book Details'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.book.coverImage != null)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.memory(widget.book.coverImage!),
                ),
              const SizedBox(height: 24),
              Text(
                widget.book.title ?? 'Unknown Title',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (widget.book.authorName != null &&
                  widget.book.authorName!.isNotEmpty)
                Text(
                  widget.book.authorName!.first,
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 16),
              if (workDetails?.firstPublishDate != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'First Published: ${workDetails!.firstPublishDate}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                )
              else if (widget.book.firstPublishYear != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'First Published: ${widget.book.firstPublishYear}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                )
              else
                const Text(
                  'First Published: Unknown',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              const SizedBox(height: 8),
              if (isLoading)
                const CircularProgressIndicator()
              else if (workDetails != null && workDetails!.description != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ExpandableDescription(
                        description: workDetails!.description!),
                  ],
                )
              else
                const Text(
                  'No description available for this book.',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Notes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${notes.length} note${notes.length == 1 ? "" : "s"}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (notes.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Center(
                    child: Text(
                      'No notes yet. Add your first note below.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${note.createdAt.month}/${note.createdAt.day}/${note.createdAt.year}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              note.content,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add a Note',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: noteController,
                          decoration: InputDecoration(
                            hintText: 'Enter your thoughts about this book...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          maxLines: 3,
                          minLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: addNote,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Add Note'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpandableDescription extends StatefulWidget {
  final String description;

  const ExpandableDescription({
    super.key,
    required this.description,
  });

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool isExpanded = false;

  String get previewText {
    const int previewLength = 100;
    if (widget.description.length <= previewLength) {
      return widget.description;
    }

    final cutoff =
        widget.description.substring(0, previewLength).lastIndexOf(' ');
    if (cutoff == -1) {
      return '${widget.description.substring(0, previewLength)}...';
    }

    return '${widget.description.substring(0, cutoff)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isExpanded ? widget.description : previewText,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isExpanded ? 'Show less' : 'Read more',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
