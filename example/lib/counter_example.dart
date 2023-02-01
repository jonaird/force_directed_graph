import 'dart:math';

import 'package:flutter/material.dart';
import 'package:force_directed_graph/force_directed_graph.dart';

class CounterExample extends StatelessWidget {
  const CounterExample({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'force_directed_graph Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Demo(title: 'Flutter Demo Home Page'),
    );
  }
}

class Demo extends StatefulWidget {
  const Demo({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  DemoState createState() => DemoState();
}

class DemoState extends State<Demo> {
  int _counter = 0;
  final _nodes = {0};
  final _edges = <Edge<int>>{};
  final r = Random();

  void _incrementCounter() {
    setState(() {
      _nodes.add(_nodes.length);
      _counter++;

      _addRandomEdge();
      _addRandomEdge();
    });
  }

  void _addRandomEdge() {
    var firstNode = _nodes.toList()[r.nextInt(_nodes.length)];
    var secondNode = _nodes.toList()[r.nextInt(_nodes.length)];
    while (firstNode == secondNode) {
      secondNode = _nodes.toList()[r.nextInt(_nodes.length)];
    }
    var edge = Edge<int>(firstNode, secondNode);
    if (!_edges.contains(edge)) _edges.add(edge);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) => GraphView(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              nodes: _nodes,
              edges: _edges,
              curve: Curves.elasticOut,
              algorithm: const FruchtermanReingoldAlgorithm(iterations: 300),
              duration: const Duration(milliseconds: 1200),
              nodeBuilder: (data, context) => FloatingActionButton(
                onPressed: _incrementCounter,
                tooltip: 'Increment',
                child: const Icon(Icons.add),
              ),
              edgeBuilder: (_, __, ___) => Container(
                height: 3,
                color: Colors.black,
              ),
            ),
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
