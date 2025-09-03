  import 'package:flutter/material.dart';
import 'package:sombot_pc/utils/colors.dart';

class LoadingGrid extends StatelessWidget {
  final double screenWidth;
  const LoadingGrid({Key? key, required this.screenWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double aspectRatio = screenWidth > 400 ? 0.7 : 0.58;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: aspectRatio,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.second2,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        );
      },
    );
  }
}