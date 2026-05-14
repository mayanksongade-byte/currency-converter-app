import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  double result = 0;
  double liveRate = 0;
  double swapTurns = 0;

  bool isDarkMode = false;
  bool isLoading = false;
  int requestId = 0;

  final TextEditingController textEditingController = TextEditingController();

  String fromCurrency = "USD";
  String toCurrency = "INR";
  List<String> favoriteCurrencies = [];

  List<String> currencies = [
    "USD",
    "INR",
    "EUR",
    "GBP",
    "JPY",
    "AUD",
    "CAD",
    "CHF",
    "CNY",
    "SGD",
    "AED",
    "AFN",
    "ALL",
    "AMD",
    "ANG",
    "AOA",
    "ARS",
    "AWG",
    "AZN",
    "BAM",
    "BBD",
    "BDT",
    "BGN",
    "BHD",
    "BIF",
    "BMD",
    "BND",
    "BOB",
    "BRL",
    "BSD",
    "BTN",
    "BWP",
    "BYN",
    "BZD",
    "CLP",
    "COP",
    "CRC",
    "CUP",
    "CZK",
    "DKK",
    "DOP",
    "DZD",
    "EGP",
    "ETB",
    "FJD",
    "GEL",
    "GHS",
    "GMD",
    "GTQ",
    "HKD",
    "HNL",
    "HRK",
    "HUF",
    "IDR",
    "ILS",
    "IQD",
    "IRR",
    "ISK",
    "JMD",
    "JOD",
    "KES",
    "KGS",
    "KHR",
    "KRW",
    "KWD",
    "KZT",
    "LAK",
    "LBP",
    "LKR",
    "MAD",
    "MDL",
    "MGA",
    "MKD",
    "MMK",
    "MNT",
    "MOP",
    "MUR",
    "MVR",
    "MXN",
    "MYR",
    "NAD",
    "NGN",
    "NOK",
    "NPR",
    "NZD",
    "OMR",
    "PAB",
    "PEN",
    "PHP",
    "PKR",
    "PLN",
    "PYG",
    "QAR",
    "RON",
    "RSD",
    "RUB",
    "SAR",
    "SEK",
    "THB",
    "TRY",
    "TWD",
    "UAH",
    "UYU",
    "UZS",
    "VND",
    "ZAR",
  ];

  Map<String, String> currencyFlags = {
    "USD": "🇺🇸",
    "INR": "🇮🇳",
    "EUR": "🇪🇺",
    "GBP": "🇬🇧",
    "JPY": "🇯🇵",
    "AUD": "🇦🇺",
    "CAD": "🇨🇦",
    "CHF": "🇨🇭",
    "CNY": "🇨🇳",
    "SGD": "🇸🇬",
    "AED": "🇦🇪",
    "AFN": "🇦🇫",
    "ALL": "🇦🇱",
    "AMD": "🇦🇲",
    "ANG": "🇳🇱",
    "AOA": "🇦🇴",
    "ARS": "🇦🇷",
    "AWG": "🇦🇼",
    "AZN": "🇦🇿",
    "BAM": "🇧🇦",
    "BBD": "🇧🇧",
    "BDT": "🇧🇩",
    "BGN": "🇧🇬",
    "BHD": "🇧🇭",
    "BIF": "🇧🇮",
    "BMD": "🇧🇲",
    "BND": "🇧🇳",
    "BOB": "🇧🇴",
    "BRL": "🇧🇷",
    "BSD": "🇧🇸",
    "BTN": "🇧🇹",
    "BWP": "🇧🇼",
    "BYN": "🇧🇾",
    "BZD": "🇧🇿",
    "CLP": "🇨🇱",
    "COP": "🇨🇴",
    "CRC": "🇨🇷",
    "CUP": "🇨🇺",
    "CZK": "🇨🇿",
    "DKK": "🇩🇰",
    "DOP": "🇩🇴",
    "DZD": "🇩🇿",
    "EGP": "🇪🇬",
    "ETB": "🇪🇹",
    "FJD": "🇫🇯",
    "GEL": "🇬🇪",
    "GHS": "🇬🇭",
    "GMD": "🇬🇲",
    "GTQ": "🇬🇹",
    "HKD": "🇭🇰",
    "HNL": "🇭🇳",
    "HRK": "🇭🇷",
    "HUF": "🇭🇺",
    "IDR": "🇮🇩",
    "ILS": "🇮🇱",
    "IQD": "🇮🇶",
    "IRR": "🇮🇷",
    "ISK": "🇮🇸",
    "JMD": "🇯🇲",
    "JOD": "🇯🇴",
    "KES": "🇰🇪",
    "KGS": "🇰🇬",
    "KHR": "🇰🇭",
    "KRW": "🇰🇷",
    "KWD": "🇰🇼",
    "KZT": "🇰🇿",
    "LAK": "🇱🇦",
    "LBP": "🇱🇧",
    "LKR": "🇱🇰",
    "MAD": "🇲🇦",
    "MDL": "🇲🇩",
    "MGA": "🇲🇬",
    "MKD": "🇲🇰",
    "MMK": "🇲🇲",
    "MNT": "🇲🇳",
    "MOP": "🇲🇴",
    "MUR": "🇲🇺",
    "MVR": "🇲🇻",
    "MXN": "🇲🇽",
    "MYR": "🇲🇾",
    "NAD": "🇳🇦",
    "NGN": "🇳🇬",
    "NOK": "🇳🇴",
    "NPR": "🇳🇵",
    "NZD": "🇳🇿",
    "OMR": "🇴🇲",
    "PAB": "🇵🇦",
    "PEN": "🇵🇪",
    "PHP": "🇵🇭",
    "PKR": "🇵🇰",
    "PLN": "🇵🇱",
    "PYG": "🇵🇾",
    "QAR": "🇶🇦",
    "RON": "🇷🇴",
    "RSD": "🇷🇸",
    "RUB": "🇷🇺",
    "SAR": "🇸🇦",
    "SEK": "🇸🇪",
    "THB": "🇹🇭",
    "TRY": "🇹🇷",
    "TWD": "🇹🇼",
    "UAH": "🇺🇦",
    "UYU": "🇺🇾",
    "UZS": "🇺🇿",
    "VND": "🇻🇳",
    "ZAR": "🇿🇦",
  };

  Map<String, double> rateCache = {};

  void toggleFavoriteCurrency(String currency) {
    setState(() {
      favoriteCurrencies.contains(currency)
          ? favoriteCurrencies.remove(currency)
          : favoriteCurrencies.add(currency);
    });
  }

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDarkMode);
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  void resetConversionOnly() {
    requestId++;
    setState(() {
      result = 0;
      liveRate = 0;
      isLoading = false;
    });
  }

  Future<void> convertCurrency() async {
    double amount = double.tryParse(textEditingController.text.trim()) ?? 0;

    if (textEditingController.text.trim().isEmpty || amount == 0) {
      resetConversionOnly();
      return;
    }

    String cacheKey = "$fromCurrency-$toCurrency";

    if (rateCache.containsKey(cacheKey)) {
      liveRate = rateCache[cacheKey]!;
      setState(() {
        result = amount * liveRate;
        isLoading = false;
      });
      return;
    }

    final int currentRequest = ++requestId;

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(
        "https://v6.exchangerate-api.com/v6/4c574df1a1a37414b36c0d18/latest/$fromCurrency",
      );

      final response = await http.get(url);

      if (!mounted) return;

      if (currentRequest != requestId ||
          textEditingController.text.trim().isEmpty) {
        return;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        liveRate = (data["conversion_rates"][toCurrency] as num).toDouble();
        rateCache[cacheKey] = liveRate;

        setState(() {
          result = amount * liveRate;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch exchange rate")),
      );
    }

    if (!mounted) return;

    if (currentRequest == requestId) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void swapCurrencies() {
    setState(() {
      String temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
      swapTurns += 0.5;
    });

    convertCurrency();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xff111827)
          : const Color(0xffEEF2FF),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Convert",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const Text(
                        "Currencies 💸",
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        isDarkMode = !isDarkMode;
                      });
                      await saveTheme();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white10 : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xff2563EB), Color(0xff4F46E5)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.currency_exchange,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Converted Amount",
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        result.toStringAsFixed(2),
                        key: ValueKey(result.toStringAsFixed(2)),
                        style: const TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      "$fromCurrency → $toCurrency",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              Row(
                children: [
                  Expanded(child: buildDropdown(fromCurrency, true)),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: swapCurrencies,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: AnimatedRotation(
                        turns: swapTurns,
                        duration: const Duration(milliseconds: 400),
                        child: const Icon(
                          Icons.swap_horiz,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(child: buildDropdown(toCurrency, false)),
                ],
              ),

              const SizedBox(height: 40),

              Text(
                "Enter Amount",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 15),

              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xff1F2937) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: TextField(
                  controller: textEditingController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {
                    if (value.trim().isEmpty) {
                      resetConversionOnly();
                      return;
                    }
                    convertCurrency();
                  },
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "0.00",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    contentPadding: const EdgeInsets.symmetric(vertical: 24),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.attach_money,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    suffix: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Text(
                        fromCurrency,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xff1F2937) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            )
                          : const Icon(
                              Icons.show_chart,
                              color: Colors.green,
                              size: 28,
                            ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Live Exchange Rate",
                            style: TextStyle(
                              fontSize: 15,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              liveRate == 0
                                  ? "Enter amount to get live rate"
                                  : "1 $fromCurrency = ${liveRate.toStringAsFixed(2)} $toCurrency",
                              key: ValueKey(liveRate.toString()),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Center(
                child: Text(
                  "Live Currency Converter 🌍",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDropdown(String value, bool isFrom) {
    return GestureDetector(
      onTap: () {
        showCurrencySearchDialog(isFrom);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xff1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              currencyFlags[value] ?? "🏳️",
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  void showCurrencySearchDialog(bool isFrom) {
    TextEditingController searchController = TextEditingController();

    List<String> filteredCurrencies = List.from(currencies);

    void sortFavoritesOnTop() {
      filteredCurrencies.sort((a, b) {
        bool aFav = favoriteCurrencies.contains(a);
        bool bFav = favoriteCurrencies.contains(b);

        if (aFav && !bFav) return -1;
        if (!aFav && bFav) return 1;

        return a.compareTo(b);
      });
    }

    sortFavoritesOnTop();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor:
              isDarkMode ? const Color(0xff1F2937) : Colors.white,

              title: TextField(
                controller: searchController,
                autofocus: true,

                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),

                decoration: InputDecoration(
                  hintText: "Search currency...",

                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white54 : Colors.grey,
                  ),

                  prefixIcon: const Icon(Icons.search),
                ),

                onChanged: (value) {
                  setDialogState(() {
                    filteredCurrencies = currencies
                        .where(
                          (currency) => currency
                          .toLowerCase()
                          .contains(value.toLowerCase()),
                    )
                        .toList();

                    sortFavoritesOnTop();
                  });
                },
              ),

              content: SizedBox(
                width: double.maxFinite,
                height: 350,

                child: ListView.builder(
                  itemCount: filteredCurrencies.length,

                  itemBuilder: (context, index) {
                    String currency = filteredCurrencies[index];

                    return ListTile(
                      leading: Text(
                        currencyFlags[currency] ?? "🏳️",
                        style: const TextStyle(fontSize: 24),
                      ),

                      title: Text(
                        currency,

                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      trailing: IconButton(
                        icon: Icon(
                          favoriteCurrencies.contains(currency)
                              ? Icons.star
                              : Icons.star_border,

                          color: Colors.amber,
                        ),

                        onPressed: () {
                          setDialogState(() {
                            toggleFavoriteCurrency(currency);

                            sortFavoritesOnTop();
                          });
                        },
                      ),

                      onTap: () {
                        setState(() {
                          if (isFrom) {
                            fromCurrency = currency;
                          } else {
                            toCurrency = currency;
                          }

                          result = 0;
                          liveRate = 0;
                        });

                        Navigator.pop(context);

                        convertCurrency();
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
