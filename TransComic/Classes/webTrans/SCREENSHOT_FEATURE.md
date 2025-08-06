# 网页分页截屏功能

## 功能概述

在网页详情页右下角添加了悬浮截屏按钮，支持自动分页截屏功能，可以将长网页分割成多张图片进行保存。

## 主要特性

### 1. 悬浮按钮
- **位置**: 右下角，位于工具栏上方
- **样式**: 圆形按钮，使用相机图标
- **交互**: 点击触发截屏，长按显示提示
- **动画**: 点击时有缩放动画效果

### 2. 智能显示/隐藏
- **滑动时**: 自动隐藏到页面外
- **停止时**: 自动显示
- **定时隐藏**: 停止滑动2秒后自动隐藏
- **动画效果**: 平滑的滑入滑出动画

### 3. 分页截屏
- **自动分页**: 根据网页高度自动计算页数
- **智能滚动**: 自动滚动到指定位置进行截屏
- **进度显示**: 实时显示截屏进度
- **错误处理**: 完善的错误处理机制

### 4. 结果处理
- **图片浏览**: 支持左右滑动查看截屏结果
- **保存功能**: 支持保存到相册
- **批量操作**: 支持批量保存所有截屏

## 技术实现

### 1. 悬浮按钮组件 (TCFloatingScreenshotButton)
```swift
// 主要功能
- 显示/隐藏动画
- 点击和长按手势
- 定时隐藏机制
- 视觉反馈效果
```

### 2. 截屏管理器 (TCScreenshotManager)
```swift
// 核心功能
- 获取网页总高度
- 计算分页数量
- 自动滚动控制
- 截屏执行
- 进度回调
```

### 3. 图片浏览 (TCScreenshotGalleryViewController)
```swift
// 浏览功能
- 全屏图片浏览
- 左右滑动切换
- 页码显示
- 单张保存
```

## 使用流程

### 1. 触发截屏
```
用户点击悬浮按钮 → 开始分页截屏 → 显示加载提示
```

### 2. 截屏过程
```
获取网页高度 → 计算页数 → 逐页滚动 → 截屏 → 更新进度
```

### 3. 结果处理
```
截屏完成 → 显示结果弹窗 → 选择保存或浏览 → 执行相应操作
```

## 代码结构

```
webTrans/
├── view/
│   └── TCFloatingScreenshotButton.swift    # 悬浮按钮
├── TCScreenshotManager.swift               # 截屏管理器
├── TCScreenshotGalleryViewController.swift # 图片浏览
└── TCWebDetailViewController.swift         # 主控制器（已更新）
```

## 关键方法

### 悬浮按钮控制
```swift
// 显示按钮
floatingScreenshotButton.show()

// 隐藏按钮
floatingScreenshotButton.hide()

// 启动隐藏定时器
floatingScreenshotButton.startHideTimer()

// 取消隐藏定时器
floatingScreenshotButton.cancelHideTimer()
```

### 截屏控制
```swift
// 开始分页截屏
screenshotManager.startPageScreenshot()

// 保存截屏到相册
screenshotManager.saveScreenshotsToPhotos(images) { success, error in
    // 处理结果
}
```

### 滚动监听
```swift
// UIScrollViewDelegate
func scrollViewDidScroll(_ scrollView: UIScrollView) {
    handleScroll() // 隐藏按钮
}

func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    handleScrollEnd() // 显示按钮
}
```

## 用户体验

### 1. 视觉反馈
- ✅ 按钮点击动画
- ✅ 滑动隐藏动画
- ✅ 截屏进度提示
- ✅ 加载状态显示

### 2. 交互体验
- ✅ 智能显示/隐藏
- ✅ 长按提示功能
- ✅ 流畅的动画效果
- ✅ 直观的操作反馈

### 3. 功能完整性
- ✅ 自动分页截屏
- ✅ 图片浏览功能
- ✅ 保存到相册
- ✅ 错误处理

## 调试信息

为了便于调试，添加了详细的日志输出：

```
📸 开始分页截屏: 总高度 2000, 屏幕高度 600, 总页数 4
📸 截屏成功: 第 1 页
📸 截屏进度: 25%
📸 截屏成功: 第 2 页
📸 截屏进度: 50%
✅ 分页截屏完成: 共 4 张图片
💾 保存截屏到相册: 4 张图片
```

## 注意事项

### 1. 性能考虑
- 截屏过程会占用较多内存
- 长网页可能产生大量图片
- 建议限制最大页数

### 2. 权限要求
- 需要相册访问权限
- 需要网络访问权限

### 3. 兼容性
- 支持iOS 11.0+
- 需要WKWebView支持

### 4. 用户体验
- 截屏过程需要等待
- 建议添加取消功能
- 考虑添加预览功能

## 扩展建议

1. **截屏设置**: 添加截屏质量、格式等设置
2. **批量操作**: 支持批量删除、分享等操作
3. **智能裁剪**: 自动去除广告、导航等区域
4. **OCR识别**: 集成文字识别功能
5. **云端同步**: 支持截屏结果云端存储 