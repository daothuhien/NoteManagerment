import "dart:io";
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_02/BTNoteManagement/Model/Note.dart';
import 'package:app_02/BTNoteManagement/DatabaseHelper/NoteDatabaseHelper.dart';
import 'package:app_02/BTNoteManagement/UI/NoteForm.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết ghi chú'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Divider(),

            SizedBox(height: 15),

            Text(note.content),

            SizedBox(height: 15),

            if (note.tags != null && note.tags!.isNotEmpty)
              Text('Tags: ${note.tags!.join(', ')}',
                style: TextStyle(color: Colors.blue),
              ),

            SizedBox(height: 16),
            Divider(),

              Text('Ngày tạo: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(note.createdAt))}',
                style: TextStyle(color: Colors.grey),
              ),
              Text('Ngày chỉnh sửa cuối: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(note.modifiedAt))}',
                style: TextStyle(color: Colors.grey),
              ),

            SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteForm(
                      note: note, // Truyền note hiện tại vào NoteForm
                      onSave: (updatedNote) async {
                        await NoteDatabaseHelper.instance.updateNote(updatedNote);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        // Cập nhật lại danh sách ghi chú nếu cần
                      },
                    ),
                  ),
                );
              },
              child: Text('Chỉnh sửa'),
            ),
          ],
        ),
      ),
    );
  }
}