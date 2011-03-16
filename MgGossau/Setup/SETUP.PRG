*********************************************************************
* Setup 4.1.2009
*********************************************************************

*-----------
*Init
*-----------

#include "Gra.ch"
#include "Xbp.ch"
#include "AppEvent.ch"
#include "FCH.ch"
#include "Common.ch"
#include "Font.ch"
#include "CAS.ch"
#include "Directry.ch"
#include "DbfDbe.ch"
#include "DLL.CH"
#include "Fileio.ch"
#include "Error.ch"

#define INSTALL_DEMO          1
#define REMOVE_DEMO           1
#define INSTALL_MP_STANDARD   2
#define REMOVE_MP_STANDARD    2

#define STANDARD_INSTALLFILE     "\Install.log"
#define STANDARD_ERRORFILE       "\Error.log"
#define CRLF                      Chr(13)+Chr(10)

#define INSTALLPB             1
#define UPDATEPB              2
#define ADVANCEDPB            3
#define REMOVEPB              4

#define CSIDL_DESKTOP            0x0000
#define CSIDL_INTERNET           0x0001
#define CSIDL_PROGRAMS           0x0002
#define CSIDL_CONTROLS           0x0003
#define CSIDL_PRINTERS           0x0004
#define CSIDL_PERSONAL           0x0005
#define CSIDL_FAVORITES          0x0006
#define CSIDL_STARTUP            0x0007
#define CSIDL_RECENT             0x0008
#define CSIDL_SENDTO             0x0009
#define CSIDL_BITBUCKET          0x000A
#define CSIDL_STARTMENU          0x000B
#define CSIDL_MYDOCUMENTS        0x000C
#define CSIDL_MYMUSIC            0x000D
#define CSIDL_MYVIDEO            0x000E
#define CSIDL_DESKTOPDIRECTORY   0x0010
#define CSIDL_DRIVES             0x0011
#define CSIDL_NETWORK            0x0012
#define CSIDL_NETHOOD            0x0013
#define CSIDL_FONTS              0x0014
#define CSIDL_TEMPLATES          0x0015
#define CSIDL_COMMON_STARTMENU   0x0016
#define CSIDL_COMMON_PROGRAMS    0x0017
#define CSIDL_COMMON_STARTUP     0x0018
#define CSIDL_COMMON_DESKTOPDIRECTORY  0x0019
#define CSIDL_APPDATA            0x001A
#define CSIDL_PRINTHOOD          0x001B
#define CSIDL_LOCAL_APPDATA      0x001C
#define CSIDL_ALTSTARTUP         0x001D
#define CSIDL_COMMON_ALTSTARTUP  0x001E
#define CSIDL_COMMON_FAVORITES   0x001F
#define CSIDL_INTERNET_CACHE     0x0020
#define CSIDL_COOKIES            0x0021
#define CSIDL_HISTORY            0x0022
#define CSIDL_COMMON_APPDATA     0x0023
#define CSIDL_WINDOWS            0x0024
#define CSIDL_SYSTEM             0x0025
#define CSIDL_PROGRAM_FILES      0x0026
#define CSIDL_MYPICTURES         0x0027
#define CSIDL_PROFILE            0x0028
#define CSIDL_SYSTEMX86          0x0029
#define CSIDL_PROGRAM_FILESX86   0x002A
#define CSIDL_PROGRAM_FILES_COMMON  0x002B
#define CSIDL_PROGRAM_FILES_COMMONX86 0x002C
#define CSIDL_COMMON_TEMPLATES   0x002D
#define CSIDL_COMMON_DOCUMENTS   0x002E
#define CSIDL_COMMON_ADMINTOOLS  0x002F
#define CSIDL_ADMINTOOLS         0x0030
#define CSIDL_CONNECTIONS        0x0031
#define CSIDL_COMMON_MUSIC       0x0035
#define CSIDL_COMMON_PICTURES    0x0036
#define CSIDL_COMMON_VIDEO       0x0037
#define CSIDL_RESOURCES          0x0038
#define CSIDL_RESOURCES_LOCALIZED  0x0039
#define CSIDL_COMMON_OEM_LINKS   0x003A
#define CSIDL_CDBURN_AREA        0x003B
#define CSIDL_COMPUTERSNEARME    0x003D
#define CSIDL_FLAG_PER_USER_INIT 0x0800
#define CSIDL_FLAG_NO_ALIAS      0x1000
#define CSIDL_FLAG_DONT_VERIFY   0x4000
#define CSIDL_FLAG_CREATE        0x8000
#define CSIDL_FLAG_MASK          0xFF00


/*
 * Main Prozedur und Event-Loop
 */

CLASS Setup from XbpDialog
   EXPORTED:

      VAR aChildList


      METHOD Create
      METHOD Close
   ENDCLASS


METHOD Setup:create( oParent, oOwner , ;
                          aPos   , aSize  , ;
                          aPParam, lVisible )
   ::XbpDialog:create( oParent, oOwner , ;
                       aPos   , aSize  , ;
                       aPParam, lVisible )

   ::aChildList         := NIL



RETURN self


METHOD Setup:Close()
   ::Destroy()
RETURN Self




PROCEDURE Main
   LOCAL nEvent, mp1, mp2, oXbp, x
   LOCAL aWinInit := {}
   LOCAL aScrInit := {}
   LOCAL aDBInit := {}
   LOCAL aPos, aSize, aCustScr, nCustScr

*-------------------
* Daten Definitionen
*-------------------

PUBLIC TimeOut           := {0,0}
PUBLIC ReorgActive       := .f.
PUBLIC Inst_Error_Handle := NIL


   SET DELETED ON
   SET CHARSET TO ansi

   nEvent := xbe_None
   DO WHILE .T.
      nEvent := AppEvent( @mp1, @mp2, @oXbp )
      oXbp:handleEvent( nEvent, mp1, mp2 )
   ENDDO


RETURN


