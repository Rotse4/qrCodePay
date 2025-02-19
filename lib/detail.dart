import 'package:flutter/material.dart';

Widget buildBottomSheet(BuildContext ctx) {
  showModalBottomSheet(
    context: ctx,
    builder: (context) {
      return Container(
        child: Column(
          children: [
            Text("pay:  ammoun"),
            SizedBox(
              height: 20,
            ),
            Text("pay:  ammoun"),
            SizedBox(
              height: 20,
            ),
            Text("pay:  ammoun")
          ],
        ),
      );
    },
  );

  return Container();
}
