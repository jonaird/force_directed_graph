part of '../force_directed_graph.dart';

abstract class GraphLayoutAlgorithm {
  Map<T, Offset> runAlgorithm<T>(Map<T, NodeOffset?> nodes, Set<Edge<T>> edges, Size size);
}

var r = Random();

class FruchtermanReingoldAlgorithm implements GraphLayoutAlgorithm {
  const FruchtermanReingoldAlgorithm({this.iterations = 1000});
  final int iterations;

  MapEntry<T, MutableNodePosition> _offsetToMutablePostion<T>(
      T key, NodeOffset? value, Size size) {
    if (value == null)
      return MapEntry(key, _randomPosition(size));
    else
      return MapEntry(key, MutableNodePosition(value.toVector(size), pinned: value.pinned));
  }

  @override
  Map<T, Offset> runAlgorithm<T>(Map<T, NodeOffset?> nodes, Set<Edge<T>> edges, Size size) {
    var temp = 0.1 * sqrt(size.width / 2 * size.height / 2);

    //initialize nodes with random positions and convert to MutableNodePosition
    var mutableNodePositions =
        nodes.map((key, value) => _offsetToMutablePostion<T>(key, value, size));

    for (var i = 0; i < iterations; i++) {
      _calculateIteration(mutableNodePositions, edges, size, temp);
      temp *= 1.0 - i / (iterations);
    }

    return mutableNodePositions
        .map((key, value) => MapEntry(key, value.position.toOffset(size)));
  }

  void _calculateIteration<T>(
      Map<T, MutableNodePosition> nodes, Set<Edge<T>> edges, Size size, double t) {
    var width = size.width;
    var height = size.height;
    final result = nodes;

    // //initialize new nodes with random positions
    // result.forEach((key, value) => value.position ??=
    //     Vector2((r.nextDouble() - 0.5) * width / 2, (r.nextDouble() - 0.5) * height / 2));

    final area = width * height;
    final k = sqrt(area / nodes.keys.length);

    double attractionForce(double x) => pow(x, 2) / k;
    double repulsionForce(double x) => pow(k, 2) / x;

    //calulate repulsive forces
    for (var v in result.values) {
      for (var u in result.values) {
        if (u != v && !v.pinned) {
          var delta = v.position - u.position;
          if (delta.length == 0) delta = Vector2(0.01, 0.01);
          if (delta.x == 0) delta.x = 0.01;
          if (delta.y == 0) delta.y = 0.01;
          delta = Vector2(delta.x, delta.y);
          v.displacement += delta / delta.length * repulsionForce(delta.length);
        }
      }
    }

    //calculate attractive forces

    for (var edge in edges) {
      var v = result[edge.source]!;
      var u = result[edge.destination]!;

      var delta = v.position - u.position;
      if (delta.length == 0) delta = Vector2(0.01, 0.01);
      if (!v.pinned) v.displacement -= delta / delta.length * attractionForce(delta.length);
      if (!u.pinned) u.displacement += delta / delta.length * attractionForce(delta.length);
    }

    //limit max displacement to temperature t and prevent from displacement
    // outside frame
    for (var v in result.values) {
      if (!v.pinned) {
        if (v.displacement.length == 0) v.displacement = Vector2(0.01, 0.01);
        v.position += (v.displacement / v.displacement.length) * min(v.displacement.length, t);
        v.position.x = min(width / 2, max(-width / 2, v.position.x));
        v.position.y = min(height / 2, max(-height / 2, v.position.y));
      }
    }
  }

  MutableNodePosition _randomPosition(Size size) {
    return MutableNodePosition(Vector2(
        (r.nextDouble() - 0.5) * size.width / 2, (r.nextDouble() - 0.5) * size.height / 2));
  }
}

class Edge<T> {
  Edge(this.source, this.destination);
  final T source;
  final T destination;

  bool operator ==(dynamic other) =>
      other is Edge && other.source == source && other.destination == destination;

  @override
  int get hashCode => source.hashCode ^ destination.hashCode;
}
