import 'package:flutter/material.dart';
import 'package:placeholder/core/usecases/upload_image.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 39, 39, 39),
        shape: BoxShape.circle,
      ),
      child:
          url == null || url!.isEmpty
              ? Icon(
                Icons.person_rounded,
                color: const Color.fromARGB(255, 153, 153, 153),
              )
              : Image.network(
                getImageUrl(url!),
                fit: BoxFit.cover,

                errorBuilder:
                    (context, error, stackTrace) => Icon(
                      Icons.person_rounded,
                      color: const Color.fromARGB(255, 153, 153, 153),
                    ),
              ),
    );
  }
}
