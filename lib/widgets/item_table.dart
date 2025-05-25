import 'package:flutter/material.dart';
import 'package:invoice_generator/models/item_model.dart';
import 'package:invoice_generator/utils/localization.dart';

class ItemTable extends StatefulWidget {
  final List<InvoiceItem> items;
  final Function(List<InvoiceItem>) onItemsChanged;
  
  const ItemTable({
    Key? key,
    required this.items,
    required this.onItemsChanged,
  }) : super(key: key);

  @override
  State<ItemTable> createState() => _ItemTableState();
}

class _ItemTableState extends State<ItemTable> {
  late List<InvoiceItem> _items;
  
  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }
  
  @override
  void didUpdateWidget(ItemTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _items = List.from(widget.items);
    }
  }
  
  void _addItem() {
    setState(() {
      _items.add(InvoiceItem(
        description: '',
        unit: '',
        quantity: 0,
        unitPrice: 0,
      ));
      widget.onItemsChanged(_items);
    });
  }
  
  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      widget.onItemsChanged(_items);
    });
  }
  
  void _updateItem(int index, InvoiceItem item) {
    setState(() {
      _items[index] = item;
      widget.onItemsChanged(_items);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF3A98B9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    AppLocalizations.of(context)!.translate('item'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    AppLocalizations.of(context)!.translate('quantity'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    AppLocalizations.of(context)!.translate('unit'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    AppLocalizations.of(context)!.translate('price'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    AppLocalizations.of(context)!.translate('total'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Space for action button
              ],
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            final isEven = index % 2 == 0;
            
            return Container(
              color: isEven ? const Color(0xFFE8F4EA) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        initialValue: item.description,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onChanged: (value) {
                          _updateItem(
                            index,
                            item.copyWith(description: value),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: item.quantity.toString(),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _updateItem(
                            index,
                            item.copyWith(quantity: double.tryParse(value) ?? 0),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: item.unit,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onChanged: (value) {
                          _updateItem(
                            index,
                            item.copyWith(unit: value),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: item.unitPrice.toString(),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _updateItem(
                            index,
                            item.copyWith(unitPrice: double.tryParse(value) ?? 0),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        item.total.toStringAsFixed(2),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeItem(index),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: Text(AppLocalizations.of(context)!.translate('add_item')),
          onPressed: _addItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3A98B9),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
