enum CameraPosition {
  front,
  rear,
  none,
}

extension CameraPositionExtension on String {
  CameraPosition get position {
    switch (this) {
      case "front":
        return CameraPosition.front;
      case "rear":
        return CameraPosition.rear;
      default:
        return CameraPosition.none;
    }
  }
}
