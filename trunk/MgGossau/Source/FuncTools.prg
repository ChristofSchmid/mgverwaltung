*FUNCTION Tools 3.7.2004, Zusammenfassunf aller Funktionen
*---------------------------------------------------------


#include "Gra.ch"
#include "Xbp.ch"
#include "AppEvent.ch"
#include "FCH.ch"
#include "Common.ch"
#include "Font.ch"
#include "MGV.CH"
#include "Directry.ch"
#include "DbfDbe.ch"
#include "Dll.ch"
#include "Fileio.ch"



FUNC SetStdSysPublVar()
*---------------------
LOCAL acPublics := {}

   aAdd( acPublics, {"CtrMemType" , "PUBLIC"} )
   aAdd( acPublics, {"MainDrive" , "C:\Programme\CAS Computing\MGVerwaltung\MGGossau\"} )
   aAdd( acPublics, {"RemoteDrive" , "C:\Programme\CAS Computing\MGVerwaltung\MGGossau\REMOTE\"} )
   aAdd( acPublics, {"DataDrive" , "C:\Programme\CAS Computing\MGVerwaltung\MGGossau\DATA\"} )
   aAdd( acPublics, {"FormDrive" , "C:\Programme\CAS Computing\MGVerwaltung\MGGossau\FORM\"} )
   aAdd( acPublics, {"DiscDrive" , "A:\"} )
   aAdd( acPublics, {"DocDrive" , "C:\Programme\CAS Computing\MGVerwaltung\MGGossau\DOCS\"} )
   aAdd( acPublics, {"InventarDrive" , "C:\Programme\CAS Computing\MGVerwaltung\MGGossau\INVE\"} )
   aAdd( acPublics, {"MessageDrive" , "C:\Programme\CAS Computing\MGVerwaltung\MGGossau\MESS\"} )
   aAdd( acPublics, {"HistoryDrive" , "C:\Programme\CAS Computing\MGVerwaltung\MGGossau\HIST\"} )
   aAdd( acPublics, {"AuswertDrive" , "C:\Programme\CAS Computing\MGVerwaltung\MGGossau\AUSW\"} )
   aAdd( acPublics, {"ImportDrive"  , "C:\Programme\CAS Computing\MGVerwaltung\MGGossau\IMPORT\"} )
   aAdd( acPublics, {"IconDrive"  , "C:\Programme\CAS Computing\MGVerwaltung\MGGossau\Icons\"} )
   aAdd( acPublics, {"PosLoged" , "101"} )
   aAdd( acPublics, {"PosLager" , "01"} )
   aAdd( acPublics, {"ZenLager" , "03"} )
   aAdd( acPublics, {"StammKunde" , "15"} )
   aAdd( acPublics, {"ZahlArtCC" , "AE, EC, VI"} )
   aAdd( acPublics, {"WiederverkaufKGR" , "02"} )
   aAdd( acPublics, {"LadenKundenKGR" , "01"} )
   aAdd( acPublics, {"BankZahlung" , "KT"} )
   aAdd( acPublics, {"BarZahlung" , "BA"} )
   aAdd( acPublics, {"StdWerbetraeger" , "01"} )
   aAdd( acPublics, {"StdDebStat" , "01"} )
   aAdd( acPublics, {"StdDebMail" , "01"} )
   aAdd( acPublics, {"DebDatAgeForValidate" , "360"} )
   aAdd( acPublics, {"MundzuMundWerbetraeger" , "01"} )
   aAdd( acPublics, {"DispLocked" , "6, 7"} )
   aAdd( acPublics, {"MemFile"  , "MGSystem.XPF"} )
   aAdd( acPublics, {"StdMWStCode" , "76"} )
   aAdd( acPublics, {"NetWork"  , "OnNet"} )
   aAdd( acPublics, {"TimeSave" , "3600"} )
   aAdd( acPublics, {"TransferIntervall" , "3600"} )
   aAdd( acPublics, {"TransferTyp" , "Auto"} )
   aAdd( acPublics, {"TransferStart" , "00.00.00"} )
   aAdd( acPublics, {"TransferEnd" , "24.00.00"} )
   aAdd( acPublics, {"TransferScript" , "Transfer.Scr"} )
   aAdd( acPublics, {"SerialNoFrames"  , "01, 10, 98"} )
   aAdd( acPublics, {"SerialNoForks"   , "05"} )
   aAdd( acPublics, {"SerialNoElement" , "01"} )
   aAdd( acPublics, {"SerialNoBrake"   , "97"} )
   aAdd( acPublics, {"MaxSDBTabRec"    , "50"} )
   aAdd( acPublics, {"MaxDocRec"       , "50"} )
   aAdd( acPublics, {"MaxDocDebRec"    , "50"} )
   aAdd( acPublics, {"MaxDebRec"       , "50"} )
   aAdd( acPublics, {"MaxKreRec"       , "50"} )
   aAdd( acPublics, {"MaxArtRec"       , "50"} )
   aAdd( acPublics, {"MaxDISRec"       , "50"} )
   aAdd( acPublics, {"MaxOrdRec"       , "50"} )
   aAdd( acPublics, {"MaxOrdKreRec"    , "50"} )
   aAdd( acPublics, {"MaxCalcQbSize"   , "50"} )
   aAdd( acPublics, {"CheckForStkList" , "0"} )
   aAdd( acPublics, {"SystemUser"      , "CS"} )
   aAdd( acPublics, {"MWStNr"          , "275131"} )
   aAdd( acPublics, {"FirstServiceArtNr"  , "10100011"} )
   aAdd( acPublics, {"FirstServiceCode"   , "01"} )
   aAdd( acPublics, {"OrderTypLieferant"   ,"02"} )
   aAdd( acPublics, {"ArtikelStartIndexFlag" , "5"} )
   aAdd( acPublics, {"KundenStartIndexFlag" , "2"} )
   aAdd( acPublics, {"KreditorStartIndexFlag" , "3"} )
   aAdd( acPublics, {"DokumentStartIndexFlag" , "3"} )
   aAdd( acPublics, {"ArtNotLMove" , "03,04"} )
   aAdd( acPublics, {"DialogResizeAtStartup" , "1"} )
   aAdd( acPublics, {"DialogMinSize" , "50"} )
   aAdd( acPublics, {"DialogMaxSize" , "200"} )
   aAdd( acPublics, {"dbArtNr" ,  " 1010000000001"} )
   aAdd( acPublics, {"dbDebNr" ,  " 1011000"} )
   aAdd( acPublics, {"dbKreNr" ,  " 1011000"} )
   aAdd( acPublics, {"dbDocNr" ,  " 1011000"} )
   aAdd( acPublics, {"dbDisNr" ,  " 1011000"} )
   aAdd( acPublics, {"dbOrdNr" ,  " 1011000"} )
   aAdd( acPublics, {"dbBikNr" , "       1"} )
   aAdd( acPublics, {"dbLagNr" ,  "1"} )
   aAdd( acPublics, {"dbFirma" ,  "101"} )
   aAdd( acPublics, {"dbStkIdx" ,  "1"} )
   aAdd( acPublics, {"cUser"   ,  "99"} )
   aAdd( acPublics, {"nStatistikJahre"   ,  "6"} )
   aAdd( acPublics, {"StatKgrPOS"   ,  "01"} )
   aAdd( acPublics, {"StatKgrGH"   ,  "02"} )
   aAdd( acPublics, {"StatAGREPNull"   ,  "05"} )
   aAdd( acPublics, {"LagerKostenAbrechnen"   ,  "1"} )
   aAdd( acPublics, {"StatStdMarginFZ"   ,  "35"} )
   aAdd( acPublics, {"StdLEBezug"   , "01"} )
   aAdd( acPublics, {"LockHolidays" , ""} )
   aAdd( acPublics, {"LockWeekdays" , "6"} )
   aAdd( acPublics, {"AppRefreshRate" , "100"} )

   aAdd( acPublics, {"FTPLocalFile" , "weblagstand.txt"} )
   aAdd( acPublics, {"FTPRemoteFile" , "admin/weblagstand.txt" } )
   aAdd( acPublics, {"FTPServerName" , "ftps.swiss-web.com"} )
   aAdd( acPublics, {"FTPUserName" , ""} )
   aAdd( acPublics, {"FTPPassWord" , ""} )
   aAdd( acPublics, {"FTPUpdateCommand" , ""} )
   aAdd( acPublics, {"FTPIntervall" , "60"} )
   aAdd( acPublics, {"FTPActivate" , "1"} )

   aAdd( acPublics, {"FTPBackupLocalFile" , "MGAllData.Zip"} )
   aAdd( acPublics, {"FTPBackupRemoteFile" , "backup/MGData.Zip" } )
   aAdd( acPublics, {"FTPBackupActivate" , "0"} )
   aAdd( acPublics, {"FTPBackupIntervall" , "60" } )
   aAdd( acPublics, {"BackupToFTPallowed" , "0" } )

   aAdd( acPublics, {"ReservationRuestZettel" , "1" } )
   aAdd( acPublics, {"TestFahrtRuestZettel" , "1" } )

   aAdd( acPublics, {"SalesBikesPGR"   ,  "01"} )
   aAdd( acPublics, {"SalesSparesPGR"  ,  "02, 03"} )
   aAdd( acPublics, {"SalesFramesPGR"  ,  "10"} )
   aAdd( acPublics, {"SalesLaborPGR"   ,  "09"} )

Return acPublics


FUNC LoadInit(aPublics, CtrFile)
*--------------
LOCAL FLines     := 0
LOCAL SegLines   := {0,0,0,0,0,0}
LOCAL FLine      := Space(0)
LOCAL LineLen    := 200
LOCAL FString    := Space(0)
LOCAL FVar       := Space(0)
LOCAL FVal       := Space(0)
LOCAL xFPos      := 0
LOCAL i,x        := 0
LOCAL MemType    := "P"

if !File(CtrFile)
   *MsgBox("Die Datei " + CtrFile + " fehlt. Sorry")
   Return {}
else
   FString := MemoRead( CtrFile )
endif

FLines = MLCount(FString)

FLine := MemoLine(FString, LineLen, 1)
xFPos := At("=", Fline )
FVar := Alltrim(Subs( FLine, 1, xFPos - 1) )
FVal := Alltrim(Subs( FLine, xFPos + 1, len(FLine) ) )

Do Case
   Case FVal == "PUBLIC" .and. FVar == "CtrMemType"
      MemType    := "P"
   Case FVal == "PRIVATE" .and. FVar == "CtrMemType"
      MemType    := "L"
   Othe
      MsgBox("Die Erste Zeile der Datei " + CtrFile + " ist falsch. Sorry")
      Return {}
Endcase

For i := 2 to FLines
    FLine := MemoLine(FString, LineLen, i)
    xFPos := At("=", Fline )
    FVar := Alltrim(Subs( FLine, 1, xFPos - 1) )
    FVal := Alltrim(Subs( FLine, xFPos + 1, len(FLine) ) )

    if !Empty(FVar)
       aAdd( aPublics, {FVar, FVal} )
    Endif
next

return aPublics


FUNC InitSysMem(aPublics)
*---------------------------------
For i := 1 to len(aPublics)
    FVal := aPublics[i][2]
    FVar := aPublics[i][1]
    PUBLIC &FVar :=  FVal
Next
Return .t.


FUNC UpdatePublics(aPublic, aInitCustom)
*----------------------------------------
LOCAL i, n

for i := 1 to len(aInitCustom)
   n := aScan(aPublic, aInitCustom[i][1] )
   if n > 0
      aPublic[n][2] := aInitCustom[i][2]
   endif
next

Return aPublic



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


FUNCTION RefreshData(cTask, Hwnd)
*------------------------------------
LOCAL i, n, x
LOCAL oldWa  := select()
LOCAL nAreas
LOCAL ObjLoaded  := WinMenu():Stack()
LOCAL nObjLoaded := Len( ObjLoaded )
LOCAL cMethodName := "ReadDoc"
LOCAL rVal
LOCAL aTasks := {}


Do Case
   case at( "ZART01" ,  cTask) >0
        aAdd( aTasks, {"Faktura","UpdateDocArt"})
        aAdd( aTasks, {"ArtStamm","UpdateArt"})
        aAdd( aTasks, {"LagerBuch","UpdateLagbuch"})
        aAdd( aTasks, {"ArtDialog","UpdateArtInfo"})

   case at( "ZDEB01" ,  cTask) >0
        aAdd( aTasks, {"Disposition","UpdateDispDeb"})
        aAdd( aTasks, {"Faktura","UpdateDocDeb"})
        aAdd( aTasks, {"DebStamm","UpdateDeb"})

  case at( "ZLAG02" ,  cTask) >0
        aAdd( aTasks, {"ArtDialog","UpdateArtLagInfo"})
        aAdd( aTasks, {"Faktura","UpdateDocDetDat"})

  case at( "DispZDIS01" ,  cTask) >0
        aAdd( aTasks, {"Disposition","UpdateDispDisp"})

  case at( "ZDIS01" ,  cTask) >0
        *Performance fraglich 8.4.2006
        aAdd( aTasks, {"Disposition","UpdateDispAll"})

  case at( "ZFAK02" ,  cTask) >0
       aAdd( aTasks, {"Faktura","UpdateDocDetDat"})

*  case at( "CloseClient" ,  cTask) >0
*       aAdd( aTasks, {"System","AppQuit"})



EndCase

   for i := 1 to nObjLoaded
      if !ObjLoaded[i]:GetHWnd() == HWnd
         For x := 1 to Len( aTasks )
            cMethodName := aTasks[x][2]
            IF IsMethod( ObjLoaded[i], cMethodName )
               if !ObjLoaded[i]:Startup
                  if !ObjLoaded[i]:EditMode
                     ObjLoaded[i]:&cMethodName.()
                     *msgbox(cTask  + " " + cMethodName + " " + " Refresh verarbeitet" ,"")
                  endif
               endif
            endif
         Next
      endif
   next

   For x := 1 to Len( aTasks )
       cMethodName := aTasks[x][2]
       IF IsFunction( cMethodName )
          &cMethodName.()
       endif
   Next

Select(OldWa)
RETURN .t.


FUNCTION LookForDataChanges()
*-------------------
LOCAL cKey         := "UpdateRequ" + Space(5) + padr( Alltrim( NetName() ), 30) + "1"
LOCAL cSysAlias    := SysAlias()
LOCAL CloseRequest := .f.

if UpdateInProgress()
   Return .f.
else
   UpdateInProgress(.t.)
endif

if ! SysDbRequest()
   UpdateInProgress(.f.)
   DbRefresh()
   Return .f.
Endif

if SysConnect( cKey ,1 )
   Do while Alltrim( ( cSysAlias )->Task ) == "UpdateRequ" .and. Alltrim( (cSysAlias)->Client ) == AllTrim( NetName() ) .and. ( cSysAlias )->open == "1" .and. !eof()
      if Alltrim( (cSysAlias)->TaskName ) == "CloseClient"
         CloseRequest := .t.
      endif
      RefreshData( Alltrim( (cSysAlias)->TaskName ),(cSysAlias)->HWnd  )
      if Reclock( Recno() )
         Replace EndTask with dtoc( date() ) + " " + Time()
         Replace User with CurrentUser()
         Replace Open with " "
         Replace Done with "1"
         Replace Status with Alltrim( NetName() )
         DbrUnlock( Recno())
      Endif
      FSkip(1)
   Enddo
endif
DbRelease( SysAlias() )

if CloseRequest
   AppQuit()
endif

UpdateInProgress(.f.)
Return .t.


FUNCTION SysConnect(cKey, nIndex)
*--------------------------------
LOCAL lFound := .f.
LOCAL cAlias  := SysAlias()

nIndex := iif(nIndex == NIL, 1, nIndex )
Select( cAlias )
OrdSetFocus( nIndex )
if FileLock( cAlias )
   DbSeek( cKey )
   lFound := Found()
   DbUnLock()
Endif
Return lFound


FUNCTION SetUpdateRequest(cTask, ODlg )
*-------------------------------------
LOCAL aClientList := {}
LOCAL OldWa       := Select()
LOCAL CurrRec     := Recno()
LOCAL i
LOCAL lFound
LOCAL cSeek       := ""
LOCAL cSysAlias   := SysAlias()
LOCAL nHWnd       := 0

if Val( AppRefreshRate ) == 0
   Return .f.
endif

if !oDlg == NIL
   nHWnd := oDlg:GetHwnd()
endif

if ! SysDbRequest()
   Return .f.
Endif

DbCommit()

if SysConnect( "MG Verwalt", 1 )
   Do While Alltrim( ( cSysAlias )->Task ) == "MG Verwalt" .and. !Eof()
      if ( cSysAlias )->Open == "1"
         if !cTask == "CloseClient"
            aAdd( aClientList, {"UpdateRequ", ( cSysAlias )->Client} )
         else
            *nur andere Stationen schliessen
            if !Alltrim( (cSysAlias )->Client) == Alltrim( NetName() )
               aAdd( aClientList, {"UpdateRequ", ( cSysAlias )->Client} )
            endif
         endif
      endif
      FSkip(1)
   Enddo
Endif

For i:= 1 to Len( aClientList )
   cSeek :=  padr( aClientList[i][1] ,15) + padr( cTask,50 ) + padr( aClientList[i][2],30 )
   if SysConnect(cSeek ,2 )
      if Reclock( Recno() )
         Replace StartTask with dtoc( date() ) + " " + Time()
         Replace EndTask with ""
         Replace HWnd with nHWND
         Replace Recno with CurrRec
         Replace User with CurrentUser()
         Replace Open with "1"
         Replace Done with " "
         DbrUnlock( Recno())
         *msgbox(TaskName + " " + client + " aktiviert" ,"")
      endif
   else
      if AppendBlank( cSysAlias )
         if Reclock( Recno() )
            Replace Task with aClientList[i][1]
            Replace TaskName with cTask
            Replace StartTask with dtoc( date() ) + " " + Time()
            Replace Client with aClientList[i][2]
            Replace HWnd with nHWND
            Replace Recno with CurrRec
            Replace User with CurrentUser()
            Replace Open with "1"
            Replace Done with " "
            DbrUnlock( Recno())
            *msgbox(TaskName + " " + client + " generiert" ,"")
         Endif
      Endif
   endif
Next
dbCommit()
OrdSetFocus(1)
DbRelease( cSysAlias )
Select(OldWa)
Return .t.


FUNCTION DataUpdate()
*-------------------------
LOCAL retVal := .f.
STATIC nTime

   IF nTime == NIL
      nTime := 1
   Else
      RetVal := iif( nTime > 10, .t. , .f.)
      nTime  := iif( nTime > 10, 1 , nTime +1)
   endif

RETURN Retval



FUNCTION SysWa( nWa )
*---------------------
STATIC nSysWa
   IF PCount() > 0
      nSysWa := nWa
   ENDIF
RETURN nSysWa

FUNCTION SysAlias( nWa )
*---------------------
STATIC cSysAlias
   IF PCount() > 0
      cSysAlias := Alias(nWa)
      SysWa( nWa )
   ENDIF
RETURN cSysAlias


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
PRIVATE aCustomScreen := {{},{},{},{}}
if File(MainDrive + "CustomScreen.xpf")
   Restore From (MainDrive + "CustomScreen.XPF" ) additive
Endif
Return aCustomScreen


FUNCTION IsDialogPosAndSize(oDlg)
*--------------------------------

if aScan( CustomScreen()[1], Subs( oDlg:getTitle(),1,10) ) > 0
   Return .t.
else
   Return .f.
Endif
Return .t.


FUNCTION SaveDialogPosAndSize(oDlg)
*----------------------------------
LOCAL nCustScr
LOCAL aCustScr
LOCAL aPos, aSize

aCustScr := CustomScreen()
nCustScr := aScan( aCustScr[1], Subs( oDlg:getTitle(),1,10) )
if nCustScr > 0
   aCustScr[2][nCustScr]  := oDlg:CurrentPos()
   aCustScr[3][nCustScr]  := oDlg:CurrentSize()
else
   aAdd( aCustScr[1], Subs( oDlg:getTitle(),1,10) )
   aAdd( aCustScr[2], oDlg:CurrentPos() )
   aAdd( aCustScr[3], oDlg:CurrentSize() )
Endif
CustomScreen(aCustScr)
Return .t.


FUNCTION RestoreDialogPosAndSize(oDlg)
*-------------------------------------
LOCAL nCustScr
LOCAL aCustScr
LOCAL aPos[2]
LOCAL aSize[2]
LOCAL MaxWinSize := AppDeskTop():CurrentSize()
LOCAL SysScrSize := AppDeskTop():CurrentSize()

if val( DialogMinSize ) >= 40
   odlg:MinSize := {odlg:CurrentSize()[1] * val( DialogMinSize )/100,odlg:CurrentSize()[2] * val( DialogMinSize )/100}
else
   odlg:MinSize := {odlg:CurrentSize()[1] / 2,odlg:CurrentSize()[2] / 2 }
Endif

if val( DialogMaxSize ) <= 250
   odlg:MaxSize := {odlg:CurrentSize()[1] * val( DialogMaxSize )/100,odlg:CurrentSize()[2] * val( DialogMaxSize )/100}
else
   odlg:MaxSize := {odlg:CurrentSize()[1] * 2.5 ,odlg:CurrentSize()[2] * 2.5 }
Endif

* auf Desktopgrösse begrenzen
if MaxWinSize[1] > oDlg:MaxSize[1] .or. MaxWinSize[2] > oDlg:MaxSize[2]
   oDlg:MaxSize := MaxWinSize
Endif

if DialogResizeAtStartup <> "1"
   *oDlg:setFrameState( XBPDLG_FRAMESTAT_NORMALIZED )
   oDlg:Show()
   Return .t.
Endif

   nCustScr := aScan( CustomScreen()[1], Subs( oDlg:getTitle(),1,10) )
   * Wenn CustScreen vorhanden
   if nCustScr > 0
      * Falls Fenter unter Min Size, Standardgrösse nehmen.
      if CustomScreen()[3][nCustScr][1] < oDlg:MinSize[1] .or. CustomScreen()[2][nCustScr][2] + CustomScreen()[3][nCustScr][2] > AppDeskTop():CurrentSize()[2]
         Do Case
            Case SysScrSize[1] * SysScrSize[2] <= 800 * 600
                 aSize[1] := SysScrSize[1] * 0.99
                 aSize[2] := SysScrSize[2] * 0.93
                 aPos        :=CenterPos( aSize, SysScrSize )
                 *aPos        := { (SysScrSize[1] - aSize[1])/2 , RootWindow():CurrentSize()[2] + RootWindow():CurrentPos()[2]- aSize[2] }

            Case SysScrSize[1] * SysScrSize[2] <= 1024 * 768

                 aSize[1] := SysScrSize[1] * 0.87 * 0.9
                 aSize[2] := SysScrSize[2] * 0.80 * 0.9
                 aPos        := { (SysScrSize[1] - aSize[1])/2 , RootWindow():CurrentSize()[2] - 120 + RootWindow():CurrentPos()[2]- aSize[2] }

            othe
                 * BS Auflösung anpassen
                 aSize[1] := SysScrSize[1] * 0.87 * 0.9
                 aSize[2] := SysScrSize[2] * 0.80 * 0.9
                 aPos     :=CenterPos( aSize, SysScrSize )

         endCase
            if Subs( oDlg:getTitle(),1,10) == "MG Verwalt"
               aSize[1] := SysScrSize[1] * 0.4
               aSize[2] := 120
               aPos[1]  := ( SysScrSize[1] / 2) - (aSize[1] / 2)
               aPos[2]  := ( SysScrSize[2] - aSize[2] - 12 )
            endif

      else

         aPos  := CustomScreen()[2][nCustScr]
         aSize := CustomScreen()[3][nCustScr]
      endif
         oDlg:Hide()
         oDlg:SetPos( aPos, .f. )
         oDlg:Setsize( aSize, .f. )
   else
         aCustScr := CustomScreen()

         aSize := {oDlg:CurrentSize()[1] + 1,oDlg:CurrentSize()[2]}
         aPos := CenterPos( aSize, SysScrSize )

         Do Case
            Case SysScrSize[1] * SysScrSize[2] <= 800 * 600
                 if odlg:CurrentSize()[1] * odlg:CurrentSize()[2] > SysScrSize[1] * 0.99 * SysScrSize[2] * 0.93
                    aSize[1] := SysScrSize[1] * 0.99
                    aSize[2] := SysScrSize[2] * 0.93
                 endif
                 aPos := CenterPos( aSize, SysScrSize )
                 *aPos        := { (SysScrSize[1] - aSize[1])/2 , RootWindow():CurrentSize()[2] + RootWindow():CurrentPos()[2]- aSize[2] }
            Case SysScrSize[1] * SysScrSize[2] <= 1024 * 768
                 if odlg:CurrentSize()[1] * odlg:CurrentSize()[2] > SysScrSize[1] * 0.99 * SysScrSize[2] * 0.93
                    aSize[1] := SysScrSize[1] * 0.87 * 0.9
                    aSize[2] := SysScrSize[2] * 0.80 * 0.9
                 endif
                 aPos        := { (SysScrSize[1] - aSize[1])/2 , RootWindow():CurrentSize()[2] - 120 + RootWindow():CurrentPos()[2]- aSize[2] }
           endCase

      aAdd( aCustScr[1], Subs( oDlg:getTitle(),1,10) )
      aAdd( aCustScr[2], aPos)
      aAdd( aCustScr[3], aSize)
      CustomScreen(aCustScr)

      oDlg:Hide()
      oDlg:SetPos( aPos, .f. )
      oDlg:Setsize( aSize, .f. )

   Endif
Return .t.





FUNC EditInit()
*--------------
Return .t.


FUNC Rund5(nVal)
*---------------

LOCAL nVal1 := nval * 10
LOCAL nValI := int(nval * 10)
LOCAL n025  := 0.25
LOCAL n050  := 0.5
LOCAL n075  := 0.75
LOCAL nComp := nVal1 - nValI

Do Case

   Case nComp < n025
        nVal := nValI
   Case nComp >= n025 .and. nComp < n075
        nVal := nValI + 0.5
   Case nComp >= n075
        nVal := nValI + 1
Endcase

Return nVal / 10


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



FUNC ReadKreDatFiles()
*---------------------------
LOCAL aDir  := Directory( ImportDrive+"*.Dbf" )
LOCAL KreWa
LOCAL TabWa
LOCAL ArtWa
LOCAL ArtStruct
LOCAL ExtStruct
LOCAL TabText  := "Tabelle 22 Firmenangaben nicht definiert"
LOCAL cKreNr   := "99999999"
LOCAL cKreName := "Kreditor"
LOCAL i, n, x
LOCAL StruComp := .t.
LOCAL CheckLen

LOCAL aFiles   := {}

OpenDb(DataDrive, ArtikelFile, {}, {})
ArtWa   := Select()
ArtStruct := DbStruct()
DbCloseArea()

OpenDb(DataDrive, LieferantenFile, LieferantenIndex, LieferantenKey)
KreWa   := Select()

OpenDb(DataDrive, TabellenFile, TabellenIndex, TabellenKey)
TabWa := Select()


Select(TabWa)
OrdSetFocus(1)
if FileLock(TabWa)
   DbSeek("022"+PosLoged)
   DbUnlock()
endif
if Found()
   TabText := Alltrim( (TabWa)->TabText )
else
   MsgBox(TabText)
   TabText := "Standard Artikel"
endif
Select(TabWa)
DbCloseArea()

aFiles   := {{TabText,ArtikelFile,ArtikelIndex, ArtikelKey, ArtStruct}}

For i:= 1 to len(aDir)
Select(KreWa)
   StruComp := .t.
   cKreNr := PadL( Subs( aDir[i][F_NAME], 1, at(".",aDir[i][F_NAME]) - 1 ), 10 )
   OrdSetFocus(1)
   if FileLock(KreWa)
      DbSeek(cKreNr)
      DbUnLock()
   Endif
   if Found()
      cKreName := (KreWa)->Name
   else
      cKreName := "Kreditor"
   Endif
   cKreNr := Alltrim(cKreNr)

   DbUseArea( .t. , , ImportDrive + aDir[i][F_NAME] )
   ExtStruct := DbStruct()
   DbCloseArea()
   if !len(ArtStruct) == len(ExtStruct)
      StruComp := .f.
   Else
      CheckLen := len(ArtStruct)
      For n:= 1 to CheckLen
         For x := 1 to 4
            if !ExtStruct[i][x] == ArtStruct[i][x]
               StruComp := .f.
            Endif
         Next
      Next
   Endif

   if StruComp
      aadd(aFiles, {cKreName, aDir[i][F_NAME], {"I" + cKreNr + "1.NTX","I" + cKreNr + "2.NTX","I" + cKreNr + "3.NTX","I" + cKreNr + "4.NTX"  },ArtikelKey,{}}  )
   else
      MsgBox("Das externe Artikel File " + ImportDrive + Alltrim( aDir[i][F_NAME] ) + " von " +  Alltrim(cKreName)  + " hat eine falsche Struktur" )
   Endif
Next
Select(KreWa)
DbCloseArea()
Return aFiles



FUNC ReadHisDatFiles()
*---------------------------
LOCAL aDir  := Directory( HistoryDrive+"Z"+PosLoged+"01"+"??.Dbf" )
LOCAL HisWa
LOCAL TabWa
LOCAL ArtWa
LOCAL HisStruct
LOCAL ExtStruct
LOCAL i, n, x
LOCAL StruComp := .t.
LOCAL CheckLen
LOCAL ReadName
LOCAL TabText

LOCAL aFiles   := {}

OpenDb(DataDrive, HistoryFile, HistoryIndex, HistoryKey)
HisWa   := Select()
HisStruct := DbStruct()
DbCloseArea()

OpenDb(DataDrive, TabellenFile, TabellenIndex, TabellenKey)
TabWa := Select()
Select(TabWa)
OrdSetFocus(1)
if FileLock(TabWa)
   DbSeek("022"+PosLoged)
   DbUnlock()
endif
if Found()
   TabText := Alltrim( (TabWa)->TabText )
else
   MsgBox(TabText)
   TabText := "Keine Angaben zu POS " + PosLoged
endif
Select(TabWa)
DbCloseArea()

For i:= 1 to len(aDir)

   DbUseArea( .t. , , HistoryDrive + aDir[i][F_NAME] )
   ExtStruct := DbStruct()
   DbCloseArea()
   if !len(HisStruct) == len(ExtStruct)
      StruComp := .f.
   Else
      CheckLen := len(HisStruct)
      For n:= 1 to CheckLen
         For x := 1 to 4
            if !ExtStruct[i][x] == HisStruct[i][x]
               StruComp := .f.
            Endif
         Next
      Next
   Endif

*   if StruComp
      ReadName := TabText + " " + Subs(aDir[i][F_NAME],7,2)
      aadd(aFiles, {ReadName, aDir[i][F_NAME], {"IH" + Subs(aDir[i][F_NAME],7,2) + "1.NTX","IH" + Subs(aDir[i][F_NAME],7,2) + "2.NTX" },HistoryKey,{}}  )
*   else
*      MsgBox("Das History File " + HistoryDrive + Alltrim( aDir[i][F_NAME] ) + " hat eine falsche Struktur" )
*   Endif
Next
Select(HisWa)
DbCloseArea()
Return aFiles


FUNCTION LogOn(oOwner, cUser)
*----------------------------
LOCAL nEvent, mp1, mp2
LOCAL Action := 0
LOCAL TabWa
LOCAL OldFocus := SetAppFocus()
LOCAL SDB    := "011"
LOCAL SDB2   := "011"
LOCAL oDlg, oXbp, drawingArea, aEditControls := {}
LOCAL aPos  := { ( AppDeskTop():CurrentSize()[1] - 350 ) /2, ( AppDeskTop():CurrentSize()[2] - 300) /2 }
LOCAL aSize
LOCAL PassWort  := Space(30)
LOCAL User      := Space(30)
LOCAL UserPw    := ""
LOCAL UserPwTxt := ""

if !cUser == NIL
   Do Case
      Case cUser == "Administrator"
      SDB  := "040"
      SDB2 := "040"
   endcase
Endif

OpenDb(DataDrive, TabellenFile, TabellenIndex, TabellenKey)
TabWa := Select()

   oDlg := DataDialog():new( AppDeskTop() ,oOwner , aPos, {350,300}, , .F.)
   oDlg:taskList := .T.
   oDlg:sysMenu   := .F.
   oDlg:minButton := .F.
   oDlg:maxButton := .F.
   oDlg:MoveWithOwner := .f.
   oDlg:title  := "Benutzer Logon"
   *oDlg:Resize := {| | NIL }
   *oDlg:move   := {| | NIL }
   oDlg:create()

   drawingArea := oDlg:drawingArea
   drawingArea:setFontCompoundName( "8.Arial" )
   oDlg:setModalState( XBP_DISP_APPMODAL )

   oDlg:aArea[TABELLEN] := TabWa
   aSize := oDlg:CurrentSize()

   oXbp := XbpStatic():new( DrawingArea, , {12,216}, {72,24} )
   oXbp:caption := "Benutzer:"
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( DrawingArea, , {96,216}, {120,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 30
   oXbp:tabStop := .T.
   oXbp:Editable := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0,  Trim(User) , User := x ) }
   oXbp:create():setData()
   oDlg:RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpStatic():new( DrawingArea, , {12,180}, {72,24} )
   oXbp:caption := "Passwort:"
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( DrawingArea, , {96,180}, {120,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 30
   oXbp:tabStop := .T.
   oXbp:UnReadable := .T.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0,  Trim(PassWort) , PassWort := x ) }
   oXbp:create():setData()
   oDlg:RegisterElement(@oXbp, .t.,,,)

   oXbp := XbpPushButton():new( DrawingArea, , {12,12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Anmelden"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| Action := 1 }
   oDlg:RegisterElement(@oXbp, .t.,,,)

   oXbp := XbpPushButton():new( DrawingArea, , {aSize[1]-96,12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Abbrechen"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| PostAppEvent(xbeP_Close,,,oDlg), PostAppEvent(xbeP_Close,,,oOwner) }
   oDlg:RegisterElement(@oXbp, .t.,,,)

   if !IsDialogPosAndSize(oDlg)
      SaveDialogPosAndSize(oDlg)
   Endif
   RestoreDialogPosAndSize(oDlg)

   SetAppFocus(oDlg:aFlowControl[1])

   oDlg:Show()

*   if cUser == NIL
       oDlg:GetDBKey(@SDB, TabWa, {1, len(TabellenKey)}, {"TabCode", "TabText"}, 5, "Benutzer Auswahl" )
*   endif

   if ! SDB == ""
      User := oDlg:GetTabText("", SDB)
      UserPwTxt := (TabWa)->Gtext
      UserPw := Encrypt(UserPwTxt)
      oDlg:SetTitle( "Benutzer Logon " + User + " anmelden" )
      oDlg:aEditControls[1]:SetData()
   else
      PostAppEvent(xbeP_Close,,,oDlg)
      PostAppEvent(xbeP_Close,,,oOwner)
   Endif

   if UserPw == ""
      oOwner:SystemUser := Subs( SDB, 4,2)
      oOwner:SetTitle( oOwner:GetTitle() + "   (" + oDlg:GettabText(SDB2, oOwner:SystemUser )+")" )
      WinMenu():SetItem( oOwner )
      PostAppEvent(xbeP_Close,,,oDlg)
   Endif


   nEvent := xbe_None

   DO WHILE nEvent <> xbeP_Close
      nEvent := AppEvent( @mp1, @mp2, @oXbp )
      oXbp:handleEvent( nEvent, mp1, mp2 )

      Do Case
         Case Action == 1
             Action := 0
             PassWort := oDlg:aFlowControl[1]:EditBuffer()
             If !Alltrim(Upper( PassWort )) == UserPw
                MsgBox(oDlg:GettabText(SDB2,Subs( SDB, 4,2) ) + " ihr Passwort ist falsch", "Logon()" )
                SetAppFocus(oDlg:aFlowControl[1])
                oDlg:aFlowControl[1]:setMarked( {1, oDlg:aFlowControl[1]:bufferLength + 1} )
             else
                oOwner:SystemUser := Subs( SDB, 4,2)
                oOwner:SetTitle( oOwner:GetTitle() + "   (" + oDlg:GettabText(SDB2, oOwner:SystemUser )+")" )
                WinMenu():SetItem( oOwner )
                PostAppEvent(xbeP_Close,,,oDlg)
             endif

         Case Action == 2
            Action := 0
      Endcase

   ENDDO

   Select(TabWa)
   DbCloseArea()
   SetAppFocus(OldFocus)
   *oDlg:setModalState( XBP_DISP_MODELESS )
   *oDlg:Destroy()
Return .t.


FUNCTION EnCrypt(cText)
*----------------------
Return Alltrim(Upper(cText))


FUNC GetaIni(cIni)
*-------------
LOCAL aIni    := {}

Do While at(",", cIni) > 0
   aAdd(aIni, Alltrim(  Subs(cIni,1,at(",", cIni)-1))  )
   cIni := Subs(cIni, At(",", cIni) + 1, len(cIni) )
Enddo
aAdd(aIni, Alltrim( cIni )  )
Return aIni


FUNC FAbsZ( o, Zeile)
*--------------------
LOCAL TabWa := o:aArea[TABELLEN]
LOCAL cAbs  := ""
LOCAL cTitel
LOCAL i
o:Connect( "022" + POSLoged, TabWa, 1 )
cAbs   :=  (TabWa)->GText
Return MemoLine( cAbs , , Zeile)


FUNCTION GuiBrowseDB( oParent, aPos, aSize, DataWorkArea )
*---------------------------------------------------------
   LOCAL oBrowse
   LOCAL DataWa := iif(DataWorkArea == NIL, oParent:aArea[TEMP], DataWorkArea )
   Select( DataWa )

   oBrowse := XbpBrowse():new( oParent,, aPos, aSize,, .F. )
   oBrowse:create()

   // Navigations Codebloecke fuer den Browser

   oBrowse:skipBlock     := {|n| xDbSkipper(DataWa,n) }
   oBrowse:goTopBlock    := {| | Select(DataWa), DbGoTop()    }
   oBrowse:goBottomBlock := {| | Select(DataWa), DbGoBottom() }
   oBrowse:phyPosBlock   := {| | Select(DataWa), Recno()      }

   // Codebloecke fuer den vertikalen Scrollbar.
   // Hinweis: DbPosition() liefert Werte zwischen 0 und 100.
   // Wir multiplizieren das mit 10 um eine feinere Granularitaet
   // fuer den Scrollbar zu erreichen.

   oBrowse:posBlock      := {| | Select(DataWa), DbPosition()*10    }
   *oBrowse:goPosBlock    := {|n| Select(DataWa), DbGoPosition(n/10) }
   oBrowse:lastPosBlock  := {| | 1000               }
   oBrowse:firstPosBlock := {| | 0                  }

   oBrowse:CursorMode    := XBPBRW_CURSOR_ROW



RETURN oBrowse


FUNCTION GuiQuickBrowse( oParent, oOwner, aPos, aSize, aPresParam, lVisible )
*----------------------------------------------------------------------------
LOCAL oXbp := XbpQuickBrowse():new( oParent, oOwner, aPos, aSize, aPresParam, lVisible )

Return oXbp



FUNCTION xDbSkipper(DataWa,n)
*--------------------------
   Select(DataWa)
*   fSkip(n)
*   Return n

   Return DbSkipper(n)


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


FUNCTION NetName()
*-----------------
// Name der Workstation feststellen

#ifdef __WIN32__
   LOCAL cKey, cEntry

   cKey   := "System\CurrentControlSet\" + ;
             "Control\ComputerName\ComputerName"

   cEntry := "ComputerName"

   RETURN QueryRegistry( HKEY_LOCAL_MACHINE, cKey, cEntry )

#endif

#ifdef __OS2__
    RETURN GetEnv( "HOSTNAME" )
#endif

   // Xbase++ Wrapper-Funktionen für jeden API-Aufruf deklarieren

   DLLFUNCTION RegOpenKeyExA( nHkeyClass, cKeyName, nReserved , nAccess , @nKeyHandle )  USING STDCALL FROM ADVAPI32.DLL

   DLLFUNCTION RegQueryValueExA( nKeyHandle, cEntry  , nReserved, @nType    , @cName  , @nSize  ) USING STDCALL FROM ADVAPI32.DLL

   DLLFUNCTION RegCloseKey( nKeyHandle ) USING STDCALL FROM ADVAPI32.DLL


   // Werte aus der Windows Registry-Datenbank auslesen

   FUNCTION QueryRegistry( nHKEY, cKey, cEntry )
      LOCAL cName  := ""            // Alle Parameter, die an
      LOCAL nSize  := 0             // API Funktionen übergeben
      LOCAL nHandle:= 0             // werden, müssen einen Wert
      LOCAL nType  := 0             // ungleich NIL haben
      LOCAL nRet
                                    // Registry öffnen
      nRet := RegOpenKeyExA( nHKEY, cKey, 0, KEY_QUERY_VALUE, @nHandle )

      IF nRet <> 0                  // Fehler beim öffnen
         RETURN cName               // ** RETURN **
      ENDIF
                                    // Länge und Typ des
                                    // Eintrags feststellen
      RegQueryValueExA( nHandle, cEntry, 0, @nType , @cName, @nSize  )

      IF nSize > 0                  // Leeren String vorbereiten.

         cName := Space( nSize-1 )  // Er wird per Referenz an die
                                    // API übergeben und enthält
                                    // dann das Ergebnis.
         RegQueryValueExA( nHandle, cEntry, 0, nType  , @cName, @nSize )

      ENDIF

      RegCloseKey( nHandle )        // Registry schließen

   RETURN cName


FUNCTION CurrentUser()
*---------------------
Return "XXX"

FUNCTION RegisterNetworkParts(oDlg)
*-------------------------------------------
LOCAL cTask     := Alltrim( Subs( oDlg:getTitle() ,1,10)+ Space(5) +  Alltrim( NetName() ) )
LOCAL cSysAlias := SysAlias()
if SysDbRequest()
   if SysConnect( cTask, 1 )
      if Reclock( Recno() )
         Replace TaskName with oDlg:getTitle()
         Replace StartTask with dtoc( date() ) + " " + Time()
         Replace EndTask with ""
         Replace HWnd with oDlg:getHWND()
         Replace User with CurrentUser()
         Replace Done with " "
         Replace Open with "1"
         DbrUnlock( Recno())
      endif
   else
      AppendBlank( cSysAlias )
      if Reclock( Recno() )
         Replace Task with Subs( oDlg:getTitle() ,1,10)
         Replace TaskName with oDlg:getTitle()
         Replace StartTask with dtoc( date() ) + " " + Time()
         Replace Client with NetName()
         Replace HWnd with oDlg:getHWND()
         Replace User with CurrentUser()
         Replace Done with " "
         Replace Open with "1"
         DbrUnlock( Recno())
      Endif
   endif
   DbCommit()
   DbRelease( cSysAlias )
   Return .t.
else
   RegisterNetworkError(1)
   Return .f.
Endif
Return .f.



FUNCTION UnRegisterNetworkParts(oDlg)
*---------------------------------------------
LOCAL cTask         := Alltrim( Subs( oDlg:getTitle() ,1,10)+ Space(5) +  Alltrim( NetName() ) )
LOCAL cSysAlias     := SysAlias()
LOCAL activDialogs  := WinMenu():Stack()
LOCAL i             := 0

*Programme mehr als einmal offen

For i:= 1 to len( activDialogs )
   if oDlg:GetTitle() == activDialogs[i]:GetTitle()
      Return .t.
   endif
Next

if SysDbRequest()
   if SysConnect( cTask, 1 )
      if Reclock( Recno() )
         Replace EndTask with dtoc( date() ) + " " + Time()
         Replace Done with "1"
         Replace Open with " "
         DbrUnlock()
      endif
   Endif
   DbCommit()
   DbRelease( cSysAlias )
   Return .t.
else
   *5.8.2005
   RegisterNetworkError(1)
   Return .f.
Endif
Return .f.

FUNCTION UniqueTask(cClient)
*---------------------------
LOCAL RetVal      := .t.
LOCAL ClientTasks := .f.
LOCAL LokalTasks  := .f.
LOCAL MainTask    := .f.
LOCAL cSysAlias := SysAlias()

if SysDbRequest()
   Select( cSysAlias )
   if FileLock( cSysAlias )
      DbGotop()
      Do While !Eof()
         if !  Alltrim( ( cSysAlias )->Client ) ==  Alltrim( NetName() )  .and. ( cSysAlias )->Open == "1"
            ClientTasks := .t.
            cClient :=  ( cSysAlias )->Client
            exit
         endif
         if Alltrim( ( cSysAlias )->Task ) == "MG Verwalt" .and. Alltrim( ( cSysAlias )->Client ) == Alltrim( NetName() )
            MainTask := .t.
         endif
         if !Alltrim( ( cSysAlias )->Task ) == "MG Verwalt" .and. Alltrim( ( cSysAlias )->Client ) == Alltrim( NetName() )  .and. ( cSysAlias )->Open == "1"
            cClient :=  ( cSysAlias )->Client
            LokalTasks := .t.
            exit
         endif
         Skip(1)
      Enddo
      DbUnlock()
   endif
   DbRelease( cSysAlias )
else
   * Bei Unsicherheit nicht zulassen
   LokalTasks := .t.
endif

if !ClientTasks .and. !LokalTasks
   retval := .t.
else
   retval := .f.
endif
Return RetVal


FUNCTION ReorgActive()
*--------------------
LOCAL RetVal    := .f.
LOCAL cSysAlias := SysAlias()

if SysDbRequest()
   if SysConnect( "Dienstprog", 1)
      if ( cSysAlias )->Open == "1"
         RetVal := .t.
      endif
   endif
   DbRelease( cSysAlias )
else
   * Bei Unsicherheit nicht zulassen
   RetVal := .t.
Endif
Return RetVal


FUNCTION RegActive()
*--------------------
LOCAL RetVal    := .f.
LOCAL cSysAlias := SysAlias()
if SysDbRequest()
   if SysConnect( "Kassenbuch", 1)
      if ( cSysAlias )->Open == "1"
         RetVal := .t.
      endif
   endif
   DbRelease( SysAlias() )
else
   * Bei Unsicherheit nicht zulassen
   RetVal := .t.
Endif
Return RetVal


FUNCTION SysDbRequest( CorrectSysDb )
*------------------------------------
LOCAL cSysAlias := SysAlias()
LOCAL WaitLoops := 10
LOCAL WaitState := 20
LOCAL nLoops    := 1

CorrectSysDB    := iif(CorrectSysDb == NIL, .f., CorrectSysDb )

Do while nLoops < WaitLoops
   if DbRequest( cSysAlias, .t. )
      Return .t.
   endif
   nLoops := nLoops + 1
   Sleep(WaitState)
enddo

if CorrectSysDb
   RegisterNetworkError( 1 )
   if DbRequest( cSysAlias, .t. )
      Return .t.
   else
      Return .f.
   endif
endif

SysDbTries := SysDbTries + 1

MsgBox("Die Systemdatenbank konnte " + Str(SysDbTries,1,0) +  " Mal nicht angefordert werden. Bitte MG Verwaltung beenden und neu starten","SysDbRequest()")
*MsgBox("Die Systemdatenbank konnte " + Str(SysDbTries,1,0) +  " Mal nicht angefordert werden. Nach dem 3. Versuch wird MoneyPenny beendet","SysDbRequest()")
Return .f.




FUNCTION RegisterNetworkError(ENum)
*----------------------------------
LOCAL activDialogs  := WinMenu():Stack()
Do Case
   Case ENum == 1
      MsgBox("Systemdatenbank Fehler. Drücken Sie OK für die Korrektur.", "RegisterNetworkError(ENum)" )

*      DBCloseAll()

*      OpenDb(DataDrive, SystemFile, SystemIndex, SystemKey, .t., .f.)
*      SysAlias( Select() )
*      DbRelease( SysAlias() )

*      For i:= 1 to len( activDialogs)
*         activDialogs[i]:Close()
*      Next

      MsgBox("Alle Programm werden beendet, neu starten.", "RegisterNetworkError(ENum)" )
      SysDbTries := 3
endcase

Return .t.


/*
 * Routine zur Abfrage des Anwendungsfensters
 */
FUNCTION RootWindow( oDlg )
   STATIC soDialog
   IF PCount() > 0
      soDialog := oDlg
   ENDIF
RETURN soDialog


FUNCTION CustomScreen( aCustomScreen )
   STATIC soScreen
   IF PCount() > 0
      soScreen := aCustomScreen
   ENDIF
RETURN soScreen


FUNCTION SetMousePointer(Mode, Obj)
*-----------------------------
* 0 == Standard
* 1 == Wait
LOCAL aChildList
LOCAL i

if !Obj == NIL
   aChildList := Obj:ChildList()
   for i:= 1 to len(aChildList)
   Do case
      Case Mode == 0
         aChildList[i]:setPointer( , XBPSTATIC_SYSICON_ARROW, XBPWINDOW_POINTERTYPE_POINTER )

      Case Mode == 1
        aChildList[i]:setPointer( , XBPSTATIC_SYSICON_WAIT, XBPWINDOW_POINTERTYPE_SYSPOINTER )

   Endcase
   next
else
   aChildList := AppDeskTop():ChildList()
   for i:= 1 to len(aChildList)
      Do case
         Case Mode == 0
            aChildList[i]:setPointer( , XBPSTATIC_SYSICON_ARROW, XBPWINDOW_POINTERTYPE_POINTER )
            aChildList[i]:DrawingArea:setPointer( , XBPSTATIC_SYSICON_ARROW, XBPWINDOW_POINTERTYPE_POINTER )
         Case Mode == 1
            aChildList[i]:setPointer( , XBPSTATIC_SYSICON_WAIT, XBPWINDOW_POINTERTYPE_SYSPOINTER )
            aChildList[i]:DrawingArea:setPointer( , XBPSTATIC_SYSICON_WAIT, XBPWINDOW_POINTERTYPE_SYSPOINTER )
      Endcase
   next
Endif
Return .t.



FUNCTION DialogPos()
*-------------------
Return { (AppDeskTop():CurrentSize()[1] - AppDeskTop():CurrentSize()[1] * 0.87 * 0.9 )/2 , RootWindow():CurrentSize()[2] - 120 + RootWindow():CurrentPos()[2]- AppDeskTop():CurrentSize()[2] * 0.80 * 0.9 }


FUNCTION DialogSize()
*--------------------
Return {802,553}


FUNCTION GenTmpFile(Drive)
*-------------------------
LOCAL FileName := Alltrim( Str( Seconds()*100,10,0 ) )

Do while File( Drive + Filename + ".Dbf" )
   FileName := Alltrim( Str( Seconds()*100,10,0 ) )
Enddo

Return FileName + ".dbf"


FUNCTION GenTmpIndex(drive)
*--------------------------
LOCAL FileName := Alltrim( Str( Seconds()*100,10,0 ) )
Do while File( Drive + Filename + ".NTX" )
   FileName := Alltrim( Str( Seconds()*100,10,0 ) )
Enddo

Return FileName + ".NTX"



FUNCTION ValidnSle(Obj, nMin, nMax)
*----------------------------
LOCAL nValue     := Val( Obj:EditBuffer() )
if pCount() == 3
   nMin := iif(nMin == NIL, 0, nMin)
   nMax := iif(nMin == NIL, 99999, nMax)
Endif
if pCount() == 2
   nMin := iif(nMin == NIL, 0, nMin)
   nMax := 99999
Endif
if pCount() == 1
   nMin := 0
   nMax := 99999
Endif
if nValue < nMin
   MsgBox("Wert zu klein. Wert muss zwischen " + Str(nMin) + " und " + Str(nMax) + " liegen","Validierung Zahlenfeld")
   return .f.
endif
if nValue > nMax
   MsgBox("Wert zu gross. Wert muss zwischen " + Str(nMin) + " und " + Str(nMax) + " liegen"  ,"Validierung Zahlenfeld")
   return .f.
endif
Return .t.



FUNC WriteErrorLog()
*-------------------
LOCAL i
Return .t.

      cErrorLog := MessageDrive + "Error" + ".000"
      Do while file(cErrorLog)
         cExtension := PadL(++i,3,"0")
         cErrorLog := MessageDrive + "Error" + "." + cExtension
      enddo

        SET ALTERNATE TO (cErrorLog)
        SET ALTERNATE ON

   ? Replicate( "-", 78 )
   ? appName(.T.) , Date(), Time()

   ? Replicate( "-", 78 )



   ? Replicate( "-", 78 )
   ? "CALLSTACK:"
   ? Replicate( "-", 78 )

   i := nStackStart
   DO WHILE ! Empty( ProcName(++i) )
      ? EHS_CALLED_FROM, Trim( ProcName(i) )   + "(" + ;
                 LTrim( Str( ProcLine(i) ) ) + ")"
   ENDDO
   ?

   SET ALTERNATE TO
   SET ALTERNATE OFF
RETURN .t.


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
            oBMP:loadFile( IconDrive + "Cancel.GIF" )
            oBMPData[1] := oBmp:SetBuffer(, XBPBMP_FORMAT_GIF)
         else
            oBmp:SetBuffer(oBMPData[1], XBPBMP_FORMAT_GIF)
         Endif

      Case cCapt == "SICHERN" .or. cCapt == "SPEICHERN"
         if oBMPData[2] == NIL
            oBMP:loadFile( IconDrive + "Save.GIF" )
            oBMPData[2] := oBmp:SetBuffer(, XBPBMP_FORMAT_GIF)
         else
            oBmp:SetBuffer(oBMPData[2], XBPBMP_FORMAT_GIF)
         Endif

      Case cCapt == "OK" .or. cCapt == "ANMELDEN"
         if oBMPData[3] == NIL
            oBMP:loadFile( IconDrive + "Ok.GIF" )
            oBMPData[3] := oBmp:SetBuffer(, XBPBMP_FORMAT_GIF)
         else
            oBmp:SetBuffer(oBMPData[3], XBPBMP_FORMAT_GIF)
         Endif

      Case cCapt == "NEU" .or. cCapt == "ERFASSEN"
         if oBMPData[4] == NIL
            oBMP:loadFile( IconDrive + "new.GIF" )
            oBMPData[4] := oBmp:SetBuffer(, XBPBMP_FORMAT_GIF)
         else
            oBmp:SetBuffer(oBMPData[4], XBPBMP_FORMAT_GIF)
         Endif

      Case cCapt == "ENDE" .or. cCapt == "ZURÜCK" .or. cCapt == "BEENDEN"
         if oBMPData[5] == NIL
            oBMP:loadFile( IconDrive + "back.GIF" )
            oBMPData[5] := oBmp:SetBuffer(, XBPBMP_FORMAT_GIF)
         else
            oBmp:SetBuffer(oBMPData[5], XBPBMP_FORMAT_GIF)
         Endif

      Case cCapt == "ÄNDERN" .or. cCapt == "MUTIEREN" .or. cCapt == "BEARBEITEN"
         if oBMPData[6] == NIL
            oBMP:loadFile( IconDrive + "CHANGE.GIF" )
            oBMPData[6] := oBmp:SetBuffer(, XBPBMP_FORMAT_GIF)
         else
            oBmp:SetBuffer(oBMPData[6], XBPBMP_FORMAT_GIF)
         Endif

      Case cCapt == "DRUCKEN"
         if oBMPData[7] == NIL
            oBMP:loadFile( IconDrive + "PRINT.GIF" )
            oBMPData[7] := oBmp:SetBuffer(, XBPBMP_FORMAT_GIF)
         else
            oBmp:SetBuffer(oBMPData[7], XBPBMP_FORMAT_GIF)
         Endif

   EndCase
   // Bitmap im PS anzeigen
   oBMP:draw( oPS, {5,4} )
   oXbp:unlockPS( oPS )

RETURN .t.


FUNCTION DebIndexExpr( cExpr, nFieldPart )
*----------------------------------------------
LOCAL i           := 0
LOCAL nFLen       := 0
LOCAL nFStartPos  := 0
LOCAL nFEndPos    := 0
LOCAL cFPart      := ""
LOCAL cDevider    := " "
LOCAL cReturn     := ""
LOCAL nCount      := 5
LOCAL aExprParts  := {}
LOCAL x           := nFieldPart


Do While At( cDevider, cExpr ) > 0
   i:= i + 1
   nFStartPos    := At( cDevider, cExpr ) - 1
   aAdd( aExprParts, Subs( cExpr, 1, nFStartPos ) )
   cExpr := Stuff( cExpr, 1, nFStartPos , "" )
   cExpr := Alltrim(cExpr)
Enddo

aAdd( aExprParts, cExpr )

For i:= 1 to len( aExprParts )
  if  x > len( aExprParts )
     x := 1
  endif
  cReturn := cReturn + aExprParts[ x ] + " "
  x := x + 1
next

cReturn := PadR( Alltrim(cReturn) , 30)

Return cReturn


FUNCTION CheckEvent(nEvent)
*--------------------------
Do Case
   Case nEvent == MP_UPDATEREQUEST
        eval( SetAppEvent(MP_UPDATEREQUEST) )
Endcase
Return nEvent

FUNCTION UpdateInProgress( UIP )
*--------------------------
   STATIC UpdateInProgress
   IF PCount() > 0
      UpdateInProgress := UIP
   ENDIF
RETURN UpdateInProgress


FUNCTION InternetOpen()
*----------------------
LOCAL sAgent           := "open connection"
LOCAL hConnection      := 0
LOCAL sProxyName       := ""
LOCAL sProxyBypass     := ""
LOCAL lFlags           := 0 &&Active
LOCAL IHandle          := 0

IHandle := DllCall("wininet.dll", DLL_STDCALL,"InternetOpenA", sAgent, hConnection, sProxyName, sProxyBypass, lFlags  )

Return IHandle


FUNCTION FTPOpen(IHandle, sServerName, sUserName, sPassWord )
*------------------------
LOCAL nServerPort      := 0 &&Konst
LOCAL lService         := 1 &&Konst FTP
LOCAL lFlags           := 0 &&Active
LOCAL lContext         := 0

FtpHandle := DllCall("wininet.dll", DLL_STDCALL,"InternetConnectA", IHandle, sServerName, nServerPort, sUserName, sPassword, lService, lFlags, lContext  )

Return FtpHandle


FUNCTION FTPCopy(FtpHandle, lpszLocalFile, lpszRemoteFile)
*--------------------------
LOCAL dwFlags          := 0 && 1 == ASC mode
LOCAL dwContext        := 0
LOCAL CopySuccess      := 0

CopySuccess := DllCall("wininet.dll", DLL_STDCALL,"FtpPutFileA", FtpHandle, lpszLocalFile, lpszRemoteFile, dwFlags, dwContext  )

Return CopySuccess


FUNCTION FTPGetFile(FtpHandle, lpszLocalFile, lpszRemoteFile)
*--------------------------
LOCAL dwFlags          := 0 && 1 == ASC mode
LOCAL dwContext        := 0
LOCAL CopySuccess      := 0
LOCAL FailIfExists     := 0
LOCAL dwFandA          := 0

CopySuccess := DllCall("wininet.dll", DLL_STDCALL,"FtpGetFileA", FtpHandle, lpszRemoteFile, lpszLocalFile, FailIfExists, dwFandA, dwFlags, dwContext  )

Return CopySuccess



FUNCTION HTTPOpen(IHandle, hURL)
*-------------------------------
LOCAL UrlSuccess       := 0

UrlSuccess := DllCall("wininet.dll", DLL_STDCALL,"InternetOpenUrlA", IHandle, hURL, "", 0, 1, 0)

Return UrlSuccess


FUNCTION InternetClose(IHandle)
*------------------------------
LOCAL CloseSuccess       := 0
CloseSuccess :=  DllCall("wininet.dll", DLL_STDCALL, "InternetCloseHandle", IHandle  )

Return CloseSuccess


FUNCTION FTPisFile(FtpHandle, FtpFile)
*-------------------------------------
LOCAL FileHandle := 0
LOCAL DirInfo    := 0
FileHandle := DllCall("wininet.dll", DLL_STDCALL, "FtpFindFirstFileA", FtpHandle, FtpFile, DirInfo, 0x80000000, 0)
Return iif( FileHandle == 0, .f.,.t.)



FUNCTION RunSendLagToWeb()
*-----------------------

if FTPActivate == "1"
   *SendLagToWeb()
endif
Return .t.


FUNCTION RunBackupToFTP()
*-----------------------

if FTPBackupActivate  == "1"
   BackupToFTP()
endif
Return .t.


FUNCTION SendLagToWeb()
*----------------------

LOCAL oProgress
LOCAL aProgrPos
LOCAL aProgrSize
LOCAL oDialog
LOCAL aSize := {300,100}
*LOCAL aPos := CenterPos( {300,100}, AppDeskTop():CurrentSize() )
LOCAL aPos := {AppDeskTop():CurrentSize()[1]-320,45}
LOCAL LagWa       := 0
LOCAL WebDbf      := GenTmpFile(AuswertDrive)
LOCAL WebTxt      := FTPLocalFile
LOCAL nHandle     := FCreate( AuswertDrive + WebTxt, FC_NORMAL )
LOCAL nFields     := 0
LOCAL cString     := ""
LOCAL i           := 1
LOCAL xVal        := ""
LOCAL aStructure  := {}
LOCAL fLen        := 0
LOCAL cTargetFile := FTPRemoteFile
LOCAL aFieldNames := {"S14", "S15", "S16", "S17", "S18", "S19", "S20", "S21", "S22", "S23", "S24", "LagStand", "R14", "R15", "R16", "R17", "R18", "R19", "R20", "R21", "R22", "R23", "R24", "ResStand"}
LOCAL IHandle
LOCAL FtpHandle
LOCAL FTPCopy
LOCAL HttpOpen
LOCAL IClose
LOCAL ProgressStep := 1

oDialog           := XbpDialog():new( AppDeskTop(), , aPos, aSize, , .F.)
oDialog:taskList  := .F.
oDialog:sysMenu   := .F.
oDialog:minButton := .F.
oDialog:maxButton := .F.
oDialog:title     := "Datenbestände auf Homepage anpassen"
oDialog:border    := 2 &&XBPDLG_SIZEBORDER
oDialog:create()
oDialog:toBack()
oDialog:show()
*SetAppFocus(oDialog)

aProgrPos  := {4, 10 }
aProgrSize := {280, 10 }

oProgress         := ProgressBar():new( oDialog ,, aProgrPos,  aProgrSize)
oProgress:create()
oProgress:minimum := 1
oProgress:color   := GRA_CLR_BLUE

OpenDb(DataDrive, LagerFile, LagerIndex, LagerKey)
LagWa    := Select()
DbSetOrder(1) &&ArtNr
DbTotal( AuswertDrive+WebDbf, {|| ArtNr }, aFieldNames, {|| Lagstand > 0} )
DbCloseArea()

OpenDb(AuswertDrive, WebDbf, {},{} )
oProgress:maximum := Lastrec()*2
ProgressStep := Lastrec()/5
IF nHandle == -1
   MsgBox("Fehler beim Erzeugen der Export Datei","SendLagToWeb()" )
   Return .f.
Endif

nFields    := FCount()
aStructure := DbStruct()
Do While !Eof()
   cString    := ""
   For i:= 1 to nFields
      xVal := FieldGet(i)
      fLen := aStructure[i][3]

      Do Case
         Case  aStructure[i][2] == "C"
            xVal := '"' + Alltrim( xVal ) + '"'
         Case  aStructure[i][2] == "D"
            xVal := dTos( xVal )
         Case  aStructure[i][2] == "N"
            xVal := Str( xVal )
         Case  aStructure[i][2] == "M"
            xVal := '"' + Alltrim( xVal ) + '"'
      EndCase
      xVal := Alltrim( xVal )
      cString := cString + xVal + iif(i < nFields, ',', '')
   next
   FWrite( nHandle, cString + Chr(13)+Chr(10) )
   FSkip(1)
   oProgress:Increment()
Enddo
FClose( nHandle )
DbCloseArea()
FErase(AuswertDrive + WebDbf )

oDialog:settitle("Internetmodul öffnen...")
iHandle   := InternetOpen()
oProgress:Increment(ProgressStep)

if iHandle == 0
   FTPActivate := "0"
   MsgBox("Das Internetmodul konnte nicht geöffnet werden. "+WebTxt + " in " + AuswertDrive + " von Hand kopieren", "SendLagToWeb()")
else
   oDialog:settitle("FTP Anmeldung...")
   FTPHandle := FTPOpen(iHandle, FTPServerName, FTPUserName, FTPPassWord )
   oProgress:Increment(ProgressStep)

   if FtpHandle == 0
      FTPActivate := "0"
      MsgBox("Die FTP Verbindung konnte nicht geöffnet werden. "+WebTxt + " in " + AuswertDrive + " von Hand kopieren", "SendLagToWeb()")
   else
      oDialog:settitle("Daten an FTP senden...")
      FTPCopy   := FTPCopy(FtpHandle, AuswertDrive + WebTxt, cTargetFile)
      oProgress:Increment(ProgressStep)

      if FtpCopy == 0
         MsgBox("Die Datei "+ WebTxt + " in " + AuswertDrive + " konnte nicht kopiert werden. Datei von Hand kopieren", "SendLagToWeb()")
      else
         oDialog:settitle("Update Programm starten...")
         HttpOpen  := HTTPOpen(iHandle, FTPUpdateCommand )
         oProgress:Increment(ProgressStep)
         if HttpOpen == 0
            MsgBox("Der Update konnte nicht gestartet werden. Update Routine manuell ausführen", "SendLagToWeb()")
         endif
      endif
   endif
   oProgress:Increment(ProgressStep)
   sleep(200)
   iClose    := InternetClose(iHandle)
   if iClose == 0
      MsgBox("Der Internethandle konnte nicht freigegeben werden.", "SendLagToWeb()")
   endif
endif

oProgress:Destroy()
oDialog:Destroy()
Return .t.


FUNCTION BackupToFTP()
*----------------------

LOCAL oProgress
LOCAL aProgrPos
LOCAL aProgrSize
LOCAL oDialog
LOCAL aSize := {300,100}
LOCAL aPos := {AppDeskTop():CurrentSize()[1]-320,45}
LOCAL LocalBackupFile   := FTPBackupLocalFile
LOCAL RemoteBackupFile  := FTPBackupRemoteFile
LOCAL i           := 1

LOCAL IHandle
LOCAL FtpHandle
LOCAL FTPCopy
LOCAL HttpOpen
LOCAL IClose
LOCAL ProgressStep := 1
LOCAL aSystemFile := {}
LOCAL aStructure  := {}
LOCAL DbtFile

oDialog           := XbpDialog():new( AppDeskTop(), , aPos, aSize, , .F.)
oDialog:taskList  := .F.
oDialog:sysMenu   := .F.
oDialog:minButton := .F.
oDialog:maxButton := .F.
oDialog:title     := "Backup to FTP"
oDialog:border    := 2 &&XBPDLG_SIZEBORDER
oDialog:create()
oDialog:toBack()
oDialog:show()
*SetAppFocus(oDialog)

aProgrPos  := {4, 10 }
aProgrSize := {280, 10 }

oProgress         := ProgressBar():new( oDialog ,, aProgrPos,  aProgrSize)
oProgress:create()
oProgress:minimum := 1
oProgress:maximum := 25*2
ProgressStep      := 25/5
oProgress:color   := GRA_CLR_BLUE

* Datenbanken in sep Verzeichnis sichern, zb $....
*aAdd( aSystemFile, HistoryFile )
aAdd( aSystemFile, TabellenFile )
*aAdd( aSystemFile, LagerFile )
*aAdd( aSystemFile, ArtikelFile )
*aAdd( aSystemFile, StkListenFile )
aAdd( aSystemFile, KundenFile )
*aAdd( aSystemFile, FakturaFile )
*aAdd( aSystemFile, FakturaDetFile )
aAdd( aSystemFile, BewegungsFile )
*aAdd( aSystemFile, PreisFile )
*aAdd( aSystemFile, RahmenNrFile )
*aAdd( aSystemFile, FremdBikeFile )
*aAdd( aSystemFile, LieferantenFile )
aAdd( aSystemFile, PlzFile )
aAdd( aSystemFile, ReportFile )
*aAdd( aSystemFile, KonditionFile )
*aAdd( aSystemFile, KassenFile )
*aAdd( aSystemFile, DispositionFile )
*aAdd( aSystemFile, OrderFile )
*aAdd( aSystemFile, OrderDetFile )
*aAdd( aSystemFile, OrderSysFile )
*aAdd( aSystemFile, BlackFile )
*aAdd( aSystemFile, LagCostFile )
*aAdd( aSystemFile, TrspCostFile )
aAdd( aSystemFile, SystemFile )

For i:= 1 to len(aSystemFile)
   oDialog:settitle("FTP Backup vorbereiten " + aSystemFile[i])
   oProgress:Increment(1)
   OpenDb(DataDrive, aSystemFile[i] ,{} ,{}, , .f. )
   aStructure := DbStruct()
   DbCreate( RemoteDrive + "$" + aSystemFile[i], aStructure )
   DbCloseArea()
   OpenDb(RemoteDrive, "$" + aSystemFile[i],{} ,{}, , .f. )
   Append From &(DataDrive + aSystemFile[i])
   DbCloseArea()
Next

* Datenbanken umbenennen

For i:= 1 to len(aSystemFile)
   DbtFile :=  iif( Rat(".", aSystemFile[i]) >0, Left(aSystemFile[i], Rat(".", aSystemFile[i])-1 ), aSystemFile[i] ) + ".Dbt"
   if FRename( RemoteDrive + "$" + aSystemFile[i], RemoteDrive+ aSystemFile[i] ) == 0
      if File(RemoteDrive + "$" + DbtFile)
         if FRename( RemoteDrive + "$" + DbtFile, RemoteDrive+ DbtFile ) == 0
            ERASE (RemoteDrive + "$" + DbtFile)
         Endif
      Endif
      ERASE (RemoteDrive + "$" + aSystemFile[i])
   Endif
Next

* Datenbanken Zippen

oDialog:settitle("FTP Backup Daten zippen" )
if SaveData("MGData.LST", "MGData.Zip", .t.)

* Backup DBF's löschen

For i:= 1 to len(aSystemFile)
   DbtFile :=  iif( Rat(".", aSystemFile[i]) >0, Left(aSystemFile[i], Rat(".", aSystemFile[i])-1 ), aSystemFile[i] ) + ".Dbt"
   ERASE (RemoteDrive + DbtFile)
   ERASE (RemoteDrive + aSystemFile[i])
Next

* Zip an FTP senden.

   oDialog:settitle("Internetmodul öffnen...")
   iHandle   := InternetOpen()
   oProgress:Increment(ProgressStep)

   if iHandle == 0
      FTPActivate := "0"
      MsgBox("Das Internetmodul konnte nicht geöffnet werden. "+WebTxt + " in " + AuswertDrive + " von Hand kopieren", "BackupToFTP()")
   else
      oDialog:settitle("FTP Anmeldung...")
      FTPHandle := FTPOpen(iHandle, FTPServerName, FTPUserName, FTPPassWord )
      oProgress:Increment(ProgressStep)

      if FtpHandle == 0
         FTPActivate := "0"
         MsgBox("Die FTP Verbindung konnte nicht geöffnet werden. "+LocalBackupFile + " in " + AuswertDrive + " von Hand kopieren", "BackupToFTP()")
      else
         oDialog:settitle("Daten an FTP senden...")
         FTPCopy   := FTPCopy(FtpHandle, AuswertDrive + LocalBackupFile, RemoteBackupFile)
         oProgress:Increment(ProgressStep)

      endif

      oProgress:Increment(ProgressStep)
      sleep(200)
      iClose    := InternetClose(iHandle)
      if iClose == 0
         MsgBox("Der Internethandle konnte nicht freigegeben werden.", "BackupToFTP()")
      endif
   endif
endif

oProgress:Destroy()
oDialog:Destroy()
Return .t.



FUNCTION RestoreFromFTP()
*------------------------

LOCAL oProgress
LOCAL aProgrPos
LOCAL aProgrSize
LOCAL oDialog
LOCAL aSize := {300,100}
LOCAL aPos := {AppDeskTop():CurrentSize()[1]-320,45}
LOCAL LocalBackupFile   := FTPBackupLocalFile
LOCAL RemoteBackupFile  := FTPBackupRemoteFile
LOCAL i           := 1

LOCAL IHandle
LOCAL FtpHandle
LOCAL FTPCopy
LOCAL HttpOpen
LOCAL IClose
LOCAL ProgressStep := 1
LOCAL aSystemFile := {}
LOCAL aStructure  := {}
LOCAL DbtFile
LOCAL FTPSuccess := .t.

oDialog           := XbpDialog():new( AppDeskTop(), , aPos, aSize, , .F.)
oDialog:taskList  := .F.
oDialog:sysMenu   := .F.
oDialog:minButton := .F.
oDialog:maxButton := .F.
oDialog:title     := "Restore from FTP"
oDialog:border    := 2 &&XBPDLG_SIZEBORDER
oDialog:create()
oDialog:toBack()
oDialog:show()
*SetAppFocus(oDialog)

aProgrPos  := {4, 10 }
aProgrSize := {280, 10 }

oProgress         := ProgressBar():new( oDialog ,, aProgrPos,  aProgrSize)
oProgress:create()
oProgress:minimum := 1
oProgress:maximum := 25*2
ProgressStep      := 25/5
oProgress:color   := GRA_CLR_BLUE


* Zip von FTP senden.

   oDialog:settitle("Internetmodul öffnen...")
   iHandle   := InternetOpen()
   oProgress:Increment(ProgressStep)

   if iHandle == 0
      FTPActivate := "0"
      FTPSuccess := .f.
      MsgBox("Das Internetmodul konnte nicht geöffnet werden.", "RestoreFromFTP()")
   else
      oDialog:settitle("FTP Anmeldung...")
      FTPHandle := FTPOpen(iHandle, FTPServerName, FTPUserName, FTPPassWord )
      oProgress:Increment(ProgressStep)

      if FtpHandle == 0
         FTPActivate := "0"
         FTPSuccess := .f.
         MsgBox("Die FTP Verbindung konnte nicht geöffnet werden.","RestoreFromFTP()")
      else
         oDialog:settitle("Daten von FTP holen...")

         FTPCopy := FTPGetFile(FtpHandle, AuswertDrive + LocalBackupFile, RemoteBackupFile)

         *FTPCopy   := FTPCopy(FtpHandle, RemoteBackupFile, AuswertDrive + LocalBackupFile)
         if FTPCopy == 1
            oProgress:Increment(ProgressStep)
            oDialog:settitle("Daten zurückladen")
            RestoreData(AuswertDrive + LocalBackupFile)
         else
            MsgBox("Der Backup konnte nicht übertragen werden.","RestoreFromFTP()")
            FTPSuccess := .f.
         endif
      endif

      oProgress:Increment(ProgressStep)
      sleep(200)
      iClose    := InternetClose(iHandle)
      if iClose == 0
         MsgBox("Der Internethandle konnte nicht freigegeben werden.", "RestoreFromFTP()")
      endif
   endif


oProgress:Destroy()
oDialog:Destroy()
Return FTPSuccess



FUNCTION AddForm( hPrinter, pForm )
*----------------------------------
LOCAL RetVal
RetVal := DllCall("winspool.drv", DLL_STDCALL, "AddFormA", hPrinter, 1, pForm)
Return iif( Retval == 0, .f., .t.)


FUNCTION OpenPrinter( cPrinterName, phPrinter )
LOCAL pDefault  := NIL
RetVal := DllCall("winspool.drv", DLL_STDCALL, "OpenPrinterA", cPrinterName, @phPrinter, pDefault)
Return iif( RetVal == 0, .f., .t.)


FUNCTION ClosePrinter( nPrinterHandle )
LOCAL Retval
RetVal := DllCall("winspool.drv", DLL_STDCALL, "ClosePrinterA", nPrinterHandle )
Return iif( Retval == 0, .f., .t.)


FUNCTION GetForm( hPrinter, cFormName )
LOCAL pForm := Array(4)
LOCAL n     := 1
LOCAL i     := 0
LOCAL x := 0
*x := DllCall("winspool.drv", DLL_STDCALL, "GetFormA", hPrinter, cFormName, 1, @pForm, n, @i   )
Return pForm


FUNCTION CheckForms(cPrinterName, FormName)
LOCAL oPrinter := NewPrinter("Test.cfg")
LOCAL PrinterHandle := oPrinter:getHDC()
LOCAL pForm

pForm  := GetForm( PrinterHandle, FormName)

If len( pForm ) == 0
   pForm := {2, FormName, {105000,148500}, {105000,148500} }
   AddForm( PrinterHandle, pForm )
endif

Return .t.



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