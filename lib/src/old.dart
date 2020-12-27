// class Graph<T> extends StatefulWidget {
//   @override
//   _GraphState<T> createState() => _GraphState<T>();
// }

// class _GraphState<T> extends State<Graph<T>>
//     with SingleTickerProviderStateMixin {
//   var nodes = <T, NodePosition>{};
//   Map<T, NodeLayout> oldLayouts;
//   Map<T, NodeLayout> finalLayouts;
//   Map<T, Animation<Offset>> animations;
//   Map<T, Widget> finalWidgets;
//   List<Edge<T>> oldEdges;
//   List<Edge<T>> edges;
//   List<Edge<T>> edgesToAnimate;
//   Size oldSize;
//   Size size;
//   Animation<Size> sizeAnimation;
//   final r = Random();
//   double temp;
//   AnimationController _controller;
//   bool determiningFinalLayout;
//   var animating = false;

//   GraphState<T> state;

//   final int iterations = 1000;
//   var currentIteration = 1;

//   @override
//   void didChangeDependencies() {
//     determiningFinalLayout = true;
//     oldLayouts = finalLayouts;
//     finalLayouts = null;
//     state =
//         context.dependOnInheritedWidgetOfExactType<InheritedGraph<T>>().state;

//     if (_controller == null) {
//       _controller = AnimationController(vsync: this, duration: state.duration);
//       _controller.addListener(() {
//         if (_controller.value != 0) setState(() {});
//       });
//       _controller.addStatusListener((status) {
//         if (status == AnimationStatus.completed) {
//           animating = false;

//           setState(() {});
//         }
//       });
//     }

//     oldSize = size;
//     size = state.size;
//     oldEdges = edges;
//     edges = List.from(state.edges);

//     var oldNodes = nodes;
//     nodes = {};
//     for (var node in state.nodes) {
//       if (oldNodes.containsKey(node))
//         nodes[node] = oldNodes[node];
//       else
//         nodes[node] = NodePosition(null);
//     }

//     _calculatePositions();
//     super.didChangeDependencies();
//   }

//   void _calculatePositions() {
//     temp = 0.1 * sqrt(state.size.width / 2 * state.size.height / 2);

//     var mutableNodes =
//         nodes.map((key, value) => MapEntry(key, value.toMutable()));

//     for (currentIteration = 1;
//         currentIteration < iterations + 1;
//         currentIteration++) {
//       // runAlgorithm(mutableNodes, state.edges, state.size, temp, r);

//       temp *= 1.0 - currentIteration / (iterations + 1);
//     }
//     nodes =
//         mutableNodes.map((key, value) => MapEntry(key, value.toImmutable()));
//   }

//   Widget edgeWidgetBuilder(
//       Edge<T> edge, NodeLayout n1Layout, NodeLayout n2Layout) {
//     var points = _calculateEdgePoints(edge, n1Layout, n2Layout);
//     var vector1 = points.item1.toVector(state.size);
//     var vector2 = points.item2.toVector(state.size);

//     // var delta = nodes[edge.destination].position - nodes[edge.source].position;
//     var delta = vector2 - vector1;

//     delta.reflect(Vector2(0, 1));
//     var angle = delta.angleToSigned(Vector2(1, 0));
//     var edgeWidget = Container(
//         width: delta.length, child: state.edgeBuilder(edge, angle, context));

//     var rotated = Transform.rotate(
//       angle: angle,
//       child: edgeWidget,
//     );
//     var offset = _offsetFromEdge(vector1, vector2);
//     return Positioned(
//       top: offset.dy,
//       left: offset.dx,
//       //  min(
//       //     nodes[edge.source].position.x, nodes[edge.destination].position.x),
//       child: rotated,
//     );
//   }

//   Tuple2<Offset, Offset> _calculateEdgePoints(
//       Edge<T> edge, NodeLayout n1, NodeLayout n2) {
//     var o1 = n1.centerOffset;
//     var o2 = n2.centerOffset;

