/// Widget Dialog Konfirmasi reusable untuk Admin Area
/// Template dialog dengan GetX untuk berbagai keperluan konfirmasi
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';

class ConfirmDialog {
  /// Menampilkan dialog konfirmasi
  /// [title] - Judul dialog
  /// [message] - Pesan konfirmasi
  /// [confirmText] - Teks tombol konfirmasi (default: 'Ya')
  /// [cancelText] - Teks tombol batal (default: 'Batal')
  /// [onConfirm] - Callback saat konfirmasi
  /// [onCancel] - Callback saat batal (optional)
  /// [isDestructive] - Jika true, tombol konfirmasi berwarna merah
  static Future<bool?> show({
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
  }) {
    return Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? Colors.red.withValues(alpha: 0.1)
                      : AppColors.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDestructive ? Icons.warning_amber_rounded : Icons.help_outline,
                  size: 32,
                  color: isDestructive ? Colors.red : AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDestructive ? Colors.red : AppColors.primaryGreen,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back(result: false);
                        onCancel?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.greyLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Confirm button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(result: true);
                        onConfirm?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor:
                            isDestructive ? Colors.red : AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Dialog konfirmasi logout
  static Future<bool?> showLogout({VoidCallback? onConfirm}) {
    return show(
      title: 'Konfirmasi Logout',
      message: 'Apakah Anda yakin ingin keluar dari sistem?',
      confirmText: 'Logout',
      cancelText: 'Batal',
      isDestructive: true,
      onConfirm: onConfirm,
    );
  }

  /// Dialog konfirmasi hapus
  static Future<bool?> showDelete({
    required String itemName,
    VoidCallback? onConfirm,
  }) {
    return show(
      title: 'Konfirmasi Hapus',
      message: 'Apakah Anda yakin ingin menghapus $itemName?',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      isDestructive: true,
      onConfirm: onConfirm,
    );
  }

  /// Dialog konfirmasi simpan
  static Future<bool?> showSave({VoidCallback? onConfirm}) {
    return show(
      title: 'Konfirmasi Simpan',
      message: 'Apakah Anda yakin ingin menyimpan perubahan?',
      confirmText: 'Simpan',
      cancelText: 'Batal',
      onConfirm: onConfirm,
    );
  }
}
