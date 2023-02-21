import 'package:flutter/material.dart';
import 'package:flutter_sqflite/db/note_db.dart';
import 'package:flutter_sqflite/model/note_model.dart';
import 'package:intl/intl.dart';

class NoteDetails extends StatefulWidget {
  const NoteDetails(this. id, {super.key});

  final int? id;

  @override
  State<NoteDetails> createState() => _NoteDetailsState();
}

class _NoteDetailsState extends State<NoteDetails> {
  late NoteModel note;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refresh();
  }

  Future<void> refresh() async {
    setState(() => isLoading = true);

    note = await NoteDB.instance.readNote(widget.id!);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Note Details'),
      ),
      body: isLoading
      ? const Center(child: CircularProgressIndicator(),)
      : ListTile(
          title: Text(note.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat.yMMMd().format(note.date), style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey.shade600)),
              Text(note.description)
            ],
          ),
        )
    );
  }
}
