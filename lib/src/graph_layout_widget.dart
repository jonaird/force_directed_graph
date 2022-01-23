part of '../force_directed_graph.dart';

class _GraphLayoutWidget<T> extends StatefulWidget {
  _GraphLayoutWidget({required this.controller, required this.configuration});
  final _GraphViewConfiguration<T> configuration;
  final GraphController<T> controller;
  @override
  ___GraphLayoutWidgetState<T> createState() => ___GraphLayoutWidgetState<T>();
}

class ___GraphLayoutWidgetState<T> extends State<_GraphLayoutWidget<T>>
    with SingleTickerProviderStateMixin {
  GraphController<T> get _controller => widget.controller;
  late AnimationController _animationController = AnimationController(vsync: this);
  _GraphViewConfiguration<T> get configuration => widget.configuration;

  @override
  void initState() {
    _controller._initialize(configuration, _animationController);
    _controller.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _GraphLayoutWidget<T> oldWidget) {
    if (oldWidget.configuration != widget.configuration) {
      _controller._setNewConfiguration(configuration);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPanUpdate(T node, DragUpdateDetails details) {
    if (configuration.draggableNodes) {
      var newOffset = _controller[node] += details.delta;
      var dx = newOffset.dx;
      var dy = newOffset.dy;

      dx = max(dx, 0);
      dy = max(dy, 0);

      dx = min(dx, _controller.currentSize.width - _controller._nodeSizes[node]!.width);
      dy = min(dy, _controller.currentSize.height - _controller._nodeSizes[node]!.height);

      _controller[node] = Offset(dx, dy);
      // Offset(_controller.size.width, _controller.size.height);
      if (configuration.draggingPinsNodes) _controller.pinNode(node);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
          width: _controller.currentSize.width,
          height: _controller.currentSize.height,
          child: Stack(
            children: [
              _EdgesWidget(_controller),
              for (var node in _controller._nodes.keys)
                Positioned(
                    left: _controller[node].dx,
                    top: _controller[node].dy,
                    child:
                        // GestureDetector(
                        //     onPanUpdate: (details) => _onPanUpdate(node, details),
                        //     child:
                        configuration.nodeBuilder(node, context)
                    // )
                    ),
            ],
          )),
      if (_controller._determiningFinalLayout)
        Positioned(
          top: 0,
          left: 0,
          child: Container(
              width: configuration.size.width,
              height: configuration.size.height,
              child: CustomMultiChildLayout(
                children: [
                  for (var node in configuration.nodes)
                    LayoutId(
                        id: node as Object, child: configuration.nodeBuilder(node, context))
                ],
                delegate: _GraphLayoutDelegate(_controller),
              )),
        )
    ]);
  }
}

class _GraphLayoutDelegate<T> extends MultiChildLayoutDelegate {
  _GraphLayoutDelegate(this.controller);
  final GraphController<T> controller;
  Map<T, Offset> get initialOffsets => controller._scheduledTransitionOffsets;

  final nodeLayouts = <T, NodeLayout>{};

  @override
  void performLayout(Size size) {
    //layout nodes
    for (var node in initialOffsets.keys) {
      var childSize = layoutChild(node as Object, BoxConstraints.loose(size));
      // controller._nodeSizes[node] = childSize;
      var childOffset = initialOffsets[node]!;
      //offset children such that the center of the child is at the calculated point
      childOffset =
          Offset(childOffset.dx - childSize.width / 2, childOffset.dy - childSize.height / 2);

      //make sure that children are not cut off at the edges
      childOffset = _childOffsetWithinConstraints(childOffset, childSize, size);
      nodeLayouts[node] = NodeLayout(childSize, childOffset);

      positionChild(node, childOffset);
    }
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      controller._startTransition(nodeLayouts);
    });
  }

  Offset _childOffsetWithinConstraints(Offset offset, Size childSize, Size size) {
    var childOffset = offset;
    if (childOffset.dx < 0) childOffset = childOffset.copyWith(x: 0);
    if (childOffset.dx > size.width - childSize.width)
      childOffset = childOffset.copyWith(x: size.width - childSize.width);
    if (childOffset.dy < 0) childOffset = childOffset.copyWith(y: 0);
    if (childOffset.dy > size.height - childSize.height)
      childOffset = childOffset.copyWith(y: size.height - childSize.height);
    return childOffset;
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}
