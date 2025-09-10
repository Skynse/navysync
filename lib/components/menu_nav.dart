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
    MenuButton(
      buttonIcon: Icons.people,
      menuOptions: [
        MenuOption(title: 'Teams', icon: Icons.group, onPressed: () {}),
        MenuOption(title: 'Projects', icon: Icons.work, onPressed: () {}),
        MenuOption(title: 'Tasks', icon: Icons.task, onPressed: () {}),
      ],
    ),
    MenuButton(
      buttonIcon: Icons.task,
      menuOptions: [
        MenuOption(title: 'Teams', icon: Icons.group, onPressed: () {}),
        MenuOption(title: 'Projects', icon: Icons.work, onPressed: () {}),
        MenuOption(title: 'Tasks', icon: Icons.task, onPressed: () {}),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: menuButtons,
      ),
    );
  }
}

class MenuButton extends StatefulWidget {
  const MenuButton({super.key, required this.menuOptions, required this.buttonIcon});

  final List<MenuOption> menuOptions;
  final IconData buttonIcon;

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  final double buttonWidth = 100;
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _showMenu(BuildContext context, Offset buttonPosition) {
    _overlayEntry = OverlayEntry(
      builder:
          (context) => Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: _hideMenu,
                  child: Container(color: Colors.transparent),
                ),
              ),
              Positioned(
                left: buttonPosition.dx,
                bottom: 100, // Height of nav bar
                width: buttonWidth,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder:
                        (context, value, child) => Transform.translate(
                          offset: Offset(0, 50 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children:
                          widget.menuOptions
                              .map(
                                (option) => ListTile(
                                  title: Text(option.title),
                                  onTap: () {
                                    _hideMenu();
                                    option.onPressed?.call();
                                  },
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    _isOpen = true;
  }

  void _hideMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final RenderBox button = context.findRenderObject() as RenderBox;
        final buttonPos = button.localToGlobal(Offset.zero);
        if (_isOpen) {
          _hideMenu();
        } else {
          _showMenu(context, buttonPos);
        }
      },
      child: SizedBox(
        width: buttonWidth,
        height: 100,
        child: Icon(widget.buttonIcon, size: 30),
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
