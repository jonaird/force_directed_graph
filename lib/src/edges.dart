part of '../force_directed_graph.dart';

class LineEdge extends StatelessWidget {
  LineEdge({this.width = 2, this.color = Colors.black});
  final Color color;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: width,
      color: color,
    );
  }
}

class _EdgeWidget<T> extends StatelessWidget {
  _EdgeWidget(this.edge, this.source, this.destination, this.builder, this.size);
  final NodeLayout source, destination;
  final Edge<T> edge;
  final Widget Function(Edge<T> edge, double rotation, BuildContext context) builder;
  final Size size;

  Offset _nodeEdgeIntersectionPoint(
      NodeLayout n1, NodeLayout n2, double slope, double yIntercept) {
    var o1 = n1.centerOffset;
    var o2 = n2.centerOffset;

    //see if intersection is on the left or right side
    double n1SideX;
    //uses right side if o2 is to the right of o1
    if (o2.dx > o1.dx)
      n1SideX = o1.dx + n1.size.width / 2;
    //else use left side
    else
      n1SideX = o1.dx - n1.size.width / 2;

    var intersectionY = slope * n1SideX + yIntercept;

    //check if y value is within bounds of the side
    if (intersectionY >= n1.offset.dy && intersectionY <= n1.offset.dy + n1.size.height)
      return Offset(n1SideX, intersectionY);
    //otherwise intersection is either top or bottom

    double n1TopBottomY;

    if (o2.dy < o1.dy)
      n1TopBottomY = n1.offset.dy;
    else
      n1TopBottomY = n1.offset.dy + n1.size.height;

    var intersectionX = (n1TopBottomY - yIntercept) / slope;
    if (intersectionX.isNaN) intersectionX = o1.dx;

    return Offset(intersectionX, n1TopBottomY);
  }

  Tuple2<Offset, Offset> _calculateEdgePoints(Edge<T> edge, NodeLayout n1, NodeLayout n2) {
    var o1 = n1.centerOffset;
    var o2 = n2.centerOffset;

    //calculate edge slope and y intercept
    var slope = (o2.dy - o1.dy) / (o2.dx - o1.dx);
    var yIntercept = o1.dy - slope * o1.dx;

    var point1 = _nodeEdgeIntersectionPoint(n1, n2, slope, yIntercept);
    var point2 = _nodeEdgeIntersectionPoint(n2, n1, slope, yIntercept);

    return Tuple2<Offset, Offset>(point1, point2);
  }

  Widget _edgeWidgetBuilder(BuildContext context) {
    var points = _calculateEdgePoints(edge, source, destination);
    var vector1 = points.item1.toVector(size);
    var vector2 = points.item2.toVector(size);

    // var delta = nodes[edge.destination].position - nodes[edge.source].position;
    var delta = vector2 - vector1;

    delta.reflect(Vector2(0, 1));
    var angle = delta.angleToSigned(Vector2(1, 0));
    var edgeWidget = Container(width: delta.length, child: builder(edge, angle, context));

    var rotated = Transform.rotate(
      angle: angle,
      child: edgeWidget,
    );
    var offset = _offsetFromEdge(vector1, vector2);
    return Positioned(
      top: offset.dy,
      left: offset.dx,
      //  min(
      //     nodes[edge.source].position.x, nodes[edge.destination].position.x),
      child: rotated,
    );
  }

  Offset _offsetFromEdge(Vector2 position1, Vector2 position2) {
    var delta = position2 - position1;

    //finds top-left most node

    var minOffset = Offset(min(position1.toOffset(size).dx, position2.toOffset(size).dx),
        min(position1.toOffset(size).dy, position2.toOffset(size).dy));
    var maxOffset = Offset(max(position1.toOffset(size).dx, position2.toOffset(size).dx),
        max(position1.toOffset(size).dy, position2.toOffset(size).dy));

    var midPointOfNodesX = minOffset.dx + (maxOffset.dx - minOffset.dx) / 2;
    var midPointOfNodesY = minOffset.dy + (maxOffset.dy - minOffset.dy) / 2;

    var midPointOfEdgeWidget = Offset(minOffset.dx + delta.length / 2, minOffset.dy);

    var differenceX = midPointOfNodesX - midPointOfEdgeWidget.dx;
    var differenceY = midPointOfNodesY - midPointOfEdgeWidget.dy;

    var x = minOffset.dx + differenceX;
    var y = minOffset.dy + differenceY;

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return _edgeWidgetBuilder(context);
  }
}

class Tuple2<T1, T2> {
  Tuple2(this.item1, this.item2);
  final T1 item1;
  final T2 item2;
}
