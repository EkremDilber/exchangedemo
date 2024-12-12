import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GeriButonu extends StatelessWidget {
  const GeriButonu({super.key});

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoNavigationBarBackButton(
            onPressed: () {
              Navigator.pop(context);
            },
            previousPageTitle: "Geri",
            color: Colors.white,
          )
        : BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.white,
          );

    /* Padding(
            padding: const EdgeInsets.all(9),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Palette.acikGri,
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 24,
                  color: Colors.blue,
                ),
              ),
            ),
          ); */
  }
}
