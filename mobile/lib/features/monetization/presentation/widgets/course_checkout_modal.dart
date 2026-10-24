import 'package:flutter/material.dart';
import '../controllers/monetization_controller.dart';

class CourseCheckoutModal extends StatefulWidget {
  final int courseId;
  final String courseTitle;
  final double price;
  final String category;
  final MonetizationController monetizationController;
  final VoidCallback onPaymentSuccess;

  const CourseCheckoutModal({
    super.key,
    required this.courseId,
    required this.courseTitle,
    required this.price,
    required this.category,
    required this.monetizationController,
    required this.onPaymentSuccess,
  });

  static Future<void> show({
    required BuildContext context,
    required int courseId,
    required String courseTitle,
    required double price,
    required String category,
    required MonetizationController monetizationController,
    required VoidCallback onPaymentSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CourseCheckoutModal(
        courseId: courseId,
        courseTitle: courseTitle,
        price: price,
        category: category,
        monetizationController: monetizationController,
        onPaymentSuccess: onPaymentSuccess,
      ),
    );
  }

  @override
  State<CourseCheckoutModal> createState() => _CourseCheckoutModalState();
}

class _CourseCheckoutModalState extends State<CourseCheckoutModal> {
  // Tabs: 0 = Academic Voucher (بطاقة الاشتراك), 1 = Electronic Payment (Edahabia / CIB)
  int _selectedTab = 0;

  final _voucherCodeController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expMonthController = TextEditingController();
  final _expYearController = TextEditingController();
  final _cvcController = TextEditingController();
  final _nameController = TextEditingController();

  final _cardFormKey = GlobalKey<FormState>();
  final _voucherFormKey = GlobalKey<FormState>();

  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    widget.monetizationController.clearErrors();
    widget.monetizationController.loadCheckoutIntent(widget.courseId);
  }

  @override
  void dispose() {
    _voucherCodeController.dispose();
    _cardNumberController.dispose();
    _expMonthController.dispose();
    _expYearController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitVoucher() async {
    if (!(_voucherFormKey.currentState?.validate() ?? false)) return;

    final success = await widget.monetizationController.redeemCourseVoucher(
      courseId: widget.courseId,
      voucherCode: _voucherCodeController.text.trim(),
    );

    if (success && mounted) {
      setState(() => _isSuccess = true);
      widget.onPaymentSuccess();
    }
  }

  Future<void> _submitCardPayment() async {
    if (!(_cardFormKey.currentState?.validate() ?? false)) return;

    final success = await widget.monetizationController.processCourseCheckout(
      courseId: widget.courseId,
      cardNumber: _cardNumberController.text.trim(),
      expMonth: int.tryParse(_expMonthController.text.trim()) ?? 12,
      expYear: int.tryParse(_expYearController.text.trim()) ?? 2028,
      cvc: _cvcController.text.trim(),
      cardholderName: _nameController.text.trim(),
    );

    if (success && mounted) {
      setState(() => _isSuccess = true);
      widget.onPaymentSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.monetizationController,
      builder: (context, _) {
        final ctrl = widget.monetizationController;
        final intent = ctrl.currentIntent;

        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: Color(0xFF2DD4BF), width: 1.5),
            ),
          ),
          child: SingleChildScrollView(
            child: _isSuccess ? _buildSuccessReceipt(ctrl) : _buildCheckoutContent(ctrl, intent),
          ),
        );
      },
    );
  }

  Widget _buildCheckoutContent(MonetizationController ctrl, dynamic intent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Course Header & Pricing
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Course Enrollment',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.courseTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.white60),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2DD4BF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2DD4BF).withValues(alpha: 0.3)),
              ),
              child: Text(
                '${widget.price.toStringAsFixed(0)} DZD',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2DD4BF),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Method Selector Tabs
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Expanded(
                child: _tabButton(
                  title: 'Academic Voucher (بطاقة الاشتراك)',
                  icon: Icons.confirmation_number_outlined,
                  isSelected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
              ),
              Expanded(
                child: _tabButton(
                  title: 'Edahabia / CIB Card',
                  icon: Icons.credit_card_rounded,
                  isSelected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Error message if any
        if (ctrl.checkoutError != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFF87171), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ctrl.checkoutError!,
                    style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Tab Content
        if (_selectedTab == 0) _buildVoucherForm(ctrl) else _buildCardForm(ctrl),
      ],
    );
  }

  Widget _tabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2DD4BF).withValues(alpha: 0.22) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: isSelected
              ? Border.all(color: const Color(0xFF2DD4BF).withValues(alpha: 0.5))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? const Color(0xFF2DD4BF) : Colors.white60,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.white60,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherForm(MonetizationController ctrl) {
    return Form(
      key: _voucherFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFF38BDF8), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Enter your teacher subscription card or academic activation voucher to unlock courses & live credits immediately.',
                    style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11.5, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _voucherCodeController,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            decoration: InputDecoration(
              labelText: 'Voucher / Activation Code',
              labelStyle: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 13),
              hintText: 'e.g. PINDO2026 or BAC2026',
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
              prefixIcon: const Icon(Icons.vpn_key_rounded, color: Color(0xFF2DD4BF), size: 20),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white24),
              ),
            ),
            validator: (v) => (v == null || v.trim().length < 4) ? 'Enter a valid voucher code' : null,
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2DD4BF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: ctrl.isProcessingPayment ? null : _submitVoucher,
              child: ctrl.isProcessingPayment
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text(
                      'Activate & Enroll Instantly',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardForm(MonetizationController ctrl) {
    return Form(
      key: _cardFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Card Number (Edahabia / CIB / Bank)',
              labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
              prefixIcon: const Icon(Icons.credit_card, color: Colors.white60, size: 20),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) => (v == null || v.replaceAll(' ', '').length < 13) ? 'Enter valid card number' : null,
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expMonthController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'MM',
                    labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || int.tryParse(v) == null) ? 'MM' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _expYearController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'YYYY',
                    labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || int.tryParse(v) == null) ? 'YYYY' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _cvcController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'CVC',
                    labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.length < 3) ? 'CVC' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Cardholder Name',
              labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
              prefixIcon: const Icon(Icons.person, color: Colors.white60, size: 20),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter cardholder name' : null,
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: ctrl.isProcessingPayment ? null : _submitCardPayment,
              child: ctrl.isProcessingPayment
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Pay ${widget.price.toStringAsFixed(0)} DZD & Enroll',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.white : Colors.white60,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14 : 12.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? const Color(0xFF2DD4BF) : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessReceipt(MonetizationController ctrl) {
    final order = ctrl.lastCompletedOrder;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        const CircleAvatar(
          radius: 30,
          backgroundColor: Color(0xFF065F46),
          child: Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 38),
        ),
        const SizedBox(height: 14),
        const Text(
          'Enrollment Successful!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          'You are now enrolled in ${widget.courseTitle}.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12.5, color: Colors.white60),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              _buildPriceRow('Order Number', order?.orderNumber ?? 'ORD_2026'),
              const SizedBox(height: 6),
              _buildPriceRow('Receipt Reference', order?.receiptNumber ?? 'RCP_XXXX'),
              const SizedBox(height: 6),
              _buildPriceRow('Method', order?.paymentMethod == 'activation_voucher' ? 'Academic Voucher' : 'E-Payment'),
              const SizedBox(height: 6),
              _buildPriceRow('Session Balance Added', '+4 Credits (Live)', isBold: true),
            ],
          ),
        ),
        const SizedBox(height: 18),

        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2DD4BF),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Access Course Now', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
