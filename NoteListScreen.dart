import 'package:flutter/material.dart';
import 'package:app_02/BTNoteManagement/Model/Note.dart';
import 'package:app_02/BTNoteManagement/DatabaseHelper/NoteDatabaseHelper.dart';
import 'package:app_02/BTNoteManagement/UI/NoteItem.dart';
import 'package:app_02/BTNoteManagement/UI/NoteDetailScreen.dart';
import 'package:app_02/BTNoteManagement/UI/NoteForm.dart';

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  late Future<List<Note>> _notesFuture;
  bool _isGrid = false;
  int _priorityFilter = 0; // 0: All, 1, 2, 3: priority
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    setState(() {
      if (_priorityFilter == 0) {
        _notesFuture = NoteDatabaseHelper.instance.getAllNotes();
      } else {
        _notesFuture = NoteDatabaseHelper.instance.getNotesByPriority(_priorityFilter);
      }
    });
  }

  Future<void> _searchNotes() async {
    setState(() {
      _notesFuture = NoteDatabaseHelper.instance.searchNotes(_searchQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách ghi chú'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshNotes,
          ),
          PopupMenuButton<int>(
            onSelected: (value) {
              setState(() {
                _priorityFilter = value;
                _refreshNotes();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 0, child: Text('Tất cả')),
              PopupMenuItem(value: 1, child: Text('Ưu tiên cao')),
              PopupMenuItem(value: 2, child: Text('Ưu tiên trung bình')),
              PopupMenuItem(value: 3, child: Text('Ưu tiên thấp')),
            ],
          ),
          /*IconButton(
            icon: Icon(_isGrid ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGrid = !_isGrid;
              });
            },
          ),*/
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                _searchQuery = value;
                _searchNotes();
              },
              decoration: InputDecoration(
                labelText: 'Tìm kiếm',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Note>>(
              future: _notesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('Không có ghi chú nào'),
                  );
                } else {
                  return _isGrid
                      ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final note = snapshot.data![index];
                      return NoteItem(
                        note: note,
                        onDelete: () async {
                          await NoteDatabaseHelper.instance.deleteNote(note.id!);
                          _refreshNotes();
                        },
                        onEdit: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteDetailScreen(note: note),
                            ),
                          );
                        },
                      );
                    },
                  )
                      : ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final note = snapshot.data![index];
                      return NoteItem(
                        note: note,
                        onDelete: () async {
                          await NoteDatabaseHelper.instance.deleteNote(note.id!);
                          _refreshNotes();
                        },
                        onEdit: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteDetailScreen(note: note),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteForm(
                onSave: (newNote) async {
                  await NoteDatabaseHelper.instance.insertNote(newNote);
                  _refreshNotes(); // Tải lại danh sách sau khi thêm note
                  Navigator.pop(context); // Đóng màn hình tạo note
                },
              ),
            ),
          );
        },
      ),
    );
  }
}