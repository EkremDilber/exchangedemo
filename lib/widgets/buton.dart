import 'package:flutter/material.dart';

class Buton extends StatelessWidget {
  final Function() onPressed;
  final Color arkaPlanRengi;
  final String butonMetni;

  const Buton({
    super.key,
    required this.onPressed,
    required this.arkaPlanRengi,
    required this.butonMetni,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        backgroundColor: arkaPlanRengi,
        fixedSize: Size(
          MediaQuery.of(context).size.width * 0.9,
          50,
        ),
        elevation: 2,
      ),
      child: Text(
        butonMetni,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
