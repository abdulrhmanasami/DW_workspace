import 'dart:async';
import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payments/payments.dart';

/// Component: PaymentMethodSelector
/// Created by: Cursor (auto-generated)
/// Purpose: Interactive payment method selection with card input and wallet support
/// Last updated: 2025-01-27

/// Local payment method data wrapper using payments package types
class PaymentMethodData {
  final PaymentMethodType type;
  final String? cardNumber;
  final String? expiryMonth;
  final String? expiryYear;
  final String? cvc;
  final String? cardholderName;

  const PaymentMethodData({
    required this.type,
    this.cardNumber,
    this.expiryMonth,
    this.expiryYear,
    this.cvc,
    this.cardholderName,
  });

  bool get isComplete {
    switch (type) {
      case PaymentMethodType.card:
        return cardNumber != null &&
            expiryMonth != null &&
            expiryYear != null &&
            cvc != null &&
            cardholderName != null &&
            cardNumber!.length >= 13 &&
            expiryMonth!.length == 2 &&
            expiryYear!.length == 2 &&
            cvc!.length >= 3 &&
            cardholderName!.isNotEmpty;
      case PaymentMethodType.applePay:
      case PaymentMethodType.googlePay:
      case PaymentMethodType.cash:
      case PaymentMethodType.cashOnDelivery:
      case PaymentMethodType.digitalWallet:
      case PaymentMethodType.bankTransfer:
        return true;
    }
  }
}

/// Interactive payment method selector widget
class PaymentMethodSelector extends StatefulWidget {
  final int amount;
  final String currency;
  final void Function(String paymentMethodId) onPaymentMethodSelected;
  final void Function(String error) onError;

  const PaymentMethodSelector({
    super.key,
    required this.amount,
    required this.currency,
    required this.onPaymentMethodSelected,
    required this.onError,
  });

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

final _colors = DwColors();
final _typography = DwTypography();
final _spacing = DwSpacing();

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  PaymentMethodType _selectedMethod = PaymentMethodType.card;
  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{
        'cardNumber': TextEditingController(),
        'expiryMonth': TextEditingController(),
        'expiryYear': TextEditingController(),
        'cvc': TextEditingController(),
        'cardholderName': TextEditingController(),
      };

  final Map<String, FocusNode> _focusNodes = <String, FocusNode>{
    'cardNumber': FocusNode(),
    'expiryMonth': FocusNode(),
    'expiryYear': FocusNode(),
    'cvc': FocusNode(),
    'cardholderName': FocusNode(),
  };

