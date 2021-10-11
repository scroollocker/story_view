import 'package:stories/stories.dart';

final cell =
    StoryCell(imagePath: 'https://picsum.photos/250?image=9', stories: [
  Story(
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    meadiaType: MediaType.video,
  ),
  Story(
    'https://picsum.photos/250?image=9',
    actionButton: StoryActionButton(onTap: () => print('Test')),
    duration: const Duration(seconds: 10),
  ),
  Story(
    'https://github.com/libgit2/libgit2sharp/raw/master/square-logo.png',
  ),
  Story(
    'https://github.com/libgit2/libgit2sharp/raw/master/square-logo.png',
    actionButton: StoryActionButton(onTap: () => print('Test')),
  ),
]);
final cell1 = StoryCell(
    imagePath:
        'https://github.com/libgit2/libgit2sharp/raw/master/square-logo.png',
    stories: [
      Story(
        'https://assets.mixkit.co/videos/preview/mixkit-daytime-city-traffic-aerial-view-56-large.mp4',
        meadiaType: MediaType.video,
      ),
      Story(
        //'assets/images/image.jpg',
        'https://github.com/libgit2/libgit2sharp/raw/master/square-logo.png',
      ),
      Story(
        'https://github.com/libgit2/libgit2sharp/raw/master/square-logo.png',
      ),
      Story(
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        meadiaType: MediaType.video,
      ),
    ]);
final cell2 = StoryCell(
    imagePath:
        'https://github.com/libgit2/libgit2sharp/raw/master/square-logo.png',
    stories: [
      Story(
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        meadiaType: MediaType.video,
      ),
    ]);
