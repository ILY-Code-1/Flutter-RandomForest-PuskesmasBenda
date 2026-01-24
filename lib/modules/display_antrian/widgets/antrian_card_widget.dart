/// Widget Card untuk Display Antrian per Poli
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/queue_model.dart';

class AntrianCardWidget extends StatelessWidget {
  final String title;
  final List<QueueModel> antrianList;

  const AntrianCardWidget({
    super.key,
    required this.title,
    required this.antrianList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.black, width: 1),
      ),
      child: Column(
        children: [
          // Title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(19),
                topRight: Radius.circular(19),
              ),
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          
          // Queue list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: antrianList.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada antrian',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.grey,
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: antrianList
                          .map((queue) => _buildQueueButton(queue))
                          .toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueButton(QueueModel queue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        queue.nomorAntrian,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
    );
  }
}
