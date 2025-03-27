import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/shift_model.dart';
import '../../providers/shift_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/confirmation_dialog.dart';

class ManageShiftOffersScreen extends StatelessWidget {
  final ShiftModel shift;
  
  const ManageShiftOffersScreen({
    Key? key,
    required this.shift,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final shiftProvider = Provider.of<ShiftProvider>(context);
    
    if (shift.changeOffers == null || shift.changeOffers!.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(
          title: 'Manage Offers',
        ),
        body: const EmptyState(
          message: 'No offers available for this shift',
          icon: Icons.person_off,
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Manage Offers',
      ),
      body: shiftProvider.isLoading
          ? const LoadingIndicator(message: 'Processing...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shift Change Offers',
                    style: AppTextStyles.headline2,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Select a crew member to approve their offer to take this shift.',
                    style: AppTextStyles.bodyText1,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Reject All Button
                  CustomButton(
                    text: 'Reject All Offers',
                    type: ButtonType.outline,
                    icon: Icons.cancel,
                    onPressed: () => _confirmRejectAll(context),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Offers List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: shift.changeOffers!.length,
                    itemBuilder: (context, index) {
                      final offer = shift.changeOffers![index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        color: AppColors.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: AppColors.primary,
                                    child: Icon(Icons.person, color: AppColors.onPrimary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          offer.userName,
                                          style: AppTextStyles.subtitle1,
                                        ),
                                        Text(
                                          'ID: ${offer.userId}',
                                          style: AppTextStyles.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              if (offer.message != null && offer.message!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Message:',
                                        style: AppTextStyles.caption.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        offer.message!,
                                        style: AppTextStyles.bodyText2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              
                              const SizedBox(height: 16),
                              
                              CustomButton(
                                text: 'Approve Offer',
                                onPressed: () => _confirmApproveOffer(context, offer.userId, offer.userName),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
  
  Future<void> _confirmApproveOffer(BuildContext context, String userId, String userName) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Approve Offer',
      message: 'Are you sure you want to approve this offer? The shift will be reassigned to $userName.',
      confirmText: 'Approve',
      cancelText: 'Cancel',
    );
    
    if (confirmed) {
      _approveOffer(context, userId, userName);
    }
  }
  
  Future<void> _approveOffer(BuildContext context, String userId, String userName) async {
    try {
      final shiftProvider = Provider.of<ShiftProvider>(context, listen: false);
      await shiftProvider.approveShiftChange(shift.id, userId, userName);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer approved successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to approve offer: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  Future<void> _confirmRejectAll(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Reject All Offers',
      message: 'Are you sure you want to reject all offers? This will keep the shift assigned to the original person.',
      confirmText: 'Reject All',
      cancelText: 'Cancel',
      isDestructive: true,
    );
    
    if (confirmed) {
      _rejectAll(context);
    }
  }
  
  Future<void> _rejectAll(BuildContext context) async {
    try {
      final shiftProvider = Provider.of<ShiftProvider>(context, listen: false);
      await shiftProvider.rejectShiftChange(shift.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All offers rejected'),
          backgroundColor: AppColors.success,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reject offers: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

