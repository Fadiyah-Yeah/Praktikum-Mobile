import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.menu_rounded),
          title: Text(
            'My App',
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          elevation: 5,
          backgroundColor: const Color.fromARGB(255, 240, 125, 255),
          actions: [
            IconButton(
              onPressed: () {
                print('Search button pressed');
              },
              icon: Icon(Icons.search),
            ),
          ],
        ), // appbar
        body: Center(
          child: GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ), 
             itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(child: Text("$index"),),
                title: Text('Item $index'),
                subtitle: Text('Subtitle $index'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  print('Tapped on item $index');
                },
              );
            },
            itemCount: 20,
          )


          // child: ListView.builder(
          //   itemBuilder: (context, index) {
          //     return ListTile(
          //       leading: CircleAvatar(child: Text("$index"),),
          //       title: Text('Item $index'),
          //       subtitle: Text('Subtitle $index'),
          //       trailing: Icon(Icons.arrow_forward_ios),
          //       onTap: () {
          //         print('Tapped on item $index');
          //       },
          //     );
          //   },
          //   itemCount: 20,

            // child: ListView(
            //   children:[
            //     Container(
            //       padding: EdgeInsets.all(10),
            //       child: Text(
            //         'Hello, World!',
            //         style: TextStyle(fontSize: 24, color: const Color.fromARGB(255, 174, 54, 254), fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
            //       ),
            //     ),

            //     Container(
            //       padding: EdgeInsets.all(10),
            //       child: Text(
            //         'Lalalalalal',
            //         style: TextStyle(fontSize: 12, color: const Color.fromARGB(255, 174, 54, 254), fontStyle: FontStyle.normal),
            //       ),
            //     )
            //   ],
            // ),

            // child: SingleChildScrollView(
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Container(
            //         child:
            //        Text(
            //         'Hello, World!',
            //         style: TextStyle(fontSize: 24, color: const Color.fromARGB(255, 174, 54, 254), fontStyle: FontStyle.italic),
            //       ),),

            //      Container(
            //         child:
            //       Text(
            //         'Welcome to my app.',
            //         style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 237, 54, 254), fontStyle: FontStyle.normal),
            //       ),
            //      ),
            //      TextButton(
            //         onPressed: () {},
            //         child: Text('Text Button'),
            //       ),

            //       Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: TextField(
            //           decoration: InputDecoration(
            //             labelText: 'Enter your name',
            //             border: OutlineInputBorder(),
            //           ),
            //         ),
            //       ),
            //       ElevatedButton(
            //         onPressed: () {},
            //         child: Icon(Icons.add),
            //       ),
            //     ],

            //   ),
            // ),
          ), // body
        ),// scaffold
    ); // materialapp
  } // build
} // MyApp