//     //calculate edge slope and y intercept
//     var slope = (o2.dy - o1.dy) / (o2.dx - o1.dx);
//     var yIntercept = o1.dy - slope * o1.dx;

//     var point1 = _nodeEdgeIntersectionPoint(n1, n2, slope, yIntercept);
//     var point2 = _nodeEdgeIntersectionPoint(n2, n1, slope, yIntercept);

//     return Tuple2<Offset, Offset>(point1, point2);
//   }

//   Offset _nodeEdgeIntersectionPoint(
//       NodeLayout n1, NodeLayout n2, double slope, double yIntercept) {
//     var o1 = n1.centerOffset;
//     var o2 = n2.centerOffset;

//     //see if intersection is on the left or right side
//     double n1SideX;
//     //uses right side if o2 is to the right of o1
//     if (o2.dx > o1.dx)
//       n1SideX = o1.dx + n1.size.width / 2;
//     //else use left side
//     else
//       n1SideX = o1.dx - n1.size.width / 2;

//     var intersectionY = slope * n1SideX + yIntercept;

//     //check if y value is within bounds of the side
//     if (intersectionY >= n1.offset.dy &&
//         intersectionY <= n1.offset.dy + n1.size.height)
//       return Offset(n1SideX, intersectionY);
//     //otherwise intersection is either top or bottom

//     double n1TopBottomY;

//     if (o2.dy < o1.dy)
//       n1TopBottomY = n1.offset.dy;
//     else
//       n1TopBottomY = n1.offset.dy + n1.size.height;

//     var intersectionX = (n1TopBottomY - yIntercept) / slope;
//     if (intersectionX.isNaN) intersectionX = o1.dx;

//     return Offset(intersectionX, n1TopBottomY);
//   }

//   Offset _offsetFromEdge(Vector2 position1, Vector2 position2) {
//     var delta = position2 - position1;

//     //finds top-left most node
//     var minOffset = Offset(
//         min(position1.toOffset(size).dx, position2.toOffset(size).dx),
//         min(position1.toOffset(size).dy, position2.toOffset(size).dy));
//     var maxOffset = Offset(
//         max(position1.toOffset(size).dx, position2.toOffset(size).dx),
//         max(position1.toOffset(size).dy, position2.toOffset(size).dy));

//     var midPointOfNodesX = minOffset.dx + (maxOffset.dx - minOffset.dx) / 2;
//     var midPointOfNodesY = minOffset.dy + (maxOffset.dy - minOffset.dy) / 2;

//     var midPointOfEdgeWidget =
//         Offset(minOffset.dx + delta.length / 2, minOffset.dy);

//     var differenceX = midPointOfNodesX - midPointOfEdgeWidget.dx;
//     var differenceY = midPointOfNodesY - midPointOfEdgeWidget.dy;

//     var x = minOffset.dx + differenceX;
//     var y = minOffset.dy + differenceY;

//     return Offset(x, y);
//   }

//   Offset _positionToOffset(Vector2 position) {
//     return Offset(
//         position.x + state.size.width / 2, position.y + state.size.height / 2);
//   }

//   void setFinalNodeLayouts(Map<T, NodeLayout> layouts) {
//     determiningFinalLayout = false;
//     finalLayouts = layouts;
//     finalWidgets = finalLayouts
//         .map((key, value) => MapEntry(key, state.nodeBuilder(key, context)));
//     if (oldLayouts != null) {
//       animations = {};
//       edgesToAnimate = [];
//       edgesToAnimate = edges.where((edge) => oldEdges.contains(edge)).toList();
//       var nodesToAnimate =
//           finalLayouts.keys.where((node) => oldLayouts.containsKey(node));
//       for (var node in nodesToAnimate)
//         animations[node] = Tween<Offset>(
//                 begin: oldLayouts[node].offset, end: finalLayouts[node].offset)
//             .animate(CurvedAnimation(
//                 parent: _controller,
//                 curve: state.curve,
//                 reverseCurve: state.curve));
//       if (oldSize != size)
//         sizeAnimation = Tween<Size>(begin: oldSize, end: size).animate(
//             CurvedAnimation(
//                 parent: _controller,
//                 curve: state.curve,
//                 reverseCurve: state.curve));
//       else
//         sizeAnimation = null;
//     }
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       if (oldLayouts == null)
//         setState(() {});
//       else {
//         animating = true;
//         _controller.value = 0;
//         _controller.forward();
//       }
//     });
//   }

