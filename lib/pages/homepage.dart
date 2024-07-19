import 'package:bukuharianv2/models/diary.dart';
import 'package:bukuharianv2/models/diary_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final textController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  int selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();

    //ambil data yang sudah ada
    readDiary();
  }

  //buat diary
  void createDiary() {
    showDialog(
      context: context,
      builder: (context) {
        DateTime localSelectedDate = selectedDate;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text("Diary Baru"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  minLines: 1,
                  maxLines: 100,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: localSelectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        localSelectedDate = picked;
                      });
                    }
                  },
                  child: Text(
                    'Tanggal: ${DateFormat('EEE, d MMMM yyyy').format(localSelectedDate)}',
                  ),
                ),
              ],
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  //menambahkan ke db
                  context.read<DiaryDatabase>().addDiary(textController.text, localSelectedDate);

                  //membersihkan controller
                  textController.clear();

                  //pop dialog box
                  Navigator.pop(context);
                },
                child: const Text('Buat'),
              ),
            ],
          ),
        );
      },
    );
  }

  //baca diary
  void readDiary() {
    context.read<DiaryDatabase>().fetchDiary();
  }

  //perbarui diary
  void updateDiary(Diary diary) {
    //munculkan text diary yang ada sekarang
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
              context.read<DiaryDatabase>().updateDiary(diary.id, textController.text);
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

  //hapus diary
  void deleteDiary(int id) {
    context.read<DiaryDatabase>().deleteDiary(id);
  }

  //fitur filter diary
  List<Diary> filterDiaryByMonth(List<Diary> allDiary, int month) {
    return allDiary.where((diary) => diary.date.month == month).toList();
  }

  @override
  Widget build(BuildContext context) {
    // diary database
    final diaryDatabase = context.watch<DiaryDatabase>();

    //current diary
    List<Diary> currentDiary = diaryDatabase.currentDiary..sort((a, b) => b.date.compareTo(a.date));

    // filter isi diary berdasarkan bulan
    currentDiary = filterDiaryByMonth(currentDiary, selectedMonth);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("demo"),
        actions: [
          DropdownButton<int>(
            value: selectedMonth,
            icon: const Icon(Icons.calendar_today),
            items: List.generate(12, (index) => index + 1)
                .map((month) => DropdownMenuItem<int>(
                      value: month,
                      child: Text(DateFormat('MMMM').format(DateTime(2024, month))),
                    ))
                .toList(),
            onChanged: (newMonth) {
              setState(() {
                selectedMonth = newMonth!;
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createDiary,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          //heading
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Buku Harian",
              style: GoogleFonts.josefinSans(
                fontSize: 30.0,
              ),
            ),
          ),

          //daftar diary
          Expanded(
            child: ListView.builder(
              itemCount: currentDiary.length,
              itemBuilder: (context, index) {
                //mengambil data individual
                final diary = currentDiary[index];

                //list tile UI yang bisa di-slide
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
                    subtitle: Text(DateFormat('EEE, d MMMM yyyy').format(diary.date)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
