import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class NodeOffset extends Offset {
  NodeOffset(double dx, double dy, this.pinned) : super(dx, dy);
  final bool pinned;

  NodeOffset copyWith({double dx, double dy, bool pinned}) =>
      NodeOffset(dx ?? this.dx, dy ?? this.dy, pinned ?? this.pinned);

  @override
  String toString() => super.toString();
}

class NodeLayout {
  NodeLayout(this.size, this.offset);
  final Size size;
  final Offset offset;

  Offset get centerOffset =>
      Offset(offset.dx + size.width / 2, offset.dy + size.height / 2);
}

class NodePosition {
  const NodePosition(this.position, {this.pinned = false});
  final Vector2 position;
  final bool pinned;

  MutableNodePosition toMutable() =>
      MutableNodePosition(position, pinned: pinned);
}

class MutableNodePosition {
  MutableNodePosition(this.position, {this.pinned = false});
  Vector2 position;
  bool pinned;
  var displacement = Vector2(0, 0);

  NodePosition toImmutable() => NodePosition(position, pinned: pinned);
}

extension ToLayout on Size {
  NodeLayout toLayout(Offset offset) => NodeLayout(this, offset);
}

extension VectorExtensions on Offset {
  Vector2 toVector(Size size) {
    return Vector2(dx - size.width / 2, dy - size.height / 2);
  }

  Offset copyWith({double x, double y}) {
    return Offset(x ?? dx, y ?? dy);
  }

  NodeOffset toNodeOffset(bool pinned) => NodeOffset(dx, dy, pinned);
}

extension ToOffset on Vector2 {
  Offset toOffset(Size size) {
    return Offset(x + size.width / 2, y + size.height / 2);
  }
}
