import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color color;

  const LoadingIndicator({
    Key? key,
    this.message,
    this.size = 40.0,
    this.color = AppColors.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: 3.0,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTextStyles.subtitle2,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

