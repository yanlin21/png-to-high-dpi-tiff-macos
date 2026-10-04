# PNG to High-DPI TIFF

[![Windows test](https://github.com/yanlin21/png-to-high-dpi-tiff/actions/workflows/windows-test.yml/badge.svg)](https://github.com/yanlin21/png-to-high-dpi-tiff/actions/workflows/windows-test.yml)

一个可双击运行的 macOS/Windows 工具，将一个或多个 PNG 文件转换为 TIFF，
并设置指定的 DPI 元数据。默认值为 600 DPI。

> DPI 只是打印尺寸元数据；本工具不会增加原图像素，也不会创造额外细节。

## macOS

- 使用系统自带的 `zsh`、AppleScript 和 `sips`，无需额外依赖。

```bash
chmod +x PNG转高DPI的TIFF.command
```

- 双击脚本，在文件选择器中选择一个或多个 PNG。
- 或将 PNG 文件拖到脚本图标上。
- 输入 72–9600 之间的 DPI；直接回车使用 600。
- TIFF 保存在原 PNG 文件夹中，且不会覆盖已有文件。

命令行也可指定 DPI：

```bash
TIFF_DPI=300 COMMAND_TOOL_NO_PAUSE=1 ./PNG转高DPI的TIFF.command image.png
```

## Windows

- 支持 Windows 10/11 和系统自带的 Windows PowerShell 5.1。
- 双击 `png-to-high-dpi-tiff.cmd`，通过文件选择器选择 PNG。
- 或把一个或多个 PNG 拖到 `.cmd` 文件上。
- `.cmd` 会调用同目录下的 `png-to-high-dpi-tiff.ps1`。
- TIFF 保存在原 PNG 旁边，不覆盖已有文件。

也可以从命令行运行：

```powershell
$env:TIFF_DPI = '300'
.\png-to-high-dpi-tiff.ps1 .\image.png
```

## Privacy

所有转换均在本机完成，不上传图片。macOS 使用系统 `sips`，Windows 使用
.NET `System.Drawing`。

## License

MIT
