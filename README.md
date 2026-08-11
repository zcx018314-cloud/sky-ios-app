# Sky iOS App (WebView 壳)

把 http://120.48.161.149:5000/ 打包成 iOS App (IPA)。

## 云构建步骤

1. 在 GitHub 新建一个仓库
2. 把本文件夹的所有文件推上去（`git init && git add . && git commit && git push`）
3. 打开仓库 **Actions** 页面
4. 点 **Build IPA** 工作流 → **Run workflow**（手动触发）
5. 等待构建完成（约 5-10 分钟）
6. 构建完成后，在工作流运行结果里下载 **SkyApp-unsigned.ipa**

## 安装说明

生成的是**未签名** IPA，只能通过以下方式安装：

- **越狱设备**：直接用 Filza/Sileo 安装
- **未越狱设备**：需要用 Apple ID 签名（AltStore / Sideloadly / 爱思助手），
  免费 Apple ID 签名后 7 天过期需重签

## 自定义

- 修改网址：编辑 `SkyApp/ContentView.swift` 里的 URL
- 修改应用名：编辑 `SkyApp/Info.plist` 的 `CFBundleDisplayName`
- 修改图标：替换 `SkyApp/Assets.xcassets/AppIcon.appiconset/AppIcon.png`
- 修改包名：编辑 `project.yml` 的 `PRODUCT_BUNDLE_IDENTIFIER`

## 文件结构

```
├── SkyApp/                  # iOS 应用源码
│   ├── SkyApp.swift         # App 入口
│   ├── ContentView.swift    # WebView 壳
│   ├── Info.plist           # 应用配置（允许 HTTP）
│   └── Assets.xcassets/     # 图标资源
├── project.yml              # XcodeGen 项目定义
├── generate_icon.py         # 生成图标的脚本
└── .github/workflows/       # GitHub Actions 云构建配置
```
