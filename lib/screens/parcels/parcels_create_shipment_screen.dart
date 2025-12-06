import 'package:design_system_shims/design_system_shims.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parcels_shims/parcels_shims.dart';

import 'package:delivery_ways_clean/l10n/generated/app_localizations.dart';
import 'package:delivery_ways_clean/state/parcels/parcel_shipments_providers.dart';
import 'package:delivery_ways_clean/widgets/dw_app_shell.dart';

/// Track C - Ticket #150: Parcels Create Shipment Screen (Screen 11)
/// Creates new shipment using ParcelShipment domain model from parcels_shims.
class ParcelsCreateShipmentScreen extends ConsumerStatefulWidget {
  const ParcelsCreateShipmentScreen({super.key});

  static const String routeName = '/parcels/create-shipment';

  @override
  ConsumerState<ParcelsCreateShipmentScreen> createState() =>
      _ParcelsCreateShipmentScreenState();
}

class _ParcelsCreateShipmentScreenState
    extends ConsumerState<ParcelsCreateShipmentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _senderNameController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _pickupAddressController = TextEditingController();
  final _dropoffAddressController = TextEditingController();
  final _weightController = TextEditingController();
  final _sizeController = TextEditingController();
  final _notesController = TextEditingController();

  String? _serviceType; // 'express' / 'standard'
  bool _isSubmitting = false;

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderPhoneController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _pickupAddressController.dispose();
    _dropoffAddressController.dispose();
    _weightController.dispose();
    _sizeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return DWAppShell(
      appBar: AppBar(
        title: Text(
          l10n?.parcelsCreateShipmentTitle ?? 'Create shipment',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DWSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSenderSection(l10n, textTheme, colorScheme),
                const SizedBox(height: DWSpacing.lg),
                _buildReceiverSection(l10n, textTheme, colorScheme),
                const SizedBox(height: DWSpacing.lg),
                _buildAddressesSection(l10n, textTheme, colorScheme),
                const SizedBox(height: DWSpacing.lg),
                _buildParcelDetailsSection(l10n, textTheme, colorScheme),
                const SizedBox(height: DWSpacing.lg),
                _buildServiceTypeSection(l10n, textTheme, colorScheme),
                const SizedBox(height: DWSpacing.xl),
                _buildSubmitButton(l10n, textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSenderSection(
      AppLocalizations? l10n, TextTheme textTheme, ColorScheme colorScheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.parcelsCreateShipmentSenderSectionTitle ?? 'Sender details',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DWSpacing.md),
            TextFormField(
              controller: _senderNameController,
              decoration: InputDecoration(
                labelText: l10n?.parcelsCreateShipmentSenderNameLabel ?? 'Sender name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DWRadius.md),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n?.commonErrorFieldRequired ?? 'This field is required';
                }
                return null;
              },
            ),
            const SizedBox(height: DWSpacing.md),
            TextFormField(
              controller: _senderPhoneController,
              decoration: InputDecoration(
                labelText: l10n?.parcelsCreateShipmentSenderPhoneLabel ?? 'Sender phone',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DWRadius.md),
                ),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n?.commonErrorFieldRequired ?? 'This field is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiverSection(
      AppLocalizations? l10n, TextTheme textTheme, ColorScheme colorScheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.parcelsCreateShipmentReceiverSectionTitle ?? 'Receiver details',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DWSpacing.md),
            TextFormField(
              controller: _receiverNameController,
              decoration: InputDecoration(
                labelText: l10n?.parcelsCreateShipmentReceiverNameLabel ?? 'Receiver name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DWRadius.md),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n?.commonErrorFieldRequired ?? 'This field is required';
                }
                return null;
              },
            ),
            const SizedBox(height: DWSpacing.md),
            TextFormField(
              controller: _receiverPhoneController,
              decoration: InputDecoration(
                labelText: l10n?.parcelsCreateShipmentReceiverPhoneLabel ?? 'Receiver phone',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DWRadius.md),
                ),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n?.commonErrorFieldRequired ?? 'This field is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressesSection(
      AppLocalizations? l10n, TextTheme textTheme, ColorScheme colorScheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.commonAddressesTitle ?? 'Addresses',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DWSpacing.md),
            TextFormField(
              controller: _pickupAddressController,
              decoration: InputDecoration(
                labelText: l10n?.parcelsCreateShipmentPickupAddressLabel ?? 'Pickup address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DWRadius.md),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n?.commonErrorFieldRequired ?? 'This field is required';
                }
                return null;
              },
            ),
            const SizedBox(height: DWSpacing.md),
            TextFormField(
              controller: _dropoffAddressController,
              decoration: InputDecoration(
                labelText: l10n?.parcelsCreateShipmentDropoffAddressLabel ?? 'Dropoff address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DWRadius.md),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n?.commonErrorFieldRequired ?? 'This field is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParcelDetailsSection(
      AppLocalizations? l10n, TextTheme textTheme, ColorScheme colorScheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.parcelsCreateShipmentParcelDetailsSectionTitle ?? 'Parcel details',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DWSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: l10n?.parcelsCreateShipmentWeightLabel ?? 'Weight (kg)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DWRadius.md),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
                const SizedBox(width: DWSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _sizeController,
                    decoration: InputDecoration(
                      labelText: l10n?.parcelsCreateShipmentSizeLabel ?? 'Size',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DWRadius.md),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DWSpacing.md),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n?.parcelsCreateShipmentNotesLabel ?? 'Notes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DWRadius.md),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeSection(
      AppLocalizations? l10n, TextTheme textTheme, ColorScheme colorScheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DWRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DWSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.parcelsCreateShipmentServiceTypeLabel ?? 'Service type',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DWSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _ServiceTypeChip(
                    label: l10n?.parcelsCreateShipmentServiceTypeExpress ?? 'Express',
                    value: 'express',
                    groupValue: _serviceType,
                    onChanged: (value) {
                      setState(() {
                        _serviceType = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: DWSpacing.sm),
                Expanded(
                  child: _ServiceTypeChip(
                    label: l10n?.parcelsCreateShipmentServiceTypeStandard ?? 'Standard',
                    value: 'standard',
                    groupValue: _serviceType,
                    onChanged: (value) {
                      setState(() {
                        _serviceType = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations? l10n, TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      child: DWButton.primary(
        label: _isSubmitting
            ? 'Loading...'
            : l10n?.parcelsCreateShipmentCta ?? 'Create shipment',
        onPressed: _isSubmitting ? null : _onSubmit,
      ),
    );
  }

  Future<void> _onSubmit() async {
    final context = this.context;
    final l10n = AppLocalizations.of(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_serviceType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.parcelsCreateShipmentServiceTypeError ?? 
            'Please select a service type',
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Capture context-dependent objects before async gap
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final now = DateTime.now();

      final sender = ParcelContact(
        name: _senderNameController.text.trim(),
        phone: _senderPhoneController.text.trim(),
      );
      
      final receiver = ParcelContact(
        name: _receiverNameController.text.trim(),
        phone: _receiverPhoneController.text.trim(),
      );

      final pickupAddress = ParcelAddress(
        label: _pickupAddressController.text.trim(),
      );

      final dropoffAddress = ParcelAddress(
        label: _dropoffAddressController.text.trim(),
      );

      // Parse weight if provided
      double? weightKg;
      if (_weightController.text.isNotEmpty) {
        weightKg = double.tryParse(_weightController.text.trim());
      }

      final shipment = ParcelShipment(
        id: 'shp_${now.microsecondsSinceEpoch}',
        sender: sender,
        receiver: receiver,
        pickupAddress: pickupAddress,
        dropoffAddress: dropoffAddress,
        status: ParcelShipmentStatus.created,
        createdAt: now,
        weightKg: weightKg,
        sizeLabel: _sizeController.text.trim().isEmpty 
            ? null 
            : _sizeController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        serviceType: _serviceType,
        // estimatedPrice / currencyCode will be set by PricingService in a future ticket
      );

      final create = ref.read(createParcelShipmentProvider);
      await create(shipment);

      if (!mounted) return;

      // Show success message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n?.parcelsCreateShipmentSuccessMessage ?? 
            'Shipment created successfully',
          ),
        ),
      );

      // Return to list
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Something went wrong'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

/// Service type selection chip widget
class _ServiceTypeChip extends StatelessWidget {
  const _ServiceTypeChip({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String label;
  final String value;
  final String? groupValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(DWRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DWSpacing.md,
          vertical: DWSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? colorScheme.primaryContainer 
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(DWRadius.md),
          border: Border.all(
            color: isSelected 
                ? colorScheme.primary 
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected) ...[
              Icon(
                Icons.check_circle,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: DWSpacing.xs),
            ],
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected 
                    ? colorScheme.onPrimaryContainer 
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
