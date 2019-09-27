import 'package:flutter/material.dart';
import 'package:note_app/screens/note_detail.dart';
import 'package:note_app/models/note.dart';
import 'package:note_app/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList>{

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {

    if(noteList == null){
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text('Notes'),
        centerTitle: false,
      ),

      // note list view
      body: getNoteListView(),

      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      // floating action button
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          debugPrint('Fap clicked');
          navigateToNoteDetail(Note('','',2),'Add Note');
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 50.0,
          color: Colors.transparent,
          child: Center(
            child: RaisedButton(
              child: Text('Owner'), 
              onPressed: () {

              },
            )
          )
        ),
      ),
    );
  }

  ListView getNoteListView(){
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position){
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(this.noteList[position].priority),
              child: getPriorityIcon(this.noteList[position].priority),
            ),
            title: Text(this.noteList[position].title, style: titleStyle,),
            subtitle: Text(this.noteList[position].date),
            trailing: GestureDetector(
              child: Icon(Icons.delete, color: Colors.grey,),
              onTap:(){ 
                _delete(context, noteList[position]);
              }
            ),
            onTap: (){
              debugPrint('Tapped Note List');
              navigateToNoteDetail(this.noteList[position],'Edit Notes');
            },
          ),
        );
      },
    );
  }

  // return the priority color
  Color getPriorityColor(int priority){
    switch(priority){
      case 1: return Colors.red;
      break;
      case 2: return Colors.yellow;
      break;

      default: 
      return Colors.yellow;
    }
  }

  // return getPriorityIcon
  Icon getPriorityIcon(int priority){
    switch(priority){
      case 1: return Icon(Icons.play_arrow);
      break;
      case 2: return Icon(Icons.keyboard_arrow_right);
      break;
      default:
      return Icon(Icons.keyboard_arrow_right);
    }
  }

  // call delete
  void _delete(BuildContext context, Note note) async{
    int result = await databaseHelper.deletNote(note.id);
    if(result != 0){
      _showSnackBar(context, 'Note Deleted Successfully');
      // to do update the list view
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message){
    var snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToNoteDetail(Note note, String title) async{
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context){
      return Notedetail(note, title);
    }));

    if(result){
      updateListView();
    }
  }

  void updateListView(){
    Future<Database> dbfuture = databaseHelper.initializeDatabase();
    dbfuture.then((database){
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList){
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}