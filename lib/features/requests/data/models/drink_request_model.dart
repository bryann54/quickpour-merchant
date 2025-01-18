class DrinkRequest {
  final String id;
  final String drinkName;
  final String additionalInstructions;
  final String merchantId;
  final String preferredTime;
  final int quantity;
  final String timestamp;

  DrinkRequest({
    required this.id,
    required this.drinkName,
    required this.additionalInstructions,
    required this.merchantId,
    required this.preferredTime,
    required this.quantity,
    required this.timestamp,
  });

  factory DrinkRequest.fromMap(Map<String, dynamic> map) {
    return DrinkRequest(
      id: map['id'] ?? '',
      drinkName: map['drinkName'] ?? '',
      additionalInstructions: map['additionalInstructions'] ?? '',
      merchantId: map['merchantId'] ?? '',
      preferredTime: map['preferredTime'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      timestamp: map['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'drinkName': drinkName,
      'additionalInstructions': additionalInstructions,
      'merchantId': merchantId,
      'preferredTime': preferredTime,
      'quantity': quantity,
      'timestamp': timestamp,
    };
  }
}
