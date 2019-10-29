import UIKit

class RotateCutImageViewController: UIViewController, UIGestureRecognizerDelegate {
    private var backStep: UIButton?
    private var saveImageButton: UIButton?
    private var showImgView: UIImageView?
    private var showImgViewRect = CGRect.zero
    private var rotationGestureRecognizer: UIRotationGestureRecognizer?
    private var orgShowImgViewTransform: CGAffineTransform!

    override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = .flipHorizontal
        view.backgroundColor = UIColor.gray
        view.layer.cornerRadius = 5.0

        let mainScreen = UIScreen.main.applicationFrame

        backStep = UIButton(type: .custom)
        backStep?.frame = CGRect(x: mainScreen.origin.x, y: mainScreen.origin.y, width: 100, height: 50)
        backStep?.backgroundColor = UIColor.clear
        backStep?.layer.cornerRadius = 5
        backStep?.setTitle("< 上一步", for: .normal)
        backStep?.setTitleColor(UIColor(red: 25.0 / 255.0, green: 25.0 / 255.0, blue: 112.0 / 255.0, alpha: 1.0), for: .normal)
        backStep?.setTitleColor(UIColor.gray, for: .highlighted)
        backStep?.addTarget(self, action: #selector(backStepFoo(_:)), for: .touchUpInside)

        saveImageButton = UIButton(type: .custom)
        saveImageButton?.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        saveImageButton?.center = CGPoint(x: mainScreen.size.width / 2, y: mainScreen.size.height - 50)
        saveImageButton?.backgroundColor = UIColor.white
        saveImageButton?.layer.cornerRadius = 5
        saveImageButton?.setTitle("保存图像", for: .normal)
        saveImageButton?.setTitleColor(UIColor.black, for: .normal)
        saveImageButton?.setTitleColor(UIColor.gray, for: .highlighted)
        saveImageButton?.addTarget(self, action: #selector(saveImageButtonFoo(_:)), for: .touchUpInside)

        showImgView = UIImageView()
        orgShowImgViewTransform = showImgView?.transform
        //  self.showImgView.backgroundColor = [UIColor greenColor];
        showImgView?.backgroundColor = UIColor.clear

        // [self creatPan];
        showImgView?.isUserInteractionEnabled = true
        addRotationGesture(to: showImgView)
        addTapGesture(to: showImgView, numberOfTaps: 1)

        if let backStep = backStep {
            view.addSubview(backStep)
        }
        if let showImgView = showImgView {
            view.addSubview(showImgView)
        }
        if let saveImageButton = saveImageButton {
            view.addSubview(saveImageButton)
        }
        // [self setModalTransitionStyle:UIModalTransitionStylePartialCurl];
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func backStepFoo(_: Any?) {
        //   [self.navigationController popViewControllerAnimated:YES];
        dismiss(animated: true)
    }

    func setImageRect(_ setRect: CGRect, andImage setImage: UIImage?) {
        showImgView?.frame = setRect
        DispatchQueue.main.async {
            self.showImgView?.image = setImage
        }
    }

    override func viewWillAppear(_: Bool) {
        showImgView?.transform = orgShowImgViewTransform
    }

    func creatPan() {
        rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        rotationGestureRecognizer?.delegate = self

        if let rotationGestureRecognizer = rotationGestureRecognizer {
            view.addGestureRecognizer(rotationGestureRecognizer)
        }
    }

    @objc func handleRotation(_: UIPanGestureRecognizer?) {
        print("rotationGestureRecognizer")
    }

    func addRotationGesture(to view: UIView?) {
        let rotation = KTOneFingerRotationGestureRecognizer(target: self, action: #selector(rotating(_:)))
        view?.addGestureRecognizer(rotation)
        //   [rotation release];
    }

    func addTapGesture(to view: UIView?, numberOfTaps: Int) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tap.numberOfTapsRequired = numberOfTaps
        view?.addGestureRecognizer(tap)
        //   [tap release];
    }

    @objc func rotating(_ recognizer: KTOneFingerRotationGestureRecognizer?) {
        let view = recognizer?.view
        view?.transform = (view?.transform.rotated(by: CGFloat(recognizer!.rotation)))!
    }

    @objc func tapped(_ recognizer: UITapGestureRecognizer?) {
        let view = recognizer?.view
        view?.transform = CGAffineTransform(rotationAngle: 0)
    }

    func saveImage(toPhotos savedImage: UIImage) {
        UIImageWriteToSavedPhotosAlbum(savedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    // 指定回调方法
    @objc func image(_: UIImage?, didFinishSavingWithError error: Error?, contextInfo _: UnsafeMutableRawPointer?) {
        var msg: String?
        if error != nil {
            msg = "保存图片失败"
        } else {
            msg = "保存图片成功"
        }
        let alert = UIAlertView(title: "保存图片结果提示", message: msg!, delegate: self, cancelButtonTitle: "确定", otherButtonTitles: "")
        alert.show()
    }

    @objc func saveImageButtonFoo(_: Any?) {
        saveImage(toPhotos: showImgView!.image!)
    }

    /*
     #pragma mark - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
         // Get the new view controller using [segue destinationViewController].
         // Pass the selected object to the new view controller.
     }
     */
}

extension RotateCutImageViewController: UIAlertViewDelegate {}
