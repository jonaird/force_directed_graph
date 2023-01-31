part of '../force_directed_graph.dart';

class GraphController<T> extends ChangeNotifier {
  late _GraphViewConfiguration<T> _configuration;
  final _nodeOffsets = <T, NodeOffset>{};
  final _nodeSizes = <T, Size>{};
  late AnimationController _animationController;
  late Map<T, Animation<Offset>> _animations = {};
  late Animation<Size> _sizeAnimation;
  bool _initialLayout = true;
  bool _nodesChanged = false;

  late Size currentSize;
  Size get currentSizeWithPadding {
    return Size(
      currentSize.width + _configuration.padding.horizontal,
      currentSize.height + _configuration.padding.vertical,
    );
  }

  void _initialize(
    _GraphViewConfiguration<T> configuration,
    AnimationController controller,
  ) {
    _configuration = configuration;
    currentSize = configuration.size;
    _animationController = controller;
    _animationController.addListener(_onAnimationChange);
    var nodeOffsets = Map<T, NodeOffset?>.fromIterable(_configuration.nodes,
        key: (node) => node, value: (node) => null);
    var offsets = configuration.algorithm
        .runAlgorithm<T>(nodeOffsets, configuration.edges, configuration.size);
    _nodeOffsets
        .addAll(offsets.map((n, v) => MapEntry(n, v.toNodeOffset(false))));
  }

  void _setNewConfiguration(_GraphViewConfiguration<T> configuration) {
    if (!DeepCollectionEquality.unordered()
        .equals(_configuration.nodes, configuration.nodes)) {
      _nodesChanged = true;
    }
    _animationController.duration = configuration.duration;
    _configuration = configuration;

    final newNodes = <T>[];

    //if node exists in _nodes, sets current offset, otherwise
    //offset is set to null as the key won't exist in _nodes
    Map<T, NodeOffset?> newNodeOffsets = {};
    for (var node in configuration.nodes) {
      var oldOffset = _nodeOffsets[node];
      if (oldOffset == null) newNodes.add(node);
      newNodeOffsets[node] = oldOffset;
    }

    final offsets = configuration.algorithm.runAlgorithm<T>(
        newNodeOffsets, configuration.edges, configuration.size);
    for (var node in newNodes) {
      _nodeOffsets[node] = offsets[node]!.toNodeOffset(false);
    }
    animateNodesTo(offsets);
  }

  void _afterInitialLayout() {
    _initialLayout = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void animateNodesTo(Map<T, Offset> nodeOffsets) {
    for (var node in nodeOffsets.keys) assert(_nodeOffsets.containsKey(node));

    if (_animationController.isAnimating) _animationController.stop();
    //if a size transition is interrupted, will finish animating to final size,
    //otherwise will not animate as size and _sheduledTransitionSize are the same.
    _sizeAnimation =
        Tween<Size>(begin: currentSize, end: _configuration.size).animate(
      CurvedAnimation(
          curve: _configuration.curve, parent: _animationController),
    );
    _animations.clear();
    for (var node in _nodeOffsets.keys) {
      var endOffset =
          nodeOffsets[node] != null ? nodeOffsets[node] : _nodeOffsets[node];
      _animations[node] =
          Tween<Offset>(begin: _nodeOffsets[node], end: endOffset).animate(
              CurvedAnimation(
                  curve: _configuration.curve, parent: _animationController));
    }
    _animationController.value = 0;
    _animationController.forward();
  }

  void _onAnimationChange() {
    for (var node in _nodeOffsets.keys)
      if (!_nodeOffsets[node]!.pinned)
        _nodeOffsets[node] = _animations[node]!.value.toNodeOffset(false);
    currentSize = _sizeAnimation.value;
    notifyListeners();
  }

  void pinNode(T node) {
    assert(_nodeOffsets.containsKey(node));
    _nodeOffsets[node] = _nodeOffsets[node]!.copyWith(pinned: true);
  }

  void unpinNode(T node) {
    assert(_nodeOffsets.containsKey(node));
    _nodeOffsets[node] = _nodeOffsets[node]!.copyWith(pinned: false);
  }

  void jumpNodesTo(Map<T, Offset> nodeOffsets) {
    for (var node in nodeOffsets.keys) {
      assert(_nodeOffsets.containsKey(node));
      this[node] = nodeOffsets[node]!;
    }
  }

  void operator []=(T node, Offset offset) {
    assert(_nodeOffsets.containsKey(node));
    var size = _nodeSizes[node]!;
    var adjustedOffset =
        Offset(offset.dx + size.width / 2, offset.dy + size.height / 2);
    _nodeOffsets[node] = _nodeOffsets[node]!
        .copyWith(dx: adjustedOffset.dx, dy: adjustedOffset.dy);
    notifyListeners();
  }

  NodeOffset operator [](T node) {
    var size = _nodeSizes[node]!;
    var offset = _nodeOffsets[node]!;
    return offset.copyWith(
        dx: offset.dx - size.width / 2, dy: offset.dy - size.height / 2);
  }

  ///unpins All nodes and recalculates positions
  void resetGraph() {
    _nodeOffsets.updateAll((key, value) => value.copyWith(pinned: false));
    _setNewConfiguration(_configuration);
    notifyListeners();
  }
}
