class CurrencyData {
  static const Map<String, Map<String, String>> currencies = {
    'USD': {
      'name': 'US Dollar',
      'symbol': '\$',
      'flag': '🇺🇸',
    },
    'EUR': {
      'name': 'Euro',
      'symbol': '€',
      'flag': '🇪🇺',
    },
    'GBP': {
      'name': 'British Pound',
      'symbol': '£',
      'flag': '🇬🇧',
    },
    'INR': {
      'name': 'Indian Rupee',
      'symbol': '₹',
      'flag': '🇮🇳',
    },
    'JPY': {
      'name': 'Japanese Yen',
      'symbol': '¥',
      'flag': '🇯🇵',
    },
    'AUD': {
      'name': 'Australian Dollar',
      'symbol': 'A\$',
      'flag': '🇦🇺',
    },
    'CAD': {
      'name': 'Canadian Dollar',
      'symbol': 'C\$',
      'flag': '🇨🇦',
    },
    'CHF': {
      'name': 'Swiss Franc',
      'symbol': 'Fr',
      'flag': '🇨🇭',
    },
    'CNY': {
      'name': 'Chinese Yuan',
      'symbol': '¥',
      'flag': '🇨🇳',
    },
    'SEK': {
      'name': 'Swedish Krona',
      'symbol': 'kr',
      'flag': '🇸🇪',
    },
    'NZD': {
      'name': 'New Zealand Dollar',
      'symbol': 'NZ\$',
      'flag': '🇳🇿',
    },
  };
  
  static List<String> get currencyCodes => currencies.keys.toList();
}