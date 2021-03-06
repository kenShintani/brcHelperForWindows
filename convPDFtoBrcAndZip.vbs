'-----------------------------------------------
' bReader支援ツール for Windows その１：　PDFからの生成支援
'-----------------------------------------------

'　
'-----------------------------------------------
'このツールに必要な次のツールたちを予めダウンロードし、パスを以下に設定してください
'　ImageMagic , GhostScript  (PDFからjpeg抽出)
'　brc　　（breader用データ生成）
'　7Zip　（zip生成）
'-----------------------------------------------
'

'ImageMagicのインストールフォルダ
ImgToolpath ="""C:\Program Files\ImageMagick-6.8.8-Q16\convert"""

'変換対象となるPDFファイルを格納しているフォルダ
srcPDFFilesFolder = "E:\BookData\WorkForBReader\PDF\"

'最終的にbrc処理させたzipを保存するためのフォルダ
'　日本語パスは使わない方が良いでしょう。
destJPGFolderRoot = "E:\BookData\WorkForBReader\Work\"

'brcツールのあるフォルダ
BrcToolpath ="""E:\BookData\WorkForBReader\brc"""

'7zipを置いているフォルダ
CompressToolpath ="""C:\Program Files\7-Zip\7z.exe"""


'-----------------------------------------------
'-----------------------------------------------
'-----------------------------------------------
'定数。ここから先は変更不要。
'-----------------------------------------------
Set fsoObj = CreateObject("Scripting.FileSystemObject")
densityParam = 300
CompressToolArgs ="a  -tzip"
successCnt = 0
jpegSkippedCnt = 0
jpegFailedCnt = 0
brcFailedCnt = 0

MainProc 


'-----------------------------------------------
'メイン実行部
'-----------------------------------------------
Sub MainProc( )
	
	msgstr = "処理を開始します" + vbCr +vbLf
	msgstr = msgstr + "入力（PDF）："  + srcPDFFilesFolder + vbCr +vbLf
	msgstr = msgstr + "出力（brc処理済みjpeg群zip）："  + destJPGFolderRoot + vbCr +vbLf
	
	msgbox msgstr
	
  'フォルダオブジェクト取得
  Set fsoFolder = fsoObj.GetFolder(srcPDFFilesFolder)
  
  'フォルダ内/ファイルループ
  For Each fsoFile In fsoFolder.Files
    
    extStr = fsoObj.GetExtensionName(fsoFile )
    
    if( "pdf" = extStr )then
    
    	DoOneFile fsoFile 
    end if
  Next
  
	msgstr = "変換処理が終了しました"+ vbCr +vbLf
	msgstr = msgstr + "成功：" + CStr( successCnt ) + vbCr +vbLf
	msgstr = msgstr + "jpeg変換失敗" + CStr( jpegFailedCnt )+ vbCr +vbLf
	msgstr = msgstr + "brc失敗：" + CStr( brcFailedCnt )+ vbCr +vbLf
	msgbox( msgstr )
  
End Sub

