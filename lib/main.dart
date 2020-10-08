// Import MaterialApp and other widgets which we can use to quickly create a material app
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

// Code written in Dart starts exectuting from the main function. runApp is part of
// Flutter, and requires the component which will be our app's container. In Flutter,
// every component is known as a "widget".
void main() => runApp(new TodoApp());

typedef void SizeChangedCallBack(Size newSize);

class LayoutSizeChangeNotification extends LayoutChangedNotification {
  LayoutSizeChangeNotification(this.newSize):super();
  Size newSize;
}

class LayoutSizeChangeNotifier extends SingleChildRenderObjectWidget {
  /// Creates a [SizeChangedLayoutNotifier] that dispatches layout changed
  /// notifications when [child] changes layout size.
  const LayoutSizeChangeNotifier({
    Key key,
    Widget child
  }) : super(key: key, child: child);

  @override 
  _SizeChangeRenderWithCallback createRenderObject(BuildContext context) {
    return new _SizeChangeRenderWithCallback(
      onLayoutChangedCallback: (size) {
        new LayoutSizeChangeNotification(size).dispatch(context);
      }
    );
  }
}

class _SizeChangeRenderWithCallback extends RenderProxyBox {
  _SizeChangeRenderWithCallback({
    RenderBox child,
    @required this.onLayoutChangedCallback
  }): assert(onLayoutChangedCallback != null),
        super(child);

  /// There's a 1:1 relationship between the _RenderSizeChangedWithCallback and
  /// the 'context; that is captured by the closure created by createRenderObject
  /// above to assign to onLayoutChangedCallback, and thus we know that the
  /// onLayoutChangedCallback will never change nor need to change.

  final SizeChangedCallBack onLayoutChangedCallback;

  Size _oldSize;

  @override 
  void performLayout() {
    super.performLayout();
    // Don't sent the initial notification, or this will be SizeObserver all
    // over again!
    if (size != _oldSize)
      onLayoutChangedCallback(size);
    _oldSize = size;
  }
}

class ActionItems extends Object {
  ActionItems({@required this.icon, @required this.onPress, this.backgroundColor:Colors.grey}) {
    assert(icon != null);
    assert(onPress != null);
  }

  final Widget icon;
  final VoidCallback onPress;
  final Color backgroundColor;
}

class OnSlide extends StatefulWidget {
  OnSlide({Key key, @required this.items, @required this.child, this.backgroundColor:Colors.white}):super(key:key){
    assert(items.length <= 6);
  }

  final List<ActionItems> items;
  final Widget child;
  final Color backgroundColor;

  @override 
  State<StatefulWidget> createState() {
    return new _OnSlideState();
  }
}

class _OnSlideState extends State<OnSlide> {
  ScrollController controller = new ScrollController();
  bool isOpen = false;

  Size childSize;

  @override 
  void initState() {
    super.initState();
  }

  bool _handleScrollNotification(dynamic notification) {
    if (notification is ScrollEndNotification) {
      if (notification.metrics.pixels >= (widget.items.length * 70.0)/2
      && notification.metrics.pixels < widget.items.length * 70.0) {
        scheduleMicrotask((){
          controller.animateTo(widget.items.length * 60.0, duration: new Duration(milliseconds: 600), curve: Curves.decelerate);
        });
      } else if (notification.metrics.pixels > 0.0 && notification.metrics.pixels < (widget.items.length * 70.0)/2) {
        scheduleMicrotask((){
          controller.animateTo(0.0, duration: new Duration(milliseconds: 600), curve: Curves.decelerate);
        });
      }
    }
    return true;
  }

  @override 
  Widget build(BuildContext context) {
    if (childSize == null) {
      return new NotificationListener(
        child: new LayoutSizeChangeNotifier(
          child: widget.child,
        ),
        onNotification: (LayoutSizeChangeNotification notification) {
          childSize = notification.newSize;
          scheduleMicrotask((){
            setState(() {});
          });
        },
      );
    }

    List<Widget> above = <Widget>[new Container(
      width: childSize.width,
      height: childSize.height,
      color: widget.backgroundColor,
      child: widget.child)];
    List<Widget> under = <Widget>[];

    for (ActionItems item in widget.items) {
      under.add(
        new Container(
          alignment: Alignment.center,
          color: item.backgroundColor,
          width: 60.0,
          height: childSize.height,
          child: item.icon)
      );
      above.add( 
        new InkWell( 
          child: new Container( 
            alignment: Alignment.center,
            width: 60.0,
            height: childSize.height
          ),
          onTap: () {
            controller.jumpTo(2.0);
            item.onPress();
          }
        )
      );
    }

    Widget items = new Container(
      width: childSize.width,
      height: childSize.height,
      color: widget.backgroundColor,
      child: new Row( 
        mainAxisAlignment: MainAxisAlignment.end,
        children: under
      )
    );

    Widget scrollview = new NotificationListener( 
      child: new ListView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        children: above
      ),
      onNotification: _handleScrollNotification,
    );

    return new Stack(
      children: <Widget>[ 
        items, 
        new Positioned(child: scrollview, left: 0.0, bottom: 0.0, right: 0.0, top: 0.0)
      ],
    );
  }
}
class _strikeThrough extends StatelessWidget {
  bool todoToggle;
  String todoText;
  _strikeThrough({this.todoToggle, this.todoText}) : super();

  Widget _strikewidget() {
    if(todoToggle==false) {
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

  // Build the whole list of todo items
  Widget _buildTodoList() {
    return ReorderableListView(
      children: <Widget>[
        for(var i = 0; i < _todoItems.length; i++)
           _buildTodoItem(i)
      ],
      onReorder:  (OldIndex, NewIndex) {
        setState(() {
          if(OldIndex < NewIndex) {
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
    return OnSlide(
      key: Key(_todoItems[i]),
      items: <ActionItems>[ 
        ActionItems(
          icon: new IconButton(
            icon: new Icon(Icons.edit),
            onPressed: () {},
            color: Colors.green),
          onPress: () {},
          backgroundColor: Colors.white),
        ActionItems(
          icon: new IconButton(
            icon: new Icon(Icons.star),
            onPressed: () {},
            color: Colors.yellow),
          onPress: () => {},
          backgroundColor: Colors.white),
        ActionItems(
          icon: new IconButton( 
            icon: new Icon(Icons.delete),
            onPressed: () {},
            color: Colors.red),
            onPress: () => _promptRemoveTodoItem(i),
          backgroundColor: Colors.white)
      ],
      child: Container(child: Card(
        child: ListTile(
          onTap: (){
            setState(() {
              if(!_todoItemsChecked[i]) {
                _todoItemsChecked[i] = true;
              } else {
                _todoItemsChecked[i] = false;
              }
            });
          },
          trailing: _todoItemsChecked[i] ? Card(shadowColor: Colors.grey[50], color: Colors.greenAccent, child: Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.done, color: Colors.white, size: 20.0)), elevation:2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0))) : Card(shadowColor: Colors.grey[50], child:  Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.fiber_manual_record, color: Colors.white, size: 20.0)), elevation:2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0))),
          title: _strikeThrough(todoText: _todoItems[i], todoToggle: _todoItemsChecked[i]),
        ),
        elevation: 5,
        margin: EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
        ),
        shadowColor: Colors.grey[50],
      ), height: 80, padding: EdgeInsets.only(bottom: 10))
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