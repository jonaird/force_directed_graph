import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:force_directed_graph/force_directed_graph.dart';
import 'package:force_directed_graph/src/helper_classes.dart';

void main() {
  test('test vector/offset conversion', () {
    var size = Size(300, 300);
    var offset = Offset(10, 10);
    var vector = offset.toVector(size);
    expect(offset.dx, vector.toOffset(size).dx);
  });
}
