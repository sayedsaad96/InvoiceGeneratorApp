import 'package:flutter/material.dart';
import 'package:invoice_generator/models/invoice_model.dart';
import 'package:invoice_generator/models/item_model.dart';
import 'package:invoice_generator/utils/localization.dart';
import 'package:invoice_generator/widgets/custom_checkbox.dart';
import 'package:invoice_generator/widgets/item_table.dart';
import 'package:intl/intl.dart';

class InvoiceForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Invoice invoice;
  final Function(Invoice) onInvoiceChanged;
  
  const InvoiceForm({
    Key? key,
    required this.formKey,
    required this.invoice,
    required this.onInvoiceChanged,
  }) : super(key: key);

  @override
  State<InvoiceForm> createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<InvoiceForm> {
  late TextEditingController _serialNumberController;
  late TextEditingController _customerNameController;
  late TextEditingController _salesRepController;
  late TextEditingController _regionController;
  late TextEditingController _paymentMethodController;
  late TextEditingController _deliveryLocationController;
  late DateTime _selectedDate;
  late DateTime? _selectedDeliveryDate;
  late String _selectedBranch;
  late bool _deliveryIncluded;
  late List<InvoiceItem> _items;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }
  
  void _initializeControllers() {
    _serialNumberController = TextEditingController(text: widget.invoice.serialNumber);
    _customerNameController = TextEditingController(text: widget.invoice.customer.name);
    _salesRepController = TextEditingController(text: widget.invoice.salesRepresentative);
    _regionController = TextEditingController(text: widget.invoice.region);
    _paymentMethodController = TextEditingController(text: widget.invoice.paymentMethod);
    _deliveryLocationController = TextEditingController(text: widget.invoice.deliveryLocation);
    _selectedDate = widget.invoice.date;
    _selectedDeliveryDate = widget.invoice.deliveryDate;
    _selectedBranch = widget.invoice.branch;
    _deliveryIncluded = widget.invoice.deliveryIncluded;
    _items = List.from(widget.invoice.items);
  }
  
  @override
  void didUpdateWidget(InvoiceForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.invoice != widget.invoice) {
      _initializeControllers();
    }
  }
  
  @override
  void dispose() {
    _serialNumberController.dispose();
    _customerNameController.dispose();
    _salesRepController.dispose();
    _regionController.dispose();
    _paymentMethodController.dispose();
    _deliveryLocationController.dispose();
    super.dispose();
  }
  
  void _updateInvoice() {
    final updatedInvoice = widget.invoice.copyWith(
      serialNumber: _serialNumberController.text,
      date: _selectedDate,
      customer: widget.invoice.customer.copyWith(
        name: _customerNameController.text,
      ),
      salesRepresentative: _salesRepController.text,
      region: _regionController.text,
      paymentMethod: _paymentMethodController.text,
      deliveryIncluded: _deliveryIncluded,
      deliveryLocation: _deliveryLocationController.text,
      deliveryDate: _selectedDeliveryDate,
      items: _items,
      branch: _selectedBranch,
    );
    
    widget.onInvoiceChanged(updatedInvoice);
  }
  
  Future<void> _selectDate(BuildContext context, bool isDeliveryDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDeliveryDate ? (_selectedDeliveryDate ?? DateTime.now()) : _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        if (isDeliveryDate) {
          _selectedDeliveryDate = picked;
        } else {
          _selectedDate = picked;
        }
        _updateInvoice();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo and title
          Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 80,
                      child: Center(
                        child: Text(
                          'ANNEX GROUP',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3A98B9),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.translate('sales_order'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Serial Number
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                AppLocalizations.of(context)!.translate('serial_number'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 120,
                child: TextFormField(
                  controller: _serialNumberController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  onChanged: (value) {
                    _updateInvoice();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Branch selection
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.translate('branch'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomCheckbox(
                        label: AppLocalizations.of(context)!.translate('insulation'),
                        value: _selectedBranch == Invoice.branchInsulation,
                        onChanged: (value) {
                          setState(() {
                            _selectedBranch = Invoice.branchInsulation;
                            _updateInvoice();
                          });
                        },
                      ),
                      CustomCheckbox(
                        label: AppLocalizations.of(context)!.translate('supplies'),
                        value: _selectedBranch == Invoice.branchSupplies,
                        onChanged: (value) {
                          setState(() {
                            _selectedBranch = Invoice.branchSupplies;
                            _updateInvoice();
                          });
                        },
                      ),
                      CustomCheckbox(
                        label: AppLocalizations.of(context)!.translate('fabrics'),
                        value: _selectedBranch == Invoice.branchFabrics,
                        onChanged: (value) {
                          setState(() {
                            _selectedBranch = Invoice.branchFabrics;
                            _updateInvoice();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomCheckbox(
                        label: AppLocalizations.of(context)!.translate('mahalla'),
                        value: _selectedBranch == Invoice.branchMahalla,
                        onChanged: (value) {
                          setState(() {
                            _selectedBranch = Invoice.branchMahalla;
                            _updateInvoice();
                          });
                        },
                      ),
                      CustomCheckbox(
                        label: AppLocalizations.of(context)!.translate('cairo'),
                        value: _selectedBranch == Invoice.branchCairo,
                        onChanged: (value) {
                          setState(() {
                            _selectedBranch = Invoice.branchCairo;
                            _updateInvoice();
                          });
                        },
                      ),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Invoice details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('date'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F4EA),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd-MMM-yyyy').format(_selectedDate)),
                            const Icon(Icons.calendar_today, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('customer_name'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _customerNameController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFE8F4EA),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.translate('required_field');
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _updateInvoice();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('sales_representative'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _salesRepController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFE8F4EA),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.translate('required_field');
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _updateInvoice();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('region'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _regionController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFE8F4EA),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _updateInvoice();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('payment_method'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _paymentMethodController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFE8F4EA),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _updateInvoice();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('delivery_included'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CustomCheckbox(
                          label: AppLocalizations.of(context)!.translate('yes'),
                          value: _deliveryIncluded,
                          onChanged: (value) {
                            setState(() {
                              _deliveryIncluded = true;
                              _updateInvoice();
                            });
                          },
                        ),
                        const SizedBox(width: 16),
                        CustomCheckbox(
                          label: AppLocalizations.of(context)!.translate('no'),
                          value: !_deliveryIncluded,
                          onChanged: (value) {
                            setState(() {
                              _deliveryIncluded = false;
                              _updateInvoice();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('delivery_location'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _deliveryLocationController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFE8F4EA),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _updateInvoice();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('delivery_date'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F4EA),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedDeliveryDate != null
                                ? DateFormat('dd-MMM-yyyy').format(_selectedDeliveryDate!)
                                : AppLocalizations.of(context)!.translate('select_date')),
                            const Icon(Icons.calendar_today, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Items table
          Text(
            AppLocalizations.of(context)!.translate('order_items'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ItemTable(
            items: _items,
            onItemsChanged: (items) {
              setState(() {
                _items = items;
                _updateInvoice();
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Summary
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.translate('total'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    widget.invoice.total.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.translate('total_quantity'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    widget.invoice.totalQuantity.toString(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
