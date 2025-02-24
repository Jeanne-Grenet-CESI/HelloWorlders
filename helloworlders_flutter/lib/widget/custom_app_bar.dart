import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            title: GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    'assets/img/helloworlders.svg',
                    height: 60,
                    width: 60,
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () => {},
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 36,
                          )),
                      IconButton(
                          onPressed: () =>
                              {Navigator.pushNamed(context, '/account')},
                          icon: Icon(
                            Icons.account_circle,
                            color: Theme.of(context).colorScheme.primary,
                            size: 36,
                          ))
                    ],
                  )
                ],
              ),
              onTap: () {
                if (ModalRoute.of(context)?.settings.name == '/home' ||
                    ModalRoute.of(context)?.settings.name == '/login' ||
                    ModalRoute.of(context)?.settings.name == '/register') {
                  return;
                } else {
                  Navigator.pushNamed(context, '/home');
                }
              },
            ),
            centerTitle: false,
            automaticallyImplyLeading: false,
          ),
          const SizedBox(height: 10),
          Container(
            height: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 12);
}
