import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sizer/sizer.dart';

import '../../../common/app_route.dart';
import '../../detail/logic.dart';

class CustomGridImageWidget extends StatelessWidget {
  final List<dynamic> mostViews;
  final bool isReversed;

  CustomGridImageWidget(this.mostViews, {this.isReversed = false});

  @override
  Widget build(BuildContext context) {


    if(mostViews.length<3)return Container();
    var sizeWidth = (33.w - 20);
    return Container(
      width: 100.w,
      child: Row(
        children: isReversed ? _buildReversedLayout(sizeWidth) : _buildNormalLayout(sizeWidth,mostViews.length),
      ),
    );
  }

  List<Widget> _buildNormalLayout(double sizeWidth, int length) {
    return [
      Column(
        children: List.generate(3, (index) => _buildImageContainer(mostViews[index], sizeWidth)),
      ),
      Expanded(
        child: _buildRightSide(sizeWidth),
      ),
    ];
  }

  List<Widget> _buildReversedLayout(double sizeWidth) {
    return [
      Expanded(
        child: _buildRightSide(sizeWidth),
      ),
      Column(
        children: List.generate(3, (index) => _buildImageContainer(mostViews[index], sizeWidth)),
      ),
    ];
  }

  Widget _buildRightSide(double sizeWidth) {
    return Column(
      children: [
        if (mostViews.length > 2)
          _buildImageContainer(mostViews[2], sizeWidth * 2 + 10, isLarge: true),
        if (mostViews.length > 3 || mostViews.length > 4)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (mostViews.length > 3)
                _buildImageContainer(mostViews[3], sizeWidth),
              if (mostViews.length > 4)
                _buildImageContainer(mostViews[4], sizeWidth),
            ],
          ),
      ],
    );
  }

  Widget _buildImageContainer(dynamic data, double size, {bool isLarge = false}) {
    return  GestureDetector(
      onTap: (){
        String itemId = data['id'];
        Get.toNamed(PageRoutes.DETAILIMAGE, arguments: {'id': itemId});
      },
      child: Container(
        width: size,
        height: isLarge ? (size) : size,
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: (data['thumbnails'].toString().length > 3)
              ? Image.network("${data['thumbnails']['336x366']}", fit: BoxFit.cover)
              : Image.asset("assets/images/tum_image.jpeg", fit: BoxFit.cover),
        ),
      ),
    );
  }

}
