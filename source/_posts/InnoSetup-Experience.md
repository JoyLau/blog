---
title: InnoSetup --- 使用心得记录
date: 2019-09-04 09:08:13
description: 记录下 InnoSetup 的使用心得记录
categories: [InnoSetup篇]
tags: [InnoSetup]
---

<!-- more -->
## 添加环境变量【Registry】

```text
   [Registry]
   Root: HKCR; Subkey: "JOY-SECURITY"; ValueType: string; ValueData: "URL:JOY-SECURITY Protocol Handler"; Flags: uninsdeletekey
```

### Root  (必需的)
根键。必须是下列值中的一个:

HKCR  (HKEY_CLASSES_ROOT) 
HKCU  (HKEY_CURRENT_USER) 
HKLM  (HKEY_LOCAL_MACHINE) 
HKU  (HKEY_USERS) 
HKCC  (HKEY_CURRENT_CONFIG) 

### Subkey  (必需的)
子键名，可以包含常量。

### ValueType
值的数据类型。必须是下面中的一个:

none
string
expandsz
multisz
dword
qword
binary 

如果指定了 none (默认设置)，安装程序将创建一个没有键值的键，在这种情况下，ValueData 参数将被忽略。
如果指定了 string，安装程序将创建一个字符串 (REG_SZ) 值。
如果指定了 expandsz，安装程序将创建一个扩展字符串 (REG_EXPAND_SZ) 值。
如果指定了 multisz，安装程序将创建一个多行文本 (REG_MULTI_SZ) 值。
如果指定了 dword，安装程序将创建一个32位整数 (REG_DWORD) 值。
如果指定了 qdword，安装程序将创建一个64位整数 (REG_QDWORD) 值。
如果指定了 binary，安装程序将创建一个二进制 (REG_BINARY) 值。

### Flags
这个参数是额外选项设置。多个选项可以使用空格隔开。支持下面的选项:

createvalueifdoesntexist 
当指定了这个标记，安装程序只在如果没有相同名字的值存在时创建值。如果值类型是 none，或如果你指定了 deletevalue 标记，这个标记无效。

deletekey 
当指定了这个标记，安装程序在如果条目存在的情况下，先将尝试删除它，包括其中的所有值和子键。如果 ValueType 不是 none，那么它将创建一个新的键和值。

要防止意外，如果 Subkey 是空白的或只包含反斜框符号，安装时这个标记被忽略。

deletevalue 
当指定了这个标记，安装程序在如果值存在的情况下，先将尝试删除值，如果 ValueType 是 none，那么在键不存在的情况下，它将创建键以及新值。

dontcreatekey 
当指定了这个标记，如果键已经在用户系统中不存在，安装程序将不尝试创建键或值。如果键不存在，不显示错误消息。

一般来说，这个键与 uninsdeletekey 标记组合使用，在卸载时删除键，但安装时不创建键。

noerror 
如果安装程序因任何原因创建键或值失败，不显示错误消息。

preservestringtype 
这只在当 ValueType 参数是 string 或 expandsz 时适用。当指定这个标记，并且值不存在或现有的值不是 string 类型 (REG_SZ 或 REG_EXPAND_SZ)，它将用 ValueType 指定的类型创建。如果值存在，并且是 string 类型，它将用先存在值的相同值类型替换。

uninsclearvalue 
当卸载程序时，设置值数据为空字符 (类型 REG_SZ)。这个标记不能与 uninsdeletekey 标记组合使用。

uninsdeletekey 
当卸载程序时，删除整个键，包含其中的所有值和子键。这对于 Windows 自身使用的键明显不是一个好方法。你只能用于你的应用程序特有的键中。

为防止意外，安装期间如果 Subkey 空白或只包含反斜框符号，这个标记被忽略。

uninsdeletekeyifempty 
当程序卸载时，如果这个键的内部没有值或子键，则删除这个键。这个标记可以与 uninsdeletevalue 组合使用

为防止意外，安装期间如果 Subkey 空白或只包含反斜框符号，这个标记被忽略。

uninsdeletevalue 
当程序卸载时删除该值。这个标记不能与 uninsdeletekeyifempty 组合使用

注意: 在早于 1.1 的 Inno Setup 版本中，你可以使用这个标记连同数据类型 none，那么它的功能与“如果空则删除键”标记一样。这个方法已经不支持了。你必须使用 uninsdeletekeyifempty 标记实现。


