import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:placeholder/core/constants/constants.dart';
import 'package:placeholder/features/release_notes/cubit/release_notes_cubit.dart';

Future<void> checkReleaseNotes(BuildContext context) async {
  ReleaseNotesCubit releaseNotesCubit = context.read<ReleaseNotesCubit>();

  bool hasReadCurrentVersion = await releaseNotesCubit.hasReadCurrentVersion();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  if (!hasReadCurrentVersion) {
    String? notes = await releaseNotesCubit.getReleaseNotes();
    if (notes != null) {
      showModalBottomSheet(
        backgroundColor: const Color.fromARGB(255, 26, 26, 26),
        context: context,
        builder:
            (context) => Container(
              padding: EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What's new in ${packageInfo.version}?",
                    style: Constants.textStyles.title3,
                  ),
                  Divider(color: Colors.grey.shade800),
                  Gap(10),
                  Text(notes, style: Constants.textStyles.description),
                ],
              ),
            ),
      );
      releaseNotesCubit.setHasReadCurrentVersion();
    }
  }
}
