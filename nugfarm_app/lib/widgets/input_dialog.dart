import 'package:flutter/material.dart';

Future<String?> showTextInputDialog(BuildContext context, String title) {
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Nama'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
        TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Simpan')),
      ],
    ),
  );
}
