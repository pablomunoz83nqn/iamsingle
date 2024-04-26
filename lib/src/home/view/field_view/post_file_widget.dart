import 'package:expandable/expandable.dart';

import 'package:flutter/material.dart';

class PostTile extends StatefulWidget {
  final String id;
  final String imgURL;
  final String name;
  final String lat;
  final String long;
  final String description;
  final String uploadedBy;
  final Map<String, dynamic> category;
  final String location;
  final String field;
  final String date;
  final String modifiedBy;
  final bool rescued;

  PostTile({
    required this.imgURL,
    required this.location,
    required this.id,
    required this.name,
    required this.lat,
    required this.long,
    required this.description,
    required this.uploadedBy,
    required this.category,
    required this.field,
    required this.date,
    required this.modifiedBy,
    required this.rescued,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card1(context),
    );
  }

  Widget Card1(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.all(5),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            SizedBox(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.rectangle,
                ),
              ),
            ),
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToCollapse: true,
                ),
                header: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    )),
                collapsed: Text(
                  widget.name, //name es yacimiento
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                expanded: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: Image(
                            height: 100,
                            image: NetworkImage(
                              widget.imgURL,
                            )),
                      ),
                      onTap: () {
                        _showDialog(context, widget.imgURL);
                      },
                    ),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          ...widget.category.entries
                              .map((u) => <Widget>[
                                    ListTile(
                                        title: Text(u.key),
                                        subtitle: Text("Cantidad"),
                                        trailing: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween, // added line
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                u.value,
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ])),
                                  ])
                              .expand((element) => element)
                              .toList(),
                        ],
                      ),
                    ),
                  ],
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

void _showDialog(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Title'),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.clear),
            ),
          ],
        ),
      ),
      content: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.fitWidth,
        )),
      ),
    ),
  );
}
