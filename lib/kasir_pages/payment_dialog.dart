import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/kasir/sales_transaction.dart';
import '../widgets/common_widgets.dart';

class PaymentDialog extends StatefulWidget {
  final double totalAmount;
  final Function(PaymentMethod, double) onPaymentComplete;

  const PaymentDialog({
    Key? key,
    required this.totalAmount,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  final TextEditingController _paidAmountController = TextEditingController();
  final currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    if (_selectedPaymentMethod == PaymentMethod.cash) {
      _paidAmountController.text = widget.totalAmount.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _paidAmountController.dispose();
    super.dispose();
  }

  void _onPaymentMethodChanged(PaymentMethod? method) {
    if (method != null) {
      setState(() {
        _selectedPaymentMethod = method;
        if (method != PaymentMethod.cash) {
          _paidAmountController.text = widget.totalAmount.toStringAsFixed(0);
        }
      });
    }
  }

  double get _paidAmount => double.tryParse(_paidAmountController.text) ?? 0;
  double get _changeAmount => _paidAmount - widget.totalAmount;

  bool get _canProcessPayment =>
      _paidAmount >= widget.totalAmount &&
      (_selectedPaymentMethod != PaymentMethod.cash || _changeAmount >= 0);

  void _processPayment() {
    if (_canProcessPayment) {
      widget.onPaymentComplete(_selectedPaymentMethod, _paidAmount);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 400,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: AppColors.brandDark, size: 28),
                SizedBox(width: 12),
                Text(
                  'Pembayaran',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Total Amount
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.brandDark.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Pembelian',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currencyFormat.format(widget.totalAmount),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandDark,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Payment Method Selection
            SectionTitle(title: 'Metode Pembayaran'),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PaymentMethod.values.map((method) {
                return ChoiceChip(
                  label: Text(method.displayName),
                  selected: _selectedPaymentMethod == method,
                  onSelected: (selected) {
                    if (selected) _onPaymentMethodChanged(method);
                  },
                  selectedColor: AppColors.brandDark.withOpacity(0.2),
                  checkmarkColor: AppColors.brandDark,
                );
              }).toList(),
            ),
            SizedBox(height: 24),

            // Payment Amount Input (only for cash)
            if (_selectedPaymentMethod == PaymentMethod.cash) ...[
              SectionTitle(title: 'Jumlah Bayar'),
              SizedBox(height: 12),
              CommonTextField(
                label: 'Masukkan jumlah bayar',
                icon: Icons.attach_money,
                brandColor: AppColors.brandDark,
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() {}),
                controller: _paidAmountController,
              ),
              SizedBox(height: 12),

              // Change Amount
              if (_paidAmount > widget.totalAmount)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kembalian',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      Text(
                        currencyFormat.format(_changeAmount),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

              // Insufficient payment warning
              if (_paidAmount < widget.totalAmount && _paidAmountController.text.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Jumlah bayar kurang dari total pembelian',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ],
                  ),
                ),
            ],

            SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Batal'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: CommonButton(
                    text: 'Proses Pembayaran',
                    onPressed: _canProcessPayment ? _processPayment : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
