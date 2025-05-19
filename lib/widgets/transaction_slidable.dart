import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fintrack/widgets/confirm_dialog.dart';

class TransactionSlidable extends StatelessWidget {
  final Widget child;
  final String deleteConfirmationText;
  final String transactionName;
  final Function onDelete;

  const TransactionSlidable({
    super.key,
    required this.child,
    required this.deleteConfirmationText,
    required this.transactionName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(transactionName),
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
