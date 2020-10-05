// Import MaterialApp and other widgets which we can use to quickly create a material app
import 'dart:collection';
import 'package:flutter/material.dart';

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
      return Text(
          todoText,
          style: TextStyle(
            fontSize: 22.0
          ),
      );
    }
    else{
      return Text(
          todoText,
          style: TextStyle(
            fontSize: 22.0,
            decoration: TextDecoration.lineThrough,
            color: Colors.redAccent,
            fontStyle: FontStyle.italic
          ),
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
      setState(() => {_todoItems.add(task), _todoItemsChecked.add(false)});
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
    return CheckboxListTile(
      value: _todoItemsChecked[i],
      onChanged: (bool){
        setState(() {
          if(!bool){
            _todoItemsChecked[i] = false;
          }
          else{
            _todoItemsChecked[i] = true;
          }
        });
      },
      key: Key(_todoItems[i]),
      title: _strikeThrough(todoText: _todoItems[i], todoToggle: _todoItemsChecked[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Todo')
      ),
      body: _buildTodoList(),
      floatingActionButton: new FloatingActionButton(
        onPressed: _pushAddTodoScreen,
        tooltip: 'Add task',
        child: new Icon(Icons.add)
      ),
    );
  }

  void _pushAddTodoScreen() {
    // Push this page onto the stack
    Navigator.of(context).push(
      // MaterialPageRoute will automatically animate the screen entry, as well as adding
      // a back button to close it
      new MaterialPageRoute(
        builder: (context) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Add a new task')
            ),
            body: new TextField(
              autofocus: true,
              onSubmitted: (val) {
                _addTodoItem(val);
                Navigator.pop(context); // Close the add todo screen
              },
              decoration: new InputDecoration(
                hintText: 'Enter something to do...',
                contentPadding: const EdgeInsets.all(16.0)
              ),
            )
          );
        }
      )
    );
  }
}