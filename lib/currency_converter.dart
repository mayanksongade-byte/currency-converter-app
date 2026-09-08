import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/currency_service.dart';
import 'utils/currency_data.dart';

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  double _result = 0;
  double _liveRate = 0;
  double _swapTurns = 0;

  bool _isDarkMode = false;
  bool _isLoading = false;
  int _requestId = 0;

  final TextEditingController _amountController = TextEditingController();
  final CurrencyService _currencyService = CurrencyService();

  String _fromCurrency = "USD";
  String _toCurrency = "INR";
  List<String> _favoriteCurrencies = [];
  final Map<String, double> _rateCache = {};

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  void _resetConversion() {
    _requestId++;
    setState(() {
      _result = 0;
      _liveRate = 0;
      _isLoading = false;
    });
  }

  Future<void> _convertCurrency() async {
    double amount = double.tryParse(_amountController.text.trim()) ?? 0;

    if (_amountController.text.trim().isEmpty || amount == 0) {
      _resetConversion();
      return;
    }

    String cacheKey = "$_fromCurrency-$_toCurrency";

    if (_rateCache.containsKey(cacheKey)) {
      setState(() {
        _liveRate = _rateCache[cacheKey]!;
        _result = amount * _liveRate;
        _isLoading = false;
      });
      return;
    }

    final int currentRequest = ++_requestId;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _currencyService.fetchExchangeRates(_fromCurrency);

      if (!mounted || currentRequest != _requestId) return;

      if (data != null) {
        final double rate = (data["conversion_rates"][_toCurrency] as num).toDouble();
        _rateCache[cacheKey] = rate;

        setState(() {
          _liveRate = rate;
          _result = amount * _liveRate;
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch rates");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
      );
    }
  }

  void _swapCurrencies() {
    setState(() {
      String temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _swapTurns += 0.5;
    });
    _convertCurrency();
  }

  void _toggleFavorite(String currency) {
    setState(() {
      _favoriteCurrencies.contains(currency)
          ? _favoriteCurrencies.remove(currency)
          : _favoriteCurrencies.add(currency);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = _isDarkMode ? const Color(0xff111827) : const Color(0xffEEF2FF);
    final cardColor = _isDarkMode ? const Color(0xff1F2937) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black;

    return Theme(
      data: theme.copyWith(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        useMaterial3: true,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(textColor),
                const SizedBox(height: 40),
                ResultCard(
                  result: _result,
                  fromCurrency: _fromCurrency,
                  toCurrency: _toCurrency,
                ),
                const SizedBox(height: 35),
                _buildCurrencySelector(cardColor, textColor),
                const SizedBox(height: 40),
                Text(
                  "Enter Amount",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
                ),
                const SizedBox(height: 15),
                _buildAmountInput(cardColor, textColor),
                const SizedBox(height: 30),
                ExchangeRateInfo(
                  isLoading: _isLoading,
                  liveRate: _liveRate,
                  fromCurrency: _fromCurrency,
                  toCurrency: _toCurrency,
                  cardColor: cardColor,
                  textColor: textColor,
                  isDarkMode: _isDarkMode,
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    "Live Currency Converter 🌍",
                    style: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.grey.shade700, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Convert", style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: textColor)),
            const Text("Currencies 💸", style: TextStyle(fontSize: 38, fontWeight: FontWeight.w600, color: Colors.blue)),
          ],
        ),
        IconButton.filledTonal(
          onPressed: () {
            setState(() => _isDarkMode = !_isDarkMode);
            _saveTheme();
          },
          icon: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
        ),
      ],
    );
  }

  Widget _buildCurrencySelector(Color cardColor, Color textColor) {
    return Row(
      children: [
        Expanded(
          child: CurrencyDropdown(
            value: _fromCurrency,
            cardColor: cardColor,
            textColor: textColor,
            onTap: () => _showSearchDialog(true),
          ),
        ),
        const SizedBox(width: 15),
        GestureDetector(
          onTap: _swapCurrencies,
          child: AnimatedRotation(
            turns: _swapTurns,
            duration: const Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.swap_horiz, color: Colors.white, size: 28),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: CurrencyDropdown(
            value: _toCurrency,
            cardColor: cardColor,
            textColor: textColor,
            onTap: () => _showSearchDialog(false),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput(Color cardColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (value) => _convertCurrency(),
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textColor),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "0.00",
          contentPadding: const EdgeInsets.symmetric(vertical: 24),
          prefixIcon: const Icon(Icons.attach_money, color: Colors.green, size: 30),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 20, top: 15),
            child: Text(_fromCurrency, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(bool isFrom) {
    showDialog(
      context: context,
      builder: (context) => CurrencySearchDialog(
        isDarkMode: _isDarkMode,
        favoriteCurrencies: _favoriteCurrencies,
        onSelected: (currency) {
          setState(() {
            if (isFrom) {
              _fromCurrency = currency;
            } else {
              _toCurrency = currency;
            }
            _result = 0;
            _liveRate = 0;
          });
          _convertCurrency();
        },
        onToggleFavorite: _toggleFavorite,
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  final double result;
  final String fromCurrency;
  final String toCurrency;

  const ResultCard({
    super.key,
    required this.result,
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff2563EB), Color(0xff4F46E5)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.currency_exchange, color: Colors.white),
              SizedBox(width: 12),
              Text("Converted Amount", style: TextStyle(color: Colors.white70, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 30),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              result.toStringAsFixed(2),
              key: ValueKey(result),
              style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text("$fromCurrency → $toCurrency", style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }
}

class CurrencyDropdown extends StatelessWidget {
  final String value;
  final Color cardColor;
  final Color textColor;
  final VoidCallback onTap;

  const CurrencyDropdown({
    super.key,
    required this.value,
    required this.cardColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Text(CurrencyData.currencyFlags[value] ?? "🏳️", style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: textColor),
          ],
        ),
      ),
    );
  }
}

class ExchangeRateInfo extends StatelessWidget {
  final bool isLoading;
  final double liveRate;
  final String fromCurrency;
  final String toCurrency;
  final Color cardColor;
  final Color textColor;
  final bool isDarkMode;

  const ExchangeRateInfo({
    super.key,
    required this.isLoading,
    required this.liveRate,
    required this.fromCurrency,
    required this.toCurrency,
    required this.cardColor,
    required this.textColor,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(14)),
            child: isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3))
                : const Icon(Icons.show_chart, color: Colors.green, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Live Exchange Rate",
                  style: TextStyle(fontSize: 15, color: isDarkMode ? Colors.white70 : Colors.grey.shade600),
                ),
                const SizedBox(height: 5),
                Text(
                  liveRate == 0
                      ? "Enter amount to get live rate"
                      : "1 $fromCurrency = ${liveRate.toStringAsFixed(2)} $toCurrency",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CurrencySearchDialog extends StatefulWidget {
  final bool isDarkMode;
  final List<String> favoriteCurrencies;
  final Function(String) onSelected;
  final Function(String) onToggleFavorite;

  const CurrencySearchDialog({
    super.key,
    required this.isDarkMode,
    required this.favoriteCurrencies,
    required this.onSelected,
    required this.onToggleFavorite,
  });

  @override
  State<CurrencySearchDialog> createState() => _CurrencySearchDialogState();
}

class _CurrencySearchDialogState extends State<CurrencySearchDialog> {
  late List<String> _filteredCurrencies;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = List.from(CurrencyData.currencies);
    _sortFavorites();
  }

  void _sortFavorites() {
    _filteredCurrencies.sort((a, b) {
      bool aFav = widget.favoriteCurrencies.contains(a);
      bool bFav = widget.favoriteCurrencies.contains(b);
      if (aFav && !bFav) return -1;
      if (!aFav && bFav) return 1;
      return a.compareTo(b);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDarkMode ? const Color(0xff1F2937) : Colors.white,
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(hintText: "Search currency...", prefixIcon: Icon(Icons.search)),
        onChanged: (value) {
          setState(() {
            _filteredCurrencies = CurrencyData.currencies
                .where((c) => c.toLowerCase().contains(value.toLowerCase()))
                .toList();
            _sortFavorites();
          });
        },
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView.builder(
          itemCount: _filteredCurrencies.length,
          itemBuilder: (context, index) {
            final currency = _filteredCurrencies[index];
            final isFav = widget.favoriteCurrencies.contains(currency);
            return ListTile(
              leading: Text(CurrencyData.currencyFlags[currency] ?? "🏳️", style: const TextStyle(fontSize: 24)),
              title: Text(currency, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: IconButton(
                icon: Icon(isFav ? Icons.star : Icons.star_border, color: Colors.amber),
                onPressed: () {
                  widget.onToggleFavorite(currency);
                  setState(() => _sortFavorites());
                },
              ),
              onTap: () {
                widget.onSelected(currency);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}
