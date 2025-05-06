import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:women_safety_framework/utils/quotes.dart';
import 'package:women_safety_framework/widgets/home_widgets/safewebview.dart';

import '../../reusable_widgets/textStyles.dart';

class CustomCarousel extends StatelessWidget {
  const CustomCarousel({Key? key}) : super(key: key);

  void navigateToRoute(BuildContext context, Widget route) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => route));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CarouselSlider(
        options: CarouselOptions(
          aspectRatio: 2.0,
          autoPlay: true,
          enlargeCenterPage: true,
        ),
        items: List.generate(
          imageSliders.length,
              (index) => Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onTap: () {
                if (index == 0) {
                  navigateToRoute(
                      context,
                      SafeWebView(
                          url:
                          "https://www.internationalwomensday.com/About"));
                } else if (index == 1) {
                  navigateToRoute(
                      context,
                      SafeWebView(
                          url:
                          "https://www.healthline.com/health/womens-health/self-defense-tips-escape"));
                } else if (index == 2) {
                  navigateToRoute(
                      context,
                      SafeWebView(
                          url:
                          "https://testbook.com/static-gk/laws-protecting-women-in-india"));
                } else {
                  navigateToRoute(
                      context,
                      SafeWebView(
                          url:
                          "https://www.mayoclinic.org/healthy-lifestyle/adult-health/in-depth/domestic-violence/art-20048397"));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          imageSliders[index],
                        ))),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 8),
                      child: normalText(articleTitle[index]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
