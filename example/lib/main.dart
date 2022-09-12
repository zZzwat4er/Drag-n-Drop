import 'dart:math';

import 'package:drag_n_drop_list/drag_n_drop_list.dart';
import 'package:drag_n_drop_list/list_item.dart';
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
      ToyData(data: Random().nextInt(500), order: i),
    }
  ];
  final List<ToyData> data2 = [
    for (int i = 10; i < 15; i++) ...{
      ToyData(data: Random().nextInt(500), order: i),
    }
  ];

  @override
  Widget build(BuildContext context) {
    var dataToAdd = Random().nextInt(500);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: DropList(
                    data: data,
                    onItemAdded: (pos, data) {
                    },
                    onItemRemoved: (pos, data) {
                    },
                    onWillAccept: (data) => true,
                    onBuildItemFromData: (data) {
                      if (data is ToyData) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(data.data.toString()),
                          ),
                        );
                      } else {
                        return const Text('Wrong DataType');
                      }
                    },
                  ),
                ),
                Expanded(
                  child: DropList(
                    data: data2,
                    onWillAccept: (data) => true,
                    onItemAdded: (pos, data) {
                      setState(() {
                        if (pos < data2.length) {
                          data2.insert(pos, data);
                        } else {
                          data2.add(data);
                        }
                      });
                    },
                    onItemRemoved: (pos, data) {
                      setState(() {
                        data2.removeAt(pos);
                      });
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
