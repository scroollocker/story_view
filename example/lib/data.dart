import 'package:stories/stories.dart';

final cell =
    StoryCell(imagePath: 'https://picsum.photos/250?image=9', stories: [
  // Story(
  //   'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
  //   meadiaType: MediaType.video,
  // ),
  Story(
    'http://212.112.103.210:8085/stories/attachment/16',
    actionButton: StoryActionButton(onTap: () => print('Test')),
    duration: const Duration(milliseconds: 5000),
  ),
  Story(
    'http://212.112.103.210:8085/stories/attachment/18',
    duration: const Duration(milliseconds: 2001),
  ),
  Story(
    'http://212.112.103.210:8085/stories/attachment/19',
    actionButton: StoryActionButton(onTap: () => print('Test')),
    duration: const Duration(milliseconds: 3002),
  ),
  Story(
    'http://212.112.103.210:8085/stories/attachment/20',
    actionButton: StoryActionButton(onTap: () => print('Test')),
    duration: const Duration(milliseconds: 4003),
  ),
  Story(
    'http://212.112.103.210:8085/stories/attachment/21',
    duration: const Duration(milliseconds: 5004),
  ),
  Story(
    'https://github.com/libgit2/libgit2sharp/raw/master/square-logo.png',
    actionButton: StoryActionButton(onTap: () => print('Test')),
    duration: const Duration(milliseconds: 6005),
  ),
  Story(
    'https://picsum.photos/250?image=9',
    actionButton: StoryActionButton(onTap: () => print('Test')),
    duration: const Duration(milliseconds: 7006),
  ),
  Story(
    'https://github.com/libgit2/libgit2sharp/raw/master/square-logo.png',
    duration: const Duration(milliseconds: 8007),
  ),
  Story(
    'https://picsum.photos/250?image=9',
    actionButton: StoryActionButton(onTap: () => print('Test')),
    duration: const Duration(milliseconds: 9008),
  ),
  Story(
    'https://github.com/libgit2/libgit2sharp/raw/master/square-logo.png',
    actionButton: StoryActionButton(onTap: () => print('Test')),
    duration: const Duration(milliseconds: 10009),
  ),
  Story(
    'https://picsum.photos/250?image=9',
    duration: const Duration(milliseconds: 11010),
  ),
  Story(
    'https://github.com/libgit2/libgit2sharp/raw/master/square-logo.png',
    actionButton: StoryActionButton(onTap: () => print('Test')),
    duration: const Duration(milliseconds: 12011),
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
    imagePath: 'http://212.112.103.210:8085/stories/attachment/19',
    stories: [
      Story(
        'http://212.112.103.210:8085/stories/attachment/19',
      ),
    ]);

final cell3 = StoryCell(
    imagePath: 'http://212.112.103.210:8085/stories/attachment/18',
    stories: [
      Story(
        'http://212.112.103.210:8085/stories/attachment/18',
      ),
    ]);

final cell4 = StoryCell(
    imagePath: 'http://212.112.103.210:8085/stories/attachment/21',
    stories: [
      Story(
        'http://212.112.103.210:8085/stories/attachment/21',
      ),
    ]);

final cell5 = StoryCell(
    imagePath: 'http://212.112.103.210:8085/stories/attachment/21',
    stories: [
      Story(
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        meadiaType: MediaType.video,
      ),
    ]);
