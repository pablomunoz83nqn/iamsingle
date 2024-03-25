import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novedades_de_campo/src/home/controller/locaciones_bloc/locaciones_bloc.dart';
import 'package:novedades_de_campo/src/home/model/locaciones_model.dart';

class LocacionesView extends StatefulWidget {
  const LocacionesView({Key? key}) : super(key: key);

  @override
  State<LocacionesView> createState() => _LocacionesViewState();
}

class _LocacionesViewState extends State<LocacionesView> {
  @override
  void initState() {
    BlocProvider.of<LocacionesBloc>(context).add(LoadLocaciones());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final LocacionesBloc locacionesBloc =
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
            final locaciones = state.locaciones;
            return ListView.builder(
              itemCount: locaciones.length,
              itemBuilder: (context, index) {
                final todo = locaciones[index];
                return ListTile(
                  title: Text(todo.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      locacionesBloc.add(DeleteLocacion(todo.id));
                    },
                  ),
                );
              },
            );
          } else if (state is LocacionesOperationSuccess) {
            locacionesBloc.add(LoadLocaciones()); // Reload todos
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
          _showAddTodoDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    final _titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Locacion'),
          content: TextField(
            controller: _titleController,
            decoration: const InputDecoration(hintText: 'Todo title'),
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
                final locacion = Locaciones(
                  id: DateTime.now().toString(),
                  name: _titleController.text,
                  yacimiento: "cambiar",
                );
                Navigator.pop(context);
                BlocProvider.of<LocacionesBloc>(context)
                    .add(AddLocacion(locacion));
              },
            ),
          ],
        );
      },
    );
  }
}
