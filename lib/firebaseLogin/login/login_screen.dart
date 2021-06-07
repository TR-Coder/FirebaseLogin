import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  static const route = '/LoginScreen';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Login Screen')),
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
