import 'package:flutter/material.dart';

class BreadcrumbItem {
  final String label;
  final String routeName;
  BreadcrumbItem(this.label, this.routeName);
}

class BreadcrumbBar extends StatelessWidget {
  final List<BreadcrumbItem> items;
  const BreadcrumbBar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.brown.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Area Lahan : ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Text('  >  ', style: TextStyle(color: Colors.grey, fontSize: 16)),
            GestureDetector(
              onTap: i == items.length - 1
                  ? null
                  : () => Navigator.of(context)
                      .popUntil(ModalRoute.withName(items[i].routeName)),
              child: Text(
                items[i].label,
                style: TextStyle(
                  fontSize: 16,
                  color: i == items.length - 1 ? Colors.black87 : Colors.blue.shade800,
                  fontWeight: i == items.length - 1 ? FontWeight.bold : FontWeight.normal,
                  decoration: i == items.length - 1 ? null : TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

PreferredSizeWidget buildAppBarWithHome(BuildContext context, String title) {
  return AppBar(
    automaticallyImplyLeading: false,
    leadingWidth: 96,
    leading: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.home),
          tooltip: 'Kembali ke Beranda',
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
    title: Text(title),
  );
}
