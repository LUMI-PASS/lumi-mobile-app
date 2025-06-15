import 'dart:io';

import 'package:lumi_pass/core/error/chess_exception.dart';
import 'package:lumi_pass/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:lumi_pass/feature/profile/data/model/profile_data.dart';
import 'package:lumi_pass/feature/profile/domain/repository/base_profile_repository.dart';
import 'package:lumi_pass/feature/profile/presentation/cubit/image_cubit/image_state.dart';
import 'package:lumi_pass/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class ImageCubit extends ChessCubit<ImageState> {
  final BaseProfileRepository _profileRepository;
  final SafeExecutionManager _safeExecutionManager;

  ImageCubit(
    this._profileRepository,
    this._safeExecutionManager,
  ) : super(const ImageInitState());

  void init(String imageUrl) {
    safeEmit(ImageLoadedState(imageUrl));
  }

  Future<void> uploadProfileImage(File file) async {
    final currentState = state;
    if (currentState is! ImageLoadedState) {
      return;
    }
    safeEmit(const ImageLoadingState());
    try {
      final imageData = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _profileRepository.updateProfileImage(file),
      );

      if (imageData != null) {
        final uploadPhoto = ProfileData(
          image: imageData.url ?? '',
        );
        updateProfile(uploadPhoto);
      } else {
        safeEmit(const ImageErrorState());
      }
    } on ChessException catch (exception) {
      safeEmit(const ImageErrorState());
      throw UnknownChessException(exception.toString());
    }
  }

  Future<void> updateProfile(ProfileData editedProfileData) async {
    try {
      final profileData = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _profileRepository.updateProfile(
          editedProfileData,
        ),
      );

      if (profileData != null) {
        safeEmit(
            ImageLoadedState(profileData.image ?? '', isImageUploaded: true));
      } else {
        safeEmit(const ImageErrorState());
      }
    } on ChessException catch (exception) {
      safeEmit(const ImageErrorState());
      throw UnknownChessException(exception.toString());
    }
  }
}
