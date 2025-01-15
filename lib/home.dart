import 'dart:async';

import 'package:flutter/material.dart';
import 'package:notes_sqllite/DB_CONFIG/DbConfig.dart';
import 'package:notes_sqllite/util/notification_helper.dart';
import 'package:share_plus/share_plus.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  List<Map<String, dynamic>> allNotes = [];
  DbConfig? dbObj;

  @override
  void initState() {
    super.initState();
    dbObj = DbConfig.getInstance();
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbObj!.getAllNotes();
    setState(() {});
  }

  Future<DateTime?> selectDateTime(BuildContext context) async {
    // Pick a date
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      // Pick a time
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );

      if (selectedTime != null) {
        // Combine the selected date and time into a DateTime object
        return DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      }
    }

    return null; // Return null if the user cancels the input
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          children: const [
            Text(
              'Notes',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.note_alt),
          ],
        ),
        actions: const [],
      ),
      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (_, index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Rounded corners for a smooth look
                        ),
                        tileColor: const Color(0xFFF5E1A4),
                        trailing: SizedBox(
                          // width: 120,
                          child: PopupMenuTheme(
                            data: PopupMenuThemeData(
                              color: Colors.amber
                                  .shade100, // Background color of the menu
                              // elevation: 2,
                              // Shadow of the menu
                            ),
                            child: PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.black,
                                ),
                                onSelected: (value) {},
                                itemBuilder: (BuildContext context) {
                                  return [
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      child: SizedBox(
                                        width: 80,
                                        child: IconButton(
                                            color: Colors.black,
                                            onPressed: () {
                                              setState(() {
                                                _delete(index);
                                              });
                                            },
                                            icon: const Icon(Icons.delete)),
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'edit',
                                      child: SizedBox(
                                        width: 80,
                                        child: IconButton(
                                            color: Colors.black,
                                            onPressed: () {
                                              _editAction(index);
                                            },
                                            icon: const Icon(Icons.edit)),
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'share',
                                      child: SizedBox(
                                        width: 80,
                                        child: IconButton(
                                            onPressed: () {
                                              _share(index);
                                            },
                                            icon: const Icon(
                                              Icons.share,
                                              color: Colors.black,
                                            )),
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'share',
                                      child: SizedBox(
                                        width: 80,
                                        child: IconButton(
                                            onPressed: () {
                                              _alarm(index);
                                            },
                                            icon: const Icon(
                                              Icons.alarm,
                                              color: Colors.black,
                                            )),
                                      ),
                                    ),
                                  ];
                                }),
                          ),
                        ),
                        leading: Text(
                          '${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        title: Text(
                          allNotes[index][DbConfig.COL_TITLE],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                allNotes[index][DbConfig.COL_DESCRIPTION],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                                // textAlign: TextAlign.start,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Added on: ${allNotes[index][DbConfig.COL_DATE_TIME]}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight
                                      .bold, // Smaller font size for the date/time
                                  color: Colors
                                      .black87, // Lighter color for the date
                                ),
                              ),
                            ],
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                    ),
                    if (index < allNotes.length - 1)
                      const Divider(
                        height: 10,
                        // color: Colors.cyanAccent,
                      ),
                  ],
                );
              })
          : const Center(
              child: Text('No Data found yet!!'),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context)
                        .viewInsets
                        .bottom, // Adjust for keyboard visibility
                  ),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Text(
                              'Add Note',
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            TextFormField(
                              controller: titleController,
                              decoration: const InputDecoration(
                                hintText: 'Enter Title',
                                label: Text('Title'),
                                border: OutlineInputBorder(
                                  // This makes the border rectangular
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          10)), // Optional: Add rounded corners
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'title is required'; // Error message when field is empty
                                }
                                return null; // No error
                              },
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            TextFormField(
                              maxLines: 5,
                              controller: descController,
                              decoration: const InputDecoration(
                                hintText: 'Enter Description',
                                label: Text('Description'),
                                border: OutlineInputBorder(
                                  // This makes the border rectangular
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          10)), // Optional: Add rounded corners
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Description is required'; // Error message when field is empty
                                }
                                return null; // No error
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.amberAccent,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              side: const BorderSide(
                                                  width: 4,
                                                  color: Colors.black))),
                                      onPressed: () async {
                                        DateTime now = DateTime.now();
                                        String formattedDateTime =
                                            '${now.toIso8601String().substring(0, 10)} ${now.toIso8601String().substring(11, 19)}';
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          bool check = await dbObj!.addNote(
                                              title: titleController.text,
                                              desc: descController.text,
                                              datetime: formattedDateTime);
                                          if (check) {
                                            getNotes();
                                            titleController.clear();
                                            descController.clear();
                                          }
                                          Navigator.pop(context);
                                        } else {}
                                      },
                                      child: const Text(
                                        'Add Note',
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      )),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.amberAccent,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              side: const BorderSide(
                                                  width: 4,
                                                  color: Colors.black))),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      )),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _delete(index) {
    dbObj!.delete(sno: allNotes[index][DbConfig.COL_SR_NO]);
    getNotes();
  }

  void _share(index) {
    Share.share(
        'Title: ${allNotes[index][DbConfig.COL_TITLE]}\nDescription: ${allNotes[index][DbConfig.COL_DESCRIPTION]}');
  }

  Future<void> _alarm(index) async {
    DateTime? userSelectedDateTime = await selectDateTime(context);
    if (userSelectedDateTime != null) {
      NotificationHelper.scheduledNotification(index, "Gentle Reminder !",
          "${allNotes[index][DbConfig.COL_TITLE]}", userSelectedDateTime);
    }
  }

  // Action for Edit
  void _editAction(index) {
    titleController.text = allNotes[index][DbConfig.COL_TITLE];
    descController.text = allNotes[index][DbConfig.COL_DESCRIPTION];
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom, // Adjust for keyboard visibility
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Edit Note',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Title',
                          label: Text('Title'),
                          border: OutlineInputBorder(
                            // This makes the border rectangular
                            borderRadius: BorderRadius.all(Radius.circular(
                                10)), // Optional: Add rounded corners
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'title is required'; // Error message when field is empty
                          }
                          return null; // No error
                        },
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      TextFormField(
                        maxLines: 5,
                        controller: descController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Description',
                          label: Text('Description'),
                          border: OutlineInputBorder(
                            // This makes the border rectangular
                            borderRadius: BorderRadius.all(Radius.circular(
                                10)), // Optional: Add rounded corners
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Description is required'; // Error message when field is empty
                          }
                          return null; // No error
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: const BorderSide(
                                            width: 4, color: Colors.black))),
                                onPressed: () async {
                                  DateTime now = DateTime.now();
                                  String formattedDateTime =
                                      '${now.toIso8601String().substring(0, 10)} ${now.toIso8601String().substring(11, 19)}';
                                  bool check = await dbObj!.updateNote(
                                      sno: allNotes[index][DbConfig.COL_SR_NO],
                                      title: titleController.text,
                                      desc: descController.text,
                                      datetime: formattedDateTime);

                                  if (check) {
                                    getNotes();
                                    titleController.clear();
                                    descController.clear();
                                  }
                                  Navigator.pop(context);
                                },
                                child: const Text('Update Note')),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: const BorderSide(
                                            width: 4, color: Colors.black))),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel')),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
