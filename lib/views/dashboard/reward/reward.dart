import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:patients/models/reward_model.dart';
import 'package:patients/models/service_model.dart';
import 'package:patients/views/dashboard/reward/reward_ctrl.dart';
import 'package:patients/views/dashboard/services/ui/booking_appointment.dart';
import 'package:shimmer/shimmer.dart';

class Rewards extends StatefulWidget {
  const Rewards({super.key});

  @override
  State<Rewards> createState() => _RewardsState();
}

class _RewardsState extends State<Rewards> with SingleTickerProviderStateMixin {
  final RewardCtrl rewardCtrl = Get.put(RewardCtrl());
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (rewardCtrl.hasMore && !rewardCtrl.isLoadingMore) {
        rewardCtrl.loadRewards();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text('Rewards & Points', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20)),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
              backgroundColor: WidgetStatePropertyAll(Colors.grey[100]),
            ),
            icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
            onPressed: () => Get.close(1),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.card_giftcard, size: 20), SizedBox(width: 8), Text('My Rewards')]),
                      ),
                      Tab(
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.history, size: 20), SizedBox(width: 8), Text('Points History')]),
                      ),
                    ],
                    labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
                    unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
                    indicator: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Get.theme.colorScheme.primary.withOpacity(0.1)),
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Get.theme.colorScheme.primary,
                    unselectedLabelColor: Colors.grey.shade600,
                    splashFactory: NoSplash.splashFactory,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        body: TabBarView(controller: _tabController, children: [_buildRewardsTab(), _buildHistoryTab()]),
      ),
    );
  }

  Widget _buildRewardsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await rewardCtrl.loadRewards(reset: true);
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildEnhancedPointsCard(),
            const SizedBox(height: 20),
            Obx(() {
              if (rewardCtrl.isLoading) {
                return _buildShimmerGrid();
              }
              final filteredRewards = rewardCtrl.availableRewards;
              if (filteredRewards.isEmpty) {
                return _buildEmptyRewardsState();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available Rewards',
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                          Text('${filteredRewards.length} available', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.5),
                      itemCount: filteredRewards.length,
                      itemBuilder: (context, index) {
                        final reward = filteredRewards[index];
                        return _buildEnhancedRewardCard(reward);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPointsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Get.theme.colorScheme.primary, Get.theme.colorScheme.primary.withOpacity(0.9)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Get.theme.colorScheme.primary.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: 1)],
      ),
      child: Obx(() {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Points',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      rewardCtrl.pointsBalance.toString(),
                      style: GoogleFonts.poppins(fontSize: 42, fontWeight: FontWeight.w700, color: Colors.white, height: 0.9),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        'Points',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: const Icon(Icons.star_rounded, color: Colors.white, size: 34),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEnhancedRewardCard(Reward reward) {
    final Color categoryColor = Colors.indigo;
    final IconData categoryIcon = Icons.card_giftcard;
    final canRedeem = rewardCtrl.pointsBalance >= reward.points;
    return InkWell(
      onTap: canRedeem ? () => _showRedeemConfirmation(reward) : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 15, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [categoryColor, categoryColor.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Icon(Icons.star_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${reward.points}',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                          child: Icon(categoryIcon, size: 40, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward.title,
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          reward.description,
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${reward.points} points',
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: categoryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 42,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: canRedeem ? Get.theme.colorScheme.primary : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: canRedeem ? [BoxShadow(color: Get.theme.colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : null,
                          ),
                          child: Center(
                            child: Text(
                              canRedeem ? 'Redeem Now' : 'Need ${reward.points - rewardCtrl.pointsBalance.value} more',
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await rewardCtrl.loadTransactions(reset: true);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                if (rewardCtrl.isLoading) {
                  return _buildShimmerList();
                }
                final transactions = rewardCtrl.transactions;
                if (rewardCtrl.transactions.isEmpty) {
                  return _buildEmptyHistoryState();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: transactions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return _buildEnhancedTransactionCard(transaction);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedTransactionCard(PatientPointTransaction transaction) {
    final Color statusColor = transaction.type == 'Credit' ? Colors.green.shade600 : Colors.red.shade600;
    final String statusText = transaction.type == 'Credit' ? 'Credit' : 'Debit';
    final String pointsText = '${transaction.type == 'Credit' ? '+' : '-'}${transaction.points} points';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.description,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTransactionDetail(icon: Icons.star_rounded, text: pointsText, color: statusColor),
                const SizedBox(width: 16),
                _buildTransactionDetail(icon: Icons.calendar_month_rounded, text: DateFormat('MMM dd, yyyy').format(transaction.createdAt), color: Colors.grey.shade600),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _buildTransactionDetail(icon: Icons.account_balance_wallet_rounded, text: 'Balance: ${transaction.balanceAfter} points', color: Colors.grey.shade600),
                      ),
                      if (transaction.source != 'Admin')
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _buildTransactionDetail(icon: Icons.autorenew_rounded, text: 'Source: ${transaction.source}', color: Colors.blue.shade600),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    statusText,
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionDetail({required IconData icon, required String text, required Color color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.75),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 120,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyRewardsState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(color: Get.theme.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.card_giftcard_rounded, size: 50, color: Get.theme.colorScheme.primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text(
            'No Rewards Available',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new exciting rewards',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(color: Get.theme.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.history_rounded, size: 50, color: Get.theme.colorScheme.primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text(
            'No Reward History',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            'Redeem your first reward to see history',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _showRedeemConfirmation(Reward reward) {
    Get.dialog(
      AlertDialog(
        title: Text('Redeem Reward', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to redeem:', style: GoogleFonts.poppins()),
            const SizedBox(height: 12),
            Text(
              reward.title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Get.theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                const SizedBox(width: 4),
                Text('${reward.points} points', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.close(1), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.close(1);
              final service = ServiceModel(id: reward.service["_id"], name: reward.service["name"], points: reward.points, charge: reward.service["charge"], images: [], isActive: true);
              await Get.to(() => BookingAppointment(service: service));
              await rewardCtrl.loadPointsBalance();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Get.theme.colorScheme.primary),
            child: const Text('Confirm Redeem'),
          ),
        ],
      ),
    );
  }
}
