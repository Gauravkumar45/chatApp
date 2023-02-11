import 'package:flutter/material.dart';

class UserTile extends StatefulWidget {
  final String userName;
  final String userId;
  const UserTile({Key? key, required this.userName,required this.userId}) : super(key: key);

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.userId),
      subtitle: Text(widget.userName),
    );
  }
}