//   Widget animatingEdgeWidget(edge) {
//     var n1 = NodeLayout(
//         finalLayouts[edge.source].size, animations[edge.source].value);
//     var n2 = NodeLayout(finalLayouts[edge.destination].size,
//         animations[edge.destination].value);
//     return edgeWidgetBuilder(edge, n1, n2);
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size containerSize;
//     if (animating && sizeAnimation != null)
//       containerSize = sizeAnimation.value;
//     else if (determiningFinalLayout && oldLayouts != null)
//       containerSize = oldSize;
//     else
//       containerSize = state.size;

//     return Stack(
//       children: [
//         Container(
//           width: containerSize.width,
//           height: containerSize.height,
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               if (!determiningFinalLayout && !animating)
//                 for (var edge in state.edges)
//                   edgeWidgetBuilder(edge, finalLayouts[edge.source],
//                       finalLayouts[edge.destination]),
//               if (animating)
//                 for (var edge in edgesToAnimate) animatingEdgeWidget(edge),
//               if (determiningFinalLayout && !animating && oldLayouts != null)
//                 for (var edge in oldEdges)
//                   edgeWidgetBuilder(edge, oldLayouts[edge.source],
//                       oldLayouts[edge.destination]),
//               if (!animating && !determiningFinalLayout)
//                 for (var node in finalLayouts.keys)
//                   Positioned(
//                       left: finalLayouts[node].offset.dx,
//                       top: finalLayouts[node].offset.dy,
//                       child: GestureDetector(
//                           onPanUpdate: (details) => setState(() {
//                                 var newOffset =
//                                     finalLayouts[node].offset + details.delta;

//                                 nodes[node] = NodePosition(
//                                     newOffset.toVector(state.size) +
//                                         Vector2(
//                                             finalLayouts[node].size.width / 2,
//                                             finalLayouts[node].size.height / 2),
//                                     pinned: true);

//                                 finalLayouts[node] = NodeLayout(
//                                     finalLayouts[node].size, newOffset);
//                               }),
//                           child: finalWidgets[node])),
//               if (animating)
//                 for (var node in animations.keys)
//                   Positioned(
//                       left: animations[node].value.dx,
//                       top: animations[node].value.dy,
//                       child: state.nodeBuilder(node, context)),
//               if (!animating && determiningFinalLayout && oldLayouts != null)
//                 for (var node in oldLayouts.keys)
//                   Positioned(
//                       left: oldLayouts[node].offset.dx,
//                       top: oldLayouts[node].offset.dy,
//                       child: state.nodeBuilder(node, context)),
//             ],
//           ),
//         ),
//         // if (determiningFinalLayout)
//         //   //use the layout widget to determine the final layouts of nodes but don't
//         //   //use it to display anything (wrapped in 0 opacity widgets). delegate uses
//         //   //a callback to set final layouts
//         //   Positioned(
//         //     left: 0,
//         //     top: 0,
//         //     child: Container(
//         //       width: state.size.width,
//         //       height: state.size.height,
//         //       child: CustomMultiChildLayout(
//         //         children: [
//         //           for (var node in nodes.keys)
//         //             LayoutId(
//         //               id: node,
//         //               child: Opacity(
//         //                   opacity: 0, child: state.nodeBuilder(node, context)),
//         //             )
//         //         ],
//         //         delegate: GraphLayoutDelegate<T>(
//         //             nodes, state.edges, setFinalNodeLayouts),
//         //       ),
//         //     ),
//         //   )
//       ],
//     );
//   }
// }
