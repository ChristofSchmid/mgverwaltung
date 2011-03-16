*********************************************************************
* ZLager 15.5.2001
*********************************************************************

*-----------
*Init
*-----------
#pragma library( "ascom10.lib" )

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
#include "THREAD.CH"

#include "outlook.ch"


/*
 * Main Prozedur und Event-Loop
 */

PROCEDURE Main
   LOCAL nEvent, mp1, mp2, oXbp, x
   LOCAL aWinInit  := {}
   LOCAL aScrInit  := {}
   LOCAL aDBInit   := {}
   LOCAL aCustInit := {}
   *StandartWerte
   LOCAL acPublics := SetStdSysPublVar()
   *Standart zur Anpassung
   LOCAL aPublics  := SetStdSysPublVar()
   LOCAL aKids
   LOCAL FVar, FVal, i
   LOCAL aPos, aSize, aCustScr, nCustScr
   LOCAL cIndex, cKey
   LOCAL bBlock


   PUBLIC WebThread    := Thread():new()
   PUBLIC BackupThread := Thread():new()
   PUBLIC SysDbTries   := 0




   SET DELETED ON
   SET CHARSET TO ansi
   SET DATE FORMAT TO "dd.mm.yyyy"



InitSysMem(acPublics) && Standard

if Len( LoadInit(@aWinInit, "initwin.ctr") ) == 0
   MsgBox("Die System Datei InitWin.ctr konnte nicht gefunden werden, Standart Werte werden eingesetzt.")
Endif

if Len( LoadInit(@aDbInit, "initDB.ctr") ) == 0
   MsgBox("Die System Datei InitDB.ctr konnte nicht gefunden werden, Standart Werte werden eingesetzt.")
Endif

if Len( LoadInit(@aScrInit, "initScreen.ctr") ) == 0
   MsgBox("Die System Datei InitScreen.ctr konnte nicht gefunden werden, Standart Werte werden eingesetzt.")
Endif

* Anpassung an ctr's
aPublics := UpdatePublics(aPublics, aWinInit)
aPublics := UpdatePublics(aPublics, aScrInit)
aPublics := UpdatePublics(aPublics, aDbInit)

if !Len( LoadInit(@aCustInit, "MGSystem.ctr") ) == 0
   aPublics := UpdatePublics(aPublics, aCustInit)
endif
*WriteInit("Cas.ctr", aPublics )

InitSysMem(aPublics)

*-------------------
* Daten Definitionen
*-------------------

PUBLIC TimeOut         := {0,0}
PUBLIC ReorgActive     := .f.


PUBLIC KundenFile     := "MGDeb01.dbf"
PUBLIC KundenIndex    := {"IDeb01.NTX","IDeb02.NTX","IDeb03.NTX","IDeb04.NTX","IDeb05.NTX", "IDeb06.NTX", "IDeb07.NTX" }
PUBLIC KundenKey      := {"DebNr","Upper(Matchcode)","Upper(Name )", "Upper( DebIndexExpr( Name, 2) )", "Upper( DebIndexExpr( Name, 3 ) )", "Upper( DebIndexExpr( Name, 4 ))", "Upper( DebIndexExpr( Name, 5 ))"}

PUBLIC BewegungsFile   := "MGLog01.dbf"
PUBLIC BewegungsIndex  := {"ILog011.NTX","ILog012.NTX"}
PUBLIC BewegungsKey    := {"DebNr","Dtos(MutDat)" }

PUBLIC TabellenFile    := "MGTab01.dbf"
PUBLIC TabellenIndex   := {"ITab01.NTX"}
PUBLIC TabellenKey     := {"TabCode"}

PUBLIC PlzFile         := "MGPlz01.dbf"
PUBLIC PlzIndex        := {"IPlz01.NTX", "IPlz02.NTX"}
PUBLIC PlzKey          := {"Upper(PlzOrt)","Upper(Ort)"}

PUBLIC ReportFile      := "MGRep01.dbf"
PUBLIC ReportIndex     := {"IRep01.NTX"}
PUBLIC ReportKey       := {"ReportId"}

