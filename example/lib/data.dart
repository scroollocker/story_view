import 'package:stories/stories.dart';

final cell = StoryCell(name: 'Octane', imagePath: 'assets/images/octane.jpg');
final cell1 = StoryCell(name: 'Cat', imagePath: 'assets/images/cat.jpg');
final cell2 = StoryCell(name: 'Cat1', imagePath: 'assets/images/cat.jpg');

final List<Story> stories = [
  Story('assets/images/image.jpg', cell),
  Story('assets/gif/wow-cat.gif', cell2),
  Story('assets/images/3.jpg', cell1),
  Story('assets/gif/wow-cat.gif', cell1),
];
