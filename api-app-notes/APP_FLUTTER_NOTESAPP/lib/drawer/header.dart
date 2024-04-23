import 'package:flutter/material.dart';
import 'package:notes_app/constants.dart';

class CustomDrawerHeader extends StatelessWidget {
  final bool isColapsed;

  const CustomDrawerHeader({
    super.key,
    required this.isColapsed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: 60,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/logo.jpg',
              width: 40, // Chiều rộng của hình ảnh
              height: 40, // Chiều cao của hình ảnh
              fit: BoxFit.fill, // Cách hiển thị hình ảnh
            ),
          ),
          if (isColapsed) const SizedBox(width: 10),
          if (isColapsed)
            const Expanded(
              flex: 3,
              child: Text(
                'Notes App',
                style: TextStyle(
                  color: kTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                maxLines: 1,
              ),
            ),
          if (isColapsed) const Spacer(),
          if (isColapsed)
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.search,
                  color: kTextColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
