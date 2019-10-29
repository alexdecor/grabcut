
import CoreMotion
import UIKit

protocol DrawViewDelegate: NSObjectProtocol {
    func setPointArray(_ pointArray: NSMutableArray, andLineWide linaWidth: Float)
}

class DrawView: UIView {
    // -(void) setLineScale:(float) scale;
    /**
     *  设置的线宽和颜色
     */
    var lineWidth: CGFloat = 10.0
    var lineColor = UIColor(red: 1.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 0.5)
    var lineScale: CGFloat = 1.0
    weak var delegate: DrawViewDelegate?

    var path = CGMutablePath()
    var pathArray: [DrawViewModel] = []
    var isHavePath = false
    // @property (strong, nonatomic) UIImage * setImage;
    var setView: UIImageView?
    var moveAction = false
    var removePathArray: [AnyHashable] = []
    var cmMotionManager = CMMotionManager()
    // @property (nonatomic) float
    var pointArray: NSMutableArray = NSMutableArray()
    /* 同时发送的只能有一组array, 删除，添加，选取都是这一个array */ private var isCutImage = false

    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     - (void)drawRect:(CGRect)rect {
     // Drawing code
     }
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(frame: CGRect, andIsCutImage isCutImage: Bool) {
        super.init(frame: frame)
        self.isCutImage = isCutImage
        self.backgroundColor = UIColor.green
        print("DrawView init frame=\(frame)")
    }

    func resetDraw() {
        /*
         if(self.pathArray != nil){
         [self.pathArray removeAllObjects];
         [self setNeedsDisplay];
         }
         */
        lineScale = 1.0
    }

    func setPhotoImage(_: UIImage?) {
        /*
         if(self.pathArray != nil){
         [self.pathArray removeAllObjects];
         [self setNeedsDisplay];
         }
         */
        lineScale = 1.0
        // self.setView.image = setImage;
        // self.image = setImage;
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawView(context)
        // [self drawCircle:context];
        print("DrawView draw rect=\(rect)")
    }

    func drawCircle(_ context: CGContext) {
        //  CGContextSetRGBStrokeColor(context, self.lineColor);
        //  CGContextSetRGBFillColor(context, 255, 100, 100, 0.5);

        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(5.0)
        context.addEllipse(in: CGRect(x: 10, y: 150, width: 300, height: 300)) // 在这个框中画圆
        context.strokePath()
    }

    func setPhotoImage() {
        lineScale = 1.0
    }

    func drawView(_ context: CGContext) {
        for myViewModel in pathArray {
            context.addPath(myViewModel.path!.cgPath)
            context.setStrokeColor( myViewModel.color.cgColor)
            //context.setStrokeColor(myViewModel.color!.cgColor)
            context.setLineWidth(myViewModel.width)
            context.setLineCap(.round)
            // CGContextDrawPath(context, kCGPathStroke);
            context.strokePath()
        }

        print("isHavePath=\(isHavePath) isCutImage=\(isCutImage)")
        if isHavePath {
            if isCutImage {
                lineColor = UIColor(red: 1.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 0.5) // [UIColor redColor];
            }
            //        self.lineColor = [UIColor  colorWithRed:0.0 green:0 blue:1.0 alpha:0.5];  //[UIColor redColor];
            context.addPath(path)
            context.setStrokeColor(lineColor.cgColor)
            context.setLineWidth(lineWidth * lineScale)
            context.setLineCap(.round)
            context.drawPath(using: .stroke)
        } else {
            // 将路径绘制为透明，为了消除路径图像
            if isCutImage {
                print("in drawView:(CGContextRef)context ")
                lineColor = UIColor(red: 1.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 0.1) // [UIColor redColor];
                //        self.lineColor = [UIColor  colorWithRed:0.0 green:0 blue:1.0 alpha:0.0];  //[UIColor redColor];
                context.addPath(path)
                context.setStrokeColor(lineColor.cgColor)
                context.setLineWidth(lineWidth * CGFloat(lineScale))
                context.setLineCap(.round)
                context.drawPath(using: .stroke)
            }
        }
    }

