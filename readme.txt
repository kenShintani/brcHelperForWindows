readme: bReader支援ツール for Windows 
(This file was encoded by UTF8)


■はじめに
このスクリプトたちは、iOS用アプリ bReader (https://itunes.apple.com/jp/app/breader-qing-kong-wen-ku/id411884081?mt=8)
のおまけツール「brc」を、手軽に利用するためのツールです。


■動作に必要なツール
このツールを利用するためには、次のツールたちが必要です。


○Windows XP以上
	このスクリプトたちはWindowsScriptingHost(WSH)を利用しています。VBScriptです。
	windows以外の環境では動作しないと予測されます。
	なお、幾つかのツールは「64bitか32bitか？」を意識してセットアップする必要がありますので、予め確認しておきましょう。
	
○ImageMagic
	http://www.imagemagick.org/
	PDFファイルをJPEG化するために利用します。
	お使いの環境（x64/x86など）に合ったものをダウンロード・セットアップしてください。
	
○GhostScript
	http://www.ghostscript.com/
	ImageMagicとともに、PDFファイルをJPEG化するために利用します。
	
○7Zip
	http://sevenzip.sourceforge.jp/
	JPEGファイルやbrcデータファイルをzipとして圧縮するために利用します。
	
○brc
	http://vtns.wordpress.com/brc-1/
	bReader用おまけツール。
	bReaderの「あの機能」を利用するためには不可欠なツールです。

■利用手順
1.　まずは上記の各ツールをダウンロードしセットアップします。
2.　次に、breaderで読みたいPDFファイルを、ひとつのフォルダにまとめておきます。
　　
3.　convPDFtoBrcAndZip.vbs　をテキストエディタで開きます。
　　15行目付近の次の各行を、各ツールのセットアップフォルダに合わせて変更します。
　　　ImgToolpath
　　　srcPDFFilesFolder
　　　destJPGFolderRoot
　　　CompressToolpath
　　　BrcToolpath
　　　
　　　　（注意）
　　　　　(1) destJPGFolderRootのフォルダパスには日本語を含まない状態をお勧めします。
　　　　　　　（c:\temp\などを推奨）
　　　　　(2)ファイルを保存するときは「Unicode（UTF16）」か「SJIS」にしてください。
　　　　　　　
　　　　　　　
4.　windowsのエクスプローラー上で　convPDFtoBrcAndZip.vbs　をダブルクリップするなどして実行します。
　　途中でアプリケーションの強制終了ダイアログなどが開いても、気にせず閉じて下さい。
　　
5.　全部のPDFの処理が終了すると、変換の成功数・失敗数が表示されます。
　　　$(destJPGFolderRoot)/jpgFailed　以下にjpeg変換に失敗したファイルの名前のフォルダが残ります。
　　　$(destJPGFolderRoot)/brcFailed　以下にbrc処理に失敗したファイルの名前のフォルダが残ります。
　　　
6.　必要に応じて3以降の処理を繰り返します。
　　
　　
　　
○JPEG変換やBRC処理で失敗したファイルの救済について
　ImageMagic/GhostScript以外のツールでPDFからJPEG出力を行うと、救済できる可能性があります。
　JPEGファイルに展開した後、convJPGtoBrcAndZip.vbsの各行を変更し実行してください。
　convJPGtoBrcAndZip.vbs　で変更すべき内容は、convPDFtoBrcAndZip.vbs　に準じます。
　
　　※jpegファイル名は 1.jpeg 2.jpeg ... 10.jpeg というように連番になっていることを期待しています。
　　　brc/breaderが認識しやすいよう、convJPGtoBrcAndZip内部で、必要に応じて頭に0を追加しています。
　　　 
　　

■制限事項
・スクリプト全体としては中止機能を持ちません。
　　必要に応じてタスクマネージャーでprocessをkillしてください。
・いくつかのファイルで、PDF→jpeg変換に失敗するケースを確認しています。
　　ImageMagicおよびGhostSciptの問題だと思われます。
　　Windowsがエラーダイアログを表示していても、ダイアログを閉じれば次のファイルへと処理を移します。
　　（スクリプト全体としては中止機能を持ちません）
・いくつかのファイルで、jpegファイル群の解析途中でbrc.exeが強制終了するようです。
　　この場合、別のPDF→jpeg変換ツールを使うと、brc処理に成功する可能性があります。
　　　　（例）pdf-xchange viewer


■その他のメモ

あくまでも自分用ツールとして作りました。
将来的に、パスの類いなどユーザー指定が必要な項目たちはiniファイル化したいと考えています。

使い勝手を向上させたいと思っているのですが、しばらく放置しっぱなしになっていましたので、
誰かの役に立つかも知れないと思い、ひとまず現状を晒してみました。

