import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:placeholder/main.dart';

part 'release_notes_state.dart';

class ReleaseNotesCubit extends HydratedCubit<ReleaseNotesState> {
  ReleaseNotesCubit() : super(ReleaseNotesState(null));

  @override
  ReleaseNotesState? fromJson(Map<String, dynamic> json) {
    return ReleaseNotesState(json["hasReadVersion"]);
  }

  @override
  Map<String, dynamic>? toJson(ReleaseNotesState state) {
    return {"hasReadVersion": state.hasReadVersion};
  }

  void setHasReadCurrentVersion({bool hasRead = true}) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    emit(ReleaseNotesState(hasRead ? packageInfo.version : null));
  }

  Future<bool> hasReadCurrentVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    log("Current version: ${packageInfo.version}");
    return state.hasReadVersion == packageInfo.version;
  }

  Future<String?> getReleaseNotes() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final response = await sb.from("release_notes").select();
    String? notes =
        response.firstWhereOrNull(
          (element) => element["version"] == packageInfo.version,
        )?["notes"];
    return notes;
  }
}
