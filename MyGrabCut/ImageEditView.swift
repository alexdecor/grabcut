
import Bridge2OpenCV
import SnapKit
import UIKit

class ImageEditView: UIView, Bridge2OpenCVDelegate, DrawViewDelegate {
    var isMove = false
    /* 移动时最好禁用其他操作 */ var isDraw = false
    /* YES是直接画mark NO是添加生长点 */ var isDelete = false
    // YES则调用删除点，NO是再判断上面的Draw
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /**
     *  画图用View
     */
    private var drawView = DrawView(frame: .zero, andIsCutImage: true)
    /**
     *  显示图片用View
     */
    private var pictureImage = UIImageView()
    /**
     *  算法模块
     */
    private var b2opcv = Bridge2OpenCV()
    /**
     线程queue
     */
    private var imageProcessQueue: DispatchQueue?

    override init(frame: CGRect) {
        super.init(frame: frame)

        pictureImage.frame = frame
        drawView.frame = frame
        addSubview(pictureImage)
        addSubview(drawView)
        drawView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        pictureImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        pictureImage.backgroundColor = UIColor.black
        drawView.backgroundColor = UIColor.clear

        b2opcv?.delegate = self
        drawView.delegate = self

        let imageInit = UIImage(color: pictureImage.backgroundColor!, andRect: CGRect(x: 0, y: 0, width: pictureImage.frame.size.width, height: pictureImage.frame.size.width))
        b2opcv?.setCalculate(imageInit, andWindowSize: frame.size)

        isMove = false
        isDraw = false // 默认是添加
        isDelete = false

        imageProcessQueue = DispatchQueue(label: "com.clover.cutImageIOS")

//        addSubview(pictureImage)
//        addSubview(drawView)
    }

    func setPicture(_ setImage: UIImage?) {
        // NSLog(@"view sW = %f",self.frame.size.width);
        // NSLog(@"view sH = %f",self.frame.size.height);
        b2opcv?.setCalculate(setImage, andWindowSize: frame.size)
        drawView.setPhotoImage() //
        pictureImage.image = setImage
    }

    func setMove(_ isMove: Bool) {
        drawView.moveAction = isMove
    }

    func redo() {
        b2opcv?.redoPoint()
        //    [self.drawView redo];
    }

    func undo() {
        b2opcv?.undoPoint()
        //    [self.drawView undo];
    }

    func setLineScale(_ scale: Float) {
        // [self.drawView setLineScale:scale];
        drawView.lineScale = CGFloat(1 / scale)
    }

    func resetAllMask() {
        b2opcv?.resetAllMask()
        //    [self.drawView resetDraw];
    }

    func resultImageReady(_ sendImage: UIImage!) {
        DispatchQueue.main.async {
            self.pictureImage.image = sendImage
        }
    }

    func resultImageReady(_ sendImage: UIImage!, andHaveMaskMat _: Bool) {

    }

    func getReusltImage() -> UIImage? {
        let resultImg = b2opcv?.getCutResult()
        return resultImg
    }

    func setPointArray(_ pointArray: NSMutableArray, andLineWide lineWidth: Float) {
        // dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        let w = Int32(lineWidth * 2)
        print("self.isDelete=\(self.isDelete) self.isDraw=\(self.isDraw)")
        imageProcessQueue!.async {
            if self.isDelete {
                self.b2opcv?.setDeletePoint(pointArray, andLineWidth: w)
            } else {
                if self.isDraw {
                    self.b2opcv?.setDrawPoint(pointArray, andLineWidth: w)
                } else {
                    print("setCreatPoint w=\(w) self.b2opcv=\(String(describing: self.b2opcv))")
                    self.b2opcv?.setCreatPoint(pointArray, andLineWidth: w)
                    print("end setCreatPoint w=\(w)")
                }
            }
        }
    }

    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     - (void)drawRect:(CGRect)rect {
     // Drawing code
     }
     */
}
