import 'dart:math';

import 'package:drag_n_drop_list/list_item.dart';
import 'package:drag_n_drop_list/lsit.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<ToyData> data = [
    for (int i = 0; i < 10; i++) ...{
      ToyData(data: i, order: i),
    }
  ];
  final List<ToyData> data2 = [
    for (int i = 10; i < 15; i++) ...{
      ToyData(data: i, order: i),
    }
  ];

  @override
  Widget build(BuildContext context) {
    var dataToAdd = Random().nextInt(500);
    final scrollController = ScrollController();
    final scrollController2 = ScrollController();

    print(data.length);
    print(data2.length);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: DragList(
                    controller: scrollController,
                    data: data,
                    onItemAdded: (pos, data) {
                      print('add1');
                    },
                    onItemRemoved: (pos, data) {
                      print('remove1');
                    },
                    onWillAccept: (data) => true,
                    onBuildItemFromData: (data) {
                      if (data is ToyData) {
                        return Text(data.data.toString());
                      } else {
                        return const Text('Wrong DataType');
                      }
                    },
                  ),
                ),
                Expanded(
                  child: DragList(
                    controller: scrollController2,
                    data: data2,
                    onWillAccept: (data) => true,
                    onItemAdded: (pos, data) {
                      print('add2');
                    },
                    onItemRemoved: (pos, data) {
                      print('remove2');
                    },
                    onBuildItemFromData: (data) {
                      if (data is ToyData) {
                        return Text(data.data.toString());
                      } else {
                        return const Text('Wrong DataType');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: DraggableListItem(
                  feedback: const SizedBox(
                    height: 100,
                    width: 100,
                    child: Center(child: Icon(Icons.check)),
                  ),
                  data: ToyData(data: dataToAdd),
                  onDragCompleted: () => setState(() {}),
                  child: const SizedBox(
                    height: 100,
                    child: Center(child: Text('Drag Me')),
                  ),
                ),
              ),
              Expanded(
                child: DragTarget(
                  onWillAccept: (data) => data is DraggableListItemData,
                  builder: (context, candidateData, rejectedData) => SizedBox(
                    height: 100,
                    child: Container(
                      color: Colors.red,
                      child: const Center(
                        child: Text('Destroy Data'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ToyData {
  final int data;
  final int? order;

  ToyData({
    required this.data,
    this.order,
  });
}
