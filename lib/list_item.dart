import 'package:flutter/material.dart';

class DraggableListItemData {
  final dynamic data;
  final int? order;
  const DraggableListItemData({
    this.data,
    this.order,
  });

  DraggableListItemData copyWith({
    dynamic data,
    int? order,
  }) =>
      DraggableListItemData(
        data: data ?? this.data,
        order: order ?? this.order,
      );
  DraggableListItemData copyWithNoData({
    int? order,
  }) =>
      DraggableListItemData(
        order: order ?? this.order,
      );
  DraggableListItemData copyWithNoOrder({dynamic data}) =>
      DraggableListItemData(
        data: data ?? data,
      );
}

class DraggableListItem extends Draggable {
  DraggableListItem({
    required super.child,
    required super.feedback,
    super.key,
    int? order,
    dynamic data,
    super.affinity,
    super.axis,
    super.childWhenDragging,
    super.dragAnchorStrategy,
    super.feedbackOffset,
    super.hitTestBehavior,
    super.ignoringFeedbackSemantics,
    super.maxSimultaneousDrags,
    super.onDragCompleted,
    super.onDragEnd,
    super.dragAnchor,
    super.onDragStarted,
    super.onDragUpdate,
    super.onDraggableCanceled,
    super.rootOverlay,
  }) : super(
            data: DraggableListItemData(
          data: data,
          order: order,
        ));
}