PROCEDURE AppSys
   LOCAL oDlg, oXbp, aPos[2], aSize[2], ScrSize
   LOCAL DrawingArea
   LOCAL aBars := {,}
   LOCAL aXbpPos  := {,,,,,}
   LOCAL aXbpSize := {,,,,,}
   LOCAL nXbpHeight := 0
   LOCAL i
   LOCAL nSpace

   StdZLagerDir( "\CAS Computing\MGVerwaltung\MgGossau" )

   PUBLIC aXbp              := {}

   aSize    := AppDeskTop():currentSize()
   nSpace   := aSize[2] / 1024 * 24
   ScrSize  := AppDeskTop():currentSize()
   aSize[1] := aSize[1] * 0.7
   aSize[2] := aSize[2] * 0.6

   aPos[1]  := ( ScrSize[1] / 2) - (aSize[1] / 2)
   aPos[2]  := ( ScrSize[2] / 2) - (aSize[2] / 2)


   nXbpHeight := ( (aSize[2] - 140 - 50 ) /6 ) - nSpace

   For i:= 1 to 6
     aXbpPos[i]  := {24 , 140 + ((i-1)*nSpace) + (i-1)* nXbpHeight }
     aXbpSize[i] := { 96, nXbpHeight }
   next


   // Anwendungsfenster erzeugen (application window)
   oDlg       := Setup():new( ,, aPos, aSize,, .F. )
   oDlg:title := "MG Verwaltung Setup"
   oDlg:close := {|| AppQuit() }
   oDlg:taskList := .T.
   oDlg:minButton := .F.
   oDlg:maxButton := .F.
   oDlg:Resize  := {| aOldSize, aNewSize, obj | ResizeDir(obj, aOldSize, aNewSize, obj:aChildList) }

   oDlg:icon := 200
   oDlg:create()
   SetAppWindow( oDlg )

   DrawingArea := oDlg

   drawingArea:setFontCompoundName( "8.Arial" )

   oXbp := XbpStatic():new( drawingArea, , {12,12}, {aSize[1]-24 ,36} )
   oXbp:caption := "Gruppe"
   oXbp:clipSiblings := .T.
   oXbp:type := XBPSTATIC_TYPE_RAISEDBOX
   oXbp:create()
   aBars[1] := oXbp

   oXbp := XbpStatic():new( drawingArea, , {12,60}, {aSize[1]-24,36} )
   oXbp:caption := "Gruppe"
   oXbp:clipSiblings := .T.
   oXbp:type := XBPSTATIC_TYPE_RAISEDBOX
   oXbp:create()
   aBars[2]  := oXbp

   oXbp := XbpPushButton():new( drawingArea, , aXbpPos[6], aXbpSize[6], { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Installieren"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| ZLagerInstall(INSTALL_DEMO, aBars ) }
   aAdd( aXbp, oXbp)

   oXbp := XbpPushButton():new( drawingArea, , aXbpPos[5], aXbpSize[5], { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Initialisieren"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:Disable()
   *oXbp:activate := {|| ResetMP( aBars) }
   aAdd( aXbp, oXbp)

   oXbp := XbpPushButton():new( drawingArea, , aXbpPos[4], aXbpSize[4], { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Advanced"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:Disable()
   *oXbp:activate := {|| NIL }
   aAdd( aXbp, oXbp)

   oXbp := XbpPushButton():new( drawingArea, , aXbpPos[3], aXbpSize[3], { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Entfernen"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:Disable()
   oXbp:activate := {|| ZLagerRemove(REMOVE_DEMO, aBars ) }
   aAdd( aXbp, oXbp)

   oXbp := XbpPushButton():new( drawingArea, , aXbpPos[1], aXbpSize[1], { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Beenden"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| AppQuit() }
   aAdd( aXbp, oXbp)

   oXbp := XbpStatic():new( drawingArea, , {12,108}, {156,24} )
   oXbp:caption := "Installationsstatus"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_BOTTOM
   oXbp:create()

   oDlg:show()

   SetAppFocus( oDlg )
   CheckStatus()
RETURN


FUNCTION CheckStatus()
*---------------------
LOCAL TargetProgramFilesPath := GetProgramFilesPath()+ StdZLagerDir()

if file( TargetProgramFilesPath + STANDARD_INSTALLFILE )
   aXbp[REMOVEPB]:enable()
   aXbp[UPDATEPB]:disable()
   aXbp[INSTALLPB]:disable()
else
   aXbp[REMOVEPB]:Disable()
   aXbp[UPDATEPB]:Disable()
   aXbp[INSTALLPB]:Enable()
endif

Return


FUNCTION ResetMP( aBars )
*-----------------------------------------------------------------------------------------
LOCAL Bar := aBars[1]
LOCAL cfError
LOCAL BarSize := Bar:CurrentSize()
LOCAL BarPos  := {10,5}
LOCAL oProgress := ProgressBar():new( Bar,, BarPos,  {BarSize[1]-20 , BarSize[2]-10})

LOCAL aGetFiles := GetDbfDataFiles()

* Verzeichnis Programme
LOCAL TargetProgramFilesPath := GetProgramFilesPath() + StdZLagerDir()

LOCAL i

LOCAL DbFile    := ""
LOCAL aDirectory := Directory(TargetProgramFilesPath + "\DATA\*.NTX"), n, nCount
nCount := Len( aDirectory )


oProgress:create()
oProgress:minimum := 1
oProgress:maximum := Len(aGetFiles)
oProgress:color   := GRA_CLR_BLUE

for i:= 1 to len( aGetFiles )
   oProgress:increment()
   if ! file( TargetProgramFilesPath + aGetFiles[i] )
      MsgBox("File " + aGetFiles[i] + " nicht gefunden", "ResetMP()" )
      loop
   endif
   Do Case
      Case at( "ZPlz01" , aGetFiles[i]  ) > 0
         loop
      Case at( "ZTab01" , aGetFiles[i]  ) > 0
         loop
      Case at( "ZKAS01" , aGetFiles[i]  ) > 0
         loop
      Case at( ".Dbt" , aGetFiles[i]  ) > 0
         loop
   endcase
   DbFile := TargetProgramFilesPath + aGetFiles[i]
   DbUseArea(.f., , DbFile,"DbFile",.f. )
   DbZap()
   DbCloseArea()
   FOR n:=1 TO nCount
      ERASE ( aDirectory[n, F_NAME] )
   NEXT
next
* Muss noch
* - Sätze eröffnen für Artikel, Kunden & Kassenbuch
* - History löschen


Msgbox("Daten gelöscht","ResetMoneyPenny")
oProgress:Destroy()
Return .t.



FUNCTION ZlagerInstall(nMode, aBars)
*-----------------------------------
LOCAL Bar := aBars[1]
LOCAL cfError
LOCAL BarSize := Bar:CurrentSize()
LOCAL BarPos  := {10,5}
LOCAL oProgress := ProgressBar():new( Bar,, BarPos,  {BarSize[1]-20 , BarSize[2]-10})
LOCAL aDirInfo := {}

LOCAL SourceDir := CurDrive() +":\"+ CurDir()

* Verzeichnis Programme
LOCAL TargetProgramFilesPath := GetProgramFilesPath()

* Verzeichnis User/Programme
LOCAL TargetProgramPath      := GetProgramPath()
LOCAL TargetSystemPath       := GetSystemPath()
LOCAL nInstalHandle          := 0
LOCAL OverWrite              := .t.
LOCAL aFileList
LOCAL aInstallDir := GetStdDir(TargetProgramFilesPath)
LOCAL i
LOCAL aInit := {}

oProgress:create()
oProgress:minimum := 1
oProgress:maximum := 12
oProgress:color   := GRA_CLR_BLUE

*FUNC GetDbfDataFiles()
*FUNC GetImportDbfFiles()
*FUNC GetImportCtrFiles()
*FUNC GetImportCsvFiles()
*FUNC GetDbfHistFiles()
*FUNC GetCfgFiles()
*FUNC GetCtrFiles()
*FUNC GetDllFiles()
*FUNC GetExEFiles()
*FUNC GetForFiles()
*FUNC GetLSTFiles()

*Standard Verzeichnisse erstellen


for i:= 1 to len( aInstallDir )
   if ! CreateDir( aInstallDir[i] )
      Do Case
         Case !fError() == 183 && Verzeichnis Schon vorhanden
           cfError := Str(FError())
           MsgBox( "Das Verzeichnis " + aInstallDir[i] + " konnte nicht erstellt werden","FError: " + cfError)
           Return .f.
         Othe
           aAdd(aDirInfo, "Dir " + aInstallDir[i] + " -> schon vorhanden " )
         endCase
   else
      aAdd(aDirInfo, "Dir " + aInstallDir[i] + " -> erstellt" )
   endif
next

TargetProgramFilesPath := TargetProgramFilesPath + StdZLagerDir()
nInstalHandle := FCreate( TargetProgramFilesPath + STANDARD_INSTALLFILE, FC_NORMAL )

for i:= 1 to len(aDirInfo)
  FWrite( nInstalHandle, aDirInfo[i] + CRLF)
next

ZlagerFileCopy( GetDbfDataFiles(), GetDbfDataFiles(), nInstalHandle, SourceDir, TargetProgramFilesPath, .f., aBars[2] )

oProgress:Increment()
ZlagerFileCopy( GetDocFiles(), GetDocFiles(), nInstalHandle, SourceDir, TargetProgramFilesPath, OverWrite, aBars[2] )

oProgress:Increment()
ZlagerFileCopy( GetImportCtrFiles(), GetImportCtrFiles(), nInstalHandle, SourceDir, TargetProgramFilesPath, OverWrite, aBars[2] )

oProgress:Increment()
ZlagerFileCopy( GetImportCsvFiles(), GetImportCsvFiles(), nInstalHandle, SourceDir, TargetProgramFilesPath, OverWrite, aBars[2] )

oProgress:Increment()
ZlagerFileCopy( GetDbfHistFiles(), GetDbfHistFiles(), nInstalHandle, SourceDir, TargetProgramFilesPath, OverWrite, aBars[2] )

oProgress:Increment()
ZlagerFileCopy( GetCfgFiles(), GetCfgFiles(), nInstalHandle, SourceDir, TargetProgramFilesPath, OverWrite, aBars[2] )

oProgress:Increment()
ZlagerFileCopy( GetCtrFiles(), GetCtrFiles(), nInstalHandle, SourceDir, TargetProgramFilesPath, .f., aBars[2] )

oProgress:Increment()
*ZlagerFileCopy( GetDllFiles(), PutDllFiles(), nInstalHandle, SourceDir, TargetSystemPath, .f., aBars[2] )
ZlagerFileCopy( GetDllFiles(), PutDllFiles(), nInstalHandle, SourceDir, TargetProgramFilesPath, OverWrite, aBars[2] )
// Besser im Programmverzeichnis. Mann weiss ja nie wegen Versionskonflikten .

oProgress:Increment()
ZlagerFileCopy( GetExEFiles(), GetExEFiles(), nInstalHandle, SourceDir, TargetProgramFilesPath, OverWrite, aBars[2] )

oProgress:Increment()
ZlagerFileCopy( GetForFiles(), GetForFiles(), nInstalHandle, SourceDir, TargetProgramFilesPath, OverWrite, aBars[2] )

oProgress:Increment()
ZlagerFileCopy( GetLSTFiles(), GetLSTFiles(), nInstalHandle, SourceDir, TargetProgramFilesPath, OverWrite, aBars[2] )

oProgress:Increment()
ZlagerFileCopy( GetIconFiles(), GetIconFiles(), nInstalHandle, SourceDir, TargetProgramFilesPath, OverWrite, aBars[2] )

ZlagerFileCopy( GetLnkFiles(), PutLnkFiles(), nInstalHandle, SourceDir, GetDeskTopPath(), OverWrite, aBars[2] )
ZlagerFileCopy( GetLnkFiles(), PutLnkFiles(), nInstalHandle, SourceDir, GetProgramPath(), OverWrite, aBars[2] )

GetLnkFiles()

if !FClose( nInstalHandle )
   MsgBox("Instalations File konnte nicht geschlossen werden.","MGinstall()")
endif

oProgress:Destroy()

WriteInit(TargetProgramFilesPath + "\InitDb.Ctr", GetInitDb(TargetProgramFilesPath))
*WriteInit(TargetProgramFilesPath + "\MGData.LST", GetLSTInfos(TargetProgramFilesPath))

if Inst_Error_Handle == NIL
   MsgBox("Installation erfolgreich beendet","MGinstall()")
else
   if !FClose( Inst_Error_Handle )
      MsgBox("Error File konnte nicht geschlossen werden.","MGinstall()")
   endif
   MsgBox("Installation nicht erflogreich beendet","MGinstall()")
endif
Inst_Error_Handle := NIL
CheckStatus()
Return .t.


FUNCTION AllFilesExist( FileLocation, aFiles )
*---------------------------------------------
   LOCAL lExist := .T., i:=0, imax := Len(aFiles)
   LOCAL FileToTest
   DO WHILE ++i <= imax .AND. lExist
      FileToTest := FileLocation + aFiles[i]
      lExist := File( FileToTest )
   ENDDO
RETURN lExist


FUNC SaveMem()
*-------------
Save to (DataDrive + MemFile) all like db?????
Return .t.

FUNC RestoreMem()
*----------------
Restore From (DataDrive + MemFile) additive
Return .t.

FUNC SaveScreen(aCS)
*-------------
PRIVATE aCustomScreen := aCS
Save to (Maindrive + "CustomScreen.xpf") all like aCustomScreen
Return .t.

FUNC RestoreScreen()
*----------------
PRIVATE aCustomScreen := {{},{},{}}
if File(MainDrive + "CustomScreen.xpf")
   Restore From (MainDrive + "CustomScreen.XPF" ) additive
Endif
Return aCustomScreen



FUNC ZResize(aSize, aButtons, pBPos, pBSize, pBLine)
*-------------------------------------------
LOCAL   aBType     := ValType(aButtons)
LOCAL   pBElements := iif( aBType == "A", len(aButtons), 1 )
LOCAL   pBhPos
LOCAL   oObj

pBhPos     := PbLine
pBPos      := {}

if pBSize[1] * pBElements > aSize[1]
   pBSize[1] := ( aSize[1] / pBElements ) - pBElements
Endif

   pBvPos     := ( aSize[1] - ( pBElements * pBSize[1]) ) / (pBElements  + 1) - 1
   For i:= 1 to pBElements
     oObj := iif( aBType == "A", aButtons[i], aButtons )
     aAdd( pBPos, { pBvPos * (i) + pBSize[1] * (i - 1) , pBhPos })
     oObj:SetPosAndSize( pBPos[i], pBSize )
     oObj:show()
   Next

Return .t.


FUNC GetaIni(cIni)
*-------------
LOCAL aIni    := {}

Do While at(",", cIni) > 0
   aAdd(aIni, Alltrim(  Subs(cIni,1,at(",", cIni)-1))  )
   cIni := Subs(cIni, At(",", cIni) + 1, len(cIni) )
Enddo
aAdd(aIni, Alltrim( cIni )  )
Return aIni


FUNCTION DoM( nMonth, Year )
*-------------------------------
LOCAL i, LastDay
LOCAL SchaltJahr := .f.
if Year == NIL
   Year := Year( Date())
Endif
if !ctod( "29.02."+ Str(Year,4,0) ) == ctod( "  .  .    ")
   SchaltJahr := .t.
Endif

Do Case
   Case nmonth == 1 .or. nmonth == 3 .or. nmonth == 5 .or. nmonth == 7 .or. nmonth == 8 .or. nmonth == 10 .or. nmonth == 12
   LastDay := 31
   Case nMonth == 2
   LastDay := iif( SchaltJahr, 29,28)
   Othe
   LastDay := 30
EndCase

Return LastDay


PROCEDUR AppQuit()
  LOCAL nButton

  nButton := ConfirmBox( , ;
                "Wollen Sie Setup beenden ?", ;
                "Beenden", ;
                 XBPMB_YESNO , ;
                 XBPMB_QUESTION+XBPMB_APPMODAL+XBPMB_MOVEABLE )


  IF nButton == XBPMB_RET_YES
     COMMIT
     CLOSE ALL
     QUIT
  ENDIF


  RETURN




FUNCTION GetDeskTopPath()
  LOCAL cPath := Replicate( " ", 256 )
  DllCall( "Shell32.DLL", DLL_STDCALL, "SHGetSpecialFolderPathA", 0, @cPath, CSIDL_DESKTOP, .F. )
  Return Subs( trim(cPath), 1, Len(Trim(cPath)) - 1 )

FUNCTION GetProgramPath()
  LOCAL cPath := Replicate( " ", 256 )
  DllCall( "Shell32.DLL", DLL_STDCALL, "SHGetSpecialFolderPathA", 0, @cPath, CSIDL_PROGRAMS, .F. )
  Return Subs( trim(cPath), 1, Len(Trim(cPath)) - 1 )

FUNCTION GetFavoritsPath()
  LOCAL cPath := Replicate( " ", 256 )
  DllCall( "Shell32.DLL", DLL_STDCALL, "SHGetSpecialFolderPathA", 0, @cPath, CSIDL_FAVORITES, .F. )
  Return Subs( trim(cPath), 1, Len(Trim(cPath)) - 1 )

FUNCTION GetStartupPath()
  LOCAL cPath := Replicate( " ", 256 )
  DllCall( "Shell32.DLL", DLL_STDCALL, "SHGetSpecialFolderPathA", 0, @cPath, CSIDL_STARTUP, .F. )
  Return Subs( trim(cPath), 1, Len(Trim(cPath)) - 1 )

FUNCTION GetRecentPath()
  LOCAL cPath := Replicate( " ", 256 )
  DllCall( "Shell32.DLL", DLL_STDCALL, "SHGetSpecialFolderPathA", 0, @cPath, CSIDL_RECENT, .F. )
  Return Subs( trim(cPath), 1, Len(Trim(cPath)) - 1 )

FUNCTION GetStartMenuPath()
  LOCAL cPath := Replicate( " ", 256 )
  DllCall( "Shell32.DLL", DLL_STDCALL, "SHGetSpecialFolderPathA", 0, @cPath, CSIDL_STARTMENU, .F. )
  Return Subs( trim(cPath), 1, Len(Trim(cPath)) - 1 )

FUNCTION GetDeskTopDirPath()
  LOCAL cPath := Replicate( " ", 256 )
  DllCall( "Shell32.DLL", DLL_STDCALL, "SHGetSpecialFolderPathA", 0, @cPath, CSIDL_DESKTOPDIRECTORY, .F. )
  Return Subs( trim(cPath), 1, Len(Trim(cPath)) - 1 )

FUNCTION GetProgramFilesPath()
  LOCAL cPath := Replicate( " ", 256 )
  DllCall( "Shell32.DLL", DLL_STDCALL, "SHGetSpecialFolderPathA", 0, @cPath, CSIDL_PROGRAM_FILES, .F. )
  Return Subs( trim(cPath), 1, Len(Trim(cPath)) - 1 )

FUNCTION GetSystemPath()
  LOCAL cPath := Replicate( " ", 256 )
  DllCall( "Shell32.DLL", DLL_STDCALL, "SHGetSpecialFolderPathA", 0, @cPath, CSIDL_SYSTEM, .F. )
  Return Subs( trim(cPath), 1, Len(Trim(cPath)) - 1 )

FUNCTION GetNetHood()
  LOCAL cPath := Replicate( " ", 256 )
  DllCall( "Shell32.DLL", DLL_STDCALL, "SHGetSpecialFolderPathA", 0, @cPath, CSIDL_NETHOOD , .F. )
  Return Subs( trim(cPath), 1, Len(Trim(cPath)) - 1 )

FUNCTION GetDeskTopDir()
  LOCAL cPath := Replicate( " ", 256 )
  DllCall( "Shell32.DLL", DLL_STDCALL, "SHGetSpecialFolderPathA", 0, @cPath, CSIDL_DESKTOPDIRECTORY , .F. )
  Return Subs( trim(cPath), 1, Len(Trim(cPath)) - 1 )



FUNCTION GetUserName()
  Local nSize    :=255
  Local cUserName:=Space(nSize+1)
  Local nUserName:=DllCall( "AdvApi32.Dll", DLL_STDCALL, "GetUserNameA", @cUserName, @nSize )

   If nUserName==0
      cUserName:=Space(1)
   EndIf

Return Alltrim( cUserName )


FUNC GetInitDb(cPath)
*-----------------
LOCAL aInitDb := {}

   aAdd( aInitDb, {"CtrMemType" , "PUBLIC"} )
   aAdd( aInitDb, {"MainDrive" ,   cPath + "\" } )
   aAdd( aInitDb, {"RemoteDrive" , cPath + "\REMOTE\"} )
   aAdd( aInitDb, {"DataDrive" ,   cPath + "\DATA\"} )
   aAdd( aInitDb, {"FormDrive" ,   cPath + "\FORM\"} )
   aAdd( aInitDb, {"DiscDrive" , "A:\"} )
   aAdd( aInitDb, {"DocDrive" ,     cPath + "\DOCS\"} )
   aAdd( aInitDb, {"InventarDrive" ,cPath  + "\INVE\"} )
   aAdd( aInitDb, {"MessageDrive" , cPath  + "\MESS\"} )
   aAdd( aInitDb, {"HistoryDrive" , cPath  + "\HIST\"} )
   aAdd( aInitDb, {"AuswertDrive" , cPath  + "\AUSW\"} )
   aAdd( aInitDb, {"ImportDrive"  , cPath  + "\IMPORT\"} )
   aAdd( aInitDb, {"IconDrive"  ,   cPath  + "\Icons\"} )
   aAdd( aInitDb, {"dbArtNr" ,  " 1010000000001"} )
   aAdd( aInitDb, {"dbDebNr" ,  "       1"} )
   aAdd( aInitDb, {"dbKreNr" ,  " 1015000"} )
   aAdd( aInitDb, {"dbDocNr" ,  " 1015000"} )
   aAdd( aInitDb, {"dbDisNr" ,  " 1015000"} )
   aAdd( aInitDb, {"dbOrdNr" ,  " 1015000"} )
   aAdd( aInitDb, {"dbBikeNr" , "       1"} )
   aAdd( aInitDb, {"dbLagNr" ,  "1"} )
   aAdd( aInitDb, {"dbFirma" ,  "101"} )
   aAdd( aInitDb, {"dbStkIdx" ,  "1"} )

Return aInitDb


FUNC GetDbfDataFiles()
*-----------------
LOCAL aFiles := {}

aAdd( aFiles, "\DATA\MGDEB01.Dbf" )
aAdd( aFiles, "\DATA\MGDEB01.Dbt" )
aAdd( aFiles, "\DATA\MGLog01.Dbf" )
aAdd( aFiles, "\DATA\MGRep01.Dbf" )
aAdd( aFiles, "\DATA\MGRep01.Dbt" )
aAdd( aFiles, "\DATA\MGSYS01.Dbf" )
aAdd( aFiles, "\DATA\MGTab01.Dbf" )
aAdd( aFiles, "\DATA\MGTab01.Dbt" )
aAdd( aFiles, "\DATA\MGPlz01.Dbf" )

Return aFiles


FUNC GetDocFiles()
*-----------------
LOCAL aFiles := {}
aAdd( aFiles, "\DOCS\Vorlagen\Versand Email.dot" )
aAdd( aFiles, "\DOCS\Vorlagen\Versand Post.dot" )
Return aFiles

FUNC GetImportCtrFiles()
*-----------------
LOCAL aFiles := {}
Return aFiles

FUNC GetImportCsvFiles()
*-----------------
LOCAL aFiles := {}
Return aFiles

FUNC GetDbfHistFiles()
*-----------------
LOCAL aFiles := {}
Return aFiles

FUNC GetCfgFiles()
*-----------------
LOCAL aFiles := {}

aAdd( aFiles, "\FORM\AddressList.cfg" )
Return aFiles

FUNC GetIconFiles()
*-----------------
LOCAL aFiles := {}
aAdd( aFiles, "\ICONS\back.gif" )
aAdd( aFiles, "\ICONS\cancel.gif" )
aAdd( aFiles, "\ICONS\change.gif" )
aAdd( aFiles, "\ICONS\new.gif" )
aAdd( aFiles, "\ICONS\ok.gif" )
aAdd( aFiles, "\ICONS\print.gif" )
aAdd( aFiles, "\ICONS\save.gif" )
aAdd( aFiles, "\ICONS\MGGossau.ICO" )
Return aFiles


FUNC GetCtrFiles()
*-----------------
LOCAL aFiles := {}
aAdd( aFiles, "\initDB.ctr" )
aAdd( aFiles, "\initScreen.Ctr" )
aAdd( aFiles, "\initwin.ctr" )
Return aFiles

FUNC GetDllFiles()
*-----------------
LOCAL aFiles := {}
aAdd( aFiles, "\RunTime\ADAC20B.Dll" )
aAdd( aFiles, "\RunTime\ADAC20C.Dll" )
aAdd( aFiles, "\RunTime\ASCOM10.Dll" )
aAdd( aFiles, "\RunTime\ASCOM10C.Dll" )
aAdd( aFiles, "\RunTime\ASLogResource.Dll" )
aAdd( aFiles, "\RunTime\ASRDBC10.Dll" )
aAdd( aFiles, "\RunTime\CDXDBE.Dll" )
aAdd( aFiles, "\RunTime\DBFDBE.Dll" )
aAdd( aFiles, "\RunTime\DELDBE.Dll" )
aAdd( aFiles, "\RunTime\FOXDBE.Dll" )
aAdd( aFiles, "\RunTime\NTXDBE.Dll" )
aAdd( aFiles, "\RunTime\SDFDBE.Dll" )
aAdd( aFiles, "\RunTime\SOM.Dll" )
aAdd( aFiles, "\RunTime\XPPDBGC.Dll" )
aAdd( aFiles, "\RunTime\XPPNAT.Dll" )
aAdd( aFiles, "\RunTime\XPPRT1.Dll" )
aAdd( aFiles, "\RunTime\XPPRT2.Dll" )
aAdd( aFiles, "\RunTime\XPPUI1.Dll" )
aAdd( aFiles, "\RunTime\XPPUI2.Dll" )
aAdd( aFiles, "\RunTime\XPPUI3.Dll" )
aAdd( aFiles, "\RunTime\XPPSYS.Dll" )
*aAdd( aFiles, "\RunTime\WZCL32.Dll" )
Return aFiles

FUNC PutDllFiles()
*-----------------
LOCAL aFiles := {}
aAdd( aFiles, "\ADAC20B.Dll" )
aAdd( aFiles, "\ADAC20C.Dll" )
aAdd( aFiles, "\ASCOM10.Dll" )
aAdd( aFiles, "\ASCOM10C.Dll" )
aAdd( aFiles, "\ASLogResource.Dll" )
aAdd( aFiles, "\ASRDBC10.Dll" )
aAdd( aFiles, "\CDXDBE.Dll" )
aAdd( aFiles, "\DBFDBE.Dll" )
aAdd( aFiles, "\DELDBE.Dll" )
aAdd( aFiles, "\FOXDBE.Dll" )
aAdd( aFiles, "\NTXDBE.Dll" )
aAdd( aFiles, "\SDFDBE.Dll" )
aAdd( aFiles, "\SOM.Dll" )
aAdd( aFiles, "\XPPDBGC.Dll" )
aAdd( aFiles, "\XPPNAT.Dll" )
aAdd( aFiles, "\XPPRT1.Dll" )
aAdd( aFiles, "\XPPRT2.Dll" )
aAdd( aFiles, "\XPPUI1.Dll" )
aAdd( aFiles, "\XPPUI2.Dll" )
aAdd( aFiles, "\XPPUI3.Dll" )
aAdd( aFiles, "\XPPSYS.Dll" )
*aAdd( aFiles, "\WZCL32.Dll" )
Return aFiles

FUNC GetExEFiles()
*-----------------
LOCAL aFiles := {}
aAdd( aFiles, "\7ZA.EXE" )
aAdd( aFiles, "\MgGossau.EXE" )
aAdd( aFiles, "\DATA\DBU.EXE" )

*aAdd( aFiles, "\Setup\Setup.exe" )
Return aFiles

FUNC GetLnkFiles()
*-----------------
LOCAL aFiles := {}
aAdd( aFiles, "\Setup\MGGOSSAU.LNK" )

Return aFiles

FUNC PutLnkFiles()
*-----------------
LOCAL aFiles := {}
aAdd( aFiles, "\MGGossau.LNK" )

Return aFiles

FUNC GetForFiles()
*-----------------
LOCAL aFiles := {}

aAdd( aFiles, "\FORM\AddressList.FOR" )
aAdd( aFiles, "\FORM\DebChange.FOR" )
aAdd( aFiles, "\FORM\DebList.for" )
aAdd( aFiles, "\FORM\DebNew.FOR" )
aAdd( aFiles, "\FORM\DebOut.FOR" )
aAdd( aFiles, "\FORM\WebList.for" )

Return aFiles


FUNC GetLSTFiles( )
*-----------------
LOCAL aFiles := {}
aAdd( aFiles, "\MGAllDATA.LST" )
aAdd( aFiles, "\MGDATA.LST" )
Return aFiles

FUNC GetStdDir( cPath )
*-----------------
LOCAL aDirs := {}
aAdd( aDirs, cPath +"\CAS Computing" )
aAdd( aDirs, cPath +"\CAS Computing\MGVerwaltung" )
aAdd( aDirs, cPath +"\CAS Computing\MGVerwaltung\MGGossau" )
aAdd( aDirs, cPath +"\CAS Computing\MGVerwaltung\MGGossau\REMOTE" )
aAdd( aDirs, cPath +"\CAS Computing\MGVerwaltung\MGGossau\DATA" )
aAdd( aDirs, cPath +"\CAS Computing\MGVerwaltung\MGGossau\FORM" )
aAdd( aDirs, cPath +"\CAS Computing\MGVerwaltung\MGGossau\DOCS" )
aAdd( aDirs, cPath +"\CAS Computing\MGVerwaltung\MGGossau\DOCS\Vorlagen" )
aAdd( aDirs, cPath +"\CAS Computing\MGVerwaltung\MGGossau\DOCS\Dokumente" )
aAdd( aDirs, cPath +"\CAS Computing\MGVerwaltung\MGGossau\INVE" )
aAdd( aDirs, cPath +"\CAS Computing\MGVerwaltung\MGGossau\MESS" )
aAdd( aDirs, cPath +"\CAS Computing\MGVerwaltung\MGGossau\HIST" )
aAdd( aDirs, cPath +"\CAS Computing\MGVerwaltung\MGGossau\AUSW" )
aAdd( aDirs, cPath +"\CAS Computing\MGVerwaltung\MGGossau\IMPORT" )
aAdd( aDirs, cPath +"\CAS Computing\MGVerwaltung\MGGossau\Icons" )
aAdd( aDirs, cPath +"\CAS Computing\MGVerwaltung\MGGossau\Setup" )
Return aDirs

FUNC GetLSTInfos( cPath )
*-----------------
LOCAL aFiles := {}
aAdd( aFiles, cPath +"\CAS Computing\MGVerwaltung\MGGossau\DATA\*.Db?" )
aAdd( aFiles, cPath +"\CAS Computing\MGVerwaltung\MGGossau\DATA\*.XPF" )
aAdd( aFiles, cPath +"\CAS Computing\MGVerwaltung\MGGossau\INVE\*.Db?" )
aAdd( aFiles, cPath +"\CAS Computing\MGVerwaltung\MGGossau\HIST\*.Db?" )
aAdd( aFiles, cPath +"\CAS Computing\MGVerwaltung\MGGossau\IMPORT\*.Ctr" )
aAdd( aFiles, cPath +"\CAS Computing\MGVerwaltung\MGGossau\IMPORT\*.CSV" )
aAdd( aFiles, cPath +"\CAS Computing\MGVerwaltung\MGGossau\IMPORT\*.CTR" )

Return aFiles


FUNCTION ZlagerFileCopy( aGetFiles, aPutFiles, nHandle, SourcePath,  TargetPath, OverWrite, Bar )
*------------------------------------------------------------------------------------------------
LOCAL i
LOCAL BarSize := Bar:CurrentSize()
LOCAL BarPos  := {10,5}
LOCAL oProgress := ProgressBar():new( Bar,, BarPos,  {BarSize[1]-20 , BarSize[2]-10})

oProgress:create()
oProgress:minimum := 1
oProgress:maximum := Len(aGetFiles)
oProgress:color   := GRA_CLR_BLUE

for i:= 1 to len( aGetFiles )
   oProgress:increment()
   if ! file( SourcePath + aGetFiles[i] )
      MsgBox("File " + aGetFiles[i] + " nicht gefunden", "ZlagerFileCopy()" )
      CopyError(aGetFiles[i],1)
      loop
   endif

   Do Case
   Case file( TargetPath + aPutFiles[i] ) .and. OverWrite
      COPY FILE ( SourcePath + aGetFiles[i] ) TO ( TargetPath + aPutFiles[i])
      FAttr( TargetPath + aPutFiles[i], "-R" )
      FWrite( nHandle, TargetPath + aPutFiles[i] + " -> overwritten"  + CRLF)

   Case file( TargetPath + aPutFiles[i] ) .and. !OverWrite
      FWrite( nHandle, TargetPath + aPutFiles[i] + " -> skipped" + CRLF)

   Case !file( TargetPath + aPutFiles[i] )
      COPY FILE ( SourcePath + aGetFiles[i] ) TO ( TargetPath + aPutFiles[i])
      FAttr( TargetPath + aPutFiles[i], "-R" )
      FWrite( nHandle, TargetPath + aPutFiles[i] + " -> installed" + CRLF)

   endcase
   if !file( TargetPath + aPutFiles[i] )
      CopyError( TargetPath + aPutFiles[i],2 )
   endif
next
oProgress:Destroy()
Return .t.


Function CopyError(cFile, Mode)
*------------------------------
LOCAL TargetProgramFilesPath := GetProgramFilesPath()

Do Case
   Case Mode == 1
      MsgBox("File " + cFile +" konnte nicht gefunden werden","CopyError")
   Case Mode == 2
      MsgBox("File " + cFile +" konnte nicht erstellt werden","CopyError")
   Othe
      Return
EndCase

TargetProgramFilesPath := TargetProgramFilesPath + StdZLagerDir()

if !file(TargetProgramFilesPath + STANDARD_ERRORFILE)
   Inst_Error_Handle := FCreate( TargetProgramFilesPath + STANDARD_ERRORFILE, FC_NORMAL )
   FWrite( Inst_Error_Handle, "Installation MG Verwaltung " + dtoc(Date()) + " " + Time() + CRLF + CRLF)
else
   if Inst_Error_Handle == NIL
      Inst_Error_Handle := FOpen( TargetProgramFilesPath + STANDARD_ERRORFILE, FO_READWRITE  )
      FSeek( Inst_Error_Handle, 0, FS_END )
      FWrite( Inst_Error_Handle, CRLF + CRLF + "Installation MG Verwaltung " + dtoc(Date()) + " " + Time() + CRLF + CRLF)
   endif
endif
FWrite( Inst_Error_Handle, cFile + " -> nicht kopiert" + CRLF)
Return .f.


FUNCTION ZlagerRemove(nMode, aBars)
*-----------------------------------
LOCAL Bar := aBars[1]
LOCAL cfError
LOCAL BarSize := Bar:CurrentSize()
LOCAL BarPos  := {10,5}
LOCAL oProgress := ProgressBar():new( Bar,, BarPos,  {BarSize[1]-20 , BarSize[2]-10})
LOCAL aInstallInfo := {}
LOCAL cInstallInfo := ""
LOCAL aDirInfo     := {}
LOCAL aFileInfo     := {}
LOCAL SourceDir := CurDrive() +":\"+ CurDir()


LOCAL TargetProgramFilesPath := GetProgramFilesPath()

LOCAL TargetProgramPath      := GetProgramPath()

LOCAL TargetSystemPath       := GetSystemPath()
LOCAL nInstalHandle          := 0
LOCAL OverWrite              := .t.
LOCAL aFileList
LOCAL aInstallDir := GetStdDir(TargetProgramFilesPath)
LOCAL i
LOCAL nLines
LOCAL cLine

oProgress:create()
oProgress:minimum := 1
oProgress:maximum := 2
oProgress:color   := GRA_CLR_BLUE

*FUNC GetDbfDataFiles()
*FUNC GetImportDbfFiles()
*FUNC GetImportCtrFiles()
*FUNC GetImportCsvFiles()
*FUNC GetDbfHistFiles()
*FUNC GetCfgFiles()
*FUNC GetCtrFiles()
*FUNC GetDllFiles()
*FUNC GetExEFiles()
*FUNC GetForFiles()
*FUNC GetLSTFiles()

TargetProgramFilesPath := TargetProgramFilesPath + StdZLagerDir()
nInstalHandle := FOpen( TargetProgramFilesPath + STANDARD_INSTALLFILE, FO_READ  )

IF !FError() == 0
   MsgBox("Install File kann nicht gelesen werden. Die Applikation muss manuell entfernt werden.","MGRemove()")
   oProgress:Destroy()
   Return .f.
Endif

cInstallInfo := FReadStr( nInstalHandle, 63000 )
if !FClose( nInstalHandle )
   MsgBox("Instalations File konnte nicht geschlossen werden.","MGinstall()")
endif

*FReadStr( nInstalHandle, @cInstallInfo, 63000 )
nLines := MlCount( cInstallInfo  ,500 )

for i:= 1 to nLines
  aAdd(aInstallInfo, MemoLine( cInstallInfo  ,500, i) )
next

oProgress:maximum := len( aInstallInfo )

for i:= 1 to len( aInstallInfo )
    if Subs( aInstallInfo[i], 1, 3) == "Dir"
       aAdd( aDirInfo, Subs(aInstallInfo[i], 5, at(" -> ", aInstallInfo[i]) - 5 ) )
    else
       aAdd( aFileInfo, Subs(aInstallInfo[i], 1, at(" -> ", aInstallInfo[i]) - 1 ) )
    endif
next
aAdd( aFileInfo, TargetProgramFilesPath + STANDARD_INSTALLFILE )
aAdd( aFileInfo, TargetProgramFilesPath + STANDARD_ERRORFILE )

EraseMisc(TargetProgramFilesPath )

for i:= 1 to len( aFileInfo )

   FErase( Alltrim( aFileInfo[i]) )
   oProgress:Increment()
next

for i:= len( aDirInfo ) to 1 Step -1
   RemoveDir( aDirInfo[i] )
   oProgress:Increment()
next

oProgress:Destroy()

MsgBox("Installation erfolgreich entfernt","MGRemove()")
CheckStatus()
Return .t.



FUNCTION EraseMisc(cPath)
*-------------------------
LOCAL aDirectory := Directory( cPath + "\DATA\*.Ntx" ), n, nCount
  nCount := Len( aDirectory )
  FOR n:=1 TO nCount
     FErase( cPath + "\DATA\" + aDirectory[n, F_NAME] )
  NEXT

  aDirectory := Directory( cPath + "\IMPORT\*.Ntx" )
  nCount := Len( aDirectory )
  FOR n:=1 TO nCount
     FErase( cPath + "\IMPORT\" + aDirectory[n, F_NAME] )
  NEXT

  aDirectory := Directory( cPath + "\DATA\*.XPF" )
  nCount := Len( aDirectory )
  FOR n:=1 TO nCount
     FErase( cPath + "\DATA\" + aDirectory[n, F_NAME] )
  NEXT

  aDirectory := Directory( cPath + "\*.XPF" )
  nCount := Len( aDirectory )
  FOR n:=1 TO nCount
     FErase( cPath + "\" + aDirectory[n, F_NAME] )
  NEXT

  aDirectory := Directory( cPath + "\*.CTR" )
  nCount := Len( aDirectory )
  FOR n:=1 TO nCount
     FErase( cPath + "\" + aDirectory[n, F_NAME] )
  NEXT

  aDirectory := Directory( cPath + "\AUSW\*.*" )
  nCount := Len( aDirectory )
  FOR n:=1 TO nCount
     FErase( cPath + "\AUSW\" + aDirectory[n, F_NAME] )
  NEXT

  aDirectory := Directory( cPath + "\DOCS\Vorlagen\*.*" )
  nCount := Len( aDirectory )
  FOR n:=1 TO nCount
     FErase( cPath + "\DOCS\Vorlagen\" + aDirectory[n, F_NAME] )
  NEXT

  aDirectory := Directory( cPath + "\DOCS\Dokumente\*.*" )
  nCount := Len( aDirectory )
  FOR n:=1 TO nCount
     FErase( cPath + "\DOCS\Dokumente\" + aDirectory[n, F_NAME] )
  NEXT


  RETURN .t.


FUNCTION StdZLagerDir( Dir )
*---------------------------
STATIC cStdDir
   IF PCount() > 0
      cStdDir := Dir
   ENDIF
RETURN cStdDir


* Standart Funktionen



FUNC WriteInit(IniFile, aPublic)
*-------------------------------
LOCAL nHandle
LOCAL i
LOCAL nTextSpace := 30
LOCAL FileTyp    := 0

   if len( aPublic ) > 0
   * 1 oder 2
      FileTyp := Len( aPublic[1] )
   endif

   if Type( "MainDrive" ) == "U"
      nHandle := FCreate(IniFile)
   else
      nHandle := FCreate(MainDrive + IniFile)
   endif
   if nHandle < 0
      MsgBox("Systemfehler, Fcreate() in WriteInit() konnte nicht ausgeführt werden", "WriteInit()")
      Return .f.
   Endif

   Do Case
   Case FileTyp == 1
      for i:= 1 to len(aPublic)
         FWrite( nHandle, Padr( aPublic[i][1],nTextSpace) + Chr(13)+Chr(10) )
      next
   Case FileTyp == 2
      for i:= 1 to len(aPublic)
         FWrite( nHandle, Padr( aPublic[i][1],nTextSpace) + " = " + aPublic[i][2] + Chr(13)+Chr(10) )
      next
   Endcase


Return FClose( nHandle )




FUNCTION IsDriveReady( cDrive )
*------------------------------
      LOCAL nReturn   := .t.

      LOCAL cOldDrive := CurDrive()       // Aktuelles Laufwerk merken
      LOCAL bError    := ErrorBlock( {|e| Break(e) } )
      LOCAL oError

      BEGIN SEQUENCE

         CurDrive( cDrive )               // Laufwerk ändern
         CurDir( cDrive )                 // Verzeichnis abfragen

      RECOVER USING oError                // Fehler ist aufgetreten

         IF oError:osCode == 21 &&DRIVE_NOT_READY
            MsgBox("Laufwerk " + cDrive + " ist nicht bereit.","Laufwerk Prüfen")
            nReturn := .f.                 // Laufwerk nicht bereit
         ELSE
            nReturn := .f.                 // Laufwerk nicht vorhanden
            MsgBox("Laufwerk " + cDrive + " ist nicht vorhanden.","Laufwerk Prüfen")
         ENDIF

      ENDSEQUENCE

      ErrorBlock( bError )                // Fehler-Codeblock und
      CurDrive( cOldDrive )               // Laufwerk zurücksetzen

   RETURN nReturn


FUNCTION ResizeDir(oDlg, aOldWSize, aNewWSize, aChildList)
*--------------------------------------------------------------

LOCAL hFactor
LOCAL vFactor
LOCAL i
LOCAL aNewPos
LOCAL aNewSize
LOCAL nNewSize
LOCAL nTabHeight
LOCAL NewFont
LOCAL nCorrSize := oDlg:CurrentSize()[2] - oDlg:DrawingArea:CurrentSize()[2]
LOCAL LBSize   := {,}
LOCAL SLESize  := {,}
LOCAL XbpKorrPos := 0


*oDlg:Hide()

aNewWSize[2] := aNewWSize[2] - nCorrSize
aOldWSize[2] := aOldWSize[2] - nCorrSize

if aChildList == NIL
   oDlg:aChildList := GetChildList(oDlg)
   if len(oDlg:aChildList) > 0
      oDlg:aChildList[3][1] := aOldWSize
      aChildList      := oDlg:aChildList
   Endif
Endif

if len(aChildList) == 0
  oDlg:Show()
  Return .f.
Endif

hFactor := (aNewWSize[1] )  / aChildList[3][1][1]
vFactor := (aNewWSize[2] )  / aChildList[3][1][2]

* - 8
* - 27

oDlg:lockUpdate(.T.)

for i := 2 to len(aChildList[1])

   aNewPos  := { int( aChildList[2][i][1] * hFactor ),  int( aChildList[2][i][2] * vFactor )}
   aNewSize := { int( aChildList[3][i][1] * hFactor ), int( aChildList[3][i][2] * vFactor )}

   NewFont  := round( Val( aChildList[4][i][1] ) * vFactor, 0)
   NewFont  := iif( NewFont >= Val( aChildList[4][i][1] ), aChildList[4][i][1], iif( NewFont < 7, "7", var2Char( NewFont ) ))
   nNewSize := val( NewFont )
   NewFont  := NewFont + "." + aChildList[4][i][2]

   Do case

      Case aChildList[1][i]:isDerivedFrom( "XbpCombobox" )
         aChildList[1][i]:setFontCompoundName( NewFont)
         XbpKorrPos := int( iif(vFactor > 1, aChildList[1][i]:sleSize()[2]*( vFactor - 1)/2 ,0) )
         if vFactor < 1
            aChildList[1][i]:setSize( {aNewSize[1], aNewSize[2] + (aChildList[3][i][2] * (1-vFactor))} )
            aChildList[1][i]:setPos( {aNewPos[1],aNewPos[2] - (aChildList[3][i][2] * (1-vFactor)) } )
         else
            aChildList[1][i]:setSize( aNewSize )
            aChildList[1][i]:setPos( {aNewPos[1], aNewPos[2] - XbpKorrPos })
         endif

      Case aChildList[1][i]:isDerivedFrom( "XbpSLE" )
         aChildList[1][i]:setFontCompoundName( NewFont)
         if vFactor < 1
            aChildList[1][i]:setSize( aNewSize)
         else
            aChildList[1][i]:setSize( {aNewSize[1],aChildList[3][i][2]})
         Endif
         aChildList[1][i]:setPos( {aNewPos[1], aNewPos[2] + iif(vFactor > 1, aChildList[3][i][2]*( vFactor - 1)/2 ,0) } )

      Case aChildList[1][i]:isDerivedFrom( "XbpPushButton" )
         aChildList[1][i]:setFontCompoundName( NewFont )
         aChildList[1][i]:setPosAndSize( aNewPos, aNewSize)
         aChildList[1][i]:paint := {| aRect, uNIL, Obj | DrawSymbol(Obj) }

      Case aChildList[1][i]:isDerivedFrom( "XbpIWindow" )
         *nichts!

      Case aChildList[1][i]:isDerivedFrom( "XbpTabPage" )
         aChildList[1][i]:setFontCompoundName( NewFont )
         aChildList[1][i]:tabHeight := nNewSize * 3
         aChildList[1][i]:setSize( aNewSize)
         aChildList[1][i]:setPos( aNewPos)

      Case aChildList[1][i]:isDerivedFrom( "XbpQuickbrowse" )
         aChildList[1][i]:setPosAndSize( aNewPos, aNewSize)
         oDlg:AdjustXbpQuickBrowseCol( aChildList[1][i], .f., , )

     Case aChildList[1][i]:isDerivedFrom( "XbpBrowse" )
 *         aChildList[1][i]:setPosAndSize( aNewPos, aNewSize)
          aChildList[1][i]:configure( , , aNewPos  , aNewSize , , )

      othe
         aChildList[1][i]:setFontCompoundName( NewFont )
         aChildList[1][i]:setPosAndSize( aNewPos, aNewSize)

   EndCase
 next

oDlg:Show()
oDlg:lockUpdate(.F.)
oDlg:invalidateRect()

Return .t.


FUNCTION GetChildList(oDlg)
*--------------------------
LOCAL aChildList := {{},{},{},{}}
LOCAL aCList1
LOCAL i, n
LOCAL cStdFontSize
LOCAL cStdFont := NIL
LOCAL SLEFont
LOCAL lDefFont
LOCAL xObj
LOCAL cSLEFontSize
LOCAL cSLEFont

if oDlg:isDerivedFrom( "XbpDialog" )
   xObj := oDlg:DrawingArea
else
   xObj := oDlg
Endif

cStdFont := xObj:SetFont()
if cStdFont == NIL
   cStdFontSize := "8"
   cStdFont     := "Arial"
else
   cStdFontSize := var2Char( xObj:SetFont():NominalPointSize )
   cStdFont     := xObj:SetFont():compoundName
endif

aChildList[1] := oDlg:ChildList()

for i:= 1 to len(aChildList[1])

   if aChildList[1][i]:isDerivedFrom( "XbpQuickbrowse" )
      loop
   endif

   aCList1 := aChildList[1][i]:ChildList()
   For n := 1 to len(aCList1)
       aAdd(aChildList[1], aCList1[n] )
   Next
next

for i:= 1 to len(aChildList[1])
   SLEFont  := NIL
   SLEFont  := aChildList[1][i]:SetFont()

   if !SLEFont == NIL
      lDefFont := .t.
      cSLEFontSize := var2Char( SLEFont:NominalPointSize )
      cSLEFont     := SLEFont:compoundName
   else
      lDefFont := .f.
      cSLEFontSize := cStdFontSize
      cSLEFont     := cStdFont
   Endif

   aAdd(aChildList[2], aChildList[1][i]:CurrentPos())
   aAdd(aChildList[3], aChildList[1][i]:CurrentSize())
   aAdd(aChildList[4], { cSLEFontSize, cSLEFont, lDefFont } )
next

Return aChildList

FUNCTION DrawSymbol( oXbp)
*---------------------------------------
* Symbol 1 == Abbrechen
STATIC oBMPData
LOCAL oPS, aSize, oBMP
   aSize       := oXbp:currentSize()
   oXbp:lbUp   := {|mp1, mp2, obj| DrawSymbol(Obj) }
   oXbp:lbDown := {|mp1, mp2, obj| DrawSymbol(Obj) }
   oXbp:paint :=  {| aRect, uNIL, Obj | DrawSymbol(Obj) }
   oPS         := oXbp:lockPS()
   cCapt       := Alltrim(Upper(oXbp:Caption))
   oBMP:= XbpBitmap():new():create( oPS )

   if oBMPData == NIL
      oBMPData := Array(7)
   Endif
   Do Case
      Case cCapt == "ABBRECHEN" .or. cCapt == "ABBRUCH" .or. cCapt == "LÖSCHEN"
         if oBMPData[1] == NIL
            oBMP:loadFile( GetProgramFilesPath()+ StdZLagerDir() + "\Icons\" + "Cancel.GIF" )
            oBMPData[1] := oBmp:SetBuffer(, XBPBMP_FORMAT_GIF)
         else
            oBmp:SetBuffer(oBMPData[1], XBPBMP_FORMAT_GIF)
         Endif

      Case cCapt == "SICHERN" .or. cCapt == "SPEICHERN"
         if oBMPData[2] == NIL
            oBMP:loadFile( GetProgramFilesPath()+ StdZLagerDir() + "\Icons\" + "Save.GIF" )
            oBMPData[2] := oBmp:SetBuffer(, XBPBMP_FORMAT_GIF)
         else
            oBmp:SetBuffer(oBMPData[2], XBPBMP_FORMAT_GIF)
         Endif

      Case cCapt == "OK" .or. cCapt == "ANMELDEN"
         if oBMPData[3] == NIL
            oBMP:loadFile( GetProgramFilesPath()+ StdZLagerDir() + "\Icons\" + "Ok.GIF" )
            oBMPData[3] := oBmp:SetBuffer(, XBPBMP_FORMAT_GIF)
         else
            oBmp:SetBuffer(oBMPData[3], XBPBMP_FORMAT_GIF)
         Endif

      Case cCapt == "NEU" .or. cCapt == "ERFASSEN"
         if oBMPData[4] == NIL
            oBMP:loadFile( GetProgramFilesPath()+ StdZLagerDir() + "\Icons\" + "new.GIF" )
            oBMPData[4] := oBmp:SetBuffer(, XBPBMP_FORMAT_GIF)
         else
            oBmp:SetBuffer(oBMPData[4], XBPBMP_FORMAT_GIF)
         Endif

      Case cCapt == "ENDE" .or. cCapt == "ZURÜCK" .or. cCapt == "BEENDEN"
         if oBMPData[5] == NIL
            oBMP:loadFile( GetProgramFilesPath()+ StdZLagerDir() + "\Icons\" + "back.GIF" )
            oBMPData[5] := oBmp:SetBuffer(, XBPBMP_FORMAT_GIF)
         else
            oBmp:SetBuffer(oBMPData[5], XBPBMP_FORMAT_GIF)
         Endif

      Case cCapt == "ÄNDERN" .or. cCapt == "MUTIEREN" .or. cCapt == "BEARBEITEN"
         if oBMPData[6] == NIL
            oBMP:loadFile( GetProgramFilesPath()+ StdZLagerDir() + "\Icons\" + "CHANGE.GIF" )
            oBMPData[6] := oBmp:SetBuffer(, XBPBMP_FORMAT_GIF)
         else
            oBmp:SetBuffer(oBMPData[6], XBPBMP_FORMAT_GIF)
         Endif

      Case cCapt == "DRUCKEN"
         if oBMPData[7] == NIL
            oBMP:loadFile( GetProgramFilesPath()+ StdZLagerDir() + "\Icons\" + "PRINT.GIF" )
            oBMPData[7] := oBmp:SetBuffer(, XBPBMP_FORMAT_GIF)
         else
            oBmp:SetBuffer(oBMPData[7], XBPBMP_FORMAT_GIF)
         Endif

   EndCase
   // Bitmap im PS anzeigen
   oBMP:draw( oPS, {5,4} )
   oXbp:unlockPS( oPS )

RETURN .t.