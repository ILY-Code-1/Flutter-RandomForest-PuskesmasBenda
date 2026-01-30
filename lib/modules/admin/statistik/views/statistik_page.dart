/// Halaman Statistik Admin
/// Menampilkan chart antrian per hari dan summary statistik
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/admin/admin_layout.dart';
import '../controllers/statistik_controller.dart';

class StatistikPage extends GetView<StatistikController> {
  const StatistikPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/admin/statistik',
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header dengan filter bulan
                    _buildHeader(context),
                    const SizedBox(height: 32),

                    // Summary Cards
                    _buildSummaryCards(constraints),
                    const SizedBox(height: 32),

                    // Chart Section
                    _buildChartSection(constraints),
                    const SizedBox(height: 32),

                    // Poli Stats Section
                    _buildPoliStatsSection(constraints),
                    const SizedBox(height: 32),

                    // Status Stats Section
                    _buildStatusStatsSection(constraints),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
          // Loading overlay
          Obx(() {
            if (controller.isLoading.value) {
              return Container(
                color: AppColors.white.withValues(alpha: 0.8),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Memuat data...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  /// Header dengan filter bulan
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistik Antrian',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => Text(
                      'Bulan: ${controller.currentMonth}',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    )),
              ],
            ),
          ),

          /// 👉 DROPDOWN (DESIGN ONLY)
          Obx(() => Transform.translate(
                offset: const Offset(0, -2), // 🔥 geser halus ke atas
                child: SizedBox(
                  height: 40, // 🔥 kunci tinggi biar sejajar
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<DateTime>(
                        value: controller.normalizeMonth(
                            controller.selectedMonth.value),
                        isDense: true,
                        alignment: Alignment.center,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.primaryGreen,
                        ),
                        items: controller.availableMonths.map((date) {
                          return DropdownMenuItem<DateTime>(
                            value: date,
                            child: Text(
                              '${controller.getMonthName(date.month)} ${date.year}',
                              style: const TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          if (value == null) return;
                          controller.selectedMonth.value = value;
                          await controller.loadStatistics();
                        },
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  /// Summary Cards
  Widget _buildSummaryCards(BoxConstraints constraints) {
    final isWide = constraints.maxWidth > 600;

    return Obx(() {
      final cards = [
        _SummaryCard(
          icon: Icons.people_outline,
          title: 'Total Antrian Bulan Ini',
          value: controller.totalQueuesThisMonth.value.toString(),
          color: AppColors.primaryGreen,
        ),
        _SummaryCard(
          icon: Icons.calendar_today,
          title: 'Hari Aktif',
          value: '${controller.totalActiveDays} hari',
          color: Colors.purple,
        ),
        _SummaryCard(
          icon: Icons.access_time,
          title: 'Rata-rata Waktu Tunggu',
          value: '${controller.averageWaitTime.value.toStringAsFixed(1)} menit',
          color: AppColors.accentYellow,
        ),
        _SummaryCard(
          icon: Icons.today,
          title: 'Antrian Hari Ini',
          value: controller.totalAntrianHariIni.toString(),
          color: Colors.blue,
        ),
      ];

      if (isWide) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards
              .map((card) => SizedBox(
                    width: (constraints.maxWidth - 48) / 2,
                    child: _buildSummaryCard(card),
                  ))
              .toList(),
        );
      } else {
        return Column(
          children: cards.map((card) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildSummaryCard(card),
          )).toList(),
        );
      }
    });
  }

  Widget _buildSummaryCard(_SummaryCard card) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: card.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(card.icon, color: card.color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  card.title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Chart Section
  Widget _buildChartSection(BoxConstraints constraints) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grafik Antrian Per Hari',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
              Obx(() => Text(
                    'Rata-rata: ${controller.averagePerActiveDay.toStringAsFixed(1)} antrian/hari',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
                'Total: ${controller.totalQueuesThisMonth.value} antrian • Hari aktif: ${controller.totalActiveDays}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              )),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // Cek apakah bulan yang dipilih adalah bulan sekarang
              final now = DateTime.now();
              final isCurrentMonth = now.year == controller.selectedMonth.value.year &&
                  now.month == controller.selectedMonth.value.month;
              final todayIndex = isCurrentMonth ? now.day - 1 : -1;

              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: controller.maxChartValue * 1.2,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => AppColors.primaryGreen,
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.all(12),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final day = group.x.toInt() + 1;
                        final count = rod.toY.toInt();
                        final month = controller.selectedMonth.value.month;
                        final year = controller.selectedMonth.value.year;

                        // Format tanggal lengkap
                        final dateText = '$day ${_getMonthName(month)} $year';

                        // Tambahkan label "Hari Ini" jika applicable
                        String additionalInfo = '';
                        if (isCurrentMonth && group.x.toInt() == todayIndex) {
                          additionalInfo = '\n📍 Hari Ini';
                        }

                        return BarTooltipItem(
                          '$dateText\n$count antrian$additionalInfo',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Tampilkan label setiap 5 hari
                          final index = value.toInt();
                          if (index >= 0 && index < controller.dailyLabels.length) {
                            if (index % 5 == 0 || index == controller.dailyLabels.length - 1) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  controller.dailyLabels[index],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: index == todayIndex
                                        ? AppColors.primaryGreen
                                        : AppColors.textSecondary,
                                    fontWeight: index == todayIndex
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            }
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() > 0) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColors.greyLight.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: AppColors.greyLight.withValues(alpha: 0.3),
                    ),
                  ),
                  barGroups: List.generate(
                    controller.dailyQueueData.length,
                    (index) {
                      final count = controller.dailyQueueData[index];
                      final hasData = count > 0;
                      final isToday = index == todayIndex;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: count.toDouble(),
                            color: hasData
                                ? (isToday ? Colors.blue : AppColors.primaryGreen)
                                : AppColors.greyLight.withValues(alpha: 0.3),
                            width: isToday ? 16 : 12,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                            borderSide: isToday && hasData
                                ? BorderSide(
                                    color: Colors.blue.withValues(alpha: 0.5),
                                    width: 2,
                                  )
                                : null,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Legend
          Obx(() {
            final now = DateTime.now();
            final isCurrentMonth = now.year == controller.selectedMonth.value.year &&
                now.month == controller.selectedMonth.value.month;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  color: AppColors.primaryGreen,
                  label: 'Ada Antrian',
                ),
                const SizedBox(width: 24),
                _buildLegendItem(
                  color: AppColors.greyLight,
                  label: 'Tidak Ada Antrian',
                ),
                if (isCurrentMonth) ...[
                  const SizedBox(width: 24),
                  _buildLegendItem(
                    color: Colors.blue,
                    label: 'Hari Ini',
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }

  /// Poli Stats Section
  Widget _buildPoliStatsSection(BoxConstraints constraints) {
    final isWide = constraints.maxWidth > 700;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Statistik Per Poli',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
              Obx(() => Text(
                    'Total: ${controller.totalQueuesThisMonth.value} antrian',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            final poliList = controller.poliStats.entries.toList();
            // Sort by count descending
            poliList.sort((a, b) => b.value.compareTo(a.value));

            if (isWide) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: poliList
                    .map((entry) => _buildPoliCard(
                          poliName: entry.key,
                          count: entry.value,
                          total: controller.totalQueuesThisMonth.value,
                        ))
                    .toList(),
              );
            } else {
              return Column(
                children: poliList
                    .map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildPoliCard(
                            poliName: entry.key,
                            count: entry.value,
                            total: controller.totalQueuesThisMonth.value,
                          ),
                        ))
                    .toList(),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildPoliCard({
    required String poliName,
    required int count,
    required int total,
  }) {
    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_hospital,
            color: AppColors.primaryGreen,
            size: 20,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                poliName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Status Stats Section
  Widget _buildStatusStatsSection(BoxConstraints constraints) {
    final isWide = constraints.maxWidth > 600;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Status Antrian',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 20),
          Obx(() {
            final total = controller.totalMenunggu.value +
                controller.totalDilayani.value +
                controller.totalSelesai.value;

            final statusCards = [
              _StatusCard(
                label: 'Menunggu',
                count: controller.totalMenunggu.value,
                color: AppColors.accentYellow,
                total: total,
              ),
              _StatusCard(
                label: 'Sedang Dilayani',
                count: controller.totalDilayani.value,
                color: Colors.blue,
                total: total,
              ),
              _StatusCard(
                label: 'Selesai',
                count: controller.totalSelesai.value,
                color: AppColors.primaryGreen,
                total: total,
              ),
            ];

            if (isWide) {
              return Row(
                children: statusCards
                    .map((card) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _buildStatusCard(card),
                          ),
                        ))
                    .toList(),
              );
            } else {
              return Column(
                children: statusCards.map((card) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildStatusCard(card),
                )).toList(),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildStatusCard(_StatusCard card) {
    final percentage = card.total > 0 ? (card.count / card.total * 100).toStringAsFixed(1) : '0.0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: card.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: card.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  card.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                card.count.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: card.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: card.total > 0 ? card.count / card.total : 0,
              backgroundColor: AppColors.greyLight.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(card.color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });
}

class _StatusCard {
  final String label;
  final int count;
  final Color color;
  final int total;

  _StatusCard({
    required this.label,
    required this.count,
    required this.color,
    required this.total,
  });
}