## 添加环境变量【Code】
``` pascal
    //添加环境变量
    procedure CurStepChanged(CurStep: TSetupStep);
    var
    oldpath:	String;
    newpath:	String;
    ErrorCode: Integer;
    begin
    if CurStep = ssPostInstall then
    begin
       RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', oldPath);
       newPath := oldPath + ';%JAVA_HOME%\bin\;';
       RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'PATH', newPath);
       RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'JAVA_HOME', ExpandConstant('{app}\java\jdk1.8.0_45'));
    end;
    end; 
```

添加环境变量后记得在 setup 中配置 `ChangesEnvironment=yes` 通知其他应用程序从注册表重新获取环境变量


## 删除环境变量【Code】
``` pascal
    procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
    var
    oldpath:	String;
    newpath:	String;
    begin
    if CurUninstallStep = usDone then
       RegDeleteValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'JAVA_HOME');
       RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path', oldPath);
       StringChangeEx(oldPath, ';%JAVA_HOME%\bin\;', '', True);
       newPath := oldPath;
       RegWriteStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'PATH', newPath);
    end;
```

## 安装完成后执行脚本
```text
    [Run]
    Filename: "{app}\service-install.bat"; Description: "{cm:LaunchProgram,{#StringChange('SERVICE_INSTALL', '&', '&&')}}"; Flags: shellexec postinstall waituntilterminated runascurrentuser
```

### Parameters
程序的可选命令行参数，可以包含常量。

### Flags
这个参数是额外选项设置。多个选项可以使用空格隔开。支持下面的选项:

32bit 
Causes the {sys} constant to map to the 32-bit System directory when used in the Filename and WorkingDir parameters. This is the default behavior in a 32-bit mode install。

这个标记不能与 shellexec 组合使用。

64bit 
Causes the {sys} constant to map to the 64-bit System directory when used in the Filename and WorkingDir parameters. This is the default behavior in a 64-bit mode install。

This flag can only be used when Setup is running on 64-bit Windows, otherwise an error will occur. On an installation supporting both 32- and 64-bit architectures, it is possible to avoid the error by adding a Check: IsWin64 parameter, which will cause the entry to be silently skipped when running on 32-bit Windows。

这个标记不能与 shellexec 组合使用。

hidewizard 
如果指定了这个标记，向导将在程序运行期间隐藏。

nowait 
如果指定了这个标记，它将在处理下一个 [Run] 条目前或完成安装前不等待进程执行完成。不能与 waituntilidle 或 waituntilterminated 组合使用。

postinstall 
仅在 [Run] 段有效。告诉安装程序在安装完成向导页创建一个选择框，用户可以选中或不选中这个选择框从而决定是否处理这个条目。以前这个标记调用 showcheckbox。

如果安装程序已经重新启动了用户的电脑 (安装了一个带 restartreplace 标记的文件或如果 [Setup] 段的 AlwaysRestart 指令是 yes 引起的)，选择框没有机会出现，因此这些条目不会被处理。

[Files] 段条目中的 isreadme 标记现在已被废弃。如果编译器带 isreadme 标记的条目，它将从 [Files] 段条目中忽略这个标记，并在 [Run] 段条目列表的开头插入一个生成的 [Run] 条目。这相生成的 [Run] 段条目运行自述文件，并带有 shellexec，skipifdoesntexist，postinstall 和 skipifsilent 标记。

runascurrentuser 
如果指定了这个标记，the spawned process will inherit Setup/Uninstall's user credentials (typically, full administrative privileges)。

This is the default behavior when the postinstall flag is not used。

这个标记不能与 runasoriginaluser 组合使用。

runasoriginaluser 
仅在 [Run] 段有效。If this flag is specified and the system is running Windows Vista or later, the spawned process will execute with the (normally non-elevated) credentials of the user that started Setup initially (i.e., the "pre-UAC dialog" credentials)。

This is the default behavior when the postinstall flag is used。

If a user launches Setup by right-clicking its EXE file and selecting "Run as administrator", then this flag, unfortunately, will have no effect, because Setup has no opportunity to run any code with the original user credentials. The same is true if Setup is launched from an already-elevated process. Note, however, that this is not an Inno Setup-specific limitation; Windows Installer-based installers cannot return to the original user credentials either in such cases。

这个标记不能与 runascurrentuser 组合使用。

