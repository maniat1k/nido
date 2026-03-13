import 'package:flutter/material.dart';

import '../data/mock_sellers.dart';
import '../repositories/items_repository.dart';
import '../widgets/item_form.dart';

class CreateItemScreen extends StatelessWidget {
  final ItemsRepository repository;

  const CreateItemScreen({
    super.key,
    required this.repository,
  });

  String _buildId() {
    return 'item-${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EFF4),
      appBar: AppBar(
        title: const Text('Publicar prenda'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBFD),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 18,
                  color: Color(0x14000000),
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ItemForm(
              currentSeller: currentMockSeller,
              onSubmit: (result) async {
                final item = result.toItem(
                  _buildId(),
                  seller: currentMockSeller,
                );
                await repository.addItem(item);

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.title} se publicó correctamente.'),
                  ),
                );

                if (!context.mounted) return;
                Navigator.of(context).pop(item.id);
              },
            ),
          ),
        ),
      ),
    );
  }
}
