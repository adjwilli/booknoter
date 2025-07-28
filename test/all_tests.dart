import 'models/doc_model_test.dart' as doc_test;
import 'models/search_result_model_test.dart' as search_result_test;
import 'models/work_model_test.dart' as work_test;
import 'models/note_model_test.dart' as note_test;
import 'services/book_service_test.dart' as book_service_test;

void main() {
  doc_test.main();
  search_result_test.main();
  work_test.main();
  note_test.main();
  book_service_test.main();
}
