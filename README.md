# SPPhoto

Side Project (SP) Photo App
- Loads Photos from the iOS Photos App into a UICollectionView
- Clicking on the photo opens a photo view controller that shows the detail of the photo - The photo view controller has a photo view (UIView) that holds a UIImageView
- The Photo view controller has a horizontal scroll view (UICollectionView) that holds the
photos. It scrolls in the horizontal direction.
- The photo view controller allows swiping left and right which changes the images and
also changes the visible region of the horizontal scroll view.
- Taping the image in the photo view zooms the image by hiding all views visible on the
screen.
- The photo view displays the location where the photo was taken if available.
- Using MVC with the Singleton Pattern. This pattern was used since I am not mentaining any mutable state. We reading from the Photos Library
