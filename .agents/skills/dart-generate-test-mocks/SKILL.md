---
name: dart-generate-test-mocks
description: Define mock objects for external dependencies using `package:mocktail`. Use when unit testing classes that depend on complex external services like APIs or databases.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Fri, 24 Apr 2026 15:13:58 GMT
---
# Testing and Mocking Dart Applications

## Contents
- [Structuring Code for Testability](#structuring-code-for-testability)
- [Managing Dependencies](#managing-dependencies)
- [Generating Mocks](#generating-mocks)
- [Implementing Unit Tests](#implementing-unit-tests)
- [Workflow: Creating and Running Mocked Tests](#workflow-creating-and-running-mocked-tests)
- [Examples](#examples)

## Structuring Code for Testability
Design Dart classes to support dependency injection. Isolate complex external dependencies (like API clients or databases) so they can be replaced with mock objects during testing.

- Inject external services (e.g., `http.Client`) through class constructors.
- Represent URLs strictly as `Uri` objects using `Uri.parse(string)`.
- Utilize Dart's object-oriented features (classes, mixins) to define clear interfaces for external interactions.

## Managing Dependencies
Configure the `pubspec.yaml` file with the necessary testing and code generation packages.

- Add runtime dependencies (e.g., `package:http`) using `dart pub add http`.
- Add testing dependencies using `dart pub add dev:test dev:mocktail`.
- Import HTTP libraries with a prefix to avoid namespace collisions: `import 'package:http/http.dart' as http;`.

## Defining Mocks
Use `package:mocktail` to define mock classes directly in the test file for fixed scenarios and behavior verification.

- Create mock classes by extending `Mock` and implementing the dependency interface.
- Use `registerFallbackValue()` when matching non-nullable custom types with `any()`.
- No code generation or `build_runner` step is required.

## Implementing Unit Tests
Isolate the system under test using the mock objects. Use `package:test` to structure the test suite.

- **Stubbing:** Configure mock behavior before interacting with the system under test.
  - Use `when(() => mock.method()).thenReturn(value)` for synchronous methods.
  - **CRITICAL:** Always use `thenAnswer((_) async => value)` for methods returning a `Future` or `Stream`. Never use `thenReturn` for asynchronous returns.
- **Verification:** Assert that the system under test interacted with the mock object correctly.
  - Use `verify(mock.method()).called(1)` to check exact invocation counts.
  - Use argument matchers like `any`, `anyNamed`, or `captureAny` for flexible verification.

## Workflow: Creating and Running Mocked Tests

Use the following checklist to implement and verify mocked unit tests.

### Task Progress
- [ ] 1. Identify the external dependency to mock (e.g., `http.Client`).
- [ ] 2. Inject the dependency into the target class constructor.
- [ ] 3. Create a test file (e.g., `target_test.dart`) and define a `Mock` subclass for the dependency.
- [ ] 4. Register fallback values for any non-nullable custom types used with `any()`.
- [ ] 5. Write the test cases using `group()` and `test()`.
- [ ] 6. Stub required behaviors using `when()`.
- [ ] 7. Execute the target method.
- [ ] 8. Verify interactions using `verify()` and assert outcomes using `expect()`.
- [ ] 9. Run the test suite using `dart test`.

### Feedback Loop: Test Failures
If tests fail:
1. **Run validator:** Execute `dart test`.
2. **Review errors:** Check for missing stubs, mismatched argument matchers, or missing fallback registrations.
3. **Fix:**
   - If a mock method throws a missing stub error, ensure the `when()` call matches the exact invocation.
   - If an async stub throws an `ArgumentError`, change `thenReturn` to `thenAnswer`.
   - If a matcher fails on a non-nullable custom type, add `registerFallbackValue(...)`.
4. Repeat until all tests pass.

## Examples

### High-Fidelity Mocking and Testing Example

**1. System Under Test (`lib/api_service.dart`)**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final http.Client client;

  ApiService(this.client);

  Future<String> fetchData(String urlString) async {
    final uri = Uri.parse(urlString);
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to load data');
    }
  }
}
```

**2. Test Implementation (`test/api_service_test.dart`)**
```dart
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/api_service.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  group('ApiService', () {
    late ApiService apiService;
    late MockClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockClient();
      apiService = ApiService(mockHttpClient);
    });

    test('returns data if the http call completes successfully', () async {
      // Arrange: Stub the async HTTP GET request using thenAnswer
      when(() => mockHttpClient.get(any(that: isA<Uri>()))).thenAnswer(
        (_) async => http.Response('{"data": "Success"}', 200),
      );

      // Act
      final result = await apiService.fetchData('https://api.example.com/data');

      // Assert
      expect(result, 'Success');

      // Verify the mock was called with the correct Uri
      verify(() => mockHttpClient.get(Uri.parse('https://api.example.com/data'))).called(1);
    });

    test('throws an exception if the http call completes with an error', () {
      // Arrange
      when(() => mockHttpClient.get(any(that: isA<Uri>()))).thenAnswer(
        (_) async => http.Response('Not Found', 404),
      );

      // Act & Assert
      expect(
        apiService.fetchData('https://api.example.com/data'),
        throwsException,
      );
    });
  });
}
```
