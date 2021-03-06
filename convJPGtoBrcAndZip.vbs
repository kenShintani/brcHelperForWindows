'-----------------------------------------------
' bReader支援ツール for Windows その２：　JPEGからの生成支援
'-----------------------------------------------

'-----------------------------------------------
'このツールに必要な次のツールたちを予めダウンロードし、パスを以下に設定してください
'　brc　　（breader用データ生成）
'　7Zip　（zip生成）
'-----------------------------------------------
'
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
	msgstr = msgstr + "入力（書籍別jpeg）："  + srcPDFFilesFolder + vbCr +vbLf
	msgstr = msgstr + "出力（brc処理済みjpeg群zip）："  + destJPGFolderRoot + vbCr +vbLf
	
	msgbox msgstr	
  'フォルダオブジェクト取得
  Set fsoFolder = fsoObj.GetFolder(destJPGFolderRoot)
  
  'フォルダ内/ファイルループ
  For Each fsoFile In fsoFolder.Subfolders
    DoOneFolder fsoFile 
  Next
  
	msgstr = "変換処理が終了しました"+ vbCr +vbLf
	msgstr = msgstr + "成功：" + CStr( successCnt ) + vbCr +vbLf
	msgstr = msgstr + "brc失敗：" + CStr( brcFailedCnt ) + vbCr +vbLf
	msgbox( msgstr )
  
End Sub

Sub DoOneFolder( trgtFolder )

	'msgbox("trgtFolder=" & trgtFolder)
		
	savePath = fsoObj.BuildPath( destJPGFolderRoot, fsoObj.GetBaseName( trgtFolder ) )
	
	'msgbox("savePath=" & savePath)
	
	zipFileName = savePath & ".zip"
	if fsoObj.FileExists( zipFileName ) then
		exit sub
	end if
	
	'JPEG Filenames modify
	if fsoObj.FolderExists( savePath ) then
		subRenameFiles( savePath )
		
	else
		exit sub
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
		exit sub
	end if
	
	'delete workfolder
	if fsoObj.FolderExists( savePath ) then
		'savePathQu = """" & savePath & """"
		'msgbox("savePathQu=" & savePathQu)
		fsoObj.DeleteFolder savePath 
	end if
	
End Sub

Sub subRenameFiles( JPGFolderRoot )
   
  Set fsoFolder = fsoObj.GetFolder( JPGFolderRoot )
  Set regExObj_001 = CreateObject("VBScript.RegExp")
  regExObj_001.Pattern = "^([0-9])$"

  Set regExObj_002 = CreateObject("VBScript.RegExp")
  regExObj_002.Pattern = "^[0-9]{2}$"

  Set regExObj_003 = CreateObject("VBScript.RegExp")
  regExObj_003.Pattern = "^[0-9]{3}$"
  
  
  'フォルダ内/ファイルループ
  For Each fsoFile In fsoFolder.Files
    if fsoObj.GetExtensionName(fsoFile) = "jpg" then
	    fname = fsoObj.GetBaseName( fsoFile )
	    fnamenew = ""
	    
	    if( regExObj_001.Test( fname ) )then
	    	fnamenew = "000" + fname 
	    elseif( regExObj_002.Test( fname ) )then
	    	fnamenew = "00" + fname 
	    elseif( regExObj_003.Test( fname ) )then
	    	fnamenew = "0" + fname 
	    end if
	    
	    if( 0 < Len( fnamenew ) )then
	    	fsoFile.Name = fnamenew + "." + fsoObj.GetExtensionName( fsoFile )
	    end if
    end if
    
  Next
   
   
End Sub

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