  String? _cardType;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _setupCardNumberFormatting();
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers.values) {
      controller.dispose();
    }
    for (final FocusNode focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Payment method tabs
        _buildPaymentMethodTabs(),

        const SizedBox(height: 24),

        // Payment method content
        Expanded(child: _buildPaymentMethodContent()),
      ],
    );
  }

  Widget _buildPaymentMethodTabs() {
    return Row(
      children: <Widget>[
        _buildMethodTab(
          type: PaymentMethodType.card,
          icon: Icons.credit_card,
          label: 'Card',
        ),
        const SizedBox(width: 8),
        _buildMethodTab(
          type: PaymentMethodType.applePay,
          icon: Icons.apple,
          label: 'Apple Pay',
        ),
        const SizedBox(width: 8),
        _buildMethodTab(
          type: PaymentMethodType.googlePay,
          icon: Icons.account_balance_wallet,
          label: 'Google Pay',
        ),
      ],
    );
  }

  Widget _buildMethodTab({
    required PaymentMethodType type,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = _selectedMethod == type;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedMethod = type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? _colors.primary.withValues(alpha: 0.1)
                : _colors.surfaceVariant,
            borderRadius: BorderRadius.circular(_spacing.mediumRadius),
            border: Border.all(
              color: isSelected ? _colors.primary : _colors.grey400,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: <Widget>[
              Icon(icon, color: isSelected ? _colors.primary : _colors.grey600),
              const SizedBox(height: 4),
              Text(
                label,
                style: _typography.caption.copyWith(
                  color: isSelected ? _colors.primary : _colors.onSurface,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodContent() {
    switch (_selectedMethod) {
      case PaymentMethodType.card:
        return _buildCardForm();
      case PaymentMethodType.applePay:
        return _buildApplePayButton();
      case PaymentMethodType.googlePay:
        return _buildGooglePayButton();
      case PaymentMethodType.digitalWallet:
      case PaymentMethodType.bankTransfer:
        return _buildDigitalWalletButton();
      case PaymentMethodType.cash:
      case PaymentMethodType.cashOnDelivery:
        return _buildCashButton();
    }
  }

  Widget _buildCardForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Card number
          _buildTextField(
            controller: _controllers['cardNumber']!,
            focusNode: _focusNodes['cardNumber']!,
            label: 'Card Number',
            hint: '1234 5678 9012 3456',
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(19),
              _CardNumberFormatter(),
            ],
            prefixIcon: _buildCardTypeIcon(),
            onChanged: _handleCardNumberChange,
          ),

          const SizedBox(height: 16),

          // Expiry and CVC row
          Row(
            children: <Widget>[
              // Expiry month
              Expanded(
                child: _buildTextField(
                  controller: _controllers['expiryMonth']!,
                  focusNode: _focusNodes['expiryMonth']!,
                  label: 'Month',
                  hint: 'MM',
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  onChanged: _handleExpiryChange,
                ),
              ),

              const SizedBox(width: 16),

              // Expiry year
              Expanded(
                child: _buildTextField(
                  controller: _controllers['expiryYear']!,
                  focusNode: _focusNodes['expiryYear']!,
                  label: 'Year',
                  hint: 'YY',
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  onChanged: _handleExpiryChange,
                ),
              ),

              const SizedBox(width: 16),

              // CVC
              Expanded(
                child: _buildTextField(
                  controller: _controllers['cvc']!,
                  focusNode: _focusNodes['cvc']!,
                  label: 'CVC',
                  hint: '123',
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onChanged: _handleCvcChange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Cardholder name
          _buildTextField(
            controller: _controllers['cardholderName']!,
            focusNode: _focusNodes['cardholderName']!,
            label: 'Cardholder Name',
            hint: 'John Doe',
            textCapitalization: TextCapitalization.words,
            onChanged: _handleCardholderNameChange,
          ),

          const SizedBox(height: 16),

          // Card validation message
          if (_getCardValidationMessage().isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCardValidationColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(_spacing.smallRadius),
                border: Border.all(color: _getCardValidationColor()),
              ),
              child: Text(
                _getCardValidationMessage(),
                style: _typography.caption.copyWith(
                  color: _getCardValidationColor(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildApplePayButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.apple, size: 64, color: _colors.primary),
        const SizedBox(height: 16),
        Text(
          'Pay with Apple Pay',
          style: _typography.headline6,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Secure payment powered by Apple',
          style: _typography.body2.copyWith(color: _colors.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _processApplePay,
            icon: const Icon(Icons.apple),
            label: const Text('Pay with Apple Pay'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _colors.primary,
              foregroundColor: _colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_spacing.mediumRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGooglePayButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.account_balance_wallet, size: 64, color: _colors.primary),
        const SizedBox(height: 16),
        Text(
          'Pay with Google Pay',
          style: _typography.headline6,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Fast and secure payment',
          style: _typography.body2.copyWith(color: _colors.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _processGooglePay,
            icon: const Icon(Icons.account_balance_wallet),
            label: const Text('Pay with Google Pay'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _colors.surface,
              foregroundColor: _colors.onSurface,
              side: BorderSide(color: _colors.grey400),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_spacing.mediumRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDigitalWalletButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.account_balance_wallet, size: 64, color: _colors.primary),
        const SizedBox(height: 16),
        Text(
          'Digital Wallet',
          style: _typography.headline6,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Pay with digital wallet',
          style: _typography.body2.copyWith(color: _colors.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _processDigitalWallet,
            icon: const Icon(Icons.account_balance_wallet),
            label: const Text('Pay with Digital Wallet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _colors.primary,
              foregroundColor: _colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_spacing.mediumRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefixIcon,
    TextCapitalization textCapitalization = TextCapitalization.none,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_spacing.mediumRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_spacing.mediumRadius),
          borderSide: BorderSide(color: _colors.grey400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_spacing.mediumRadius),
          borderSide: BorderSide(color: _colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_spacing.mediumRadius),
          borderSide: BorderSide(color: _colors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildCardTypeIcon() {
    IconData? icon;
    Color? color;

    switch (_cardType) {
      case 'visa':
        icon = Icons.credit_card;
        color = _colors.primary;
        break;
      case 'mastercard':
        icon = Icons.credit_card;
        color = _colors.primary;
        break;
      case 'amex':
        icon = Icons.credit_card;
        color = _colors.primary;
        break;
      default:
        icon = Icons.credit_card;
        color = _colors.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Icon(icon, color: color, size: 20),
    );
  }

  void _setupCardNumberFormatting() {
    _controllers['cardNumber']?.addListener(() {
      final String text =
          _controllers['cardNumber']?.text.replaceAll(' ', '') ?? '';
      if (text.length >= 4) {
        final String cardType = _detectCardType(text);
        setState(() => _cardType = cardType);
      }
    });
  }

  String _detectCardType(String cardNumber) {
    if (cardNumber.startsWith('4')) {
      return 'visa';
    }
    if (cardNumber.startsWith('5') || cardNumber.startsWith('2')) {
      return 'mastercard';
    }
    if (cardNumber.startsWith('3')) {
      return 'amex';
    }
    return 'unknown';
  }

  void _handleCardNumberChange(String value) {
    // Auto-advance to next field when complete
    if (value.length == 19) {
      _focusNodes['expiryMonth']?.requestFocus();
    }
  }

  void _handleExpiryChange(String value) {
    // Auto-advance from month to year
    if ((_controllers['expiryMonth']?.text.length ?? 0) == 2) {
      _focusNodes['expiryYear']?.requestFocus();
    }
    // Auto-advance from year to CVC
    if ((_controllers['expiryYear']?.text.length ?? 0) == 2) {
      _focusNodes['cvc']?.requestFocus();
    }
  }

  void _handleCvcChange(String value) {
    // Auto-advance to cardholder name when complete
    if (value.length >= 3) {
      _focusNodes['cardholderName']?.requestFocus();
    }
  }

  String _getCardValidationMessage() {
    final String cardNumber =
        _controllers['cardNumber']?.text.replaceAll(' ', '') ?? '';
    final String expiryMonth = _controllers['expiryMonth']?.text ?? '';
    final String expiryYear = _controllers['expiryYear']?.text ?? '';
    final String cvc = _controllers['cvc']?.text ?? '';
    final String cardholderName = _controllers['cardholderName']?.text ?? '';

    if (cardNumber.isEmpty &&
        expiryMonth.isEmpty &&
        expiryYear.isEmpty &&
        cvc.isEmpty &&
        cardholderName.isEmpty) {
      return '';
    }

    if (cardNumber.length < 13) {
      return 'Please enter a valid card number';
    }

    if (expiryMonth.isEmpty || expiryYear.isEmpty) {
      return 'Please enter expiry date';
    }

    if (cvc.length < 3) {
      return 'Please enter CVC code';
    }

    if (cardholderName.isEmpty) {
      return 'Please enter cardholder name';
    }

    return 'Card details look good!';
  }

  Color _getCardValidationColor() {
    final String message = _getCardValidationMessage();
    if (message.isEmpty) return _colors.info;
    if (message.contains('Please enter')) return _colors.warning;
    if (message.contains('look good')) return _colors.success;
    return _colors.info;
  }

  void _handleCardholderNameChange(String value) {
    // Auto-advance when complete
    if (value.isNotEmpty) {
      // TODO: bind via payments shim
    }
  }

  Future<void> _processApplePay() async {
    // TODO: call payments shim
    setState(() {
      _isProcessing = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate processing
      widget.onPaymentMethodSelected('apple_pay');
    } catch (e) {
      widget.onError('Apple Pay processing failed: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processGooglePay() async {
    // TODO: call payments shim
    setState(() {
      _isProcessing = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate processing
      widget.onPaymentMethodSelected('google_pay');
    } catch (e) {
      widget.onError('Google Pay processing failed: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processDigitalWallet() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate processing
      widget.onPaymentMethodSelected('digital_wallet');
    } catch (e) {
      widget.onError('Digital wallet payment failed: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Widget _buildCashButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.money, size: 64, color: _colors.primary),
        const SizedBox(height: 16),
        Text(
          'Pay with Cash',
          style: _typography.headline6,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Cash payment on delivery',
          style: _typography.body2.copyWith(color: _colors.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _processCash,
            icon: const Icon(Icons.money),
            label: const Text('Pay with Cash'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _colors.primary,
              foregroundColor: _colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_spacing.mediumRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _processCash() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate processing
      widget.onPaymentMethodSelected('cash');
    } catch (e) {
      widget.onError('Cash payment selection failed: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}

/// Card number formatter for proper spacing
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String text = newValue.text.replaceAll(' ', '');
    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
