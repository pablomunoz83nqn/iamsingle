import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      height: 180,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imgURL,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$description',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '$location',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
