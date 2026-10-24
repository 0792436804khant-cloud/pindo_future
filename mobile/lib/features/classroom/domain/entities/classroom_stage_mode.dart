enum ClassroomStageMode {
  camera,
  whiteboard,
  screenShare,
}

extension ClassroomStageModeExtension on ClassroomStageMode {
  String get name {
    switch (this) {
      case ClassroomStageMode.camera:
        return 'camera';
      case ClassroomStageMode.whiteboard:
        return 'whiteboard';
      case ClassroomStageMode.screenShare:
        return 'screen_share';
    }
  }

  static ClassroomStageMode fromString(String? val) {
    switch (val) {
      case 'whiteboard':
        return ClassroomStageMode.whiteboard;
      case 'screen_share':
        return ClassroomStageMode.screenShare;
      case 'camera':
      default:
        return ClassroomStageMode.camera;
    }
  }
}
