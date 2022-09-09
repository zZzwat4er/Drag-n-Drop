import 'package:drag_n_drop_list/list_item.dart';
import 'package:drag_n_drop_list/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class DragList extends StatefulWidget {
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final double? itemExtent;
  final Widget? prototypeItem;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final List<dynamic> data;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final Container? itemContainer;

  final Widget Function(Object data) onBuildItemFromData;
  final bool Function(Object? data)? onWillAccept;
  final void Function(int pos, dynamic data)? onItemAdded;
  final void Function(int pos, dynamic data)? onItemRemoved;

  const DragList({
    this.data = const [],
    required this.onBuildItemFromData,
    this.onWillAccept,
    this.onItemAdded,
    this.onItemRemoved,
    this.itemContainer,
    super.key,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.clipBehavior = Clip.hardEdge,
    this.controller,
    this.dragStartBehavior = DragStartBehavior.start,
    this.itemExtent,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.padding,
    this.physics,
    this.primary,
    this.prototypeItem,
    this.restorationId,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.semanticChildCount,
    this.shrinkWrap = false,
  });

  @override
  State<DragList> createState() => _DragListState();
}

class _DragListState extends State<DragList> {
  List<dynamic> listData = [];
  late final bool Function(Object?) onWillAccept;
  late final void Function(int pos, dynamic data) onItemRemoved;
  late final void Function(int pos, dynamic data) onItemAdded;

  @override
  void initState() {
    listData = List<dynamic>.from(widget.data);
    onWillAccept = widget.onWillAccept ?? (data) => true;
    onItemAdded = widget.onItemAdded ?? (pos, data) {};
    onItemRemoved = widget.onItemRemoved ?? (pos, data) {};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dragTarget = DragTarget(
      onWillAccept: (data) {
        bool cond = data is DraggableListItemData &&
            (data.order == null ||
                listData.length <= data.order! ||
                listData[data.order!] != data.data);
        return cond && onWillAccept(data);
      },
      onAccept: (data) {
        print('wtf');
        data as DraggableListItemData;
        if (data.order == null ||
            listData.length <= data.order! ||
            listData[data.order!] != data.data) {
          _addItem(data.data);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final showContainerCond = candidateData.isNotEmpty &&
            ((candidateData.first as DraggableListItemData).order == null ||
                listData.length <=
                    (candidateData.first as DraggableListItemData).order! ||
                listData[(candidateData.first as DraggableListItemData)
                        .order!] !=
                    (candidateData.first as DraggableListItemData).data);

        final addContainer = Container(
          decoration: BoxDecoration(
            color: showContainerCond ? Colors.grey.withOpacity(0.2) : null,
          ),
          height: 100,
          child: Center(
            child: showContainerCond ? const Icon(Icons.add) : null,
          ),
        );

        return Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.max,
          children: [
            addContainer,
          ],
        );
      },
    );

    return ListView(
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      cacheExtent: widget.cacheExtent,
      clipBehavior: widget.clipBehavior,
      controller: widget.controller,
      dragStartBehavior: widget.dragStartBehavior,
      itemExtent: widget.itemExtent,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      padding: widget.padding,
      physics: widget.physics,
      primary: widget.primary,
      prototypeItem: widget.prototypeItem,
      restorationId: widget.restorationId,
      reverse: widget.reverse,
      scrollDirection: widget.scrollDirection,
      semanticChildCount: widget.semanticChildCount,
      shrinkWrap: widget.shrinkWrap,
      children: [
        for (int i = 0; i < listData.length; i++) ...{
          _addDragTarget(
            widget.onBuildItemFromData(listData[i]),
            listData[i],
            i,
          ),
        },
        dragTarget,
      ],
    );
  }

  Widget _addDragTarget(Widget child, dynamic data, int order) =>
      Builder(builder: (context) {
        final dragTarget = DragTarget(
          onWillAccept: (inputData) {
            bool cond = inputData is DraggableListItemData &&
                data.hashCode !=
                    (inputData as DraggableListItemData).data.hashCode;
            return cond && onWillAccept(data);
          },
          onAccept: (data) {
            data as DraggableListItemData;
            if (data.order != null) {
              _insertItemOnPos(
                  order + (data.order! < order ? 1 : 0), data.data);
            } else {
              _insertItemOnPos(order + 1, data.data);
            }
          },
          builder: (context, candidateData, rejectedData) {
            return child;
          },
        );

        final item = DraggableListItem(
          feedback: child,
          data: data,
          order: order,
          childWhenDragging: Opacity(
            opacity: 0,
            child: child,
          ),
          onDragCompleted: () {
            if (order + 1 < listData.length && listData[order + 1] == data) {
              _destroyDataOnPos(order + 1);
            } else {
              _destroyDataOnPos(order);
            }
          },
          onDragEnd: (details) {
            print("Drag end, ${details.wasAccepted} ${details.offset}");
          },
          child: dragTarget,
        );

        return item;
      });

  void _destroyDataOnPos(int pos) {
    onItemRemoved(pos, listData[pos]);
    setState(() {
      // listData.removeAt(pos);
    });
  }

  void _insertItemOnPos(int pos, dynamic data) {
    onItemAdded(pos, data);
    setState(() {
      listData = widget.data;
      // listData.insert(pos, data);
    });
  }

  void _addItem(dynamic data) {
    onItemAdded(listData.length, data);
    setState(() {
      listData = widget.data;
      // listData.add(data);
    });
  }
}