PUBLIC SystemFile      := "MGSys01.dbf"
PUBLIC SystemIndex     := {"ISys01.NTX","ISys02.NTX" }
PUBLIC SystemKey       := {"Task + Client + Open","Task + TaskName + Client" }

CustomScreen(RestoreScreen())

if File( DataDrive + "MGInReorg.SYS" )
   MsgBox("Daten werden reorganisiert","Dateien Check")
   CLOSE ALL
   QUIT
endif


*ArtikelFile, LieferantenFile, KundenFile, LagerFile, BewegungsFile, TabellenFile, PlzFile, StkListenFile, ReportFile, FakturaFile, FakturaDetFile, PreisFile, KonditionFile, KassenFile, RahmenNrFile, DispositionFile, OrderFile, OrderDetFile, OrderSysFile, HistoryFile, BlackFile


   IF !AllFilesExist( DataDrive, { KundenFile, BewegungsFile, TabellenFile, PlzFile, ReportFile, SystemFile } )
      Quit
   ENDIF

   If File(DataDrive + MemFile)
      RestoreMem()
   else
      SaveMem()
   Endif

   OpenDb(DataDrive, SystemFile, SystemIndex, SystemKey, .t., .f.)
   SysAlias( Select() )
   DbRelease( SysAlias() )


   * Versuch crash zu verhindern? 3.12.2002 1820
   *DbeInfo(COMPONENT_DATA,DBFDBE_LOCKRETRY,100)
   *DbeInfo(COMPONENT_DATA,DBFDBE_LOCKDELAY,10)
   *DbeInfo(COMPONENT_ORDER,NTXDBE_LOCKRETRY,100)
   *DbeInfo(COMPONENT_ORDER,NTXDBE_LOCKDELAY,10)


   if File(Maindrive + "CustomScreen.xpf")
      if !( CustomScreen()[4][1][1] == AppDeskTop():currentSize()[1] .and. CustomScreen()[4][1][2] == AppDeskTop():currentSize()[2] )
         MsgBox("Die Auflösung wurde geändert. Custom Screens werden zurückgesetzt.", "Startup()")
         CustomScreen( {{},{},{},{}} )
         aCustScr := CustomScreen()
         aAdd( aCustScr[1], Subs( RootWindow():getTitle(),1,10))
         aAdd( aCustScr[2], RootWindow():CurrentPos()  )
         aAdd( aCustScr[3], RootWindow():CurrentSize() )
         aAdd( aCustScr[4],  AppDeskTop():currentSize() )
         CustomScreen(aCustScr)
      else
         RestoreDialogPosAndSize(RootWindow())
      endif
   else
      aCustScr := CustomScreen()
      aAdd( aCustScr[1], Subs( RootWindow():getTitle(),1,10))
      aAdd( aCustScr[2], RootWindow():CurrentPos()  )
      aAdd( aCustScr[3], RootWindow():CurrentSize() )
      aAdd( aCustScr[4],  AppDeskTop():currentSize() )
      CustomScreen(aCustScr)
   Endif

   WebThread:setInterval(val(FTPIntervall)*6000)
   WebThread:setPriority( PRIORITY_BELOWNORMAL )
   WebThread:start( "RunSendLagToWeb" )


   BackupThread:setInterval(val(FTPBackupIntervall)*6000)
   BackUpThread:setPriority( PRIORITY_BELOWNORMAL )
   BackupThread:start( "RunBackupToFTP" )


   RegisterNetworkParts( RootWindow() )
   RootWindow():Show()
   UpdateInProgress(.f.)
   SetAppEvent( MP_UPDATEREQUEST, {|mp1, mp2, oXbp| LookForDataChanges() } )
   SetTimerEvent( Val( AppRefreshRate ), {|| PostAppEvent( MP_UPDATEREQUEST, , , RootWindow() ) } )