Sub DoOneFile( trgtFile )

	savePath = fsoObj.BuildPath( destJPGFolderRoot, fsoObj.GetBaseName( trgtFile ) )
	
	zipFileName = savePath & ".zip"
	if fsoObj.FileExists( zipFileName ) then
		exit sub
	end if
	
	'PDF to JPEG
	if fsoObj.FolderExists( savePath ) then
		' JPEGフォルダがあるなら何もしない・・
		' fsoObj.DeleteFolder savePath
		
		jpegSkippedCnt = jpegSkippedCnt +1
	else
		ret = PDFToJPEGOneFile( trgtFile , savePath )
		
		if 0 <> ret  then
			jpegFailedCnt = jpegFailedCnt +1
			exit sub
		end if
	end if
	
	
	Set WshShell = WScript.CreateObject("WScript.Shell")
	
	'brc exec
	
	brcfile = savePath & "\d.brd"
	if fsoObj.FolderExists( brcfile ) then
		
	else
		brcCmdPath = BrcToolpath
		brcCmdPath = brcCmdPath & "  " 
		brcCmdPath = brcCmdPath & """" & savePath & """"
		ret = WshShell.Run( brcCmdPath , 8, true) 
		WScript.Sleep 3000
		'msgbox("brc ret=" & ret)
		
		if 0 = ret then
		else
			brcFailedCnt = brcFailedCnt +1
			exit sub
		end if
		
	end if
	
	'Files to zip
	
	
	zipCmdPath = CompressToolpath
	zipCmdPath = zipCmdPath & "  " 
	zipCmdPath = zipCmdPath & CompressToolArgs
	zipCmdPath = zipCmdPath & "  " 
	zipCmdPath = zipCmdPath & """" & zipFileName & """"
	zipCmdPath = zipCmdPath & "  " 
	zipCmdPath = zipCmdPath & """" & savePath & "\"""
	'msgbox("zipCmdPath=" & zipCmdPath)
	ret = WshShell.Run( zipCmdPath , 8, true) 
	'msgbox("zip ret=" & ret)
	
	WScript.Sleep 3000
	
	if 0 = ret then
	else
		saveBrcFailedPath = fsoObj.BuildPath( destJPGFolderRoot, "brcFailed" )
		subCreateFolders saveBrcFailedPath
		saveBrcFailedPath = fsoObj.BuildPath( saveBrcFailedPath, fsoObj.GetBaseName( trgtFile ) )
		fsoObj.MoveFolder saveTmpPath, saveBrcFailedPath
		exit sub
	end if
	
	'delete workfolder
	if fsoObj.FolderExists( savePath ) then
		'savePathQu = """" & savePath & """"
		'msgbox("savePathQu=" & savePathQu)
		fsoObj.DeleteFolder savePath 
	end if
	
	successCnt = successCnt +1
	
End Sub

' PDFファイルをJPEGに変換。
'  ImageMagick, GhostScriptが別途必要
Function PDFToJPEGOneFile( trgtFile , savePath)

	'convert.exeは日本語ファイル名中に半角スペースが有ると動作がおかしくなる。
	'なので元ファイル名、出力ファイルパスを強制的に変更し、あとでrenameする
	
	subCreateFolders destJPGFolderRoot
	tmpFilePath = fsoObj.BuildPath( destJPGFolderRoot, "temp.pdf" )
	fsoObj.CopyFile trgtFile , tmpFilePath
	
	saveTmpPath = fsoObj.BuildPath( destJPGFolderRoot, "work" )
	subCreateFolders saveTmpPath
	
	

	cmdPath = ImgToolpath
	cmdPath = cmdPath & "  " 
	cmdPath = cmdPath & " -density " 
	cmdPath = cmdPath & densityParam
	cmdPath = cmdPath & "  " 
	cmdPath = cmdPath & """" & tmpFilePath & """"
	cmdPath = cmdPath & "  " 
	cmdPath = cmdPath & """" & saveTmpPath
	cmdPath = cmdPath & "\%04d.jpg" & """"
	
	Set WshShell = WScript.CreateObject("WScript.Shell")
	ret = WshShell.Run( cmdPath , 8, true) 
	
	if 0 = ret then
		fsoObj.MoveFolder saveTmpPath, savePath
	else
		saveTmpPath02 = fsoObj.BuildPath( destJPGFolderRoot, "jpgFailed" )
		subCreateFolders saveTmpPath02
		saveTmpPath02 = fsoObj.BuildPath( saveTmpPath02, fsoObj.GetBaseName( trgtFile ) )
		fsoObj.MoveFolder saveTmpPath, saveTmpPath02
	end if
	fsoObj.DeleteFile tmpFilePath
	
	
	PDFToJPEGOneFile = ret
End Function


Sub subCreateFolders( strPathorg )
   Dim objFileSys
   Dim strPath, strNewFolder
   
   strPath = strPathorg
   If Right(strPath, 1) <> "\" Then
      strPath = strPath & "\"
   End If

   strNewFolder = ""
   Do Until strPath = strNewFolder
      strNewFolder = Left(strPath, InStr(Len(strNewFolder) + 1, strPath, "\"))
    
      If fsoObj.FolderExists(strNewFolder) = False Then
         fsoObj.CreateFolder(strNewFolder)
      End If
   Loop
End Sub
