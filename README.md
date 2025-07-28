# BookNoter

BookNoter is a Flutter application that allows users to search for books, view detailed information about them, and add personal notes for each book. It integrates with the Open Library API to provide comprehensive book data.

## Features

- Search for books by title, author, or subject
- View book details including cover images, publication information, and descriptions
- Add and manage personal notes for each book
- Infinite scrolling to load more search results

## Screenshots

<img width="250" alt="Screenshot 2025-07-28 at 1 13 58 PM" src="https://github.com/user-attachments/assets/d083fb39-d2dd-430a-8b9d-a98c2d9527bb" />
<img width="250" alt="Screenshot 2025-07-28 at 1 14 24 PM" src="https://github.com/user-attachments/assets/0c2488bd-c812-4bb1-aa34-aa6931be2010" />
<img width="250" alt="Screenshot 2025-07-28 at 1 14 51 PM" src="https://github.com/user-attachments/assets/351568ce-a65d-4e7b-9ce5-2b4777189f6f" />

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (3.3.0 or higher)
- Dart SDK (3.8.0 or higher)
- An IDE (VS Code, Android Studio, or IntelliJ)

### Setup

1. **Clone the repository**

```bash
git clone https://github.com/adjwilli/booknoter.git
cd booknoter
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Run the app**

For development:

```bash
flutter run
```

Please note this app has only been tested and vetted on Chrome, iOS 18.5, MacOS 15.5, and Android SDK 36. Running on Linux or Window (or other versions of the other targets) may require additional set up.


## Project Structure

```
lib/
├── models/          # Data models
├── services/        # API services
```

## Testing

BookNoter includes comprehensive unit tests for all models and services. To run the tests:

```bash
flutter test
```

The testing suite includes:

- Model tests: Validating model construction, JSON serialization/deserialization, and helper methods
- Service tests: Ensuring API interactions and data management work correctly

## API Integration

BookNoter uses the Open Library API to search for books and retrieve book information. The application makes the following API calls:

- Search: `https://openlibrary.org/search.json?q={query}`
- Cover images: `https://covers.openlibrary.org/b/id/{cover_id}-{size}.jpg`
- Work details: `https://openlibrary.org/works/{work_id}.json`
