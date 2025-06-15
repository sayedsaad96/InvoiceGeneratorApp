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
  late TextEditingController
      _salesRepController; // Changed back to TextEditingController
  late TextEditingController _regionController;
  late TextEditingController
      _paymentMethodController; // Changed back to TextEditingController
  late TextEditingController _deliveryLocationController;
  late DateTime _selectedDate;
  late DateTime? _selectedDeliveryDate;
  late Set<String> _selectedBranches;
  late bool _deliveryIncluded;
  late List<InvoiceItem> _items;
  // Removed _selectedSalesRep and _selectedPaymentMethod state variables

  // Dropdown options for Autocomplete
  final List<String> salesRepOptions = [
    'سيد سعد',
    'محمد ايمن',
    'عبد العزيز مدحت',
    'محمد الحديدي',
    'احمد عادل',
    'احمد زهران',
    'محمد جمال',
    'قمر ذكي',
  ];
  final List<String> paymentMethodOptions = [
    'كاش',
    'اجل اسبوعين',
    'اجل شهر',
    'اجل شهرين',
    'اجل 3 شهور'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _serialNumberController =
        TextEditingController(text: widget.invoice.serialNumber);
    _customerNameController =
        TextEditingController(text: widget.invoice.customer.name);
    _salesRepController =
        TextEditingController(text: widget.invoice.salesRepresentative);
    _regionController = TextEditingController(text: widget.invoice.region);
    _paymentMethodController =
        TextEditingController(text: widget.invoice.paymentMethod);
    _deliveryLocationController =
        TextEditingController(text: widget.invoice.deliveryLocation);
    _selectedDate = widget.invoice.date;
    _selectedDeliveryDate = widget.invoice.deliveryDate;
    _selectedBranches = Set.from(widget.invoice.selectedBranches);
    _deliveryIncluded = widget.invoice.deliveryIncluded;
    _items = List.from(widget.invoice.items);

    // Add listeners to update invoice on text change
    _salesRepController.addListener(_updateInvoiceFromText);
    _paymentMethodController.addListener(_updateInvoiceFromText);
  }

  @override
  void didUpdateWidget(InvoiceForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.invoice != widget.invoice) {
      // Remove old listeners before re-initializing
      _salesRepController.removeListener(_updateInvoiceFromText);
      _paymentMethodController.removeListener(_updateInvoiceFromText);
      _initializeControllers();
    }
  }

  @override
  void dispose() {
    _serialNumberController.dispose();
    _customerNameController.dispose();
    _salesRepController.removeListener(_updateInvoiceFromText);
    _salesRepController.dispose();
    _regionController.dispose();
    _paymentMethodController.removeListener(_updateInvoiceFromText);
    _paymentMethodController.dispose();
    _deliveryLocationController.dispose();
    super.dispose();
  }

  // Separate update function for text controllers to avoid infinite loops
  void _updateInvoiceFromText() {
    _updateInvoice();
  }

  void _updateInvoice() {
    final updatedInvoice = widget.invoice.copyWith(
      serialNumber: _serialNumberController.text,
      date: _selectedDate,
      customer: widget.invoice.customer.copyWith(
        name: _customerNameController.text,
      ),
      salesRepresentative:
          _salesRepController.text, // Use text controller value
      region: _regionController.text,
      paymentMethod: _paymentMethodController.text, // Use text controller value
      deliveryIncluded: _deliveryIncluded,
      deliveryLocation: _deliveryLocationController.text,
      deliveryDate: _selectedDeliveryDate,
      items: _items,
      selectedBranches: _selectedBranches,
    );
    // Use a post frame callback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onInvoiceChanged(updatedInvoice);
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isDeliveryDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDeliveryDate
          ? (_selectedDeliveryDate ?? DateTime.now())
          : _selectedDate,
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

  void _handleBranchSelection(String branch, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (Invoice.group1Branches.contains(branch)) {
          _selectedBranches
              .removeWhere((b) => Invoice.group1Branches.contains(b));
        }
        _selectedBranches.add(branch);
      } else {
        _selectedBranches.remove(branch);
      }
      _updateInvoice();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

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
                  localizations.translate('sales_order'),
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
                localizations.translate('serial_number'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 120,
                child: TextFormField(
                  controller: _serialNumberController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                    localizations.translate('branch'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomCheckbox(
                        label: localizations.translate('insulation'),
                        value: _selectedBranches
                            .contains(Invoice.branchInsulation),
                        onChanged: (value) => _handleBranchSelection(
                            Invoice.branchInsulation, value),
                      ),
                      CustomCheckbox(
                        label: localizations.translate('supplies'),
                        value:
                            _selectedBranches.contains(Invoice.branchSupplies),
                        onChanged: (value) => _handleBranchSelection(
                            Invoice.branchSupplies, value),
                      ),
                      CustomCheckbox(
                        label: localizations.translate('fabrics'),
                        value:
                            _selectedBranches.contains(Invoice.branchFabrics),
                        onChanged: (value) => _handleBranchSelection(
                            Invoice.branchFabrics, value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomCheckbox(
                        label: localizations.translate('mahalla'),
                        value:
                            _selectedBranches.contains(Invoice.branchMahalla),
                        onChanged: (value) => _handleBranchSelection(
                            Invoice.branchMahalla, value),
                      ),
                      CustomCheckbox(
                        label: localizations.translate('cairo'),
                        value: _selectedBranches.contains(Invoice.branchCairo),
                        onChanged: (value) =>
                            _handleBranchSelection(Invoice.branchCairo, value),
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
                      localizations.translate('date'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F4EA),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd-MMM-yyyy')
                                .format(_selectedDate)),
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
                      localizations.translate('customer_name'),
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
                          return localizations.translate('required_field');
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
                      localizations.translate('sales_representative'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    // Autocomplete for Sales Representative
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<String>.empty();
                        }
                        return salesRepOptions.where((String option) {
                          // Simple contains check, could be improved for Arabic matching
                          return option.contains(textEditingValue.text);
                        });
                      },
                      onSelected: (String selection) {
                        _salesRepController.text = selection;
                        _updateInvoice();
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController fieldTextEditingController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted) {
                        // Assign the controller from the state
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (fieldTextEditingController.text !=
                              _salesRepController.text) {
                            fieldTextEditingController.text =
                                _salesRepController.text;
                          }
                        });
                        return TextFormField(
                          controller:
                              _salesRepController, // Use the state controller
                          focusNode: fieldFocusNode,
                          style: const TextStyle(fontFamily: 'NotoSansArabic'),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFE8F4EA),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return localizations.translate('required_field');
                            }
                            return null;
                          },
                        );
                      },
                      optionsViewBuilder: (BuildContext context,
                          AutocompleteOnSelected<String> onSelected,
                          Iterable<String> options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            child: SizedBox(
                              height: 200.0,
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final String option =
                                      options.elementAt(index);
                                  return InkWell(
                                    onTap: () {
                                      onSelected(option);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(option,
                                          style: const TextStyle(
                                              fontFamily: 'NotoSansArabic')),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
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
                      localizations.translate('region'),
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
                      localizations.translate('payment_method'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    // Autocomplete for Payment Method
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<String>.empty();
                        }
                        return paymentMethodOptions.where((String option) {
                          return option.contains(textEditingValue.text);
                        });
                      },
                      onSelected: (String selection) {
                        _paymentMethodController.text = selection;
                        _updateInvoice();
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController fieldTextEditingController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (fieldTextEditingController.text !=
                              _paymentMethodController.text) {
                            fieldTextEditingController.text =
                                _paymentMethodController.text;
                          }
                        });
                        return TextFormField(
                          controller:
                              _paymentMethodController, // Use the state controller
                          focusNode: fieldFocusNode,
                          style: const TextStyle(fontFamily: 'NotoSansArabic'),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFE8F4EA),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return localizations.translate('required_field');
                            }
                            return null;
                          },
                        );
                      },
                      optionsViewBuilder: (BuildContext context,
                          AutocompleteOnSelected<String> onSelected,
                          Iterable<String> options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            child: SizedBox(
                              height: 200.0, // Adjust height as needed
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final String option =
                                      options.elementAt(index);
                                  return InkWell(
                                    onTap: () {
                                      onSelected(option);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(option,
                                          style: const TextStyle(
                                              fontFamily: 'NotoSansArabic')),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
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
                      localizations.translate('delivery_included'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CustomCheckbox(
                          label: localizations.translate('yes'),
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
                          label: localizations.translate('no'),
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
                      localizations.translate('delivery_location'),
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
                      localizations.translate('delivery_date'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F4EA),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedDeliveryDate != null
                                ? DateFormat('dd-MMM-yyyy')
                                    .format(_selectedDeliveryDate!)
                                : localizations.translate('select_date')),
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
            localizations.translate('order_items'),
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
                    localizations.translate('total'),
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
                    localizations.translate('total_quantity'),
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
