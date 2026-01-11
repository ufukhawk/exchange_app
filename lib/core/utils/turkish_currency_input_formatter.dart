import 'package:flutter/services.dart';

class TurkishCurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Boş string ise direkt döndür
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Sadece rakamları ve virgülü kabul et
    String text = newValue.text.replaceAll(RegExp(r'[^\d,]'), '');

    // Birden fazla virgül varsa, sadece ilkini tut
    final int commaCount = ','.allMatches(text).length;
    if (commaCount > 1) {
      final int firstCommaIndex = text.indexOf(',');
      text = text.substring(0, firstCommaIndex + 1) +
          text.substring(firstCommaIndex + 1).replaceAll(',', '');
    }

    // Virgülden sonra en fazla 2 basamak
    if (text.contains(',')) {
      final List<String> parts = text.split(',');
      if (parts[1].length > 2) {
        text = '${parts[0]},${parts[1].substring(0, 2)}';
      }
    }

    // Binlik ayırıcıları ekle
    final String formatted = _formatWithThousandsSeparator(text);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatWithThousandsSeparator(String text) {
    // Virgülü ayır
    final List<String> parts = text.split(',');
    final String integerPart = parts[0];
    final String decimalPart = parts.length > 1 ? parts[1] : '';

    // Tam sayı kısmına binlik ayırıcı ekle
    var formattedInteger = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count == 3) {
        formattedInteger = '.$formattedInteger';
        count = 0;
      }
      formattedInteger = integerPart[i] + formattedInteger;
      count++;
    }

    // Birleştir
    if (text.contains(',')) {
      return '$formattedInteger,$decimalPart';
    }
    return formattedInteger;
  }
}
