part of '../force_directed_graph.dart';

class _Nodes<T> extends StatefulWidget {
  const _Nodes(this.controller, {Key? key}) : super(key: key);
  final GraphController<T> controller;
  @override
  State<_Nodes<T>> createState() => _NodesState<T>();
}

class _NodesState<T> extends State<_Nodes<T>> {
  GraphController<T> get _controller => widget.controller;
  late final layoutDelegate = _GraphLayoutDelegate(_controller);
  _GraphViewConfiguration<T> get configuration => _controller._configuration;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (_controller._nodesChanged) {
      _controller._nodesChanged = false;
      setState(() {});
    }
  }

  void _onPanUpdate(T node, DragUpdateDetails details) {
    if (configuration.draggableNodes) {
      var newOffset = _controller[node] += details.delta;
      var dx = newOffset.dx;
      var dy = newOffset.dy;

      var nodeSize = _controller._nodeSizes[node]!;

      dx = max(dx, 0 - nodeSize.width / 2);
      dy = max(dy, 0 - nodeSize.height / 2);

      dx = min(dx, _controller.currentSize.width - _controller._nodeSizes[node]!.width / 2);
      dy = min(dy, _controller.currentSize.height - _controller._nodeSizes[node]!.height / 2);

      _controller[node] = Offset(dx, dy);
      // Offset(_controller.size.width, _controller.size.height);
      if (configuration.draggingPinsNodes) _controller.pinNode(node);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      child: CustomMultiChildLayout(
        children: [
          for (var node in configuration.nodes)
            LayoutId(
              id: node as Object,
              child: GestureDetector(
                onPanUpdate: (details) => _onPanUpdate(node, details),
                child: configuration.nodeBuilder(node, context),
              ),
            )
        ],
        delegate: layoutDelegate,
      ),
      builder: (context, child) {
        return Container(
            width: _controller.currentSizeWithPadding.width,
            height: _controller.currentSizeWithPadding.height,
            child: child);
      },
    );
  }
}

class _GraphLayoutDelegate<T> extends MultiChildLayoutDelegate {
  _GraphLayoutDelegate(this.controller) : super(relayout: controller);
  final GraphController<T> controller;

  @override
  void performLayout(Size size) {
    //layout nodes
    for (var node in controller._configuration.nodes) {
      var childSize = layoutChild(node as Object, BoxConstraints.loose(size));
      controller._nodeSizes[node] = childSize;
      // controller._nodeSizes[node] = childSize;
      Offset childOffset = controller._nodeOffsets[node]!;
      //offset children such that the center of the child is at the calculated point
      childOffset =
          Offset(childOffset.dx - childSize.width / 2, childOffset.dy - childSize.height / 2);
      //add padding
      childOffset = Offset(childOffset.dx + controller._configuration.padding.left,
          childOffset.dy + controller._configuration.padding.top);
      //make sure that children are not cut off at the edges
      // childOffset = _childOffsetWithinConstraints(childOffset, childSize, size);

      positionChild(node, childOffset);
    }
    if (controller._initialLayout) {
      controller._afterInitialLayout();
    }
  }

  // Offset _childOffsetWithinConstraints(Offset offset, Size childSize, Size size) {
  //   var childOffset = offset;
  //   if (childOffset.dx < 0) childOffset = childOffset.copyWith(x: 0);
  //   if (childOffset.dx > size.width - childSize.width)
  //     childOffset = childOffset.copyWith(x: size.width - childSize.width);
  //   if (childOffset.dy < 0) childOffset = childOffset.copyWith(y: 0);
  //   if (childOffset.dy > size.height - childSize.height)
  //     childOffset = childOffset.copyWith(y: size.height - childSize.height);
  //   return childOffset;
  // }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}
