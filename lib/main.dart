// Import MaterialApp and other widgets which we can use to quickly create a material app
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Code written in Dart starts exectuting from the main function. runApp is part of
// Flutter, and requires the component which will be our app's container. In Flutter,
// every component is known as a "widget".
void main() => runApp(new TodoApp());

class _strikeThrough extends StatelessWidget{
  bool todoToggle;
  String todoText;
  _strikeThrough({this.todoToggle, this.todoText}) : super();

  Widget _strikewidget(){
    if(todoToggle==false){
      return Padding(
        padding: EdgeInsets.only(left: 15.0),
        child: Text(
          todoText,
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w400
          )
        ))
      );
    }
    else{
      return Padding(
        padding: EdgeInsets.only(left: 15.0),
        child: Text(
          todoText,
          style: GoogleFonts.lato(
            textStyle: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.lineThrough,
            color: Colors.blueGrey[200]
          ))
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _strikewidget();
  }
}

// Every component in Flutter is a widget, even the whole app itself
class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Todo',
      home: new TodoList()
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  createState() => new TodoListState();
}

class TodoListState extends State<TodoList> {
  List<String> _todoItems = [];
  List<bool> _todoItemsChecked = [];

  void _addTodoItem(String task) {
    // Only add the task if the user actually entered something
    if(task.length > 0) {
      // Putting our code inside "setState" tells the app that our state has changed, and
      // it will automatically re-render the list
      setState(() => {_todoItems.insert(0, task), _todoItemsChecked.insert(0, false)});
    }
  }

  /*
  void _removeTodoItem(int index) {
    setState(() => {_todoItems.removeAt(index), _todoItemsChecked.removeAt(index)});
  }

  void _promptRemoveTodoItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Mark "${_todoItems[index]}" as done?'),
          actions: <Widget>[
            new FlatButton(
              child: new Text('CANCEL'),
              // The alert is actually part of the navigation stack, so to close it, we
              // need to pop it.
              onPressed: () => Navigator.of(context).pop()
            ),
            new FlatButton(
              child: new Text('MARK AS DONE'),
              onPressed: () {
                _removeTodoItem(index);
                Navigator.of(context).pop();
              }
            )
          ]
        );
      }
    );
  }
  */

  // Build the whole list of todo items
  Widget _buildTodoList() {
    return ReorderableListView(
      children: <Widget>[
        for(var i = 0; i < _todoItems.length; i++)
           _buildTodoItem(i)
      ],
      onReorder:  (OldIndex, NewIndex){
        setState(() {
          if(OldIndex < NewIndex){
            NewIndex -= 1;
          }
          var getReplacedTodoWidget = _todoItems.removeAt(OldIndex);
          _todoItems.insert(NewIndex, getReplacedTodoWidget);
          var getReplacedTodoCheckedWidget = _todoItemsChecked.removeAt(OldIndex);
          _todoItemsChecked.insert(NewIndex, getReplacedTodoCheckedWidget);
        });
      },
    );
  }

  // Build a single todo item
  Widget _buildTodoItem(int i) {
    return Card(
      child: ListTile(
        onTap: (){
          setState(() {
            if(!_todoItemsChecked[i]){
              _todoItemsChecked[i] = true;
            }
            else{
              _todoItemsChecked[i] = false;
            }
          });
        },
        trailing: _todoItemsChecked[i] ? Card(shadowColor: Colors.grey[50], color: Colors.greenAccent, child: Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.done, color: Colors.white, size: 20.0)), elevation:2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0))) : Card(shadowColor: Colors.grey[50], child:  Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.fiber_manual_record, color: Colors.white, size: 20.0)), elevation:2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0))),
        title: _strikeThrough(todoText: _todoItems[i], todoToggle: _todoItemsChecked[i]),
      ),
      key: Key(_todoItems[i]),
      elevation: 5,
      margin: EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      shadowColor: Colors.grey[50],
    );
  }

  @override
  Widget build(BuildContext context) {
    var _controller = TextEditingController();
    var scaffold = new Scaffold(
      appBar: new AppBar(
        title: Text('Todo',
            style: GoogleFonts.lato(
              textStyle: TextStyle(fontSize: 30.0,
              letterSpacing: .5,
              fontWeight: FontWeight.w300,
              color: Colors.black.withOpacity(0.8))),
          ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0
      ),
      body: new ListView(
        children: <Widget>[
          Container(
            child: Card(child: TextField(
              controller: _controller,
              onSubmitted: (String value) => _addTodoItem(value),
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixIcon: IconButton(
                  onPressed: () => {FocusScope.of(context).unfocus(), _addTodoItem(_controller.text)},
                  icon: Icon(Icons.add),
                  color: Colors.grey,
                  iconSize: 25,
                  padding: EdgeInsets.only(right: 20.0),
                ),
                hintText: 'Add task',
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0)
              ),
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400
              )), 
              ),
              elevation: 0,
              margin: EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0),
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
              ),
              color: Colors.blueGrey[50]),
              padding: EdgeInsets.only(bottom: 20),

            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300])))
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            child: _buildTodoList())
        ],
      )
    );
    return scaffold;
  }
}