import 'package:expandable/expandable.dart';

import 'package:flutter/material.dart';
import 'package:novedades_de_campo/src/home/model/posts_model.dart';

class PostTile extends StatefulWidget {
  final Posts post;

  PostTile({required this.post});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: card(context),
    );
  }

  Widget card(BuildContext context) {
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
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      widget.post.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    )),
                collapsed: Text(
                  widget.post.name, //name es yacimiento
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
                              widget.post.imgURL,
                            )),
                      ),
                      onTap: () {
                        _showDialog(context, widget.post.imgURL);
                      },
                    ),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          ...widget.post.category.entries
                              .map((u) => <Widget>[
                                    ListTile(
                                        title: Text(u.key),
                                        subtitle: const Text("Cantidad"),
                                        trailing: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween, // added line
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                u.value.toString(),
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
                    IconButton(
                        onPressed: () => Navigator.pushNamed(context, '/edit',
                            arguments: widget.post),
                        icon: const Icon(Icons.edit_note))
                  ],
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 10),
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
