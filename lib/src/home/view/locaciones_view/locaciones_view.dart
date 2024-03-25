import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novedades_de_campo/src/home/controller/locaciones_bloc/locaciones_bloc.dart';
import 'package:novedades_de_campo/src/home/model/locaciones_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    BlocProvider.of<LocacionesBloc>(context).add(LoadLocaciones());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final LocacionesBloc _locacionesBloc =
        BlocProvider.of<LocacionesBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore'),
      ),
      body: BlocBuilder<LocacionesBloc, LocacionesState>(
        builder: (context, state) {
          if (state is LocacionesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LocacionesLoaded) {
            final todos = state.locaciones;
            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  title: Text(todo.name),
                  /*   leading: Checkbox(
                        value: todo.name,
                        onChanged: (value) {
                          final updatedLocaciones = todo.copyWith(completed: value);
                          _locacionesBloc.add(UpdateLocacion(updatedLocaciones));
                        },
                      ), */
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _locacionesBloc.add(DeleteLocacion(todo.id));
                    },
                  ),
                );
              },
            );
          } else if (state is LocacionesOperationSuccess) {
            _locacionesBloc.add(LoadLocaciones()); // Reload todos
            return Container(); // Or display a success message
          } else if (state is LocacionesError) {
            return Center(child: Text(state.errorMessage));
          } else {
            return Container();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddLocacionesDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddLocacionesDialog(BuildContext context) {
    final _titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Locaciones'),
          content: TextField(
            controller: _titleController,
            decoration: const InputDecoration(hintText: 'Locaciones title'),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                final todo = Locaciones(
                  id: DateTime.now().toString(),
                  name: _titleController.text,
                  yacimiento: "Loma campana",
                );
                BlocProvider.of<LocacionesBloc>(context).add(AddLocacion(todo));
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
