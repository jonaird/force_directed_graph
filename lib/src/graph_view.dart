part of '../force_directed_graph.dart';

class GraphView<T> extends StatelessWidget {
  GraphView({
    required this.nodes,
    required this.edges,
    required this.nodeBuilder,
    required this.edgeBuilder,
    required this.width,
    required this.height,
    this.padding = const EdgeInsets.all(10),
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOutExpo,
    this.controller,
    this.algorithm = const FruchtermanReingoldAlgorithm(),
    this.animated = true,
    this.draggableNodes = true,
    this.draggingPinsNodes = false,
  }) {
    assert(_nodesContainsAllEdgeNodes(nodes, edges));
  }
  final Set<T> nodes;
  final Set<Edge<T>> edges;
  final Widget Function(T data, BuildContext context) nodeBuilder;
  final double width, height;
  final EdgeInsets padding;
  final Duration duration;
  final Curve curve;
  final Widget Function(Edge<T> edge, double rotation, BuildContext context)
      edgeBuilder;
  final GraphController<T>? controller;
  final GraphLayoutAlgorithm algorithm;
  final bool animated, draggableNodes, draggingPinsNodes;
  @override
  Widget build(BuildContext context) {
    return _GraphLayoutWidget<T>(
      controller: controller ?? GraphController<T>(),
      configuration: _GraphViewConfiguration<T>(
          nodes: Set.from(nodes),
          edges: Set.from(edges),
          nodeBuilder: nodeBuilder,
          edgeBuilder: edgeBuilder,
          size: Size(width - padding.horizontal, height - padding.vertical),
          padding: padding,
          curve: curve,
          duration: duration,
          algorithm: algorithm,
          animated: animated,
          draggableNodes: draggableNodes,
          draggingPinsNodes: draggingPinsNodes),
    );
  }

  bool _nodesContainsAllEdgeNodes(Set<T> nodes, Set<Edge<T>> edges) {
    for (final edge in edges) {
      if (!nodes.contains(edge.source) || !nodes.contains(edge.destination)) {
        return false;
      }
    }
    return true;
  }
}

class _GraphViewConfiguration<T> {
  _GraphViewConfiguration({
    required this.nodes,
    required this.edges,
    required this.nodeBuilder,
    required this.edgeBuilder,
    required this.size,
    required this.padding,
    required this.duration,
    required this.curve,
    required this.algorithm,
    required this.animated,
    required this.draggableNodes,
    required this.draggingPinsNodes,
  });
  final Set<T> nodes;
  final Set<Edge<T>> edges;
  final Widget Function(T data, BuildContext context) nodeBuilder;
  final Widget Function(Edge<T> edge, double rotation, BuildContext context)
      edgeBuilder;
  final Size size;
  final EdgeInsets padding;
  final Duration duration;
  final Curve curve;
  final GraphLayoutAlgorithm algorithm;
  final bool animated, draggableNodes, draggingPinsNodes;

  bool operator ==(other) {
    var eq = DeepCollectionEquality.unordered();
    return other is _GraphViewConfiguration<T> &&
        eq.equals(other.nodes, nodes) &&
        eq.equals(other.edges, edges) &&
        size == other.size &&
        algorithm == other.algorithm &&
        animated == other.animated &&
        draggableNodes == other.draggableNodes &&
        draggingPinsNodes == other.draggingPinsNodes;
  }

  int get hashCode =>
      hashList(nodes) ^
      hashList(edges) ^
      size.hashCode ^
      algorithm.hashCode ^
      animated.hashCode ^
      draggableNodes.hashCode ^
      draggingPinsNodes.hashCode;
}

class _InheritedGraph<T> extends InheritedWidget {
  _InheritedGraph({
    required this.state,
    required Widget child,
  }) : super(child: child);
  final _GraphViewConfiguration<T> state;

  @override
  bool updateShouldNotify(covariant _InheritedGraph oldWidget) {
    var result = state != oldWidget.state;
    return result;
  }
}
