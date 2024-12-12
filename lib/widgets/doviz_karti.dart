import 'package:exchangedemo/config/palette.dart';
import 'package:flutter/material.dart';

class DovizKarti extends StatelessWidget {
  final Function() onTap;
  final String doviz;
  final Map<String, dynamic>? dovizPariteleri;

  const DovizKarti({
    super.key,
    required this.onTap,
    required this.doviz,
    this.dovizPariteleri,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Palette.doaTuruncu,
          child: Text(
            doviz,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          dovizPariteleri![doviz]?.toStringAsFixed(2) ?? 'N/A',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 20,
          color: Palette.doaKoyuTuruncu,
        ),
      ),
    );
  }
}
