import 'package:flutter/material.dart';
import 'package:gatherly/core/constants/style.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class StallCard extends StatelessWidget {
  final String date;
  final String title;
  final String subtitle;
  final String fileCount;
  final String imageUrl;
  final bool useNetworkImage;
  final void Function()? onTap;

  const StallCard({
    super.key,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.fileCount,
    required this.imageUrl,
    required this.useNetworkImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: 39.h,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                child: useNetworkImage
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 22.h,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        imageUrl,
                        width: double.infinity,
                        height: 22.h,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date,
                          style: GoogleFonts.roboto(
                              textStyle: CustomTextStyles.bodyGreyText2),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: GoogleFonts.roboto(
                              textStyle: CustomTextStyles.subheadline),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.roboto(
                              textStyle: CustomTextStyles.bodyGreyText1),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              fileCount,
                              style: GoogleFonts.roboto(
                                  textStyle: CustomTextStyles.bodyGreyText1),
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Text(
                              "files",
                              style: GoogleFonts.roboto(
                                  textStyle: CustomTextStyles.bodyGreyText1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 24.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
