# PNG to High-DPI TIFF for macOS

一个可双击运行的 macOS 工具，将一个或多个 PNG 文件转换为 TIFF，并设置
指定的 DPI 元数据。默认值为 600 DPI。

> DPI 只是打印尺寸元数据；本工具不会增加原图像素，也不会创造额外细节。

## Requirements

- macOS
- 系统自带的 `zsh`、AppleScript 和 `sips`

## Usage

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

## Privacy

所有转换均在本机完成，不上传图片。

## License

MIT

