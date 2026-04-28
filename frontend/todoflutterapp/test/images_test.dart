import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:todoflutterapp/resources/resources.dart';

void main() {
  test('images assets test', () {
    expect(File(Images.appIcon).existsSync(), isTrue);
  });
}
