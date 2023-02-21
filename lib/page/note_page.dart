import 'package:flutter/material.dart';
import 'package:flutter_sqflite/db/note_db.dart';
import 'package:flutter_sqflite/model/note_model.dart';
import 'package:flutter_sqflite/page/note_details.dart';
import 'package:intl/intl.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  late List<NoteModel> notes;
  bool isLoading = false;
  final titleEditingController = TextEditingController();
  final commentEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    refreshNotes();
  }

  @override
  void dispose() async {
    super.dispose();

    NoteDB.instance.close();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);

    notes = await NoteDB.instance.readAllNotes();

    setState(() => isLoading = false);
  }

  void _addNote() {
    if(titleEditingController.text.isEmpty && commentEditingController.text.isEmpty) return;

    final data = NoteModel(
      title: titleEditingController.text,
      description: commentEditingController.text,
      date: DateTime.now()
    );

    NoteDB.instance.createNote(data);
    refreshNotes();
    Navigator.pop(context);
  }

  void _editNote(item) {
    if(titleEditingController.text.isEmpty && commentEditingController.text.isEmpty) return;

    final data = NoteModel(
      id: item.id,
      title: titleEditingController.text,
      description: commentEditingController.text,
      date: DateTime.now()
    );

    NoteDB.instance.updateNote(data);
    refreshNotes();
    Navigator.pop(context);
  }

  Future<void> _showAlert(bool isEdit, item) async {
    if(isEdit) {
      final NoteModel noteDate =  item;

      titleEditingController.text = noteDate.title;
      commentEditingController.text = noteDate.description;
    } else {
      titleEditingController.text = '';
      commentEditingController.text = '';
    }

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Notes'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleEditingController,
                decoration: const InputDecoration(
                  hintText: 'Add Notes'
                ),
              ),
              TextField(
                controller: commentEditingController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add Comments'
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => isEdit ? _editNote(item) : _addNote(),
              child: Text( isEdit ? 'Edit' : 'Add'),
            ),
          ],
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note'),
        centerTitle: true,
      ),
      body: isLoading
      ? const Center(child: CircularProgressIndicator(),)
      : notes.isEmpty
        ? const Center(child: Text('Not Data Found'),)
        : ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final item = notes[index];
            final dateFormat = DateFormat.yMMMd().format(item.date);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8),
              child: Card(
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NoteDetails(item.id),)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0,),
                    child: ListTile(
                      horizontalTitleGap: 0,
                      minVerticalPadding: 0,
                      contentPadding: const EdgeInsets.only(left: 16),
                      title: Text(item.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dateFormat, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey.shade600)),
                          Text(item.description, style: const TextStyle(overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        onSelected: (value) async {
                          if(value == 0) _showAlert(true, item);
                          if(value == 1) {
                            await NoteDB.instance.removeNote(item.id!);
                            refreshNotes();
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry> [
                          const PopupMenuItem(
                            value: 0,
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 1,
                            child: Text('Delete'),
                          ),
                        ]
                      ),
                    ),
                  ),
                )
              ),
            );
          }
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAlert(false, ''),
        child: const Icon(Icons.add),
      ),
    );
  }
}
