part of '../force_directed_graph.dart';

class GraphView<T> extends StatelessWidget {
  GraphView(
      {this.nodes,
      this.edges,
      this.nodeBuilder,
      this.edgeBuilder,
      this.size,
      this.duration = const Duration(milliseconds: 400),
      this.curve = Curves.easeInOutExpo,
      this.controller,
      this.algorithm = const FruchtermanReingoldAlgorithm(),
      this.animated = true,
      this.draggableNodes = true,
      this.draggingPinsNodes = false})
      : assert(nodes != null),
        assert(edges != null),
        assert(nodeBuilder != null),
        assert(edgeBuilder != null);
  final List<T> nodes;
  final List<Edge<T>> edges;
  final Widget Function(T data, BuildContext context) nodeBuilder;
  final Size size;
  final Duration duration;
  final Curve curve;
  final Widget Function(Edge<T> edge, double rotation, BuildContext context)
      edgeBuilder;
  final GraphController<T> controller;
  final NodeLayoutAlgorithm algorithm;
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
          controller: controller,
          algorithm: algorithm,
          animated: animated,
          draggableNodes: draggableNodes,
          draggingPinsNodes: draggingPinsNodes),
      child: _GraphLayoutWidget<T>(),
    );
  }
}

class _GraphState<T> {
  _GraphState(
      {this.nodes,
      this.edges,
      this.nodeBuilder,
      this.edgeBuilder,
      this.size,
      this.duration,
      this.curve,
      this.controller,
      this.algorithm,
      this.animated,
      this.draggableNodes,
      this.draggingPinsNodes});
  final List<T> nodes;
  final List<Edge<T>> edges;
  final Widget Function(T data, BuildContext context) nodeBuilder;
  final Widget Function(Edge<T> edge, double rotation, BuildContext context)
      edgeBuilder;
  final Size size;
  final Duration duration;
  final Curve curve;
  final GraphController<T> controller;
  final NodeLayoutAlgorithm algorithm;
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
  _InheritedGraph({this.state, Widget child}) : super(child: child);
  final _GraphState<T> state;

  @override
  bool updateShouldNotify(covariant _InheritedGraph oldWidget) {
    var result = state != oldWidget.state;
    return result;
  }
}
