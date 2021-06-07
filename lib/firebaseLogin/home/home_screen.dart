import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  static const route = '/HomeScreen';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('HomeScreen')),
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
