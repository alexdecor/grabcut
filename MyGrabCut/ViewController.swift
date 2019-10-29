//  Converted to Swift 5.1 by Swiftify v5.1.30744 - https://objectivec2swift.com/
//
//  ViewController.swift
//  cutImageIOS
//
//  Created by vk on 15/8/21.
//  Copyright (c) 2015年 Clover. All rights reserved.
//  方形编辑区域

import UIKit

// #import "CustomPopAnimation.h"
// #import "ImageShowView.h"
let LINESTEP = 5
let DEFLINEWIDTH = 10

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    private var photoImg: UIImage?
    private var appImageView: ImageEditView!
    // @property (nonatomic, strong) UIImageView *showImgView;
    private var openPhotoAlbumButton = UIButton(type: .custom)
    private var addCalculatePointButton = UIButton(type: .custom)
    private var addMaskPointButton = UIButton(type: .custom)
    private var deleteMaskPointButton = UIButton(type: .custom)
    private var moveImgButton = UIButton(type: .custom)
    private var undoButton = UIButton(type: .custom)
    /* 前进 */ private var redoButton = UIButton(type: .custom)
    /* 返回 */ private var nextStepButton = UIButton(type: .custom)
    private var pointArray: [Any]?
    /* 同时发送的只能有一组array, 删除，添加，选取都是这一个array */
    private var sysTestButton = UIButton(type: .custom)
    private var resetDrawButton = UIButton(type: .custom)
    private var orgRect = CGRect.zero
    // @property (nonatomic, strong) Bridge2OpenCV *b2opcv;
    private var imgWindowSize = CGSize.zero
    private var orgTrf: CGAffineTransform!
    private var isMove = false
    /* 移动时最好禁用其他操作 */ private var isDraw = false
    /* YES是直接画mark NO是添加生长点 */ private var isDelete = false
    /* YES则调用删除点，NO是再判断上面的Draw */ private var setLineWidth = 0
    private var panGestureRecognizer: UIGestureRecognizer?
    private var pinchGestureRecognizer: UIPinchGestureRecognizer?
    private var rotateCutImageViewController: RotateCutImageViewController?
    private var getFinnalImageQueue = DispatchQueue(label: "com.clover.cutImageIOS")

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.isNavigationBarHidden = true
        rotateCutImageViewController = RotateCutImageViewController()

        let smallButtonWidth: Float = 70
        let bigButtonWidth: Float = 100
        setLineWidth = DEFLINEWIDTH // 线宽默认是10
        let mainScreen = UIScreen.main.bounds
        let screenCenter = CGPoint(x: mainScreen.size.width / 2, y: mainScreen.size.height / 2 + 20)
        pointArray = []

        // 上半部分遮挡view

        appImageView = ImageEditView(frame: CGRect(x: 0, y: 0, width: mainScreen.size.width, height: mainScreen.size.width))
        appImageView?.bounds = CGRect(x: 0, y: 0, width: mainScreen.size.width, height: mainScreen.size.width)
        appImageView?.center = CGPoint(x: screenCenter.x, y: screenCenter.y - ((mainScreen.size.height - mainScreen.size.width) / 4))

        if let width = appImageView?.frame.size.width {
            print("self.appImageView.frame.size.width  = \(width)")
        }
        if let height = appImageView?.frame.size.height {
            print("self.appImageView.frame.size.height = \(height)")
        }

        orgRect = appImageView?.frame ?? CGRect.zero
        // self.appImageView.backgroundColor = [UIColor clearColor];

        let imageInit = UIImage(color: UIColor.clear, andRect: CGRect(x: 0, y: 0, width: appImageView.frame.size.width, height: appImageView.frame.size.width)) // [self.appImageView image];
        imgWindowSize = CGSize(width: appImageView.frame.size.width , height: appImageView.frame.size.height)
        orgTrf = appImageView?.transform
        // [self.b2opcv setCalculateImage:imageInit andWindowSize:self.imgWindowSize];

        creatPan()
        // 生成一个遮挡平面，这样可以得到小图的剪切
        // float tmpHeight =   self.showImgView.frame.origin.y;
        let tmpHeight = appImageView.frame.origin.y
        let upKeepOutView = UIImageView(frame: CGRect(x: 0, y: 0, width: mainScreen.size.width, height: CGFloat(tmpHeight)))
        upKeepOutView.backgroundColor = UIColor.gray
        // [upKeepOutView.layer setCornerRadius:5];
        let bottomKeepOutView = UIImageView(frame: CGRect(x: 0, y: CGFloat(tmpHeight + (appImageView?.frame.size.height)! ), width: mainScreen.size.width, height: mainScreen.size.height - CGFloat(tmpHeight) - appImageView.frame.size.height))
        bottomKeepOutView.backgroundColor = UIColor.gray
        // [bottomKeepOutView.layer setCornerRadius:5];

        // 打开相册按键
        openPhotoAlbumButton = UIButton(type: .custom)
        openPhotoAlbumButton.frame = CGRect(x: mainScreen.size.width - 100, y: mainScreen.size.height - 60, width: 140, height: 50)
        openPhotoAlbumButton.backgroundColor = UIColor.white
        openPhotoAlbumButton.layer.cornerRadius = 5
        openPhotoAlbumButton.setTitle("Open Album", for: .normal)
        openPhotoAlbumButton.setTitleColor(UIColor.black, for: .normal)
        openPhotoAlbumButton.setTitleColor(UIColor.gray, for: .highlighted)
        openPhotoAlbumButton.addTarget(self, action: #selector(takePictureClick(_:)), for: .touchUpInside)
        // 测试用按键，图片位置复位
        sysTestButton = UIButton(type: .custom)
        sysTestButton.frame = CGRect(x: 0, y: mainScreen.size.height - 60, width: 140, height: 50)
        sysTestButton.backgroundColor = UIColor.white
        sysTestButton.layer.cornerRadius = 5
        sysTestButton.setTitle("Reset", for: .normal)
        sysTestButton.setTitleColor(UIColor.black, for: .normal)
        sysTestButton.setTitleColor(UIColor.gray, for: .highlighted)
        sysTestButton.addTarget(self, action: #selector(resetPosion(_:)), for: .touchUpInside)
        /**
         *  重画按键，点击后消除所有当前图像所有Mask
         */

        resetDrawButton.frame = CGRect(x: (mainScreen.size.width / 2) - 50, y: mainScreen.size.height - 60, width: 140, height: 50)
        resetDrawButton.backgroundColor = UIColor.white
        resetDrawButton.layer.cornerRadius = 5
        resetDrawButton.setTitle("Redraw", for: .normal)
        resetDrawButton.setTitleColor(UIColor.black, for: .normal)
        resetDrawButton.setTitleColor(UIColor.gray, for: .highlighted)
        resetDrawButton.addTarget(self, action: #selector(resetDraw(_:)), for: .touchUpInside)

        // 添加计算点按键

        addCalculatePointButton.frame = CGRect(x: 0, y: (screenCenter.y - ((mainScreen.size.height - mainScreen.size.width) / 4) - (mainScreen.size.width / 2)) + mainScreen.size.width, width: CGFloat(smallButtonWidth), height: 50)
        addCalculatePointButton.center = CGPoint(x: mainScreen.size.width / 5, y: addCalculatePointButton.center.y ?? 0.0)
        addCalculatePointButton.backgroundColor = UIColor.yellow
        addCalculatePointButton.layer.cornerRadius = 5
        addCalculatePointButton.setTitle("Selection", for: .normal)
        addCalculatePointButton.setTitleColor(UIColor.black, for: .normal)
        addCalculatePointButton.setTitleColor(UIColor.gray, for: .highlighted)
        addCalculatePointButton.addTarget(self, action: #selector(cutImageCut(_:)), for: .touchUpInside)
        // 添加移动图片按键

        moveImgButton.frame = CGRect(x: mainScreen.size.width - CGFloat(smallButtonWidth), y: (screenCenter.y - ((mainScreen.size.height - mainScreen.size.width) / 4) - (mainScreen.size.width / 2)) + mainScreen.size.width, width: CGFloat(smallButtonWidth), height: 50)
        moveImgButton.center = CGPoint(x: mainScreen.size.width / 5 * 4, y: moveImgButton.center.y ?? 0.0)
        moveImgButton.backgroundColor = UIColor.white
        moveImgButton.layer.cornerRadius = 5
        moveImgButton.setTitle("Move", for: .normal)
        moveImgButton.setTitleColor(UIColor.black, for: .normal)
        moveImgButton.setTitleColor(UIColor.gray, for: .highlighted)
        moveImgButton.addTarget(self, action: #selector(enableMoveImg(_:)), for: .touchUpInside)
        // 添加单独添加Mask按键

        addMaskPointButton.frame = CGRect(x: 0, y: (screenCenter.y - ((mainScreen.size.height - mainScreen.size.width) / 4) - (mainScreen.size.width / 2)) + mainScreen.size.width, width: CGFloat(smallButtonWidth), height: 50)
        addMaskPointButton.center = CGPoint(x: mainScreen.size.width / 5 * 2, y: addMaskPointButton.center.y ?? 0.0)
        addMaskPointButton.backgroundColor = UIColor.white
        addMaskPointButton.layer.cornerRadius = 5
        addMaskPointButton.setTitle("Restore", for: .normal)
        addMaskPointButton.setTitleColor(UIColor.black, for: .normal)
        addMaskPointButton.setTitleColor(UIColor.gray, for: .highlighted)
        addMaskPointButton.addTarget(self, action: #selector(addMaskPointFoo(_:)), for: .touchUpInside)
        // 添加删除Mark的按键

        deleteMaskPointButton.frame = CGRect(x: 0, y: (screenCenter.y - ((mainScreen.size.height - mainScreen.size.width) / 4) - (mainScreen.size.width / 2)) + mainScreen.size.width, width: CGFloat(smallButtonWidth), height: 50)
        deleteMaskPointButton.center = CGPoint(x: mainScreen.size.width / 5 * 3, y: deleteMaskPointButton.center.y ?? 0.0)
        deleteMaskPointButton.backgroundColor = UIColor.white
        deleteMaskPointButton.layer.cornerRadius = 5
        deleteMaskPointButton.setTitle("Erase", for: .normal)
        deleteMaskPointButton.setTitleColor(UIColor.black, for: .normal)
        deleteMaskPointButton.setTitleColor(UIColor.gray, for: .highlighted)
        deleteMaskPointButton.addTarget(self, action: #selector(deleteMaskPointFoo(_:)), for: .touchUpInside)
        /**
         *  增加回退按钮
         */

        redoButton.frame = CGRect(x: 0, y: (screenCenter.y - ((mainScreen.size.height - mainScreen.size.width) / 4) - (mainScreen.size.width / 2)) + mainScreen.size.width, width: CGFloat(smallButtonWidth), height: 50)
        redoButton.center = CGPoint(x: mainScreen.size.width / 5, y: (addCalculatePointButton.center.y ?? 0.0) + 60)
        redoButton.backgroundColor = UIColor.white
        redoButton.layer.cornerRadius = 5
        redoButton.setTitle("undo", for: .normal)
        redoButton.setTitleColor(UIColor.black, for: .normal)
        redoButton.setTitleColor(UIColor.gray, for: .highlighted)
        redoButton.addTarget(self, action: #selector(redoButtonFoo), for: .touchUpInside)
        /**
         *  增加前进按钮
         */

        undoButton.frame = CGRect(x: mainScreen.size.width - CGFloat(smallButtonWidth), y: (screenCenter.y - ((mainScreen.size.height - mainScreen.size.width) / 4) - (mainScreen.size.width / 2)) + mainScreen.size.width, width: CGFloat(smallButtonWidth), height: 50)
        undoButton.center = CGPoint(x: mainScreen.size.width / 5 * 4, y: (moveImgButton.center.y ?? 0.0) + 60)
        undoButton.backgroundColor = UIColor.white
        undoButton.layer.cornerRadius = 5
        undoButton.setTitle("redo", for: .normal)
        undoButton.setTitleColor(UIColor.black, for: .normal)
        undoButton.setTitleColor(UIColor.gray, for: .highlighted)
        undoButton.addTarget(self, action: #selector(undoButtonFoo), for: .touchUpInside)

        nextStepButton.frame = CGRect(x: mainScreen.size.width - 100, y: orgRect.origin.y - 50, width: 100, height: 50)
        nextStepButton.backgroundColor = UIColor.clear
        nextStepButton.layer.cornerRadius = 5
        nextStepButton.setTitle("Next >", for: .normal)
        nextStepButton.setTitleColor(UIColor.black, for: .normal)
        nextStepButton.setTitleColor(UIColor.gray, for: .highlighted)
        nextStepButton.addTarget(self, action: #selector(nextStepFoo(_:)), for: .touchUpInside)

        // [self.view addSubview:self.showImgView];

        view.addSubview(appImageView)
        view.addSubview(upKeepOutView)
        view.addSubview(bottomKeepOutView)
        view.addSubview(openPhotoAlbumButton)
        view.addSubview(sysTestButton)
        view.addSubview(addCalculatePointButton)
        view.addSubview(addMaskPointButton)
        view.addSubview(deleteMaskPointButton)
        view.addSubview(moveImgButton)
        view.addSubview(resetDrawButton)
        view.addSubview(redoButton)
        view.addSubview(undoButton)
        view.addSubview(nextStepButton)
        view.backgroundColor = UIColor.gray
        setButtonsFont()

        isMove = false
        isDraw = false // 默认是添加
        isDelete = false

        /**
         *  得到最终的剪切图的线程建立
         *
         *  @param "com.clover.cutImageIOS" <#"com.clover.cutImageIOS" description#>
         *  @param NULL                     <#NULL description#>
         *
         *  @return <#return value description#>
         */

        // Do any additional setup after loading the view, typically from a nib.
    }

    func setButtonsFont() {
        openPhotoAlbumButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
       addCalculatePointButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        addMaskPointButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
       deleteMaskPointButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        moveImgButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        undoButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        redoButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        nextStepButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
    }

    func resultImageReady(_ sendImage: UIImage?) {
        DispatchQueue.global(qos: .default).async {
            // 耗时处理
            DispatchQueue.main.async {
                // 同步显示
                self.appImageView?.setPicture(sendImage)
            }
        }
    }

    /**
     *  将试图恢复到初始位置,并且添加动画
     *
     *  @param sender 按键sender
     */
    @objc func resetPosion(_: Any?) {
        UIView.animate(withDuration: 0.5, animations: {
            self.appImageView?.transform = CGAffineTransform(a: 1, b: 0.0, c: 0.0, d: 1, tx: 0, ty: 0)
            self.appImageView?.frame = self.orgRect
        })
    }

    /**
     *  重置所有绘制
     *
     *  @param sender <#sender description#>
     */
    @objc func resetDraw(_: Any?) {
        appImageView?.transform = orgTrf.scaledBy(x: 1, y: 1)
        appImageView?.frame = orgRect
        setLineWidth = DEFLINEWIDTH
        appImageView?.resetAllMask()
    }

    /**
     *  回退操作
     */
    @objc func redoButtonFoo() {
        appImageView?.redo()
    }

    /**
     *  前进操作
     */
    @objc func undoButtonFoo() {
        appImageView?.undo()
    }

    @objc func cutImageCut(_: Any?) {
        appImageView.isMove = false
        appImageView.isUserInteractionEnabled = true
        appImageView.isDraw = false
        appImageView.isDelete = false
        addCalculatePointButton.backgroundColor = UIColor.yellow
        addMaskPointButton.backgroundColor = UIColor.white
        deleteMaskPointButton.backgroundColor = UIColor.white
        moveImgButton.backgroundColor = UIColor.white
        isDraw = false
        isMove = false
        isDelete = false
        appImageView.removeGestureRecognizer(panGestureRecognizer!)
        appImageView.removeGestureRecognizer(pinchGestureRecognizer!)
    }

    @objc func addMaskPointFoo(_: Any?) {
        appImageView.isMove = false
        appImageView.isUserInteractionEnabled = true
        appImageView.isDraw = true
        appImageView.isDelete = false
        addCalculatePointButton.backgroundColor = UIColor.white
        addMaskPointButton.backgroundColor = UIColor.yellow
        deleteMaskPointButton.backgroundColor = UIColor.white
        moveImgButton.backgroundColor = UIColor.white
        isDraw = true
        isMove = false
        isDelete = false
        appImageView.removeGestureRecognizer(panGestureRecognizer!)
        appImageView.removeGestureRecognizer(pinchGestureRecognizer!)
    }

    @objc func deleteMaskPointFoo(_: Any?) {
        appImageView.isMove = false
        appImageView.isUserInteractionEnabled = true
        appImageView.isDraw = false
        appImageView.isDelete = true
        addCalculatePointButton.backgroundColor = UIColor.white
        addMaskPointButton.backgroundColor = UIColor.white
        deleteMaskPointButton.backgroundColor = UIColor.yellow
        moveImgButton.backgroundColor = UIColor.white
        isDelete = true
        isMove = false
        appImageView.removeGestureRecognizer(panGestureRecognizer!)
        appImageView.removeGestureRecognizer(pinchGestureRecognizer!)
    }

    @objc func enableMoveImg(_: Any?) {
        appImageView.isMove = true
        appImageView.isUserInteractionEnabled = true
        addCalculatePointButton.backgroundColor = UIColor.white
        addMaskPointButton.backgroundColor = UIColor.white
        deleteMaskPointButton.backgroundColor = UIColor.white
        moveImgButton.backgroundColor = UIColor.yellow
        isMove = true

        appImageView.addGestureRecognizer(panGestureRecognizer!)
        appImageView.addGestureRecognizer(pinchGestureRecognizer!)
    }

    @objc func nextStepFoo(_: Any?) {
        // RotateCutImageViewController *aa = [[RotateCutImageViewController alloc]init];
        getFinnalImageQueue.async {
            let setImage = self.appImageView?.getReusltImage()
            self.rotateCutImageViewController?.setImageRect(self.orgRect, andImage: setImage)
        }

        if let rotateCutImageViewController = rotateCutImageViewController {
            present(rotateCutImageViewController, animated: true)
        }
    }

    /**
     *  开打相册功能函数
     *
     *  @param sender <#sender description#>
     */
    @objc func takePictureClick(_: Any?) {
        /* 注：使用，需要实现以下协议：UIImagePickerControllerDelegate,
         UINavigationControllerDelegate
         */
        let picker = UIImagePickerController()
        // 设置图片源(相簿)
        picker.sourceType = .savedPhotosAlbum
        // 设置代理
        picker.delegate = self
        // 设置可以编辑
        picker.allowsEditing = true
        // 打开拾取器界面
        present(picker, animated: true)
    }

    // 完成选择图片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // 加载图片
        let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage
        appImageView.setPicture(image)
        // 重置绘制线宽
        setLineWidth = DEFLINEWIDTH
        // 选择框消失
        picker.dismiss(animated: true)
    }

    // 取消选择图片
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    /**
     *  初始化手势动作，其中不添加
     */
    func creatPan() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGestureRecognizer?.delegate = self
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinchGestureRecognizer?.delegate = self
    }

    @objc func handlePan(_ recognizer: UIPanGestureRecognizer?) {
        if isMove {
            if recognizer?.state == .changed {
                let translation = recognizer?.translation(in: view)
                recognizer?.view?.center = CGPoint(x: (recognizer?.view?.center.x ?? 0.0) + (translation?.x ?? 0.0), y: (recognizer?.view?.center.y ?? 0.0) + (translation?.y ?? 0.0))
                recognizer?.setTranslation(CGPoint.zero, in: view)
            } else if recognizer?.state == .ended {
                _ = recognizer?.view?.transform
                _ = orgTrf
            }
        }
    }

    @objc func handlePinch(_ recognizer: UIPinchGestureRecognizer?) {
        if isMove {
            if recognizer?.state == .changed {
                recognizer?.view?.transform = (recognizer?.view?.transform.scaledBy(x: recognizer!.scale, y: recognizer!.scale))!
                recognizer?.scale = 1 // 不重置为1则变化会太快
            } else if recognizer?.state == .ended {
                if (recognizer?.view?.transform.a ?? 0.0) > 2.0 {
                    UIView.animate(withDuration: 0.25, animations: {
                        recognizer?.view?.transform = CGAffineTransform(a: 2.0, b: 0.0, c: 0.0, d: 2.0, tx: 0, ty: 0) // 取消一切形变
                    })
                } else if (recognizer?.view?.transform.a ?? 0.0) < 0.6 {
                    UIView.animate(withDuration: 0.25, animations: {
                        recognizer?.view?.transform = CGAffineTransform(a: 0.6, b: 0.0, c: 0.0, d: 0.6, tx: 0, ty: 0) // 取消一切形变
                    })
                }

                appImageView?.setLineScale(Float((recognizer?.view?.transform.a)!))
                print("view.transform.a = \(recognizer?.view?.transform.a ?? 0.0)")
                let show = recognizer?.view?.transform
                let show2 = orgTrf
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addPoint2Array(_ aPoint: CGPoint) {
        if aPoint.x >= 0, aPoint.x < orgRect.size.width, aPoint.y >= 0, aPoint.y < orgRect.size.height {
            pointArray?.append(NSValue(cgPoint: aPoint))
        }
    }
}
