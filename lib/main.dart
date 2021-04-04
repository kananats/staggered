import 'package:flutter/material.dart';
import 'package:staggered/grid_animator.dart';
import 'package:staggered/list_animator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GridViewAnimator(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        //itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.green,
            child: Center(
              child: Text("$index"),
            ),
          );
        },
      ),
    )
        /*body: ListViewAnimator(
        /*child: ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text("Item $index"),
            );
          },
        ),*/
        /*child: ListView(
          children: [
            ListTile(title: Text("Item 0")),
            ListTile(title: Text("Item 1")),
          ],
        ),*/
        child: ListView.separated(
          itemCount: 20,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text("Item $index"),
            );
          },
          separatorBuilder: (context, index) => Divider(),
        ),
      ),*/
        );
  }
}
