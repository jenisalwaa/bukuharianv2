import 'package:isar/isar.dart';

part 'diary.g.dart';

@collection
class Diary {
  Id id = Isar.autoIncrement;

  late String text;
  late DateTime date;

}
