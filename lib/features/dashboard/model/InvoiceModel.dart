class Invoice {
  final String? id;
  final String sellerId;
  final double pieces;
  final double kg;
  final double unitPrice;
  final double totalAmount;
  final String status; // 'draft', 'finalized', 'paid', 'partial'
  final double amountPaid;
  final double amountDue;
  final bool isDraft;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? finalizedAt;
  final DateTime? paymentDate;
  final String? notes;

  Invoice({
    this.id,
    required this.sellerId,
    required this.pieces,
    required this.kg,
    required this.unitPrice,
    this.totalAmount = 0.0,
    this.status = 'draft',
    this.amountPaid = 0.0,
    this.amountDue = 0.0,
    this.isDraft = true,
    required this.createdAt,
    required this.updatedAt,
    this.finalizedAt,
    this.paymentDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'pieces': pieces,
      'kg': kg,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'status': status,
      'amountPaid': amountPaid,
      'amountDue': amountDue,
      'isDraft': isDraft,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'finalizedAt': finalizedAt,
      'paymentDate': paymentDate,
      'notes': notes,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map, String id) {
    return Invoice(
      id: id,
      sellerId: map['sellerId'] ?? '',
      pieces: (map['pieces'] ?? 0.0).toDouble(),
      kg: (map['kg'] ?? 0.0).toDouble(),
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'draft',
      amountPaid: (map['amountPaid'] ?? 0.0).toDouble(),
      amountDue: (map['amountDue'] ?? 0.0).toDouble(),
      isDraft: map['isDraft'] ?? true,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      finalizedAt: map['finalizedAt']?.toDate(),
      paymentDate: map['paymentDate']?.toDate(),
      notes: map['notes'],
    );
  }

  Invoice copyWith({
    String? id,
    String? sellerId,
    double? pieces,
    double? kg,
    double? unitPrice,
    double? totalAmount,
    String? status,
    double? amountPaid,
    double? amountDue,
    bool? isDraft,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? finalizedAt,
    DateTime? paymentDate,
    String? notes,
  }) {
    return Invoice(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      pieces: pieces ?? this.pieces,
      kg: kg ?? this.kg,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      amountPaid: amountPaid ?? this.amountPaid,
      amountDue: amountDue ?? this.amountDue,
      isDraft: isDraft ?? this.isDraft,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      finalizedAt: finalizedAt ?? this.finalizedAt,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
    );
  }
}
