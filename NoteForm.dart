import 'package:flutter/material.dart';
import 'package:app_02/BTNoteManagement/Model/Note.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class NoteForm extends StatefulWidget {
  final Note? note; // Null if creating new note, not null if editing
  final Function(Note note) onSave;

  const NoteForm({
    Key? key,
    this.note,
    required this.onSave,
  }) : super(key: key);

  @override
  _NoteFormState createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int _priority = 1; // Default priority
  Color _selectedColor = Colors.white; // Default color
  List<String> _tags = [];
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _priority = widget.note!.priority;
      _selectedColor = widget.note!.color != null
          ? Color(int.parse(widget.note!.color!.substring(1, 9), radix: 16))
          : Colors.white;
      _tags = widget.note!.tags ?? [];
    }  else {
      // Đặt giá trị mặc định cho trường hợp tạo note mới (nếu cần)
      _selectedColor = Colors.white;
      _priority = 1;
      _tags = [];
      _titleController.text = '';
      _contentController.text = '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final note = Note(
        id: widget.note?.id,
        title: _titleController.text,
        content: _contentController.text,
        priority: _priority,
        createdAt: widget.note?.createdAt ?? now.toIso8601String(),
        modifiedAt: now.toIso8601String(),
        tags: _tags,
        color: '#${_selectedColor.value.toRadixString(16).padLeft(8, '0')}',
      );

      widget.onSave(note);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Cập nhật ghi chú' : 'Thêm ghi chú mới'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Nội dung'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nội dung';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Ưu tiên: '),
                  Radio<int>(
                    value: 1,
                    groupValue: _priority,
                    onChanged: (value) => setState(() => _priority = value!),
                  ),
                  Text('Cao'),
                  Radio<int>(
                    value: 2,
                    groupValue: _priority,
                    onChanged: (value) => setState(() => _priority = value!),
                  ),
                  Text('Trung bình'),
                  Radio<int>(
                    value: 3,
                    groupValue: _priority,
                    onChanged: (value) => setState(() => _priority = value!),
                  ),
                  Text('Thấp'),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Màu sắc: '),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Chọn màu'),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: _selectedColor,
                                onColorChanged: (color) {
                                  setState(() => _selectedColor = color);
                                },
                                pickerAreaHeightPercent: 0.8,
                              ),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                child: const Text('Chọn'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      color: _selectedColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 8.0,
                children: _tags.map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () {
                    setState(() {
                      _tags.remove(tag);
                    });
                  },
                )).toList(),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tagController,
                      decoration: InputDecoration(labelText: 'Nhãn'),
                      onFieldSubmitted: (value) {
                        setState(() {
                          if (value.isNotEmpty) {
                            _tags.add(value);
                            _tagController.clear();
                          }
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        if (_tagController.text.isNotEmpty) {
                          _tags.add(_tagController.text);
                          _tagController.clear();
                        }
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(
                    isEditing ? 'CẬP NHẬT' : 'THÊM MỚI',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}