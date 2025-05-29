import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// Layout & theme constants
const double kPagePadding = 16.0;
const double kButtonRadius = 16.0;
const double kScrollThreshold = 200.0;
const double kChipSpacing = 10.0;
const double kTitleDividerHeight = 5.0;

typedef JsonMap = Map<String, dynamic>;

// Modelklasse für ein Menü-Item
class MenuItem {
  final String restaurant;
  final String tag;
  final String name;
  final double preis;

  MenuItem({
    required this.restaurant,
    required this.tag,
    required this.name,
    required this.preis,
  });

  factory MenuItem.fromJson(JsonMap json) {
    return MenuItem(
      restaurant: json['Restaurant'] as String,
      tag: json['Tag'] as String,
      name: json['Gericht Name'] as String,
      preis: (json['Gericht Preis'] as num).toDouble(),
    );
  }
}

class Speisekarte extends StatefulWidget {
  const Speisekarte({super.key});

  @override
  State<Speisekarte> createState() => _SpeisekarteState();
}

class _SpeisekarteState extends State<Speisekarte> {
  late Future<List<MenuItem>> _futureMenus;
  Set<String> _selectedRestaurants = {};
  Set<String> _selectedDays = {};
  String _searchQuery = '';

  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > kScrollThreshold && !_showScrollToTopButton) {
        setState(() => _showScrollToTopButton = true);
      } else if (_scrollController.offset <= kScrollThreshold && _showScrollToTopButton) {
        setState(() => _showScrollToTopButton = false);
      }
    });
    final wd = DateTime.now().weekday;
    const dayNames = {
      DateTime.monday: 'Montag',
      DateTime.tuesday: 'Dienstag',
      DateTime.wednesday: 'Mittwoch',
      DateTime.thursday: 'Donnerstag',
      DateTime.friday: 'Freitag',
    };
    _selectedDays =
        (wd >= DateTime.monday && wd <= DateTime.friday)
            ? {dayNames[wd]!}
            : {};
    _selectedRestaurants.clear();
    _futureMenus = loadMenuItems();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<List<MenuItem>> loadMenuItems() async {
    final raw = await rootBundle.loadString('assets/json/gerichte.json');
    final List<dynamic> data = jsonDecode(raw);
    return data.map((e) => MenuItem.fromJson(e as JsonMap)).toList();
  }

  void _resetFilters() {
    setState(() {
      _selectedRestaurants.clear();
      final wd = DateTime.now().weekday;
      const dayNames = {
        DateTime.monday: 'Montag',
        DateTime.tuesday: 'Dienstag',
        DateTime.wednesday: 'Mittwoch',
        DateTime.thursday: 'Donnerstag',
        DateTime.friday: 'Freitag',
      };
      _selectedDays =
          (wd >= DateTime.monday && wd <= DateTime.friday)
              ? {dayNames[wd]!}
              : {};
    });
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).iconTheme.color;
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: kPagePadding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Was gibt's heute zu essen?",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.restaurant_menu, color: iconColor),
            ],
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kTitleDividerHeight),
          child: const Divider(
            height: kTitleDividerHeight,
            thickness: kTitleDividerHeight,
          ),
        ),
      ),
      floatingActionButton: _showScrollToTopButton
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: const Color(0xFFF0EDDB),
              foregroundColor: const Color(0xFF1A3F2B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kButtonRadius)),
              child: const Icon(Icons.arrow_upward),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(kPagePadding),
        child: FutureBuilder<List<MenuItem>>(
          future: _futureMenus,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Fehler: ${snapshot.error}'));
            }

            final allMenus = snapshot.data!;
            final restaurants =
                allMenus.map((m) => m.restaurant).toSet().toList()..sort();
            final days = <String>[
              'Montag',
              'Dienstag',
              'Mittwoch',
              'Donnerstag',
              'Freitag',
            ];

            final filtered = allMenus.where((m) {
              final okRest = _selectedRestaurants.isEmpty || _selectedRestaurants.contains(m.restaurant);
              final okDay = _selectedDays.isEmpty || _selectedDays.contains(m.tag);
              final okSearch = _searchQuery.isEmpty || m.name.toLowerCase().contains(_searchQuery.toLowerCase());
              return okRest && okDay && okSearch;
            }).toList();

            return ListView(
              controller: _scrollController,
              children: [
                _buildRestaurantChips(context, restaurants),
                const SizedBox(height: kPagePadding * 1.5),
                _buildDayChips(context, days),
                const SizedBox(height: kPagePadding),
                // Reset-Button
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Gericht suchen',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _resetFilters,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kButtonRadius)),
                      ),
                      child: const Text('AUSWAHL ZURÜCKSETZEN'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Gefilterte Liste mit Restaurant-Header
                if (filtered.isEmpty)
                  const Center(child: Text('Keine Treffer'))
                else ...[
                  for (var idx = 0; idx < filtered.length; idx++) ...[
                    if (idx == 0 || filtered[idx].restaurant != filtered[idx - 1].restaurant) ...[
                      const SizedBox(height: 20),
                      const Divider(),
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 20),
                          Text(
                            filtered[idx].restaurant,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    ListTile(
                      title: Text(filtered[idx].name),
                      subtitle: Text(filtered[idx].tag),
                      trailing: Text(
                        '${filtered[idx].preis.toStringAsFixed(2)} €',
                      ),
                    ),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // Helper method for restaurant chips
  Widget _buildRestaurantChips(BuildContext context, List<String> restaurants) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Restaurant auswählen:',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: kPagePadding / 2),
        Wrap(
          runSpacing: kChipSpacing,
          spacing: kChipSpacing,
          children: [
            ChoiceChip(
              label: const Text('Alle'),
              selected: _selectedRestaurants.isEmpty,
              onSelected: (_) => setState(() => _selectedRestaurants.clear()),
            ),
            ...restaurants.map((r) => ChoiceChip(
              label: Text(r),
              selected: _selectedRestaurants.contains(r),
              onSelected: (_) => setState(() {
                _selectedRestaurants.contains(r)
                  ? _selectedRestaurants.remove(r)
                  : _selectedRestaurants.add(r);
              }),
            )),
          ],
        ),
      ],
    );
  }

  // Helper method for day chips
  Widget _buildDayChips(BuildContext context, List<String> days) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tag auswählen:',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: kPagePadding / 2),
        Wrap(
          runSpacing: kChipSpacing,
          spacing: kChipSpacing,
          children: [
            ChoiceChip(
              label: const Text('Alle'),
              selected: _selectedDays.isEmpty,
              onSelected: (_) => setState(() => _selectedDays.clear()),
            ),
            ...days.map((d) => ChoiceChip(
              label: Text(d),
              selected: _selectedDays.contains(d),
              onSelected: (_) => setState(() {
                _selectedDays.contains(d)
                  ? _selectedDays.remove(d)
                  : _selectedDays.add(d);
              }),
            )),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }
}