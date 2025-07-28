import 'package:mockito/mockito.dart' as i1;
import 'package:http/http.dart' as i2;
import 'dart:async' as i3;

// Mock class for http.Client
class MockClient extends i1.Mock implements i2.Client {
  MockClient() {
    i1.throwOnMissingStub(this);
  }

  @override
  i3.Future<i2.Response> get(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
        Invocation.method(
          #get,
          [url],
          {#headers: headers},
        ),
        returnValue: i3.Future<i2.Response>.value(_FakeResponse()),
      ) as i3.Future<i2.Response>);
}

class _FakeResponse extends i1.Fake implements i2.Response {}
