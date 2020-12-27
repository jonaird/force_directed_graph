import 'package:flutter/material.dart';
import 'package:force_directed_graph/force_directed_graph.dart';
import 'dart:math';

void main() {
  runApp(Example());
}

class Example extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: GraphExample()),
      ),
    );
  }
}

class GraphExample extends StatefulWidget {
  @override
  _GraphExampleState createState() => _GraphExampleState();
}

class _GraphExampleState extends State<GraphExample> {
  List<int> nodes;
  List<Edge<int>> edges;
  final r = Random();
  double size = 400;
  final _controller = GraphController<int>();

  @override
  void initState() {
    nodes = [for (var i = 0; i < 10; i += 1) i];

    edges = [
      for (var i = 0; i < 20; i++)
        Edge(nodes[r.nextInt(10)], nodes[r.nextInt(10)])
    ];
    // nodes = [1, 2];
    // edges = [Edge(1, 2)];

    for (var edge in edges) {
      if (edge.source == edge.destination) edges.remove(edge);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            RaisedButton(
              child: Text('decrease area size'),
              onPressed: () => setState(() => size -= 100),
            ),
            RaisedButton(
              child: Text('increase area size'),
              onPressed: () => setState(() => size += 100),
            ),
            RaisedButton(
              child: Text('add node'),
              onPressed: () => setState(() {
                nodes.add(nodes.length);
                edges.addAll(
                    [Edge(nodes.length - 1, r.nextInt(nodes.length - 1))]);
              }),
            ),
            RaisedButton(
                child: Text('reset'),
                onPressed: () => _controller.resetGraph()),
          ],
        ),
        Container(
          color: Colors.black12,
          child: GraphView<int>(
            nodes: nodes,
            edges: edges,
            controller: _controller,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOutQuad,
            edgeBuilder: (edge, rotation, context) => LineEdge(),
            nodeBuilder: (data, context) => Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(data.toString()),
              ),
            ),
            size: Size(size, size),
          ),
        ),
      ],
    );
  }
}
