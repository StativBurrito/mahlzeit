import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:m3_carousel/m3_carousel.dart';

// Layout & theme constants
const double kPagePadding = 16.0;
const double kButtonRadius = 16.0;
const double kScrollThreshold = 200.0;
const double kChipSpacing = 10.0;
const double kTitleDividerHeight = 5.0;
const double kPriceMin = 0.0;
const double kPriceMax = 20.0;

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
  bool _dialogDisplayed = false;
  RangeValues _selectedPriceRange = const RangeValues(kPriceMin, kPriceMax);

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dialogDisplayed) {
        _dialogDisplayed = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            titlePadding: EdgeInsets.only(right: 10, top: 10),
            title: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, schön dich zu sehen!",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Die Webseite ist aktuell noch in Aufbau, aber schau dich doch gerne schon mal um!",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Falls du Probleme entdecken solltest, melde dich gerne bei mir",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.mood,
                      
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text('OK!'),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    });
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
      _selectedPriceRange = const RangeValues(kPriceMin, kPriceMax);
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
              final okPrice = m.preis >= _selectedPriceRange.start && m.preis <= _selectedPriceRange.end;
              return okRest && okDay && okSearch && okPrice;
            }).toList();

            return ListView(
              controller: _scrollController,
              children: [
                _buildRestaurantChips(context, restaurants),
                const SizedBox(height: kPagePadding * 1.5),
                _buildDayChips(context, days),
                const SizedBox(height: kPagePadding),
                // Price filter
                Text(
                  'Preis filtern:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_selectedPriceRange.start.toStringAsFixed(2)} €'),
                    Text('${_selectedPriceRange.end.toStringAsFixed(2)} €'),
                  ],
                ),
                RangeSlider(
                  values: _selectedPriceRange,
                  min: kPriceMin,
                  max: kPriceMax,
                  divisions: 20,
                  labels: RangeLabels(
                    '${_selectedPriceRange.start.toStringAsFixed(2)} €',
                    '${_selectedPriceRange.end.toStringAsFixed(2)} €',
                  ),
                  onChanged: (values) => setState(() => _selectedPriceRange = values),
                ),
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
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => RestaurantDetailPage(
                              restaurantName: filtered[idx].restaurant,
                              menuItems: allMenus.where((m) => m.restaurant == filtered[idx].restaurant).toList(),
                            ),
                          ));
                        },
                        child: Row(
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
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right,
                              color: iconColor,
                            ),
                          ],
                        ),
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

class RestaurantDetailPage extends StatefulWidget {
  final String restaurantName;
  final List<MenuItem> menuItems;
  const RestaurantDetailPage({
    Key? key,
    required this.restaurantName,
    required this.menuItems,
  }) : super(key: key);

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurantName),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Placeholder for restaurant image
          Container(
            height: 200,
            color: Colors.grey.shade300,
            child: const Icon(
              Icons.restaurant,
              size: 80,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              widget.restaurantName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Musterstraße 1, 12345 Musterstadt', // Placeholder address
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(height: kPagePadding),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.link),
                  label: const Text('Zur Webseite'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                const SizedBox(width: kPagePadding),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Zur Wochenkarte'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: kPagePadding),
          SizedBox(
            height: 200,
            child: M3Carousel(
              type: 'uncontained',
              heroAlignment: 'center',
              onTap: (int tapIndex) {
                // TODO: handle tap if needed
              },
              children: widget.menuItems.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                return SizedBox(
                  height: 200,
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                    child: Stack(
                      children: [
                        // Watermark with first two uppercase letters of the day
                        Positioned.fill(
                          child: Center(
                            child: Text(
                              item.tag.substring(0, 2).toUpperCase(),
                              style: TextStyle(
                                fontSize: 100,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                              ),
                            ),
                          ),
                        ),
                        // Actual content
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 70.0, top: 20.0, bottom: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.tag,
                                style: const TextStyle(fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                              Text(
                                item.name,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                maxLines: 3,
                                overflow: TextOverflow.fade,
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}