import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fintrack/widgets/confirm_dialog.dart';

class SlidableItem extends StatelessWidget {
  final Widget child;
  final String deleteConfirmationText;
  final String itemName;
  final Function onDelete;
  final Function onEdit;

  const SlidableItem({
    super.key,
    required this.child,
    required this.deleteConfirmationText,
    required this.itemName,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(itemName),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(
          onDismissed: () => onDelete(),
          confirmDismiss: () async {
            bool confirm = false;
            await ConfirmDialog.show(
              context: context,
              content: deleteConfirmationText,
              onConfirm: () {
                confirm = true;
              },
            );
            return confirm;
          },
        ),
        children: [
          SlidableAction(
            onPressed: (context) {
              onEdit();
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
          ),
          SlidableAction(
            onPressed: (context) {
              ConfirmDialog.show(
                context: context,
                content: deleteConfirmationText,
                onConfirm: () => onDelete(),
              );
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Hapus',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Widget hanya untuk fitur hapus (tanpa edit)
class SlidableDeleteItem extends StatelessWidget {
  final Widget child;
  final String deleteConfirmationText;
  final String itemName;
  final Function onDelete;

  const SlidableDeleteItem({
    super.key,
    required this.child,
    required this.deleteConfirmationText,
    required this.itemName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(itemName),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(
          onDismissed: () => onDelete(),
          confirmDismiss: () async {
            bool confirm = false;
            await ConfirmDialog.show(
              context: context,
              content: deleteConfirmationText,
              onConfirm: () {
                confirm = true;
              },
            );
            return confirm;
          },
        ),
        children: [
          SlidableAction(
            onPressed: (context) {
              ConfirmDialog.show(
                context: context,
                content: deleteConfirmationText,
                onConfirm: () => onDelete(),
              );
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Hapus',
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
      child: child,
    );
  }
}
 