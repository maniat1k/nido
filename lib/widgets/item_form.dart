import 'package:flutter/material.dart';

import '../data/mock_items.dart';
import '../models/item.dart';
import '../models/seller.dart';
import 'tags_input_field.dart';

const List<String> kItemCategories = [
  'Bodies',
  'Pijamas',
  'Conjuntos',
  'Abrigos',
  'Calzado',
  'Accesorios',
  'Juguetes',
  'Otros',
];

const List<String> kItemConditions = [
  'Como nuevo',
  'Muy buen estado',
  'Buen estado',
];

const List<String> kSuggestedTags = [
  'algodón',
  'invierno',
  'nuevo',
  'lote',
  'neutral',
  'regalo',
];

class ItemFormResult {
  final String title;
  final String description;
  final double price;
  final String category;
  final String size;
  final String condition;
  final List<String> imageUrls;
  final String? brand;
  final String? color;
  final String? ageSuggested;
  final List<String> tags;

  const ItemFormResult({
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.size,
    required this.condition,
    required this.imageUrls,
    this.brand,
    this.color,
    this.ageSuggested,
    this.tags = const [],
  });

  Item toItem(String id, {required Seller seller}) {
    return Item(
      id: id,
      title: title,
      description: description,
      price: price,
      category: category,
      size: size,
      condition: condition,
      sellerId: seller.id,
      imageUrls: imageUrls,
      isFavorite: false,
      brand: brand,
      color: color,
      ageSuggested: ageSuggested,
      tags: tags,
      badge: 'Venta',
      inquiryCount: 0,
      lastActivity: 'recién publicado',
    );
  }
}

class ItemForm extends StatefulWidget {
  final Seller currentSeller;
  final Future<void> Function(ItemFormResult value) onSubmit;

  const ItemForm({
    super.key,
    required this.currentSeller,
    required this.onSubmit,
  });

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _sizeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandController = TextEditingController();
  final _colorController = TextEditingController();
  final _ageSuggestedController = TextEditingController();

  String? _selectedImage;
  String? _selectedCategory;
  String? _selectedCondition;
  List<String> _selectedTags = [];
  bool _hasAttemptedSubmit = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = kItemCategories.first;
    _selectedCondition = kItemConditions.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _colorController.dispose();
    _ageSuggestedController.dispose();
    super.dispose();
  }

  double? _parsePrice(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return null;
    return double.tryParse(value.replaceAll(',', '.'));
  }

  Future<void> _submit() async {
    if (!_hasAttemptedSubmit) {
      setState(() => _hasAttemptedSubmit = true);
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _selectedImage == null) {
      return;
    }

    final price = _parsePrice(_priceController.text);
    if (price == null || price <= 0) {
      return;
    }

    await widget.onSubmit(
      ItemFormResult(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        category: _selectedCategory!,
        size: _sizeController.text.trim(),
        condition: _selectedCondition!,
        imageUrls: [_selectedImage!],
        brand: _normalizedOrNull(_brandController.text),
        color: _normalizedOrNull(_colorController.text),
        ageSuggested: _normalizedOrNull(_ageSuggestedController.text),
        tags: _selectedTags,
      ),
    );
  }

  String? _normalizedOrNull(String raw) {
    final value = raw.trim();
    return value.isEmpty ? null : value;
  }

  @override
  Widget build(BuildContext context) {
    final imageMissing = _hasAttemptedSubmit && _selectedImage == null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto principal',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: mockImageOptions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final url = mockImageOptions[index];
                final selected = url == _selectedImage;
                return GestureDetector(
                  key: ValueKey('item-image-option-$index'),
                  onTap: () => setState(() => _selectedImage = url),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 90,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected ? const Color(0xFFC695B2) : const Color(0xFFE6D6DE),
                        width: selected ? 2 : 1,
                      ),
                      color: selected ? const Color(0xFFFFF7FB) : Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: Colors.black.withValues(alpha: 0.06),
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (imageMissing)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Elegí una foto principal para publicar.',
                style: TextStyle(color: Color(0xFFB24552), fontSize: 12),
              ),
            ),
          const SizedBox(height: 20),
          _FormTextField(
            controller: _titleController,
            label: 'Título',
            hint: 'Ej. Body de algodón estampado',
            validator: (value) {
              if ((value ?? '').trim().isEmpty) return 'Ingresá un título.';
              return null;
            },
          ),
          const SizedBox(height: 14),
          _FormTextField(
            controller: _priceController,
            label: 'Precio',
            hint: 'Ej. 650',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final raw = (value ?? '').trim();
              if (raw.isEmpty) return 'Ingresá el precio.';
              final parsed = _parsePrice(raw);
              if (parsed == null) return 'Ingresá un precio válido.';
              if (parsed <= 0) return 'El precio debe ser mayor a 0.';
              return null;
            },
          ),
          const SizedBox(height: 14),
          _FormTextField(
            controller: _sizeController,
            label: 'Talle',
            hint: 'Ej. RN, 3-6m, 18',
            validator: (value) {
              if ((value ?? '').trim().isEmpty) return 'Ingresá el talle.';
              return null;
            },
          ),
          const SizedBox(height: 14),
          _ResponsiveFieldGroup(
            children: [
              _DropdownField<String>(
                value: _selectedCategory,
                label: 'Categoría',
                items: kItemCategories,
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              _DropdownField<String>(
                value: _selectedCondition,
                label: 'Estado',
                items: kItemConditions,
                onChanged: (value) => setState(() => _selectedCondition = value),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7D9E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Publicás como',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.58),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.currentSeller.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _FormTextField(
            controller: _descriptionController,
            label: 'Descripción corta',
            hint: 'Contá el estado, uso y algo útil para quien compra.',
            maxLines: 4,
            validator: (value) {
              if ((value ?? '').trim().isEmpty) return 'Sumá una descripción.';
              return null;
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Datos opcionales',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _FormTextField(
            controller: _brandController,
            label: 'Marca',
            hint: 'Ej. Carters',
          ),
          const SizedBox(height: 14),
          _ResponsiveFieldGroup(
            children: [
              _FormTextField(
                controller: _colorController,
                label: 'Color',
                hint: 'Ej. Beige',
              ),
              _FormTextField(
                controller: _ageSuggestedController,
                label: 'Edad sugerida',
                hint: 'Ej. 6-12m',
              ),
            ],
          ),
          const SizedBox(height: 14),
          TagsInputField(
            suggestedTags: kSuggestedTags,
            initialTags: _selectedTags,
            onChanged: (tags) {
              _selectedTags = tags;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Publicar prenda'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String? value)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  const _FormTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: _inputDecoration(label, hint: hint),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final T? value;
  final String label;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: _inputDecoration(label),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                '$item',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      selectedItemBuilder: (context) {
        return items
            .map(
              (item) => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$item',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList();
      },
      onChanged: onChanged,
      validator: (value) => value == null ? 'Campo obligatorio.' : null,
    );
  }
}

class _ResponsiveFieldGroup extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveFieldGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            children: [
              for (int index = 0; index < children.length; index++) ...[
                children[index],
                if (index < children.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (int index = 0; index < children.length; index++) ...[
              Expanded(child: children[index]),
              if (index < children.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}

InputDecoration _inputDecoration(String label, {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE7D9E1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE7D9E1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFC695B2), width: 1.5),
    ),
  );
}
