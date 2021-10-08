import 'package:stories/stories.dart';

final cell = StoryCell(name: 'Octane', imagePath: 'assets/images/octane.jpg');
final cell1 = StoryCell(name: 'Cat', imagePath: 'assets/images/cat.jpg');
final cell2 = StoryCell(name: 'Cat1', imagePath: 'assets/images/cat.jpg');

final List<Story> stories = [
  Story(
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    cell,
    meadiaType: MediaType.video,
  ),
  Story(
    'assets/images/image.jpg',
    cell,
    actionButton: StoryActionButton(onTap: () => print('Test')),
    duration: const Duration(seconds: 10),
  ),
  Story('assets/gif/wow-cat.gif', cell),
  Story(
    'https://assets.mixkit.co/videos/preview/mixkit-daytime-city-traffic-aerial-view-56-large.mp4',
    cell1,
    meadiaType: MediaType.video,
  ),
  Story(
    'assets/images/image.jpg',
    cell1,
    //actionButton: StoryActionButton(onTap: () => print('Test')),
  ),
  Story(
    'assets/images/image.jpg',
    cell,
    actionButton: StoryActionButton(onTap: () => print('Test')),
  ),
  Story('assets/images/3.jpg', cell1),
  Story(
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    cell1,
    meadiaType: MediaType.video,
  ),
  Story(
    'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    cell2,
    meadiaType: MediaType.video,
  ),
];