Do While .t.

   Begin Sequence

   SET DELETED ON
   SET CHARSET TO ansi
   SET DATE FORMAT TO "dd.mm.yyyy"


   DO WHILE .T.
      nEvent := AppEvent( @mp1, @mp2, @oXbp )

      *5.8.2005
      if SysDbTries == 0
         CheckEvent(nEvent)
      else
         if SysDbTries > 2
            DbCloseAll()
            Quit
         endif
      endif

      oXbp:handleEvent( nEvent, mp1, mp2 )
   ENDDO

   Recover
   *   aKids := Rootwindow():ChildList()

   end Sequence

Enddo


RETURN


PROCEDURE AppSys
   LOCAL oDlg, oXbp, aPos[2], aSize[2], ScrSize
   LOCAL DrawingArea
   LOCAL pBSize
   LOCAL pBPos  := {,}
   LOCAL pBElements
   LOCAL i
   LOCAL pBvPos   := 10
   LOCAL pBhPos   := 10
   LOCAL aButtons := {}
   LOCAL oStatic
   LOCAL nElement := 1
   LOCAL Obj
   LOCAL aPP := { { XBP_PP_FGCLR       , GRA_CLR_BLACK         }, ;
                  { XBP_PP_BGCLR       , GRA_CLR_YELLOW        }  }


   // Gr”áe vom DeskTop feststellen
   // und Anwendungsfenster dimensionieren
   aSize    := AppDeskTop():currentSize()
   ScrSize  := AppDeskTop():currentSize()

   *aSize[1] *= 0.95
   aSize[1] *= 0.4
   aSize[2] := 145

   aPos[1]  := ( ScrSize[1] / 2) - (aSize[1] / 2)
   aPos[2]  := ( ScrSize[2] - aSize[2] - 12 )


   // Anwendungsfenster erzeugen (application window)
   oDlg       := XbpDialog():new( ,, aPos, aSize,, .F. )
   oDlg:title := "MG Verwaltung 1.0"
*   oDlg:icon  := ICON_APPLICATION
   oDlg:close := {|| AppQuit(.f.) }
   oDlg:taskList := .T.
   *oDlg:sysMenu   := .F.
   oDlg:minButton := .F.
   oDlg:maxButton := .F.

   oDlg:icon := MGGOSSAU
   *oDlg:Resize := {| aOldSize, aNewSize, obj | ResizeDataDialog(obj, aOldSize, aNewSize, GetChildList(Obj) ) }
   oDlg:resize := {| aOldSize, aNewSize, Obj | ZResize(aNewSize, aButtons, @pBPos, {67,67}, aNewSize[2] - 135 ) }
   oDlg:drawingArea:motion := {| aPos, uNIL, SELF | MouseMsg("", @oStatic, aPos, SELF, pBPos , @nElement, 0 )}
   oDlg:create()
   oDlg:drawingArea:SetColorBG( XBPSYSCLR_APPWORKSPACE )

   SetAppWindow( oDlg )

   DrawingArea := oDlg

   // Hauptmen systemweit abrufbar machen (UDF)
   AppMenu( oDlg:menuBar() )

   // Mensystem erzeugen (UDF)
   MenuCreate( AppMenu() )



   // Direktzugriff Laden

*BITMAP     501 = "ICONS\ARTIKELSTAMM.BMP"        //
*BITMAP     502 = "ICONS\KUNDENSTAMM.BMP"        //
*BITMAP     503 = "ICONS\LIEFERANTENSTAMM.BMP"        //
*BITMAP     504 = "ICONS\RECHNUNG.BMP"        //
*BITMAP     505 = "ICONS\KASSE.BMP"        //
*BITMAP     506 = "ICONS\WERKSTATT.BMP"        //
*BITMAP     507 = "ICONS\STATISTIK.BMP"        //
*BITMAP     508 = "ICONS\LAGERINFO.BMP"        //
*BITMAP     509 = "ICONS\LAGER.BMP"        //
*BITMAP     510 = "ICONS\INVENTAR.BMP"        //

   pBSize     := {67,67}
   pBElements := 6
   pBhPos     := 0   &&aSize[2] - 55 - pBSize[2]

   pBvPos     := 0 &&( aSize[1] - ( pBElements * pBSize[1]) ) / (pBElements  + 1)
   For i:= 1 to pBElements
     aAdd( pBPos, {0, pBhPos })
   Next

   oStatic := XbpStatic():new( drawingArea, , , , aPP, )
   oStatic:clipSiblings := .T.
   oStatic:motion  := {| aPos, uNIL, SELF | MouseMsg("", @oStatic, aPos, SELF, pBPos , @nElement, 0 )}
   oStatic:options := XBPSTATIC_TEXT_VCENTER + XBPSTATIC_TEXT_CENTER
   oStatic:create()
   oStatic:hide()

