#!/bin/zsh

# PNG -> high-DPI TIFF converter for macOS.
# Drag PNG files onto this script, or double-click it and choose files.

emulate -L zsh
setopt NO_NOMATCH

print ""
print "========================================"
print "       PNG -> 高 DPI TIFF"
print "========================================"
print ""

typeset -a input_files

if (( $# > 0 )); then
  input_files=("$@")
else
  selected_files=$(osascript <<'APPLESCRIPT'
try
  set chosenFiles to choose file of type {"public.png"} with prompt "请选择一个或多个 PNG 图片" with multiple selections allowed
  set outputText to ""
  repeat with chosenFile in chosenFiles
    set outputText to outputText & POSIX path of chosenFile & linefeed
  end repeat
  return outputText
on error number -128
  return ""
end try
APPLESCRIPT
  )

  if [[ -n "$selected_files" ]]; then
    while IFS= read -r selected_file; do
      [[ -n "$selected_file" ]] && input_files+=("$selected_file")
    done <<< "$selected_files"
  fi
fi

if (( ${#input_files[@]} == 0 )); then
  print "未选择 PNG 文件。"
  print ""
  [[ "${COMMAND_TOOL_NO_PAUSE:-0}" != "1" ]] && read -r "_?按回车键关闭..."
  exit 0
fi

if [[ -n "${TIFF_DPI:-}" ]]; then
  target_dpi="$TIFF_DPI"
else
  read -r "dpi_input?请输入目标 DPI [默认 600]: "
  target_dpi=${dpi_input:-600}
fi

if [[ ! "$target_dpi" =~ '^[0-9]+$' ]] || (( target_dpi < 72 || target_dpi > 9600 )); then
  print "DPI 无效，请输入 72 到 9600 之间的整数。"
  print ""
  [[ "${COMMAND_TOOL_NO_PAUSE:-0}" != "1" ]] && read -r "_?按回车键关闭..."
  exit 1
fi

integer success_count=0
integer failure_count=0

print ""
print "正在转换为 ${target_dpi} DPI..."
print ""

for input_path in "${input_files[@]}"; do
  if [[ ! -f "$input_path" ]]; then
    print "[跳过] 找不到文件：$input_path"
    (( failure_count++ ))
    continue
  fi

  extension=${input_path:e:l}
  if [[ "$extension" != "png" ]]; then
    print "[跳过] 不是 PNG 文件：$input_path"
    (( failure_count++ ))
    continue
  fi

  source_dir=${input_path:h}
  source_name=${input_path:t:r}
  output_path="${source_dir}/${source_name}.tiff"

  integer suffix=2
  while [[ -e "$output_path" ]]; do
    output_path="${source_dir}/${source_name}_${suffix}.tiff"
    (( suffix++ ))
  done

  if /usr/bin/sips \
      --setProperty format tiff \
      --setProperty dpiWidth "$target_dpi" \
      --setProperty dpiHeight "$target_dpi" \
      "$input_path" \
      --out "$output_path" >/dev/null 2>&1; then
    print "[OK] ${output_path:t}"
    (( success_count++ ))
  else
    print "[失败] ${input_path:t}"
    (( failure_count++ ))
  fi
done

print ""
print "完成：成功 ${success_count} 个，跳过或失败 ${failure_count} 个。"
print "TIFF 文件已保存到原 PNG 所在文件夹。"
print ""
[[ "${COMMAND_TOOL_NO_PAUSE:-0}" != "1" ]] && read -r "_?按回车键关闭..."

(( failure_count == 0 ))

