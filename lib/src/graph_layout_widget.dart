part of '../force_directed_graph.dart';

class _GraphLayoutWidget<T> extends StatefulWidget {
  _GraphLayoutWidget({required this.controller, required this.configuration});
  final _GraphViewConfiguration<T> configuration;
  final GraphController<T>? controller;
  @override
  ___GraphLayoutWidgetState<T> createState() => ___GraphLayoutWidgetState<T>();
}

class ___GraphLayoutWidgetState<T> extends State<_GraphLayoutWidget<T>>
    with SingleTickerProviderStateMixin {
  late GraphController<T> _controller =
      widget.controller ?? GraphController<T>();
  late AnimationController _animationController =
      AnimationController(vsync: this);
  _GraphViewConfiguration<T> get configuration => widget.configuration;

  @override
  void initState() {
    _controller._initialize(configuration, _animationController);
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Container(
            width: _controller.currentSizeWithPadding.width,
            height: _controller.currentSizeWithPadding.height,
            child: child);
      },
      child: Stack(
        children: [_EdgesWidget(_controller), _Nodes(_controller)],
      ),
    );
  }
}
