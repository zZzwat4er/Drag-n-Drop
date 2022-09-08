import 'package:drag_n_drop_list/list_item.dart';
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

  final Widget Function(Object data) onBuildItemFromData;
  final bool Function(Object? data)? onWillAccept;

  const DragList({
    this.data = const [],
    required this.onBuildItemFromData,
    this.onWillAccept,
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

  @override
  void initState() {
    listData = widget.data;
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
        final willAccept = widget.onWillAccept ?? (data) => true;
        return cond && willAccept(data);
      },
      onAccept: (data) {
        data as DraggableListItemData;
        if (data.order == null ||
            listData.length <= data.order! ||
            listData[data.order!] != data.data) {
          setState(() {
            listData.add(data.data);
          });
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
        final dataContainer = Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
              ),
            ],
          ),
          child: child,
        );

        final dragTarget = DragTarget(
          onWillAccept: (data) {
            bool cond = data is DraggableListItemData;
            final willAccept = widget.onWillAccept ?? (data) => true;
            return cond && willAccept(data);
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
            return dataContainer;
          },
        );

        final item = DraggableListItem(
          feedback: dataContainer,
          data: data,
          order: order,
          childWhenDragging: Opacity(
            opacity: 0,
            child: dataContainer,
          ),
          onDragCompleted: () {
            if (order + 1 < listData.length && listData[order + 1] == data) {
              _destroyDataOnPos(order + 1);
            } else {
              _destroyDataOnPos(order);
            }
          },
          child: dragTarget,
        );

        return item;
      });

  void _destroyDataOnPos(int pos) {
    setState(() {
      listData.removeAt(pos);
    });
  }

  void _insertItemOnPos(int pos, dynamic data) {
    setState(() {
      listData.insert(pos, data);
    });
  }
}
