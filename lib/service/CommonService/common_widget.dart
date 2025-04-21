import 'package:flutter_application_1/service/CommonService/export_service.dart';
import 'package:intl/intl.dart';

Widget buildContainer({
  required Widget child,
  required EdgeInsets margin,
  required EdgeInsets padding,
}) {
  return Container(
    margin: margin,
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 4),
      ],
    ),
    child: child,
  );
}

Widget buildSection(String title, List<Widget> children) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4),
          ],
        ),
        child: Column(children: children),
      ),
    ],
  );
}

Widget buildProfileItem(BuildContext context, IconData icon, String title,
    String value, Color color, VoidCallback onTap) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle:
        Text(value, style: const TextStyle(fontSize: 14, color: Colors.grey)),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    onTap: onTap,
  );
}

Widget buildSettingsTile(
    BuildContext context, IconData icon, String title, Color color,
    {VoidCallback? onTap}) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    onTap: onTap,
  );
}

Widget buildTextField({
  required TextEditingController controller,
  required String labelText,
  required IconData icon,
  bool obscureText = false,
  bool isNumeric = false,
  IconData? trailingIcon, 
  VoidCallback? onIconTap, 
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
    inputFormatters: isNumeric
        ? [FilteringTextInputFormatter.digitsOnly] // Restricts to integers
        : [],
    style: const TextStyle(fontSize: 16),
    decoration: InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: Colors.black54),
      suffixIcon: trailingIcon != null
          ? IconButton(
              icon: Icon(trailingIcon, color: Colors.black54),
              onPressed: onIconTap, 
            )
          : null,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    ),
  );
}

Widget buildCustomButton({
  required String label,
  required VoidCallback? onPressed,
  bool isLoading = false,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    ),
  );
}

Widget buildMainHeaderBackup() {
  return Container(
    color: Colors.black,
    height: 100,
    width: double.infinity,
    alignment: Alignment.center,
    child: const SafeArea(
      child: Text(
        'GymTest',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );
}

PreferredSizeWidget buildMainHeader({bool showBackButton = false, required BuildContext context}) {
  return AppBar(
    backgroundColor: Colors.black,
    centerTitle: true,
    title: const Text(
      'GymTest',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    leading: showBackButton
        ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          )
        : null,
  );
}

Widget buildMainFooter() {
  return Container(
    color: Colors.black,
    height: 30,
    width: double.infinity,
  );
}

Widget buildSelectOption({
  required String title,
  required bool isSelected,
  required VoidCallback onPressed,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    width: double.infinity,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Colors.black : Colors.white,
        side: const BorderSide(color: Colors.black, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    ),
  );
}

Widget buildMonthPickerTile({
  required BuildContext context,
  required DateTime selectedMonth,
  required String label, // e.g. "Start" or "End"
  required Future<DateTime?> Function(DateTime, String) pickMonth,
  required ValueChanged<DateTime> onMonthChanged,
  Color iconColor = Colors.red,
  EdgeInsets margin = const EdgeInsets.all(0),
}) {
  return GestureDetector(
    onTap: () async {
      // Show your date picker
      final picked = await pickMonth(selectedMonth, 'Select $label Month');
      if (picked != null && picked != selectedMonth) {
        onMonthChanged(picked);
      }
    },
    child: Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon + Text
          Row(
            children: [
              // Circle icon background
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_month,
                  color: iconColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "$label: ${DateFormat('MMMM').format(selectedMonth)}",
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
          // Right arrow
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
        ],
      ),
    ),
  );
}

Widget buildCustomAppBar({
  String? title, // Make title optional
  RxString? dynamicTitle,
}) {
  return AppBar(
    title: dynamicTitle != null
        ? Obx(() => Text(
              "Welcome, ${dynamicTitle.value}",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ))
        : Text(
            title ?? '', // Use title if provided, otherwise empty string
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
    backgroundColor: Colors.white,
    elevation: 0,
    foregroundColor: Colors.black,
  );
}