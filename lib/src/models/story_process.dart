enum StoryStatus {
  init,
  loading,
  error,
  timeout,
  complete,
  downloading,
}

class StoryProcess {
  final int id;
  final Duration? duration;
  final StoryStatus status;
  final dynamic error;

  StoryProcess(
      {required this.id, this.duration, required this.status, this.error});
}
