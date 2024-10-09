import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Column(
                children: [
                  Container(
                    height: 150,
                    color: Colors.transparent,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              // color: Theme.of(context).colorScheme.primary,
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.only(bottom: 20, left: 18),
              child: Text(
                "Drowning Detection",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 1), // changes position of shadow
                  ),
                ],
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 18),
              child: Wrap(
                children: [
                  SingleHomeMenuWidget(
                    icon: Icon(
                      Icons.photo,
                      size: 35,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: "Gambar",
                    onTap: () {
                      context.push("/photo");
                    },
                  ),
                  SingleHomeMenuWidget(
                    icon: Icon(
                      Icons.camera,
                      size: 35,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: "Kamera",
                    onTap: () {
                      context.push("/camera");
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SingleHomeMenuWidget extends StatelessWidget {
  const SingleHomeMenuWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  final String title;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 90,
        width: 80,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon(
            //   Icons.dashboard,
            //   size: 30,
            //   color: Theme.of(context).colorScheme.primary,
            // ),
            icon,
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }
}
