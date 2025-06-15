sealed class ImageState {
  const ImageState();
}

class ImageInitState extends ImageState {
  const ImageInitState();
}

class ImageLoadingState extends ImageState {
  const ImageLoadingState();
}

class ImageLoadedState extends ImageState {
  final String imageUrl;
  bool isImageUploaded;

  ImageLoadedState(this.imageUrl, {this.isImageUploaded = false});
}

class ImageErrorState extends ImageState {
  const ImageErrorState();
}
