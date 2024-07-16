import 'package:bukuharianv2/components/date_provider.dart';
import 'package:bukuharianv2/models/diary.dart';
import 'package:bukuharianv2/models/diary_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final textController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    readDiary();
  }

  void createDiary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Diary Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              maxLines: 100,
              minLines: 1,
            ),
            const SizedBox(height: 10.0),
            Consumer<DateProvider>(
              builder: (context, dateProvider, child) => OutlinedButton(
                onPressed: () {
                  DatePicker.showDatePicker(
                    context,
                    showTitleActions: true,
                    minTime: DateTime(2016, 1, 1),
                    maxTime: DateTime(2100, 12, 31),
                    // Update selectedDate using DateProvider
                    onSelect: (date) => dateProvider.changeSelectedDate(date),
                  );
                },
                child: Text(
                  selectedDate.toIso8601String(),
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              context
                  .read<DiaryDatabase>()
                  .addDiary(textController.text, selectedDate);
              textController.clear();
              Navigator.pop(context);
            },
            child: const Text('Buat'),
          ),
        ],
      ),
    );
  }

  void readDiary() {
    context.read<DiaryDatabase>().fetchDiary();
  }

  void updateDiary(Diary diary) {
    textController.text = diary.text;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Perbarui Diary"),
        content: TextField(controller: textController),
        actions: [
          //munculkan tombol update
          MaterialButton(
            onPressed: () {
              //perbarui data di db
              context
                  .read<DiaryDatabase>()
                  .updateDiary(diary.id, textController.text);
              //clear controller
              textController.clear();
              //pop dialog box
              Navigator.pop(context);
            },
            child: const Text("Perbarui"),
          ),
        ],
      ),
    );
  }

  void deleteDiary(int id) {
    context.read<DiaryDatabase>().deleteDiary(id);
  }

  @override
  Widget build(BuildContext context) {
    final diaryDatabase = context.watch<DiaryDatabase>();
    final currentDiary = diaryDatabase.currentDiary;

    return ChangeNotifierProvider<DateProvider>(
      create: (context) => DateProvider(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("demo"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: createDiary,
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Buku Harian",
                style: GoogleFonts.josefinSans(
                  fontSize: 30.0,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: currentDiary.length,
                itemBuilder: (context, index) {
                  final diary = currentDiary[index];
                  return Slidable(
                    key: ValueKey(diary.id),
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) => updateDiary(diary),
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.black,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                        SlidableAction(
                          onPressed: (context) => deleteDiary(diary.id),
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.black,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(diary.text),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
