class StoryBack {
  static const image = 'IMAGE';
  static const gradient = 'GRADIENT';

  final int? id;
  final String? type;
  final String? url;
  final String? gradientStart;
  final String? gradientEnd;

  StoryBack(
      {this.id, this.type, this.url, this.gradientEnd, this.gradientStart});
}
