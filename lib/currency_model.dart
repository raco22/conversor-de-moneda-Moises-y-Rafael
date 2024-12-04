class Currency {
  final String code;
  final String name;

  Currency({required this.code, required this.name});

  static List<Currency> getCurrencies() {
    return [
      Currency(code: 'EUR', name: 'Euro'),
      Currency(code: 'GBP', name: 'Libra esterlina'),
      Currency(code: 'CAD', name: 'Dólar canadiense'),
      Currency(code: 'PLN', name: 'Zloty polaco'),
    ];
  }
}
