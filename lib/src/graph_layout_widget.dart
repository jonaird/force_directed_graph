part of '../force_directed_graph.dart';

class _GraphLayoutWidget<T> extends StatefulWidget {
  // _GraphLayoutWidget(this.grap)
  @override
  ___GraphLayoutWidgetState<T> createState() => ___GraphLayoutWidgetState<T>();
}

class ___GraphLayoutWidgetState<T> extends State<_GraphLayoutWidget<T>>
    with SingleTickerProviderStateMixin {
  late GraphController<T> _controller;
  late AnimationController _animationController;
  bool _firstPass = true;
  late _GraphState<T> state;
  late Map<T, Widget> _children;
  late Map<T, Size> _nodeSizes;
  late bool _draggingPinsNode, _draggableNodes;

  @override
  void didChangeDependencies() {
    state = context.dependOnInheritedWidgetOfExactType<_InheritedGraph<T>>()!.state;

    _children = Map<T, Widget>.fromIterable(
      state.nodes,
      key: (element) => element,
      value: (e) => Builder(builder: (builderContext) => state.nodeBuilder(e, builderContext)),
    );
    if (_firstPass) {
      _controller = state.controller;
      _animationController = AnimationController(vsync: this);
      _controller._initialize(state.nodes, state.edges, state.size, _animationController,
          state.animated, state.curve, state.duration, state.algorithm);
      _controller.addListener(() => setState(() {}));
      _firstPass = false;
    } else
      _controller._setNewConfiguration(state.nodes, state.edges, state.size, state.animated,
          state.curve, state.duration, state.algorithm);
    _controller._determiningFinalLayout = true;
    _draggableNodes = state.draggableNodes;
    _draggingPinsNode = state.draggingPinsNodes;
    super.didChangeDependencies();
  }

  void _setFinalLayouts(Map<T, NodeLayout> finalLayouts) {
    _controller._determiningFinalLayout = false;
    _nodeSizes = finalLayouts.map((key, value) => MapEntry(key, value.size));
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _controller._startTransition(finalLayouts
          // finalLayouts.map((key, value) => MapEntry(key, value.offset)
          );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPanUpdate(T node, DragUpdateDetails details) {
    if (_draggableNodes) {
      var newOffset = _controller[node] += details.delta;
      var dx = newOffset.dx;
      var dy = newOffset.dy;

      dx = max(dx, 0);
      dy = max(dy, 0);

      dx = min(dx, _controller.size.width - _nodeSizes[node]!.width);
      dy = min(dy, _controller.size.height - _nodeSizes[node]!.height);

      _controller[node] = Offset(dx, dy);
      // Offset(_controller.size.width, _controller.size.height);
      if (_draggingPinsNode) _controller.pinNode(node);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
          width: _controller.size.width,
          height: _controller.size.height,
          child: Stack(
            children: [
              if (!_firstPass)
                for (var edge in _controller._edges)
                  _EdgeWidget(
                      edge,
                      _nodeSizes[edge.source]!.toLayout(_controller[edge.source]),
                      _nodeSizes[edge.destination]!.toLayout(_controller[edge.destination]),
                      state.edgeBuilder,
                      _controller.size),
              if (!_firstPass)
                for (var node in _controller._nodes.keys)
                  Positioned(
                      left: _controller[node].dx,
                      top: _controller[node].dy,
                      child: GestureDetector(
                          onPanUpdate: (details) => _onPanUpdate(node, details),
                          child: _children[node])),
            ],
          )),
      if (_controller._determiningFinalLayout)
        Positioned(
          top: 0,
          left: 0,
          child: Container(
              width: _controller._scheduledTransitionSize.width,
              height: _controller._scheduledTransitionSize.height,
              child: CustomMultiChildLayout(
                children: [
                  for (var node in _children.keys)
                    LayoutId(
                        id: node as Object, child: Opacity(opacity: 0, child: _children[node]))
                ],
                delegate: _GraphLayoutDelegate(
                    _controller._scheduledTransitionOffsets, _setFinalLayouts),
              )),
        )
    ]);
  }
}

class _GraphLayoutDelegate<T> extends MultiChildLayoutDelegate {
  _GraphLayoutDelegate(this.offsets, this.callback);
  final void Function(Map<T, NodeLayout> layouts) callback;
  final Map<T, Offset> offsets;

  final sizes = <NodePosition, Size>{};

  final nodeLayouts = <T, NodeLayout>{};

  @override
  void performLayout(Size size) {
    //layout nodes
    for (var node in offsets.keys) {
      var childId = node;
      var childSize = layoutChild(childId as Object, BoxConstraints.loose(Size.infinite));

      var childOffset = offsets[node]!;
      //offset children such that the center of the child is at the calculated point
      childOffset =
          Offset(childOffset.dx - childSize.width / 2, childOffset.dy - childSize.height / 2);

      //make sure that children are not cut off at the edges
      if (childOffset.dx < 0) childOffset = childOffset.copyWith(x: 0);
      if (childOffset.dx > size.width - childSize.width)
        childOffset = childOffset.copyWith(x: size.width - childSize.width);
      if (childOffset.dy < 0) childOffset = childOffset.copyWith(y: 0);
      if (childOffset.dy > size.height - childSize.height)
        childOffset = childOffset.copyWith(y: size.height - childSize.height);
      nodeLayouts[node] = NodeLayout(childSize, childOffset);

      positionChild(childId, childOffset);
    }
    callback(nodeLayouts);
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}
