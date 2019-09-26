import 'package:flutter/material.dart';
import 'dart:async';
import 'package:note_app/models/note.dart';
import 'package:note_app/utils/database_helper.dart';
import 'package:intl/intl.dart';

class Notedetail extends StatefulWidget {

  final String appBarTitle;
  final Note note;

  Notedetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<Notedetail> {
  var _priority = ['High', 'Low'];
  DatabaseHelper databaseHelper = DatabaseHelper();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String appBarTitle;
  Note note;

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
      onWillPop: (){
        moveToLastScreen();
        return null;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(this.appBarTitle),
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              moveToLastScreen();
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            children: <Widget>[
              // priority drop down
              ListTile(
                title: DropdownButton(
                  items: _priority.map((String dropDownStringItem) {
                    return DropdownMenuItem(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(note.priority),
                  onChanged: (valueSelectedByUser) {
                    setState(() {
                      debugPrint('User selected $valueSelectedByUser');
                      updatePriorityAsInt(valueSelectedByUser);
                    });
                  },
                ),
              ),

              // note title text field
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('on changed on title textfield');
                    updateTitle();
                  },
                  decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),

              // note description text field
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('on changed on title textfield');
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),

              // save and delete buttons
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Save',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint("save button clicked");
                            _save();
                          });
                        },
                      ),
                    ),
                    Container(width: 5.0),
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Delete',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint("delete button clicked");
                            _delete();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }

  void moveToLastScreen(){
    Navigator.pop(context, true);
  }

  // convert the string priority to integer
  void updatePriorityAsInt(String value){
    switch(value){
      case 'High': note.priority = 1;
      break;
      case 'Low': note.priority = 2;
      break;
    }
  }

  // convert int priority to string
  String getPriorityAsString (int value){
    String priority;
    switch(value){
      case 1: priority = _priority[0];
      break;
      case 2: priority = _priority[1];
      break;
    }
    return priority;
  }

  //update the title of the note object
  void updateTitle(){
    note.title = titleController.text;
  }

  // update the descripton 
  void updateDescription(){
    note.description = descriptionController.text;
  }

  // save data to database
  void _save() async{
    debugPrint(note.title);
    debugPrint(note.description);

    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result; 
    if(note.id != null){
      // update operation
      result = await databaseHelper.updateNote(note);
    }else{
      // new note inserting operation
      result = await databaseHelper.insertNote(note);
    }
    if(result != 0){
      // success
      _showAlterDialog('Status', 'Note Saved Successfully');
    }else{
      // failure
      _showAlterDialog('Status', 'Problem saving note');
    }
  }

  void _showAlterDialog(String status, String msg){
    AlertDialog alertDialog = AlertDialog(
      title: Text(status),
      content: Text(msg),
    );
    showDialog(
      context: context,
      builder: (_) => alertDialog
    );
  }

  // delete note
  void _delete() async{
    // case 1: if user is trying to delete the new note i.e he has come to 
    // the detail page by pressing the fab of the notelist page
    if(note.id == null){
      _showAlterDialog('Status', 'No Note was deleted');
      return;
    }

    // case 2: user is trying to delete the old note that already has a valid id
    int result = await databaseHelper.deletNote(note.id);
    if(result != 0){
      // success
      _showAlterDialog('Status', 'Note deleted Successfully');
    }else{
      // failure
      _showAlterDialog('Status', 'Problem deleting note');
    }
  }
}


