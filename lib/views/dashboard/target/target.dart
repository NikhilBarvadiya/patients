import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patients/models/target_model.dart';
import 'package:patients/views/dashboard/target/target_ctrl.dart';
import 'package:patients/views/dashboard/target/ui/target_card.dart';
import 'package:shimmer/shimmer.dart'; // Add this import

class Targets extends StatefulWidget {
  const Targets({super.key});

  @override
  State<Targets> createState() => _TargetsState();
}

class _TargetsState extends State<Targets> {
  final TargetCtrl targetCtrl = Get.put(TargetCtrl());
  final ScrollController _scrollController = ScrollController();
  final Map<String, IconData> _filterIcons = {
    'active': Icons.play_arrow,
    'completed': Icons.check_circle,
    'all': Icons.all_inclusive,
    'fitness': Icons.fitness_center,
    'health': Icons.health_and_safety,
    'nutrition': Icons.restaurant,
    'medical': Icons.medication,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (targetCtrl.targets.isEmpty) {
        targetCtrl.loadTargets();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Goals'),
        centerTitle: false,
        leading: IconButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
            backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
          ),
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          onPressed: () => Get.close(1),
        ),
        actions: [
          IconButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
              backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
            ),
            icon: const Icon(Icons.search, color: Colors.black87, size: 20),
            onPressed: () => _showSearch(context),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.primary.withOpacity(0.03),
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(children: [_buildQuickStats(), const SizedBox(height: 16), _buildFilterRow()]),
        ),
        Expanded(
          child: Obx(() {
            if (targetCtrl.isLoading) {
              return _buildShimmerLoading();
            }
            final filteredTargets = targetCtrl.filteredTargets;
            if (filteredTargets.isEmpty) {
              return _buildEmptyState();
            }
            return RefreshIndicator(onRefresh: () => targetCtrl.loadTargets(), child: _buildTargetsList(filteredTargets));
          }),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return GetBuilder<TargetCtrl>(
      builder: (ctrl) {
        return Obx(() {
          if (ctrl.isLoading) {
            return _buildStatsShimmer();
          }
          final stats = ctrl.getStats();
          return Row(
            children: [
              Expanded(child: _buildStatChip('Active', stats['active'].toString(), Icons.trending_up, const Color(0xFF4CAF50))),
              const SizedBox(width: 8),
              Expanded(child: _buildStatChip('Progress', '${(stats['progress'] * 100).toStringAsFixed(0)}%', Icons.bar_chart, const Color(0xFF2196F3))),
              const SizedBox(width: 8),
              Expanded(child: _buildStatChip('Streak', '${stats['streak']}', Icons.local_fire_department, const Color(0xFFFF9800))),
            ],
          );
        });
      },
    );
  }

  Widget _buildStatsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Row(
        children: [
          Expanded(child: _buildShimmerStatChip()),
          const SizedBox(width: 8),
          Expanded(child: _buildShimmerStatChip()),
          const SizedBox(width: 8),
          Expanded(child: _buildShimmerStatChip()),
        ],
      ),
    );
  }

  Widget _buildShimmerStatChip() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 14,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 4),
              Container(
                width: 30,
                height: 10,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: color),
              ),
              Text(title, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _filterIcons.entries.map((entry) {
          final isSelected = targetCtrl.selectedFilter == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                targetCtrl.setFilter(entry.key);
                setState(() {});
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? Get.theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? Get.theme.colorScheme.primary : Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(entry.value, size: 16, color: isSelected ? Colors.white : Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      _getFilterLabel(entry.key),
                      style: GoogleFonts.poppins(fontSize: 12, color: isSelected ? Colors.white : null, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'all':
        return 'All';
      case 'fitness':
        return 'Fitness';
      case 'health':
        return 'Health';
      case 'nutrition':
        return 'Nutrition';
      case 'medical':
        return 'Medical';
      default:
        return filter;
    }
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: ListView.separated(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: Get.height * .1),
        itemCount: 6,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildShimmerCard();
        },
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 120,
                height: 16,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              ),
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 4),
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 12,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
                height: 10,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
              ),
              Container(
                width: 50,
                height: 10,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 100,
                height: 32,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag_outlined, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              targetCtrl.selectedFilter == 'active' ? 'No Active Goals' : 'No Goals Found',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              targetCtrl.selectedFilter == 'active' ? 'Create your first health goal to start tracking' : 'Try changing the filter or create a new goal',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetsList(List<Target> targets) {
    return ListView.separated(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: Get.height * .1),
      itemCount: targets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final target = targets[index];
        return TargetCard(target: target);
      },
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _TargetSearchDelegate(targetCtrl: targetCtrl),
    );
  }
}

class _TargetSearchDelegate extends SearchDelegate {
  final TargetCtrl targetCtrl;

  _TargetSearchDelegate({required this.targetCtrl});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
          backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
        ),
        icon: const Icon(Icons.clear, color: Colors.black87, size: 20),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      ),
      SizedBox(width: 10),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
        backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
      ),
      icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = targetCtrl.targets.where((target) {
      return target.title.toLowerCase().contains(query.toLowerCase()) || target.description.toLowerCase().contains(query.toLowerCase()) || target.category.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return _buildResultsList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? targetCtrl.targets.take(5).toList()
        : targetCtrl.targets
              .where((target) {
                return target.title.toLowerCase().contains(query.toLowerCase()) || target.description.toLowerCase().contains(query.toLowerCase());
              })
              .take(5)
              .toList();
    return _buildResultsList(suggestions);
  }

  Widget _buildResultsList(List<Target> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No goals found', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Try different keywords', style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final target = results[index];
        return TargetCard(target: target);
      },
    );
  }
}
