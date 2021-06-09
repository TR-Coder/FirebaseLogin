import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static const route = '/HomeScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login screen')),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              child: Text('Sign out'),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return BlocBuilder<TABBLOC.Def, TABBLOC.AppTab>(
  //     builder: (context, activeTab) {
  //       return Scaffold(
  //         appBar: AppBar(
  //           title: Text('Home Screen'),
  //         ),
  //         body: (activeTab == TABBLOC.AppTab.todos) ? ListViewFilteredTodos() : ShowStats(),
  //         floatingActionButton: FloatingActionButton(
  //           child: Icon(Icons.add),
  //           onPressed: () => Navigator.of(context).pushNamed(AddEditScreen.nom),
  //         ),
  //       );
  //     },
  //   );
  // }
}
