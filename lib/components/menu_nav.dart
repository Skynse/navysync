import 'package:flutter/material.dart';

class MenuNav extends StatefulWidget {
  const MenuNav({super.key});

  @override
  State<MenuNav> createState() => _MenuNavState();
}

class _MenuNavState extends State<MenuNav> {
  List<MenuButton> menuButtons = [
    MenuButton(
      buttonIcon: Icons.home,
      menuOptions: [
        MenuOption(title: 'Teams', icon: Icons.group, onPressed: () {}),
        MenuOption(title: 'Projects', icon: Icons.work, onPressed: () {}),
        MenuOption(title: 'Tasks', icon: Icons.task, onPressed: () {}),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(height: 100, child: Row(children: menuButtons));
  }
}

class MenuButton extends StatelessWidget {
  MenuButton({super.key, required this.menuOptions, required this.buttonIcon});

  final List<MenuOption> menuOptions;
  final double buttonWidth = 100;
  final IconData buttonIcon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTapDown: (details) {
        final RenderBox overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;
        final position = overlay.localToGlobal(details.globalPosition);

        showMenu(
          context: context,
          position: RelativeRect.fromDirectional(textDirection: TextDirection.ltr, start: 0, top: MediaQuery.of(context).size.height + 200, end: position.dx + buttonWidth, bottom: position.dy + 100),
          items:
              menuOptions.map((option) {
                return PopupMenuItem<MenuOption>(
                  value: option,
                  child: ListTile(
                    leading: Icon(option.icon),
                    title: Text(option.title),
                  ),
                  onTap: option.onPressed,
                );
              }).toList(),
        );
      },
      child: Container(
        child: Icon(buttonIcon, size: 30),
        width: buttonWidth,
        height: 100,
      ),
    );
  }
}

class MenuOption {
  final String title;
  final IconData icon;
  Function()? onPressed;
  MenuOption({required this.title, required this.icon, this.onPressed});

  MenuOption copyWith({String? title, IconData? icon, Function()? onPressed}) {
    return MenuOption(
      title: title ?? this.title,
      icon: icon ?? this.icon,
      onPressed: onPressed ?? this.onPressed,
    );
  }
}
