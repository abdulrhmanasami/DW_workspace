/// Parcel Create Shipment Screen
/// Created by: Track C - Ticket #46
/// Purpose: Full screen for creating a new shipment from My Shipments.
/// This screen allows users to enter Sender/Receiver/Parcel details/Service type.
/// Last updated: 2025-11-28

import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parcels_shims/parcels_shims.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/widgets/dw_app_shell.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_orders_state.dart';

/// Internal enum for UI service type selection.
/// Maps to domain ParcelServiceType for provider calls.
enum _ParcelServiceType { express, standard }

/// Convert UI enum to domain enum.
ParcelServiceType _toDomainServiceType(_ParcelServiceType type) {
  switch (type) {
    case _ParcelServiceType.express:
      return ParcelServiceType.express;
    case _ParcelServiceType.standard:
      return ParcelServiceType.standard;
  }
}

/// Parcel Create Shipment Screen Widget.
/// Screen 11 in the High-Fidelity Mockups.
class ParcelCreateShipmentScreen extends ConsumerStatefulWidget {
  const ParcelCreateShipmentScreen({super.key});

  @override
  ConsumerState<ParcelCreateShipmentScreen> createState() =>
      _ParcelCreateShipmentScreenState();
}

class _ParcelCreateShipmentScreenState
    extends ConsumerState<ParcelCreateShipmentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Sender controllers
  late final TextEditingController _senderNameController;
  late final TextEditingController _senderPhoneController;
  late final TextEditingController _senderAddressController;

  // Receiver controllers
  late final TextEditingController _receiverNameController;
  late final TextEditingController _receiverPhoneController;
  late final TextEditingController _receiverAddressController;

  // Parcel details controllers
  late final TextEditingController _weightController;
  late final TextEditingController _notesController;

  // Size selection
  ParcelSize _selectedSize = ParcelSize.medium;

  // Service type selection
  _ParcelServiceType _serviceType = _ParcelServiceType.express;

  // Loading state
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _senderNameController = TextEditingController();
    _senderPhoneController = TextEditingController();
    _senderAddressController = TextEditingController();

    _receiverNameController = TextEditingController();
    _receiverPhoneController = TextEditingController();
    _receiverAddressController = TextEditingController();

    _weightController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _senderAddressController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _receiverAddressController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context);
    final colorScheme = theme.colorScheme;

    return DWAppShell(
      appBar: AppBar(
        title: Text(l10n?.parcelsCreateShipmentTitle ?? 'New Shipment'),
      ),
      applyPadding: false, // Custom padding in body
      useSafeArea: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DWSpacing.md,
          vertical: DWSpacing.lg,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // ========== SENDER SECTION ==========
                  _buildSectionHeader(
                    l10n?.parcelsCreateSenderSectionTitle ?? 'Sender',
                    textTheme,
                  ),
                  const SizedBox(height: DWSpacing.sm),
                  _buildTextFormField(
                    controller: _senderNameController,
                    label: l10n?.parcelsCreateSenderNameLabel ?? 'Sender name',
                    validator: (value) =>
                        _requiredValidator(value, l10n),
                  ),
                  const SizedBox(height: DWSpacing.sm),
                  _buildTextFormField(
                    controller: _senderPhoneController,
                    label: l10n?.parcelsCreateSenderPhoneLabel ?? 'Sender phone',
                    keyboardType: TextInputType.phone,
                    validator: (value) => _phoneValidator(value, l10n),
                  ),
                  const SizedBox(height: DWSpacing.sm),
                  _buildTextFormField(
                    controller: _senderAddressController,
                    label: l10n?.parcelsCreateSenderAddressLabel ?? 'Sender address',
                    validator: (value) =>
                        _requiredValidator(value, l10n),
                  ),
                  const SizedBox(height: DWSpacing.xl),

                  // ========== RECEIVER SECTION ==========
                  _buildSectionHeader(
                    l10n?.parcelsCreateReceiverSectionTitle ?? 'Receiver',
                    textTheme,
                  ),
                  const SizedBox(height: DWSpacing.sm),
                  _buildTextFormField(
                    controller: _receiverNameController,
                    label: l10n?.parcelsCreateReceiverNameLabel ?? 'Receiver name',
                    validator: (value) =>
                        _requiredValidator(value, l10n),
                  ),
                  const SizedBox(height: DWSpacing.sm),
                  _buildTextFormField(
                    controller: _receiverPhoneController,
                    label: l10n?.parcelsCreateReceiverPhoneLabel ?? 'Receiver phone',
                    keyboardType: TextInputType.phone,
                    validator: (value) => _phoneValidator(value, l10n),
                  ),
                  const SizedBox(height: DWSpacing.sm),
                  _buildTextFormField(
                    controller: _receiverAddressController,
                    label: l10n?.parcelsCreateReceiverAddressLabel ?? 'Receiver address',
                    validator: (value) =>
                        _requiredValidator(value, l10n),
                  ),
                  const SizedBox(height: DWSpacing.xl),

                  // ========== PARCEL DETAILS SECTION ==========
                  _buildSectionHeader(
                    l10n?.parcelsCreateDetailsSectionTitle ?? 'Parcel details',
                    textTheme,
                  ),
                  const SizedBox(height: DWSpacing.sm),
                  _buildTextFormField(
                    controller: _weightController,
                    label: l10n?.parcelsCreateWeightLabel ?? 'Weight (kg)',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => _numberValidator(value, l10n),
                  ),
                  const SizedBox(height: DWSpacing.sm),
                  // Size selection dropdown
                  Text(
                    l10n?.parcelsCreateSizeLabel ?? 'Size',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: DWSpacing.xs),
                  _buildSizeSelector(colorScheme),
                  const SizedBox(height: DWSpacing.sm),
                  _buildTextFormField(
                    controller: _notesController,
                    label: l10n?.parcelsCreateNotesLabel ?? 'Notes (optional)',
                    maxLines: 3,
                    validator: null, // Optional field
                  ),
                  const SizedBox(height: DWSpacing.xl),

                  // ========== SERVICE TYPE SECTION ==========
                  _buildSectionHeader(
                    l10n?.parcelsCreateServiceSectionTitle ?? 'Service type',
                    textTheme,
                  ),
                  const SizedBox(height: DWSpacing.sm),
                  Row(
                    children: [
                      ChoiceChip(
                        label: Text(
                          l10n?.parcelsCreateServiceExpress ?? 'Express',
                        ),
                        selected: _serviceType == _ParcelServiceType.express,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _serviceType = _ParcelServiceType.express);
                          }
                        },
                      ),
                      const SizedBox(width: DWSpacing.sm),
                      ChoiceChip(
                        label: Text(
                          l10n?.parcelsCreateServiceStandard ?? 'Standard',
                        ),
                        selected: _serviceType == _ParcelServiceType.standard,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _serviceType = _ParcelServiceType.standard);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: DWSpacing.xl),

                  // Spacer for bottom button
                  SizedBox(height: MediaQuery.of(context).padding.bottom + DWSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: SizedBox(
          width: double.infinity,
          child: DWButton.primary(
            label: l10n?.parcelsCreateShipmentCtaGetEstimate ?? 'Get estimate',
            onPressed: _isSubmitting ? null : _onSubmit,
          ),
        ),
      ),
    );
  }

  /// Build section header text widget.
  Widget _buildSectionHeader(String title, TextTheme textTheme) {
    return Text(
      title,
      style: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Build a TextFormField with consistent styling.
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }

  /// Build size selector using SegmentedButton.
  Widget _buildSizeSelector(ColorScheme colorScheme) {
    return SegmentedButton<ParcelSize>(
      segments: const [
        ButtonSegment(
          value: ParcelSize.small,
          label: Text('S'),
          icon: Icon(Icons.inventory_2_outlined, size: 16),
        ),
        ButtonSegment(
          value: ParcelSize.medium,
          label: Text('M'),
          icon: Icon(Icons.inventory_2_outlined, size: 20),
        ),
        ButtonSegment(
          value: ParcelSize.large,
          label: Text('L'),
          icon: Icon(Icons.inventory_2_outlined, size: 24),
        ),
        ButtonSegment(
          value: ParcelSize.oversize,
          label: Text('XL'),
          icon: Icon(Icons.inventory_2_outlined, size: 28),
        ),
      ],
      selected: {_selectedSize},
      onSelectionChanged: (Set<ParcelSize> newSelection) {
        setState(() {
          _selectedSize = newSelection.first;
        });
      },
    );
  }

  /// Validator for required fields.
  String? _requiredValidator(String? value, AppLocalizations? l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n?.parcelsCreateErrorRequired ?? 'This field is required';
    }
    return null;
  }

  /// Validator for phone fields.
  String? _phoneValidator(String? value, AppLocalizations? l10n) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return l10n?.parcelsCreateErrorRequired ?? 'This field is required';
    }
    if (v.length < 7) {
      return l10n?.parcelsCreateErrorInvalidPhone ?? 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validator for numeric fields.
  String? _numberValidator(String? value, AppLocalizations? l10n) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return l10n?.parcelsCreateErrorRequired ?? 'This field is required';
    }
    final normalized = v.replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null || parsed <= 0) {
      return l10n?.parcelsCreateErrorInvalidNumber ?? 'Please enter a valid number';
    }
    return null;
  }

  /// Submit the form and create the shipment.
  Future<void> _onSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isSubmitting = true);

    try {
      final weightText = _weightController.text.trim();
      final notes = _notesController.text.trim();

      await ref.read(parcelOrdersProvider.notifier).createShipmentFromForm(
        senderName: _senderNameController.text.trim(),
        senderPhone: _senderPhoneController.text.trim(),
        senderAddress: _senderAddressController.text.trim(),
        receiverName: _receiverNameController.text.trim(),
        receiverPhone: _receiverPhoneController.text.trim(),
        receiverAddress: _receiverAddressController.text.trim(),
        weightText: weightText,
        size: _selectedSize,
        notes: notes.isEmpty ? null : notes,
        serviceType: _toDomainServiceType(_serviceType),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

