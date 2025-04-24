import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_02/BTNoteManagement/Model/Note.dart';

class NoteItem extends StatelessWidget {
  final Note note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteItem({
    Key? key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color priorityColor = Colors.grey;
    if (note.priority == 1) {
      priorityColor = Colors.red;
    } else if (note.priority == 2) {
      priorityColor = Colors.orange;
    } else if (note.priority == 3) {
      priorityColor = Colors.green;
    }

    Color? noteColor;
    if (note.color != null && note.color!.isNotEmpty) {
      final colorString = note.color!;
      final hexColor = int.tryParse(colorString.substring(1), radix: 16);
      if (hexColor != null) {
        noteColor = Color(hexColor);
      }
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: noteColor, // Đặt màu nền của Card
      child: ListTile(
        // ... phần leading, title, subtitle, trailing giữ nguyên ...
        title: Text(note.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.tags != null && note.tags!.isNotEmpty)
              Text(
                'Tags: ${note.tags!.join(', ')}',
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.black),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Xác nhận xoá'),
                    content: Text('Bạn có chắc chắn muốn xoá ghi chú này?'),
                    actions: [
                      TextButton(
                        child: Text('Huỷ'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        child: Text('Xoá'),
                        onPressed: () {
                          onDelete();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}