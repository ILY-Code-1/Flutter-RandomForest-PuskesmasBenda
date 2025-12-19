/// Isi Form Page - Screen 3: Form input data antrian
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../widgets/shared/navbar.dart';
import '../../../widgets/shared/custom_button.dart';
import '../../../widgets/shared/custom_card.dart';
import '../../../widgets/shared/responsive_layout.dart';
import '../controllers/isi_form_controller.dart';

class IsiFormPage extends GetView<IsiFormController> {
  const IsiFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= AppSizes.tabletBreakpoint;
          final isMobile = constraints.maxWidth < AppSizes.mobileBreakpoint;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  // Navbar
                  const AppNavbar(),

                  const SizedBox(height: AppSizes.paddingL),

                  // Title
                  Text(
                    AppStrings.isiForm,
                    style: isDesktop ? AppTextStyles.heading2 : AppTextStyles.heading3,
                  ),

                  SizedBox(height: isMobile ? AppSizes.paddingL : AppSizes.paddingXL),

                  // Form Card
                  ContentConstraint(
                    maxWidth: AppSizes.maxFormWidth,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? AppSizes.paddingM : AppSizes.paddingXL,
                    ),
                    child: CustomCard(
                      padding: EdgeInsets.all(
                        isMobile ? AppSizes.paddingL : AppSizes.paddingXL,
                      ),
                      child: Form(
                        key: controller.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Field: Nama Lengkap
                            _buildTextField(
                              label: AppStrings.namaLengkap,
                              controller: controller.namaController,
                              validator: controller.validateNama,
                              isMobile: isMobile,
                            ),

                            SizedBox(height: isMobile ? AppSizes.paddingL : AppSizes.paddingXL),

                            // Field: Jenis Kelamin
                            _buildDropdownField(isMobile: isMobile),

                            SizedBox(height: isMobile ? AppSizes.paddingL : AppSizes.paddingXL),

                            // Field: Usia
                            _buildTextField(
                              label: AppStrings.usia,
                              controller: controller.usiaController,
                              validator: controller.validateUsia,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              isMobile: isMobile,
                            ),

                            SizedBox(height: isMobile ? AppSizes.paddingXL : AppSizes.paddingXXL),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isMobile ? AppSizes.paddingL : AppSizes.paddingXL),

                  // Button Ambil Antrian
                  CustomButton(
                    text: AppStrings.ambilAntrian,
                    onPressed: controller.submitForm,
                    width: isMobile ? 180 : 220,
                    height: isMobile ? 48 : 56,
                  ),

                  const SizedBox(height: AppSizes.paddingXXL),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Widget text field dengan style underline
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    required bool isMobile,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: AppTextStyles.bodyLarge.copyWith(
        fontSize: isMobile ? 16 : 18,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.label.copyWith(
          fontSize: isMobile ? 14 : 16,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: isMobile ? AppSizes.paddingM : AppSizes.paddingL,
        ),
      ),
    );
  }

  // Widget dropdown untuk jenis kelamin
  Widget _buildDropdownField({required bool isMobile}) {
    return Obx(() => DropdownButtonFormField<String>(
          initialValue: controller.selectedJenisKelamin.value,
          decoration: InputDecoration(
            labelText: AppStrings.jenisKelamin,
            labelStyle: AppTextStyles.label.copyWith(
              fontSize: isMobile ? 14 : 16,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: isMobile ? AppSizes.paddingM : AppSizes.paddingL,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: isMobile ? 16 : 18,
            color: AppColors.textSecondary,
          ),
          items: controller.jenisKelaminList
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: controller.setJenisKelamin,
        ));
  }
}
