/// Display Antrian Page - Untuk TV Ruang Tunggu
/// Menampilkan daftar antrian semua poli secara realtime
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/display_antrian_controller.dart';
import '../widgets/antrian_card_widget.dart';
import '../widgets/header_display_widget.dart';
import '../widgets/called_queue_dialog.dart';

class DisplayAntrianPage extends GetView<DisplayAntrianController> {
  const DisplayAntrianPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Header
              const HeaderDisplayWidget(),
              
              // Title bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: Colors.orange,
                child: const Center(
                  child: Text(
                    'Daftar Antrian',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              // Queue columns
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Obx(() => Row(
                    children: [
                      // Poli Umum
                      Expanded(
                        child: AntrianCardWidget(
                          title: 'Poli Umum',
                          antrianList: controller.antrianPoliUmum.toList(),
                        ),
                      ),
                      const SizedBox(width: 24),
                      
                      // Poli Gigi
                      Expanded(
                        child: AntrianCardWidget(
                          title: 'Poli Gigi',
                          antrianList: controller.antrianPoliGigi.toList(),
                        ),
                      ),
                      const SizedBox(width: 24),
                      
                      // Poli KIA
                      Expanded(
                        child: AntrianCardWidget(
                          title: 'Poli KIA',
                          antrianList: controller.antrianPoliKia.toList(),
                        ),
                      ),
                    ],
                  )),
                ),
              ),
            ],
          ),
          
          // Called queue dialog overlay (dari Firebase realtime)
          Obx(() {
            if (controller.showCallDialog.value && 
                controller.calledQueueData.value != null) {
              final data = controller.calledQueueData.value!;
              return CalledQueueDialogFromMap(data: data);
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
