class DashboardResponse {
  final int total;
  final int thisMonth;
  final int thisWeek;
  final int speciesCount;
  final double totalCarbonSequestered;

  const DashboardResponse({
    required this.total,
    required this.thisMonth,
    required this.thisWeek,
    required this.speciesCount,
    required this.totalCarbonSequestered,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      total: _parseInt(json['total']),
      thisMonth: _parseInt(json['this_month']),
      thisWeek: _parseInt(json['this_week']),
      speciesCount: _parseInt(json['species_count']),
      totalCarbonSequestered:
          _parseDouble(json['total_carbon_sequestered']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'this_month': thisMonth,
      'this_week': thisWeek,
      'species_count': speciesCount,
      'total_carbon_sequestered': totalCarbonSequestered,
    };
  }

  // -------------------------------
  // 🔐 SAFE PARSERS (PRIVATE)
  // -------------------------------

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