runhidden 
如果指定了这个标记，它将在隐藏窗口中运行程序。请在执行一个要提示用户输入的程序中不要使用这个标记。

runmaximized 
如果指定了这个标记，将在最大化窗口运行程序或文档。

runminimized 
如果指定了这个标记，将在最小化窗口运行程序或文档。

shellexec 
如果 Filename 不是一个直接可执行文件 (.exe 或 .com 文件)，这个标记是必需的。当设置这个标记时，Filename 可以是一个文件夹或任何已注册的文件类型 -- 包括 .hlp，.doc 等。该文件将用用户系统中与这个文件类型关联的应用程序打开，与在资源管理器双击文件的方法是相同的。

按默认，当使用 shellexec 标记时，将不等待，直到生成的进程终止。
如果你需要，你必须添加标记 waituntilterminated。注意，如果新进程未生成，它不能执行也将不等待 -- 例如，文件指定指定为一个文件夹。

skipifdoesntexist 
如果这个标记在 [Run] 段中指定，如果 Filename 不存在，安装程序不显示错误消息。

如果这个标记在 [UninstallRun] 段中指定，如果 Filename 不存在，卸载程序不显示“一些元素不能删除”的警告。

在使用这个标记时， Filename 必须是一个绝对路径。

skipifnotsilent 
仅在 [Run] 段有效。告诉安装程序如果安装程序未在后台运行则跳过这个条目。

skipifsilent 
仅在 [Run] 段有效。告诉安装程序如果安装程序在后台运行则跳过这个条目。

unchecked 
仅在 [Run] 段有效。告诉安装程序初始为不选中选择框。如果用户希望处理这个条目，可以通过选取选择框执行。如果 postinstall 标记未同时指定，这个标记被忽略。

waituntilidle 
如果指定了这个标记，它将在未输入期间等待，直到进程等待用户输入，而不是等待进程终止。(调用 WaitForInputIdle Win32 函数。) 不能与 nowait 或 waituntilterminated 组合使用。

waituntilterminated 
如果指定这个标记，将等待到进程完全终止。注意这是一个默认动作 (也就是你不需要指定这个标记)，除非你使用了 shellexec 标记，在这种情况下，如果你要等待，需要指定这个标记。不能与 nowait 或 waituntilidle 组合使用。

## 安装前卸载旧版本
``` pascal
    function InitializeSetup(): boolean;
    var
    bRes: Boolean;
    ResultStr: String;
    ResultCode: Integer;
    begin
    if RegQueryStringValue(HKLM, 'SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{4AA89D60-9EB2-4A69-B73E-67E3AC22CF8E}_is1', 'UninstallString', ResultStr) then
      begin
        MsgBox('检测到系统之前安装过本程序,即将卸载低版本！', mbInformation, MB_OK);
        ResultStr := RemoveQuotes(ResultStr);
        bRes := Exec(ResultStr, '/silent', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
        if bRes and (ResultCode = 0) then begin
          result := true;
          Exit;
        end else
          MsgBox('卸载低版本失败！', mbInformation, MB_OK);
          result:= false;
          Exit;
      end;
      result := true;
    end;
```

## 检测服务是否存在并删除
``` pascal
    function DeleteService(strExeName: String): Boolean;
    var
    ErrorCode: Integer;
    bRes: Boolean;
    strCmdFind: String;
    strCmdDelete: String;
    begin
      strCmdFind := Format('/c sc query "%s"', [strExeName]);
      strCmdDelete := Format('/c sc stop "%s" & sc delete "%s"', [strExeName, strExeName]);
      bRes := ShellExec('open', ExpandConstant('{cmd}'), strCmdFind, '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
      if bRes and (ErrorCode = 0) then begin
          if MsgBox('检测到 ' + strExeName + ' 服务存在，需要删除，是否继续？', mbConfirmation, MB_YESNO) = IDYES then begin
              bRes := ShellExec('open', ExpandConstant('{cmd}'), strCmdDelete, '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
              if bRes and (ErrorCode = 0) then begin
                 MsgBox('服务 '+strExeName+' 删除成功！', mbInformation, MB_OK);
                 result := true;
                 Exit;
              end else
                 MsgBox('删除失败，请手动删除服务 ' + strExeName, mbError, MB_OK);
                 result := false;
                 Exit;
          end else
          result := false;
          Exit;
      end;
      MsgBox('服务 '+strExeName+' 不存在！', mbInformation, MB_OK);
      result := true;
    end;
```