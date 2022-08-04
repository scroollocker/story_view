import 'package:stories/stories.dart';

final cell = StoryCell(
    iconUrl: 'https://picsum.photos/250?image=9',
    watched: false,
    stories: [
      // Story(
      //   'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      //   meadiaType: MediaType.video,
      // ),
      Story(
        url: 'http://212.112.103.210:8085/stories/attachment/16',
        actionButton: StoryActionButton(onTap: () => print('Test')),
        duration: const Duration(milliseconds: 5000),
      ),
      Story(
        url: 'http://212.112.103.210:8085/stories/attachment/18',
        duration: const Duration(milliseconds: 2001),
      ),
      Story(
        url: 'http://212.112.103.210:8085/stories/attachment/19',
        actionButton: StoryActionButton(onTap: () => print('Test')),
        duration: const Duration(milliseconds: 3002),
      ),
      Story(
        url: 'http://212.112.103.210:8085/stories/attachment/20',
        actionButton: StoryActionButton(onTap: () => print('Test')),
        duration: const Duration(milliseconds: 4003),
      ),
      Story(
        url: 'http://212.112.103.210:8085/stories/attachment/21',
        duration: const Duration(milliseconds: 5004),
      ),
      Story(
        url:
            'https://github.com/libgit2/libgit2sharp/raw/master/square-logo.png',
        actionButton: StoryActionButton(onTap: () => print('Test')),
        duration: const Duration(milliseconds: 6005),
      ),
      Story(
        url: 'https://picsum.photos/250?image=9',
        actionButton: StoryActionButton(onTap: () => print('Test')),
        duration: const Duration(milliseconds: 7006),
      ),
      Story(
        url:
            'https://github.com/libgit2/libgit2sharp/raw/master/square-logo.png',
        duration: const Duration(milliseconds: 8007),
      ),
      Story(
        url: 'https://picsum.photos/250?image=9',
        actionButton: StoryActionButton(onTap: () => print('Test')),
        duration: const Duration(milliseconds: 9008),
      ),
      Story(
        url:
            'https://github.com/libgit2/libgit2sharp/raw/master/square-logo.png',
        actionButton: StoryActionButton(onTap: () => print('Test')),
        duration: const Duration(milliseconds: 10009),
      ),
      Story(
        url: 'https://picsum.photos/250?image=9',
        duration: const Duration(milliseconds: 11010),
      ),
      Story(
        url:
            'https://github.com/libgit2/libgit2sharp/raw/master/square-logo.png',
        actionButton: StoryActionButton(onTap: () => print('Test')),
        duration: const Duration(milliseconds: 12011),
      ),
    ]);
final cell1 = StoryCell(
    watched: false,
    iconUrl:
        'https://github.com/libgit2/libgit2sharp/raw/master/square-logo.png',
    stories: [
      Story(
        url:
            'https://assets.mixkit.co/videos/preview/mixkit-daytime-city-traffic-aerial-view-56-large.mp4',
        meadiaType: MediaType.video,
      ),
      Story(
        //'assets/images/image.jpg',
        url:
            'https://github.com/libgit2/libgit2sharp/raw/master/square-logo.png',
      ),
      Story(
        url:
            'https://github.com/libgit2/libgit2sharp/raw/master/square-logo.png',
      ),
      Story(
        url:
            'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        meadiaType: MediaType.video,
      ),
    ]);
final cell2 = StoryCell(
    watched: false,
    iconUrl: 'http://212.112.103.210:8085/stories/attachment/19',
    stories: [
      Story(
        url: 'http://212.112.103.210:8085/stories/attachment/19',
      ),
    ]);

final cell3 = StoryCell(
    watched: false,
    iconUrl: 'http://212.112.103.210:8085/stories/attachment/18',
    stories: [
      Story(
        url: 'http://212.112.103.210:8085/stories/attachment/18',
      ),
    ]);

final cell4 = StoryCell(
    watched: false,
    iconUrl: 'http://212.112.103.210:8085/stories/attachment/21',
    stories: [
      Story(
        url: 'http://212.112.103.210:8085/stories/attachment/21',
      ),
    ]);

final cell5 = StoryCell(
    watched: false,
    iconUrl: 'http://212.112.103.210:8085/stories/attachment/21',
    stories: [
      Story(
        url:
            'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        meadiaType: MediaType.video,
      ),
    ]);
