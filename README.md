


# DraggableFloatingViewController

### Like YouTube app

DraggableFloatingViewController allows you to play videos on a floating mini window at the bottom of your screen from sites like YouTube, Vimeo & Facebook or custom video , yes you have to prepare your video view for that.


How it works
------------
The view will animate the view just like Youtube mobile app, while tapping on video a UIView pops up from right corner of the screen and the view can be dragged to  right corner through Pan Gesture and more features are there as Youtube iOS app


Screenshot
------------
 ![Output sample](https://github.com/entotsu/DraggableFloatingViewController/raw/master/Screenshot2.gif)



# Usage


## extend this class

#### set your video view in "viewDidLoad" of subclass

```swift
override func viewDidLoad() {

    self.setupViewsWithVideoView(yourMoivePlayer.view, //UIView
        videoViewHeight: yourPlayerHeight, //CGFloat
        minimizeButton: yourButton //UIButton
    )

    // add your view to bodyView
    self.bodyView.addSubview(yourView)
}
```

## in parent view controller

### show

```swift
func showSecondController() {
    removeDraggableFloatingViewController()
    self.videoViewController = VideoDetailViewController()
    self.videoViewController.delegate = self
    self.videoViewController.showVideoViewControllerOnParentVC(self)
}
```


### dismiss

```swift
func removeDraggableFloatingViewController() {
    if self.videoViewController != nil {
        self.videoViewController.removeAllViews()
        self.videoViewController = nil
    }
}
```




--------------------------------------------------


# Please edit "info.plist"
To disable swipe down gesture of Notification Center, you need to edit "info.plist" to hide status bar.
http://stackoverflow.com/questions/18059703/cannot-hide-status-bar-in-ios7
![editInfoPlist](http://i.stack.imgur.com/dM32P.png "editInfoPlist")


--------------------------------------------------

--------------------------------------------------

--------------------------------------------------
# please override if you want
```swift
override func didExpand() {
    showVideoControl()
}
override func didMinimize() {
    hideVideoControl()
}
```

-------------------------------------------------------

## Please see demo app
If you want to use this, you have to check this demo app.


<!--
## Minimam example Classes

### Minimam subclass

```swift
class VideoDetailViewController: DraggableFloatingViewController {

    var moviePlayer: MPMoviePlayerController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // prepare your video player
        moviePlayer = MPMoviePlayerController()

        // prepare your closing button
        let foldBtn = UIButton()
        foldBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        foldBtn.setImage(UIImage(named: "DownArrow"), forState: UIControlState.Normal)

        // please call this in "viewDidLoad"
        self.setupViewsWithVideoView(moviePlayer.view,
            videoViewHeight: 160,
            foldButton: foldBtn
        );

        // you can add sub views on bodyView
        let testView = UILabel()
        testView.frame = CGRect(x: 20, y: 20, width: 100, height: 40)
        testView.text = "test view"
        self.bodyView.addSubview(testView)
    }

    // please override if you want
    override func didExpand() {
        showVideoControl()
    }
    override func didMinimize() {
        hideVideoControl()
    }
}
```


### Minimam parent view controller

```swift
class FirstViewController: UIViewController , DraggableFloatingViewControllerDelegate {

    var videoViewController: VideoDetailViewController!

    @IBAction func onTapButton(sender: AnyObject) {
        self.showSecondController()
    }

    override func viewWillDisappear(animated: Bool) {
        // when go to fullscreen, this is also called
        if !self.videoViewController.isFullScreen() {
            removeDraggableFloatingViewController()
        }
    }

    func showSecondController() {
        removeDraggableFloatingViewController()
        self.videoViewController = VideoDetailViewController()
        self.videoViewController.delegate = self
        self.videoViewController.showVideoViewControllerOnParentVC(self)
    }

    // DraggableFloatingViewControllerDelegate
    func removeDraggableFloatingViewController() {
        if self.videoViewController != nil {
            self.videoViewController.removeAllViews()
            self.videoViewController = nil
        }
    }
}
```
-->