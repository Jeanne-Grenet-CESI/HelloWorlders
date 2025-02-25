import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:helloworlders_flutter/global/utils.dart';

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
                          onPressed: () async {
                            bool isAuth = await Global.isAuthenticated() == 200;
                            if (isAuth) {
                              Navigator.pushNamed(context, '/add-expatriate');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Vous devez être connecté pour créer un profil.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              Navigator.pushNamed(context, '/login');
                            }
                          },
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 36,
                          )),
                      IconButton(
                          onPressed: () async {
                            bool isAuth = await Global.isAuthenticated() == 200;
                            print(isAuth);
                            if (isAuth) {
                              Navigator.pushNamed(context, '/account');
                            } else {
                              Navigator.pushNamed(context, '/login');
                            }
                          },
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
