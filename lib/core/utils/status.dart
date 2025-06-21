import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status) {
    case 'paid': return Colors.green;
    case 'partial': return Colors.orange;
    case 'finalized': return Colors.red;
    default: return Colors.grey;
  }
}

String getStatusText(String status) {
  switch (status) {
    case 'paid': return 'পরিশোধিত';
    case 'partial': return 'আংশিক';
    case 'finalized': return 'বাকি';
    default: return 'খসড়া';
  }
}