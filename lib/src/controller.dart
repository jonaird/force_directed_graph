part of '../force_directed_graph.dart';

class GraphController<T> extends ChangeNotifier {
  GraphController();

  final _nodes = <T, NodeOffset>{};
  final _nodeSizes = <T, Size>{};
  final _edges = <Edge<T>>[];
  late AnimationController _animationController;
  late Map<T, Animation<Offset>> _animations = {};
  late Animation<Size> _sizeAnimation;
  late GraphLayoutAlgorithm algorithm;

  late Map<T, Offset> _scheduledTransitionOffsets;
  late Size _scheduledTransitionSize;
  late List<Edge<T>> _scheduledTransitionEdges;
  late Curve curve;
  late Duration duration;
  late bool animated, _determiningFinalLayout, _initialLayout = true;
  late Size size;

  void _initialize(
      List<T> nodes,
      List<Edge<T>> edges,
      Size initialSize,
      AnimationController controller,
      bool animated,
      Curve curve,
      Duration duration,
      GraphLayoutAlgorithm algorithm) {
    size = initialSize;
    this.animated = animated;
    this.curve = curve;
    this.duration = duration;
    this.algorithm = algorithm;
    _animationController = controller;
    _animationController.addListener(_onAnimationChange);
    var nodeOffsets =
        Map<T, NodeOffset?>.fromIterable(nodes, key: (node) => node, value: (node) => null);
    _scheduledTransitionOffsets = algorithm.runAlgorithm<T>(nodeOffsets, edges, size);
    _scheduledTransitionSize = initialSize;
    _scheduledTransitionEdges = edges;
  }

  void _setNewConfiguration(List<T> newNodes, List<Edge<T>> edges, Size newSize, bool animated,
      Curve newCurve, Duration duration, GraphLayoutAlgorithm algorithm) {
    this.algorithm = algorithm;
    curve = newCurve;
    animated = animated;
    _animationController.duration = duration;

    //if node exists in _nodes, sets current offset, otherwise
    //offset is set to null as the key won't exist in _nodes
    Map<T, NodeOffset?> newNodeOffsets = {};
    for (var node in newNodes) newNodeOffsets[node] = _nodes[node];

    _scheduledTransitionOffsets = algorithm.runAlgorithm<T>(newNodeOffsets, edges, newSize);
    _scheduledTransitionSize = newSize;
    _scheduledTransitionEdges = edges;
  }

  void _startTransition(Map<T, NodeLayout> finalOffsets) {
    if (_initialLayout) {
      var nodeOffsets = finalOffsets
          .map((node, offset) => MapEntry(node, offset.centerOffset.toNodeOffset(false)));
      _nodes.addAll(nodeOffsets);
      _edges.addAll(_scheduledTransitionEdges);
      _nodeSizes.addAll(finalOffsets.map((key, value) => MapEntry(key, value.size)));
      _initialLayout = false;
      notifyListeners();
    } else {
      var oldOffsets = Map.from(_nodes);
      _nodes.clear();
      //initial node offsets for animation should be their old position or
      // their final position if they're newly added nodes
      for (var node in finalOffsets.keys)
        _nodes[node] =
            oldOffsets[node] ?? finalOffsets[node]!.centerOffset.toNodeOffset(false);
      _edges.clear();
      _edges.addAll(_scheduledTransitionEdges);
      _nodeSizes.clear();
      _nodeSizes.addAll(finalOffsets.map((key, value) => MapEntry(key, value.size)));

      animateNodesTo(finalOffsets.map((key, value) => MapEntry(key, value.centerOffset)));
    }
  }

  void animateNodesTo(Map<T, Offset> nodeOffsets) {
    for (var node in nodeOffsets.keys) assert(_nodes.containsKey(node));

    if (_animationController.isAnimating) _animationController.stop();
    //if a size transition is interrupted, will finish animating to final size,
    //otherwise will not animate as size and _sheduledTransitionSize are the same.
    _sizeAnimation = Tween<Size>(begin: size, end: _scheduledTransitionSize)
        .animate(CurvedAnimation(curve: curve, parent: _animationController));
    _animations.clear();
    for (var node in _nodes.keys) {
      var endOffset = nodeOffsets[node] != null ? nodeOffsets[node] : _nodes[node];
      _animations[node] = Tween<Offset>(begin: _nodes[node], end: endOffset)
          .animate(CurvedAnimation(curve: curve, parent: _animationController));
    }
    _animationController.value = 0;
    _animationController.forward();
  }

  void _onAnimationChange() {
    for (var node in _nodes.keys)
      if (!_nodes[node]!.pinned) _nodes[node] = _animations[node]!.value.toNodeOffset(false);
    size = _sizeAnimation.value;
    notifyListeners();
  }

  void pinNode(T node) {
    assert(_nodes.containsKey(node));
    _nodes[node] = _nodes[node]!.copyWith(pinned: true);
  }

  void unpinNode(T node) {
    assert(_nodes.containsKey(node));
    _nodes[node] = _nodes[node]!.copyWith(pinned: false);
  }

  void jumpNodesTo(Map<T, Offset> nodeOffsets) {
    for (var node in nodeOffsets.keys) {
      assert(_nodes.containsKey(node));
      this[node] = nodeOffsets[node]!;
    }
  }

  void operator []=(T node, Offset offset) {
    assert(_nodes.containsKey(node));
    var size = _nodeSizes[node]!;
    var adjustedOffset = Offset(offset.dx + size.width / 2, offset.dy + size.height / 2);
    _nodes[node] = _nodes[node]!.copyWith(dx: adjustedOffset.dx, dy: adjustedOffset.dy);
    notifyListeners();
  }

  NodeOffset operator [](T node) {
    var size = _nodeSizes[node]!;
    var offset = _nodes[node]!;
    return offset.copyWith(dx: offset.dx - size.width / 2, dy: offset.dy - size.height / 2);
  }

  ///unpins All nodes and recalculates positions
  void resetGraph() {
    _determiningFinalLayout = true;
    _nodes.updateAll((key, value) => value.copyWith(pinned: false));
    _setNewConfiguration(
        _nodes.keys.toList(), List.from(_edges), size, animated, curve, duration, algorithm);
    notifyListeners();
  }
}
