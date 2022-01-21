part of '../force_directed_graph.dart';

class GraphView<T> extends StatelessWidget {
  GraphView({
    required this.nodes,
    required this.edges,
    required this.nodeBuilder,
    required this.edgeBuilder,
    required this.size,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOutExpo,
    this.controller,
    this.algorithm = const FruchtermanReingoldAlgorithm(),
    this.animated = true,
    this.draggableNodes = true,
    this.draggingPinsNodes = false,
  });
  final List<T> nodes;
  final List<Edge<T>> edges;
  final Widget Function(T data, BuildContext context) nodeBuilder;
  final Size size;
  final Duration duration;
  final Curve curve;
  final Widget Function(Edge<T> edge, double rotation, BuildContext context) edgeBuilder;
  final GraphController<T>? controller;
  final GraphLayoutAlgorithm algorithm;
  final bool animated, draggableNodes, draggingPinsNodes;
  @override
  Widget build(BuildContext context) {
    return _InheritedGraph<T>(
      state: _GraphState<T>(
          nodes: List.from(nodes),
          edges: List.from(edges),
          nodeBuilder: nodeBuilder,
          edgeBuilder: edgeBuilder,
          size: size,
          curve: curve,
          duration: duration,
          controller: controller ?? GraphController<T>(),
          algorithm: algorithm,
          animated: animated,
          draggableNodes: draggableNodes,
          draggingPinsNodes: draggingPinsNodes),
      child: _GraphLayoutWidget<T>(),
    );
  }
}

class _GraphState<T> {
  _GraphState({
    required this.nodes,
    required this.edges,
    required this.nodeBuilder,
    required this.edgeBuilder,
    required this.size,
    required this.duration,
    required this.curve,
    required this.controller,
    required this.algorithm,
    required this.animated,
    required this.draggableNodes,
    required this.draggingPinsNodes,
  });
  final List<T> nodes;
  final List<Edge<T>> edges;
  final Widget Function(T data, BuildContext context) nodeBuilder;
  final Widget Function(Edge<T> edge, double rotation, BuildContext context) edgeBuilder;
  final Size size;
  final Duration duration;
  final Curve curve;
  final GraphController<T> controller;
  final GraphLayoutAlgorithm algorithm;
  final bool animated, draggableNodes, draggingPinsNodes;

  bool operator ==(other) {
    var eq = DeepCollectionEquality.unordered();
    return other is _GraphState<T> &&
        eq.equals(other.nodes, nodes) &&
        eq.equals(other.edges, edges) &&
        size == other.size &&
        algorithm == other.algorithm;
  }

  int get hashCode =>
      nodes.map((e) => e.hashCode).reduce((value, element) => value + element) +
      edges.map((e) => e.hashCode).reduce((value, element) => value + element) +
      size.hashCode +
      algorithm.hashCode;
}

class _InheritedGraph<T> extends InheritedWidget {
  _InheritedGraph({
    required this.state,
    required Widget child,
  }) : super(child: child);
  final _GraphState<T> state;

  @override
  bool updateShouldNotify(covariant _InheritedGraph oldWidget) {
    var result = state != oldWidget.state;
    return result;
  }
}
