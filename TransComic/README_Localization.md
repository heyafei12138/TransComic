# TransComic 本地化使用指南

## 概述

TransComic 应用现已支持多语言本地化，包括以下语言：
- 简体中文 (zh-Hans)
- 英语 (en)
- 日语 (ja)
- 韩语 (ko)
- 德语 (de)
- 法语 (fr)
- 意大利语 (it)

## 本地化文件结构

```
TransComic/base/
├── zh-Hans.lproj/          # 简体中文
│   └── Localizable.strings
├── en.lproj/               # 英语
│   └── Localizable.strings
├── ja.lproj/               # 日语
│   └── Localizable.strings
├── ko.lproj/               # 韩语
│   └── Localizable.strings
├── de.lproj/               # 德语
│   └── Localizable.strings
├── fr.lproj/               # 法语
│   └── Localizable.strings
└── it.lproj/               # 意大利语
    └── Localizable.strings
```

## 使用方法

### 1. 在代码中使用本地化字符串

项目已经集成了 `Localize-Swift` 库，您可以通过以下方式使用本地化字符串：

```swift
// 方式1：使用 .localized 扩展
let title = "设置".localized

// 方式2：使用 Localized 函数
let title = Localized("设置")

// 方式3：使用 TCLanguageManager
let title = TCLanguageManager.shared.localizedString(for: "设置")
```

### 2. 切换语言

使用 `TCLanguageManager` 来管理语言切换：

```swift
// 切换语言
TCLanguageManager.shared.changeLanguage(to: "en") { success in
    if success {
        // 语言切换成功，重新加载界面
        // 通常需要重新设置根视图控制器
        kWindow?.rootViewController = UINavigationController(rootViewController: HomeViewController())
    }
}

// 获取当前语言
let currentLanguage = TCLanguageManager.shared.currentLanguage

// 获取可用语言列表
let availableLanguages = TCLanguageManager.shared.availableLanguages
```

### 3. 监听语言变化

```swift
// 添加语言变化通知监听
NotificationCenter.default.addObserver(
    self,
    selector: #selector(languageDidChange),
    name: .languageDidChange,
    object: nil
)

@objc private func languageDidChange() {
    // 处理语言变化，更新UI
    updateLocalizedTexts()
}
```

## 添加新的本地化字符串

### 1. 在代码中添加新的字符串

```swift
let newText = "新功能".localized
```

### 2. 在所有语言的 Localizable.strings 文件中添加对应的翻译

**中文 (zh-Hans.lproj/Localizable.strings):**
```
"新功能" = "新功能";
```

**英文 (en.lproj/Localizable.strings):**
```
"新功能" = "New Feature";
```

**日文 (ja.lproj/Localizable.strings):**
```
"新功能" = "新機能";
```

**韩文 (ko.lproj/Localizable.strings):**
```
"新功能" = "새로운 기능";
```

**德文 (de.lproj/Localizable.strings):**
```
"新功能" = "Neue Funktion";
```

**法文 (fr.lproj/Localizable.strings):**
```
"新功能" = "Nouvelle fonctionnalité";
```

**意大利文 (it.lproj/Localizable.strings):**
```
"新功能" = "Nuova funzionalità";
```

## 本地化字符串分类

为了便于维护，本地化字符串按以下分类组织：

- **通用**: 常用的按钮文本、状态提示等
- **导航和标题**: 页面标题、导航栏文本等
- **功能描述**: 功能说明、介绍文本等
- **设置**: 设置页面相关的文本
- **语言名称**: 各种语言的名称
- **快捷指令设置**: 快捷指令配置相关的文本
- **快捷指令步骤**: 设置步骤说明
- **历史记录**: 历史记录相关的文本
- **网页翻译**: 网页翻译功能相关的文本
- **图片相关**: 图片处理相关的文本
- **关于页面**: 关于页面的文本
- **分享和反馈**: 分享、反馈功能相关的文本
- **其他**: 其他杂项文本

## 注意事项

1. **保持一致性**: 确保所有语言的 Localizable.strings 文件包含相同的键值对
2. **及时更新**: 添加新功能时，记得同时更新所有语言的本地化文件
3. **测试验证**: 切换不同语言后，验证所有文本是否正确显示
4. **文化适应**: 某些文本可能需要根据目标语言的文化背景进行调整

## 故障排除

### 常见问题

1. **文本未本地化**: 检查是否使用了 `.localized` 扩展或 `Localized()` 函数
2. **语言切换无效**: 确保在语言切换后重新加载了界面
3. **某些文本仍显示中文**: 检查是否遗漏了某些硬编码的文本

### 调试技巧

```swift
// 打印当前语言
print("Current language: \(TCLanguageManager.shared.currentLanguage)")

// 打印本地化字符串
print("Localized string: \(TCLanguageManager.shared.localizedString(for: "设置"))")

// 检查语言包是否正确加载
let bundle = TCLanguageManager.shared.getBundle(for: "en")
print("Bundle path: \(bundle.bundlePath)")
```

## 扩展支持

如需添加新的语言支持，请：

1. 在 `TransComic/base/` 目录下创建新的 `.lproj` 文件夹
2. 复制现有语言的 `Localizable.strings` 文件并翻译内容
3. 在 `TCLanguageManager` 的 `availableLanguages` 数组中添加新语言
4. 测试新语言的显示效果

---

如有任何问题或建议，请联系开发团队。
