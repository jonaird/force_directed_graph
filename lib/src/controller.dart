part of '../force_directed_graph.dart';

class GraphController<T> extends ChangeNotifier {
  late _GraphViewConfiguration<T> _configuration;
  final _nodes = <T, NodeOffset>{};
  final _nodeSizes = <T, Size>{};
  late AnimationController _animationController;
  late Map<T, Animation<Offset>> _animations = {};
  late Animation<Size> _sizeAnimation;

  late Map<T, Offset> _scheduledTransitionOffsets;
  late bool _determiningFinalLayout, _initialLayout = true;
  late Size currentSize;

  void _initialize(
    _GraphViewConfiguration<T> configuration,
    AnimationController controller,
  ) {
    _determiningFinalLayout = true;
    _configuration = configuration;
    currentSize = configuration.size;
    _animationController = controller;
    _animationController.addListener(_onAnimationChange);
    var nodeOffsets = Map<T, NodeOffset?>.fromIterable(_configuration.nodes,
        key: (node) => node, value: (node) => null);
    _scheduledTransitionOffsets = configuration.algorithm
        .runAlgorithm<T>(nodeOffsets, configuration.edges, configuration.size);
  }

  void _setNewConfiguration(_GraphViewConfiguration<T> configuration) {
    _determiningFinalLayout = true;
    _animationController.duration = configuration.duration;
    _configuration = configuration;

    //if node exists in _nodes, sets current offset, otherwise
    //offset is set to null as the key won't exist in _nodes
    Map<T, NodeOffset?> newNodeOffsets = {};
    for (var node in configuration.nodes) newNodeOffsets[node] = _nodes[node];

    _scheduledTransitionOffsets = configuration.algorithm
        .runAlgorithm<T>(newNodeOffsets, configuration.edges, configuration.size);
  }

  void _startTransition(Map<T, NodeLayout> finalOffsets) {
    _determiningFinalLayout = false;
    _nodeSizes.clear();
    _nodeSizes.addAll(finalOffsets.map((key, value) => MapEntry(key, value.size)));

    if (_initialLayout) {
      var nodeOffsets = finalOffsets
          .map((node, offset) => MapEntry(node, offset.centerOffset.toNodeOffset(false)));
      _nodes.addAll(nodeOffsets);
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

      animateNodesTo(finalOffsets.map((key, value) => MapEntry(key, value.centerOffset)));
    }
  }

  void animateNodesTo(Map<T, Offset> nodeOffsets) {
    for (var node in nodeOffsets.keys) assert(_nodes.containsKey(node));

    if (_animationController.isAnimating) _animationController.stop();
    //if a size transition is interrupted, will finish animating to final size,
    //otherwise will not animate as size and _sheduledTransitionSize are the same.
    _sizeAnimation = Tween<Size>(begin: currentSize, end: _configuration.size).animate(
      CurvedAnimation(curve: _configuration.curve, parent: _animationController),
    );
    _animations.clear();
    for (var node in _nodes.keys) {
      var endOffset = nodeOffsets[node] != null ? nodeOffsets[node] : _nodes[node];
      _animations[node] = Tween<Offset>(begin: _nodes[node], end: endOffset)
          .animate(CurvedAnimation(curve: _configuration.curve, parent: _animationController));
    }
    _animationController.value = 0;
    _animationController.forward();
  }

  void _onAnimationChange() {
    for (var node in _nodes.keys)
      if (!_nodes[node]!.pinned) _nodes[node] = _animations[node]!.value.toNodeOffset(false);
    currentSize = _sizeAnimation.value;
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
    _setNewConfiguration(_configuration);
    notifyListeners();
  }
}