*   oXbp := XbpPushButton():new( drawingArea, , pBPos[1], pBSize, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
*   oXbp:caption := 501
*   oXbp:tabStop := .T.
*   oXbp:motion := {| aPos, uNIL, Obj | MouseMsg("Artikelstamm", oStatic, aPos, Obj, pBPos, @nElement, 1 )}
*   oXbp:create()
*   oxbp:hide()
*   oXbp:activate := {|| ZARTIKEL() }
*   aAdd(aButtons, oXbp)

   oXbp := XbpPushButton():new( drawingArea, , pBPos[1], pBSize, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := 501
   oXbp:tabStop := .T.
   oXbp:motion := {| aPos, uNIL, Obj | MouseMsg("Mitglieder" ,oStatic,aPos, Obj, pBPos, @nElement, 1 )}
   oXbp:create()
   oxbp:hide()
   oXbp:activate := {|| ZKUNDEN(KUNDEN) }
    aAdd(aButtons, oXbp)

   oXbp := XbpPushButton():new( drawingArea, , pBPos[2], pBSize, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := 502
   oXbp:tabStop := .T.
   oXbp:motion := {| aPos, uNIL, Obj | MouseMsg("Listen drucken" ,oStatic,aPos, Obj, pBPos, @nElement, 2 )}
   oXbp:create()
   oxbp:hide()
   oXbp:activate := {|| ZForms() }
   aAdd(aButtons, oXbp)


   oXbp := XbpPushButton():new( drawingArea, , pBPos[3], pBSize, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := 503
   oXbp:motion := {| aPos, uNIL, Obj | MouseMsg("EMail versenden" ,oStatic,aPos, Obj, pBPos, @nElement, 3 )}
   oXbp:tabStop := .T.
   oXbp:create()
   oxbp:hide()
   oXbp:activate := {|| MailMerge() }
   aAdd(aButtons, oXbp)


   oXbp := XbpPushButton():new( drawingArea, , pBPos[4], pBSize, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := 504
   oXbp:motion := {| aPos, uNIL, Obj | MouseMsg("Tabellenstamm" ,oStatic,aPos, Obj, pBPos, @nElement, 4 )}
   oXbp:tabStop := .T.
   oXbp:create()
   oxbp:hide()
   oXbp:activate := {|| TabellenStamm() }
   aAdd(aButtons, oXbp)

   oXbp := XbpPushButton():new( drawingArea, , pBPos[5], pBSize, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := 505
   oXbp:motion := {| aPos, uNIL, Obj | MouseMsg("Programm Optionen" ,oStatic,aPos, Obj, pBPos, @nElement, 5 )}
   oXbp:tabStop := .T.
   oXbp:create()
   oxbp:hide()
   oXbp:activate := {|| ZAdminTask("SetAdvanced") }
   aAdd(aButtons, oXbp)

   oXbp := XbpPushButton():new( drawingArea, , pBPos[6], pBSize, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := 506
   oXbp:motion := {| aPos, uNIL, Obj | MouseMsg("Reorganisation" ,oStatic,aPos, Obj, pBPos, @nElement, 6 )}
   oXbp:tabStop := .T.
   oXbp:create()
   oxbp:hide()
   oXbp:activate := {|| ZReorg() }
   aAdd(aButtons, oXbp)


   *ZResize(aSize, aButtons, @pBPos, {70,70}, aSize[2] - 110 )

   SetAppFocus( oDlg )
   RootWindow( oDlg )

   *ZResize(aSize, aButtons, @pBPos, {50,50}, aSize[2] - 110 )

RETURN


/*
 * Routine zum Beenden eines Programms
 */
PROCEDURE AppQuit( QuitStatus )
   LOCAL i
   LOCAL nButton, oXbp := SetAppFocus()
   LOCAL activDialogs  := WinMenu():Stack()
   LOCAL lLastApp      := .f.

   QuitStatus := iif(QuitStatus == NIL, .f., QuitStatus)

   for i := 1 to len(activDialogs)
      SaveDialogPosAndSize( activDialogs[i] )
   next
   SaveDialogPosAndSize(RootWindow())
   SaveScreen(CustomScreen())

   if BackupToFTPallowed == "1"
      nButton := ConfirmBox( , ;
                    "Wollen Sie die Daten auf FTP sichern?", ;
                    "Sichern", ;
                    XBPMB_YESNO , ;
                    XBPMB_QUESTION+XBPMB_APPMODAL+XBPMB_MOVEABLE )

      IF nButton == XBPMB_RET_YES
         BackupToFTP()
      ENDIF
   Endif


   if QuitStatus
      nButton := ConfirmBox( , ;
                    "Wollen Sie das Programm beenden ?", ;
                    "Beenden", ;
                    XBPMB_YESNO , ;
                    XBPMB_QUESTION+XBPMB_APPMODAL+XBPMB_MOVEABLE )

      IF nButton == XBPMB_RET_YES

         Do while len( activDialogs) > 0
            UnRegisterNetworkParts( activDialogs[len(activDialogs)] )
            activDialogs[len(activDialogs)]:Close()
         enddo

         UnRegisterNetworkParts( RootWindow() )
         DbCloseAll()
         QUIT
      ENDIF
   else

      Do while len( activDialogs) > 0
         UnRegisterNetworkParts( activDialogs[len(activDialogs)] )
         activDialogs[len(activDialogs)]:Close()
      enddo

      UnRegisterNetworkParts( RootWindow() )
      DbCloseAll()
      QUIT
   ENDIF
   SetAppFocus( oXbp )
RETURN


*--------------------------------------------------------------
* CAS, Nur Zlager Main
*--------------------------------------------------------------

FUNCTION AllFilesExist( FileLocation, aFiles )
   LOCAL lExist := .T., i:=0, imax := Len(aFiles)
   LOCAL FileToTest
   DO WHILE ++i <= imax .AND. lExist
      FileToTest := FileLocation + aFiles[i]
      lExist := File( FileToTest )
   ENDDO
   If !lExist
      MsgBox("Die Datei " + FileToTest + " ist nicht vorhanden.", "AllFilesExist( FileLocation, aFiles )")
   endif
RETURN lExist


FUNCTION AppMenu( oMenu )
   STATIC soMenuBar
   IF PCount() > 0
      soMenuBar := oMenu
   ENDIF
RETURN soMenuBar




FUNC MouseMsg(Text, oStatic, aPos, Obj, pbPos, nButt, Butt)
*---------------------------------------------------------
LOCAL StaticPos  := {0,0}
LOCAL StaticSize := {0,0}
LOCAL aPoints

if Butt == 0
   oStatic:hide()
   nButt := 0
   Return .t.
Endif

if Butt == nButt
   Return .t.
Endif


aPoints    := GraQueryTextBox( Obj:LockPs() , Text )
Obj:UnlockPS()

StaticSize[1] := aPoints[3][1] - aPoints[1][1]
StaticSize[1] := StaticSize[1] * 1.2
StaticSize[2] := 12

StaticPos[1] := pBPos[Butt][1]+aPos[1] - (  StaticSize[1] /2 )
StaticPos[2] := pBPos[Butt][2]+aPos[2] - 20

if  StaticPos[1] < 10 && am linken Rand
    StaticPos[1] := pBPos[Butt][1]+aPos[1]
Endif


oStatic:Configure( , , StaticPos, StaticSize )
oStatic:SetCaption(Text)
oStatic:Show()

nButt := butt

Return .t.