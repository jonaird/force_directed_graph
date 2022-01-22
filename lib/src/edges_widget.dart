part of '../force_directed_graph.dart';

class _EdgesWidget<T> extends StatefulWidget {
  const _EdgesWidget(this.controller, {Key? key}) : super(key: key);
  final GraphController<T> controller;

  @override
  State<_EdgesWidget<T>> createState() => _EdgesWidgetState<T>();
}

class _EdgesWidgetState<T> extends State<_EdgesWidget<T>> {
  GraphController<T> get _controller => widget.controller;
  @override
  void initState() {
    _controller.addListener(_update);
    super.initState();
  }

  void _update() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (var edge in _controller._configuration.edges)
          if (_controller._nodeSizes[edge.source] != null &&
              _controller._nodeSizes[edge.destination] != null)
            _EdgeWidget(
              edge,
              _controller._nodeSizes[edge.source]!.toLayout(_controller[edge.source]),
              _controller._nodeSizes[edge.destination]!
                  .toLayout(_controller[edge.destination]),
              _controller._configuration.edgeBuilder,
              _controller.currentSize,
            )
      ],
    );
  }
}
