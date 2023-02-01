import 'package:flutter/material.dart';
import 'package:force_directed_graph/force_directed_graph.dart';
import 'dart:math';
import 'counter_example.dart';

void main() {
  runApp(CounterExample());
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
  final nodes = {for (var i = 0; i < 10; i += 1) i};
  late final edges = {
    for (var i = 0; i < 20; i++) Edge(r.nextInt(10), r.nextInt(10))
  };
  final r = Random();
  double size = 400;
  final _controller = GraphController<int>();

  @override
  void initState() {
    super.initState();

    final edgesToRemove = <Edge<int>>[];
    for (var edge in edges) {
      if (edge.source == edge.destination) edgesToRemove.add(edge);
    }
    edgesToRemove.forEach(edges.remove);
  }

  void _removeNode() {
    setState(() {
      final node = nodes.toList()[r.nextInt(nodes.length)];
      nodes.remove(node);
      edges.removeWhere((e) => e.source == node || e.destination == node);
    });
  }

  void _addNode() {
    final nodeList = nodes.toList();
    final node = r.nextInt(100);
    setState(() {
      final existingNode = nodeList[r.nextInt(nodeList.length)];
      final existingNode2 = nodeList[r.nextInt(nodeList.length)];
      if (node != existingNode) edges.add(Edge(existingNode, node));
      if (node != existingNode2) edges.add(Edge(existingNode2, node));
      nodes.add(node);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(
              child: Text('decrease area size'),
              onPressed: () => setState(() => size -= 100),
            ),
            ElevatedButton(
              child: Text('increase area size'),
              onPressed: () => setState(() => size += 100),
            ),
            ElevatedButton(
              child: Text('add node'),
              onPressed: _addNode,
            ),
            ElevatedButton(
              child: Text('remove node'),
              onPressed: _removeNode,
            ),
            ElevatedButton(
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
            nodeBuilder: (node, context) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(node.toString()),
                ),
              ),
            ),
            width: size,
            height: size,
            padding: EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }
}