    func setMove(_ isMove: Bool) {
        moveAction = isMove
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        print("touchesBegan")
        if !moveAction {
            removePathArray.removeAll()
            pointArray.removeAllObjects()
            if let touch = touches.first {
            let location = touch.location(in: self)
            path = CGMutablePath()
            isHavePath = true
            path.move(to: CGPoint(x: location.x, y: location.y), transform: .identity)



            pointArray.add(NSValue(cgPoint: location))

                NSLog("touch began (x, y) is (%f, %f)", location.x, location.y);
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !moveAction {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            path.addLine(to: CGPoint(x: location.x, y: location.y), transform: .identity)
            setNeedsDisplay()
            pointArray.add(NSValue(cgPoint: location))
            // NSLog(@"touch move (x, y) is (%f, %f)", location.x, location.y);
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded moveAction=\(moveAction)")
        if !moveAction {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            NSLog("touch end(x, y) is (%f, %f)", location.x, location.y);
            path.move(to: CGPoint(x: location.x, y: location.y), transform: .identity)
            pointArray.add(NSValue(cgPoint: location))
            print("touchesEnded isCutImage=\(isCutImage)")
            if !isCutImage {
                let bezierPath = UIBezierPath(cgPath: path)
                let myViewModel = DrawViewModel(color: lineColor, path: bezierPath, width: lineWidth * lineScale)
                pathArray.append(myViewModel)
                print("_pathArray.count = \(pathArray.count)")
                if pathArray.count == 9000 {
                    pathArray.remove(at: 0)
                }
                setNeedsDisplay() // 让path全透明
                // NSLog(@"_pathArray.count = %d",_pathArray.count);
            }

            isHavePath = false
            if isCutImage {
                setNeedsDisplay() // 让path全透明
                delegate?.setPointArray(pointArray, andLineWide: Float(lineWidth * lineScale))
            }
        }
    }

    func redo() {
        print(String(format: "length = %lu", UInt(pathArray.count)))
        let sizeOfPathArray = pathArray.count
        if sizeOfPathArray != 0 && sizeOfPathArray < pathArray.count {
            let viewModelWillSave = pathArray[sizeOfPathArray - 1]
            //if let viewModelWillSave = viewModelWillSave {
                removePathArray.append(viewModelWillSave)
            //}
            pathArray.removeLast()
            setNeedsDisplay()
        }
    }

    func undo() {
        print(String(format: "length = %lu", UInt(pathArray.count)))
        if removePathArray.count != 0 {
            let sizeOfRemovePathArray = Int(removePathArray.count)
            let viewModelWillSave = removePathArray[sizeOfRemovePathArray - 1] as? DrawViewModel
            if let viewModelWillSave = viewModelWillSave {
                pathArray.append(viewModelWillSave)
            }
            removePathArray.removeLast()
            setNeedsDisplay()
        }
    }

    /*
     -(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
     {
     NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
     UITouch *touch = [allTouches anyObject];   //视图中的所有对象
     CGPoint point = [touch locationInView:self.appImageView]; //返回触摸点在视图中的当前坐标
     int x = point.x;
     int y = point.y;
     // if(x >= 0 && x<= self.orgRect.size.width)
     NSLog(@"touch moved (x, y) is (%d, %d)", x, y);
     [self addPoint2Array:point];
     }

     -(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
     {

     NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
     UITouch *touch = [allTouches anyObject];   //视图中的所有对象
     CGPoint point = [touch locationInView:self.appImageView]; //返回触摸点在视图中的当前坐标
     int x = point.x;
     int y = point.y;
     NSLog(@" ");
     NSLog(@"touch began (x, y) is (%d, %d)", x, y);
     [self.pointArray removeAllObjects];
     [self addPoint2Array:point];
     }

     -(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
     {
     NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
     UITouch *touch = [allTouches anyObject];   //视图中的所有对象
     CGPoint point = [touch locationInView:self.appImageView]; //返回触摸点在视图中的当前坐标
     int x = point.x;
     int y = point.y;
     NSLog(@"touch ended (x, y) is (%d, %d)", x, y);
     [self addPoint2Array:point];

     if(self.isMove == NO){
     if(self.isDelete == NO){
     if(self.isDraw == NO){
     [self.b2opcv setCreatPoint:self.pointArray andLineWidth:self.setLineWidth];
     }
     else{
     [self.b2opcv setDrawPoint:self.pointArray andLineWidth:self.setLineWidth];
     }
     }
     else
     {
     [self.b2opcv setDeletePoint:self.pointArray andLineWidth:self.setLineWidth];
     }
     }
     //UIImage *imgSend = self.appImageView.image;
     }
     */
}
