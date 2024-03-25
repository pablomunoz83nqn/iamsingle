import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class SearchElementBar extends StatefulWidget {
  const SearchElementBar({super.key});

  @override
  _SearchElementBarState createState() => _SearchElementBarState();
}

class _SearchElementBarState extends State<SearchElementBar> {
  TextEditingController seachtf = TextEditingController();
  var yacimiento, locacion;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 400,
        height: 200,
        color: Colors.amber,
        child: _dropdownLocation());
  }

  Widget _dropdownLocation() {
    return SizedBox(
      height: 200,
      width: 300,
      child: Column(
        children: [
          Center(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('yacimiento')
                  .orderBy('name')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return Container();

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Row(
                      children: [
                        const Text('Yacimiento: '),
                        const SizedBox(
                          width: 20,
                        ),
                        DropdownButton(
                          underline: Container(),
                          isExpanded: false,
                          value: yacimiento,
                          items: snapshot.data!.docs.map((value) {
                            return DropdownMenuItem(
                              value: value.get('name'),
                              child: Text('${value.get('name')}'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(
                              () {
                                debugPrint('make selected: $value');

                                yacimiento = value;
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Card(
              child: Center(
                child: yacimiento != null
                    ? StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('locaciones')
                            .where('yacimiento', isEqualTo: yacimiento)
                            .orderBy('name')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            debugPrint('snapshot status: ${snapshot.error}');
                            return Text(
                                '$snapshot yacimiento: $yacimiento locacion: $locacion');
                          }
                          List<DropdownMenuItem<Object>>? itemsLocacion =
                              snapshot.data!.docs.map((value) {
                            locacion = value.get("name");

                            debugPrint('Locacion: ${value.get('name')}');

                            //TODO: crear la lista de locaciones en value: q ponga la primera
                            return DropdownMenuItem(
                              value: value.get('name'),
                              child: Text(
                                '${value.get('name')}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList();
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Text('Pad o locación: '),
                                DropdownButton(
                                  isExpanded: false,
                                  value: locacion,
                                  items: itemsLocacion,
                                  onChanged: (value) {
                                    debugPrint('Locacion selected: $value');
                                    setState(
                                      () {
                                        locacion = value;
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : const Text('Seleccione un yacimiento'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
