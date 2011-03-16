*********************************************************************
* ZSystem 10.8.2002 (AdminTask)
*********************************************************************
#include "Gra.ch"
#include "Xbp.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "DMLB.ch"
#include "MGV.CH"
#include "Fileio.ch"




CLASS AdminTask FROM DataDialog
   EXPORTED:

     VAR aFileList
     VAR aInitData
     VAR ButtonControl
     VAR TabFocus
     VAR TabSelect
     VAR SysData
     VAR SysDataDet
     VAR SysDataMark
     VAR aSysDrive

     METHOD Create
     METHOD Close
     METHOD ChangeDeb
     METHOD FreeSysLog
     METHOD CloseNetApps
     METHOD ExecuteCloseNetApps

     METHOD SetupAdvanced
     METHOD AdvPage
     METHOD AdvPage1
     METHOD AdvPage2
     METHOD AdvPage3
     METHOD AdvPage4
     METHOD AdvPage5
     METHOD AdvRead
     METHOD AdvSave
     METHOD AdvSetTabs
     METHOD RegisterSysElement
     METHOD MoveVarToListbox
     METHOD LoadTabData
     METHOD GenMultiPublics
     METHOD GenSinglePublics
     METHOD SaveInit
     METHOD RestoreInit
     METHOD ValidDrive
     METHOD SelectDir


ENDCLASS


METHOD AdminTask:create( oParent, oOwner , ;
                          aPos   , aSize  , ;
                          aPParam, lVisible )

   ::DataDialog:create( oParent, oOwner , ;
                       aPos   , aSize  , ;
                       aPParam, lVisible )

   ::aFileList       := {}
   ::aInitData       := {}
   ::ButtonControl   := {{},{},{},{}}
   ::TabFocus        := NIL
   ::Tabselect       := 0
   ::SysData         := {}
   ::SysDataDet      := {}
   ::SysDataMark     := {}
   ::aSysDrive       := {}


RETURN self

METHOD AdminTask:Close()
*-----------------------
LOCAL i
for i := 1 to len(::aArea)
   if !::aArea[i] == NIL
      Select( ::aArea[i] )
      if Used()
         DbCloseArea()
      endif
   endif
Next

   ::DataDialog:Close()
   ::Destroy()
RETURN self



PROCEDURE ZAdminTask(cAppRequest)
*----------------------------
   LOCAL nEvent, mp1, mp2
   LOCAL DrawingArea
   LOCAL oDlg
   LOCAL cClient     := ""

   aSize       := DialogSize()
   aPos        := DialogPos()

   if cAppRequest == NIL
      Return
   endif

*   aAdd(oDlg:aFileList, {ArtikelFile, ArtikelIndex, ArtikelKey} )
*   aAdd(oDlg:aFileList, {LieferantenFile, LieferantenIndex, LieferantenKey} )
*   aAdd(oDlg:aFileList, {KundenFile, KundenIndex, KundenKey} )
*   aAdd(oDlg:aFileList, {BewegungsFile, BewegungsIndex, BewegungsKey} )
*   aAdd(oDlg:aFileList, {TabellenFile, TabellenIndex, TabellenKey} )
*   aAdd(oDlg:aFileList, {StkListenFile, StkListenIndex, StkListenKey} )
*   aAdd(oDlg:aFileList, {ReportFile, ReportIndex, ReportKey} )
*   aAdd(oDlg:aFileList, {FakturaFile, FakturaIndex, FakturaKey} )
*   aAdd(oDlg:aFileList, {FakturaDetFile, FakturaDetIndex, FakturaDetKey} )
*   aAdd(oDlg:aFileList, {PreisFile, PreisIndex, PreisKey} )
*   aAdd(oDlg:aFileList, {KonditionFile, KonditionIndex, KonditionKey} )
*   aAdd(oDlg:aFileList, {KassenFile, KassenIndex, KassenKey} )
*   aAdd(oDlg:aFileList, {RahmenNrFile, RahmenNrIndex, RahmenNrKey} )
*   aAdd(oDlg:aFileList, {DispositionFile, DispositionIndex, DispositionKey} )
*   aAdd(oDlg:aFileList, {OrderFile, OrderIndex, OrderKey} )
*   aAdd(oDlg:aFileList, {OrderDetFile, OrderDetIndex, OrderDetKey} )
*   aAdd(oDlg:aFileList, {OrderSysFile, OrderSysIndex, OrderSysKey} )
*   aAdd(oDlg:aFileList, {PlzFile, PlzIndex, PlzKey} )
*   aAdd(oDlg:aFileList, {HistoryFile, HistoryIndex, HistoryKey} )
*   aAdd(oDlg:aFileList, {BlackFile, BlackIndex, BlackKey} )
*   aAdd(oDlg:aFileList, {LagCostFile, LagCostIndex, LagCostKey} )
*   aAdd(oDlg:aFileList, {TrspCostFile, TrspCostIndex, TrspCostKey} )
*   aAdd(oDlg:aFileList, {FremdBikeFile, FremdBikeIndex, FremdBikeKey} )
*   aAdd(oDlg:aFileList, {SystemFile, SystemIndex, SystemKey} )

   Do Case

      Case cAppRequest == "FreeLogAuto"
         oDlg := AdminTask():new( AppDesktop(), , aPos, aSize, , .F.)
         oDlg:taskList := .T.
         oDlg:title := "Administrator Tasks"
         oDlg:setDisplayFocus := {||    WinMenu():checkItem( oDlg, TEMP )}
         oDlg:KeyBoard        :=  {|nKey,x,obj| oDlg:ValidKey( nKey, obj ) }
         oDlg:create()

         DrawingArea := oDlg:DrawingArea
         drawingArea:setFontCompoundName( "8.Arial" )

         oDlg:windowMenu  := WinMenu()
         WinMenu():addItem( oDlg )
         WinMenu():checkItem( oDlg )
         oDlg:hide()
         oDlg:FreeSysLog(.t.)

      Case cAppRequest == "FreeLog"
         oDlg := AdminTask():new( AppDesktop(), , aPos, aSize, , .F.)
         oDlg:taskList := .T.
         oDlg:title := "Administrator Tasks"
         oDlg:setDisplayFocus := {||    WinMenu():checkItem( oDlg, TEMP )}
         oDlg:KeyBoard        :=  {|nKey,x,obj| oDlg:ValidKey( nKey, obj ) }
         oDlg:create()

         DrawingArea := oDlg:DrawingArea
         drawingArea:setFontCompoundName( "8.Arial" )

         oDlg:windowMenu  := WinMenu()
         WinMenu():addItem( oDlg )
         WinMenu():checkItem( oDlg )
         oDlg:show()
         oDlg:FreeSysLog(.f.)

      Case cAppRequest == "CloseNetApp"
         oDlg := AdminTask():new( AppDesktop(), , aPos, aSize, , .F.)
         oDlg:taskList := .T.
         oDlg:title := "Administrator Tasks -> MG Verwaltung Netzwerkweit schliessen"
         oDlg:setDisplayFocus := {||    WinMenu():checkItem( oDlg, TEMP )}
         oDlg:KeyBoard        :=  {|nKey,x,obj| oDlg:ValidKey( nKey, obj ) }
         oDlg:create()

         DrawingArea := oDlg:DrawingArea
         drawingArea:setFontCompoundName( "8.Arial" )
         oDlg:CloseNetApps(drawingArea)
         oDlg:windowMenu  := WinMenu()
         WinMenu():addItem( oDlg )
         WinMenu():checkItem( oDlg )
         SetAppFocus(oDlg)
         oDlg:show()
         Logon(oDlg,"Administrator")

      Case cAppRequest == "ReplaceDebNr"
         oDlg := AdminTask():new( AppDesktop(), , aPos, aSize, , .F.)
         oDlg:taskList := .T.
         oDlg:title := "Administrator Tasks"
         oDlg:setDisplayFocus := {||    WinMenu():checkItem( oDlg, TEMP )}
         oDlg:KeyBoard        :=  {|nKey,x,obj| oDlg:ValidKey( nKey, obj ) }
         oDlg:create()

         DrawingArea := oDlg:DrawingArea
         drawingArea:setFontCompoundName( "8.Arial" )

         oDlg:windowMenu  := WinMenu()
         WinMenu():addItem( oDlg )
         WinMenu():checkItem( oDlg )
         oDlg:show()
         oDlg:ChangeDeb()

      Case cAppRequest == "SetAdvanced"
         oDlg := AdminTask():new( AppDesktop(), , aPos, aSize, , .F.)
         oDlg:taskList := .T.
         oDlg:title := "Administrator Tasks"
         oDlg:setDisplayFocus := {||    WinMenu():checkItem( oDlg, TEMP )}
         oDlg:KeyBoard        :=  {|nKey,x,obj| oDlg:ValidKey( nKey, obj ) }
         oDlg:create()

         DrawingArea := oDlg:DrawingArea
         drawingArea:setFontCompoundName( "8.Arial" )

         oDlg:SetupAdvanced(DrawingArea)

         oDlg:windowMenu  := WinMenu()
         WinMenu():addItem( oDlg )
         WinMenu():checkItem( oDlg )
         oDlg:show()
         LogOn(oDlg, "Administrator")

   othe

      MsgBox("Ungültiger Aufruf", "AdminTask()")
   endcase
Return


METHOD AdminTask:CloseNetApps(DrawingArea)
*-----------------------------------------

LOCAL aSize, aPos[2]
LOCAL oXbp, oXbp1
LOCAL cText
LOCAL cSysAlias
LOCAL cClient := NetName()
LOCAL aTasks  := {}
LOCAL i

aSize    := Drawingarea:currentSize()

   cText := "Achtung, wenn Sie Ausführen wählen werden alle MG Verwaltungs Anwendungen ohne ;"   + ;
            "Rückfrage auf allen Arbeitsstationen im Netzwerk geschlossen. Begonnene Arbeiten ;"  + ;
            "werden gespeichert. ;"  + ;
            "Bitte stellen Sie sicher, dass Sie keine wichtigen Jobs für andere Benutzer abbrechen. ;"  + ;
            " ;" + ;
            "Diesen Task sollten Sie vorsichtig ausführen"

   oXbp := XbpStatic():new(drawingArea, ,{20 ,aSize[2] - 200}, {aSize[1]-40, 150 } )
   oXbp:options := XBPSTATIC_TEXT_VCENTER + XBPSTATIC_TEXT_LEFT + XBPSTATIC_TEXT_WORDBREAK
   oXbp:caption := StrTran( cText, ";", Chr(13) )
   oXbp:create()


   oXbp := XbpListBox():new( drawingArea, , {20 ,aSize[2] - 400}, {aSize[1]-40, 150 }, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:AddItem("Offene Tasks auf anderen Clients")
   if !SysDbRequest()
      MsgBox("Die System Datenbank konnte nicht angefordert werden.","FreeSysLog()" )
      PostAppEvent(xbeP_Close,,,SELF)
      return
   else
      cSysAlias := SysAlias()
      Select( cSysAlias )
      DbRefresh()
      if FileLock ( cSysAlias )
         DbGoTop()
         DbUnlock()
         Do While !eof()
            if (cSysAlias)->Open == "1" .and. !Alltrim( cClient ) == Alltrim( (cSysAlias)->Client )
               aAdd(aTasks, Alltrim( (cSysAlias)->Client ) + " -> " + Alltrim( (cSysAlias)->TaskName ) )
            endif
            fSkip(1)
         Enddo
      endif
      DbRelease( cSysAlias )
   endif

   aTasks := aSort( aTasks )
   for i:= 1 to len( aTasks)
       oXbp:AddItem( aTasks[i] )
   next

   oXbp := XbpPushButton():new( DrawingArea, , {12,12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Ausführen"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| ::ExecuteCloseNetApps() }
   ::RegisterElement(@oXbp, .f.,,,)


   oXbp := XbpPushButton():new( DrawingArea, , { aSize[1] - 96 , 12 }, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Beenden"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| PostAppEvent(xbeP_Close,,,SELF) }
   ::RegisterElement(@oXbp, .f.,,,)

RETURN



METHOD AdminTask:ExecuteCloseNetApps()
*-------------------------------------
LOCAL nButton
LOCAL cKey      := "MG Verwalt" + Space(5) + Alltrim( NetName() )
LOCAL cSysAlias := SysAlias()
   nButton := ConfirmBox( ,  "MG Verwaltung Netzwerkweit schliessen?", "AdminTask()", XBPMB_YESNO ,  XBPMB_QUESTION+XBPMB_APPMODAL+XBPMB_MOVEABLE )
   IF nButton == XBPMB_RET_YES
      SetAppFocus(SELF)
      SetUpdateRequest("CloseClient" , SELF )
      PostAppEvent(xbeP_Close,,,SELF)
   Else
      PostAppEvent(xbeP_Close,,,SELF)
   ENDIF
Return


METHOD AdminTask:FreeSysLog(lAuto)
*---------------------------------
LOCAL nButton
LOCAL cKey      := "MG Verwalt" + Space(5) + Alltrim( NetName() )
LOCAL cSysAlias := SysAlias()
lAuto := iif(lAuto == NIL, .f., lAuto)
   if !lAuto
      nButton := ConfirmBox( ,  "SystemFile zurücksetzen?", "AdminTask()", XBPMB_YESNO ,  XBPMB_QUESTION+XBPMB_APPMODAL+XBPMB_MOVEABLE )
   else
      nButton := XBPMB_RET_YES
   endif
   IF nButton == XBPMB_RET_YES
      SetAppFocus(SELF)

      if !SysDbRequest()
         MsgBox("Die System Datenbank konnte nicht angefordert werden.","FreeSysLog()" )
         PostAppEvent(xbeP_Close,,,SELF)
         return
      endif

      Select( cSysAlias )
      if FileLock ( cSysAlias )
         DbGoTop()
         DbUnlock()
         Do While !eof()
            if Reclock( Recno() )
               Replace Open with " "
               Replace Done with "1"
               DbrUnlock( Recno() )
            endif
            fSkip(1)
         Enddo

         if SysConnect( cKey ,1 )
            if Reclock( Recno() )
               Replace Open with "1"
               Replace Done with " "
               DbrUnlock( Recno() )
            endif
         endif

         DbRelease( cSysAlias )
         RegisterNetworkParts(SELF)
      endif
      PostAppEvent(xbeP_Close,,,SELF)
   Else
      PostAppEvent(xbeP_Close,,,SELF)
   ENDIF
Return

METHOD AdminTask:ChangeDeb()
*---------------------------

MsgBox("Task nicht verfügbar", "AdminTask()")
PostAppEvent(xbeP_Close,,,SELF)

Return


METHOD AdminTask:SetupAdvanced(DrawingArea)
*-------------------------------
   LOCAL TabWa
   ::Startup := .t.

   OpenDb(DataDrive, TabellenFile, TabellenIndex, TabellenKey)
   TabWa := Select()
   ::aArea[TABELLEN] := TabWa

   ::AdvPage(DrawingArea)
   ::AdvPage1(DrawingArea)
   ::AdvPage2(DrawingArea)
   ::AdvPage3(DrawingArea)
   ::AdvPage4(DrawingArea)
   ::AdvPage5(DrawingArea)
   ::AdvRead()
   ::Startup := .f.
   ::AdvSetTabs(1)
   SetAppFocus(SELF)

RETURN


METHOD AdminTask:AdvPage(DrawingArea)
*-------------------------
   LOCAL aSize, aPos[2]
   LOCAL oXbp, oXbp1
   aSize    := Drawingarea:currentSize()

   oXbp := XbpPushButton():new( DrawingArea, , {12,12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Sichern"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| ::SaveInit() }
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpPushButton():new( DrawingArea, , {96,12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Standard"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| ::RestoreInit() }
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpPushButton():new( DrawingArea, , { aSize[1] - 96 , 12 }, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Beenden"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| ::Close() }
   ::RegisterElement(@oXbp, .f.,,,)

RETURN

METHOD AdminTask:AdvPage1(DrawingArea)
*--------------------------------------

   LOCAL aSize, aPos[2]
   LOCAL oXbp, oXbp1, nSLE
   LOCAL DirSelected := ""
   aSize    := Drawingarea:currentSize()
   aPos[1]  := 12
   aPos[2]  := 48
   aSize[1] := aSize[1] - 24
   aSize[2] := aSize[2] - 24 -36

   ::bKillInputFocus := {| uNIL1, uNIL2, Obj |  ::ValidDrive(obj, 1) }

   oXbp1 := XbpTabPage():new( drawingArea, , aPos, aSize, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE } } )
   oXbp1:caption := "Installations Einstellungen"
   oXbp1:minimized  := .F.
   oXbp1:preOffset  := 0
   oXbp1:postOffset := 80
   oXbp1:tabStop := .T.
   oXbp1:tabActivate := {|| ::AdvSetTabs(1) }
   oXbp1:create()
   aAdd(::aTabs, oXbp1)

   oXbp := XbpStatic():new( oXbp1, , {12,384}, {156,24} )
   oXbp:caption := "Programm Verzeichnis:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {180,384}, {492,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 100
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( MainDrive ), MainDrive := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)
   aAdd(::aSysDrive, oXbp )

   oXbp := XbpPushButton():new( oXbp1, , {696,384}, {24,24}, { { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "..."
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {||  ::SelectDir( ::aSysDrive[1] , SELF ) }

   oXbp := XbpStatic():new( oXbp1, , {12,360}, {156,24} )
   oXbp:caption := "Daten Verzeichnis:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {180,360}, {492,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 100
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( DataDrive ), DataDrive := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)
   aAdd(::aSysDrive, oXbp )


   oXbp := XbpPushButton():new( oXbp1, , {696,360}, {24,24}, { { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "..."
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {||  ::SelectDir( ::aSysDrive[2] , SELF ) }

   oXbp := XbpStatic():new( oXbp1, , {12,336}, {156,24} )
   oXbp:caption := "Formular Verzeichnis:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {180,336}, {492,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 100
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( FormDrive ), FormDrive := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)
   aAdd(::aSysDrive, oXbp )

   oXbp := XbpPushButton():new( oXbp1, , {696,336}, {24,24}, { { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "..."
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {||  ::SelectDir( ::aSysDrive[3] , SELF ) }

   oXbp := XbpStatic():new( oXbp1, , {12,312}, {156,24} )
   oXbp:caption := "Auswertungs Verzeichnis:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {180,312}, {492,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 100
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( AuswertDrive ), AuswertDrive := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)
   aAdd(::aSysDrive, oXbp )


   oXbp := XbpPushButton():new( oXbp1, , {696,312}, {24,24}, { { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "..."
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {||  ::SelectDir( ::aSysDrive[4] , SELF ) }

   oXbp := XbpStatic():new( oXbp1, , {12,288}, {156,24} )
   oXbp:caption := "Dokumenten Verzeichnis:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {180,288}, {492,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 100
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( DocDrive ), DocDrive := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)
   aAdd(::aSysDrive, oXbp )


   oXbp := XbpPushButton():new( oXbp1, , {696,288}, {24,24}, { { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "..."
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {||  ::SelectDir( ::aSysDrive[5] , SELF ) }

   oXbp := XbpStatic():new( oXbp1, , {12,264}, {156,24} )
   oXbp:caption := "Datensicherungs Verzeichnis:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {180,264}, {492,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 100
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( DiscDrive ), DiscDrive := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)
   aAdd(::aSysDrive, oXbp )


   oXbp := XbpPushButton():new( oXbp1, , {696,264}, {24,24}, { { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "..."
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {||  ::SelectDir( ::aSysDrive[6] , SELF ) }

   oXbp := XbpStatic():new( oXbp1, , {12,240}, {156,24} )
   oXbp:caption := "Inventar Verzeichnis:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {180,240}, {492,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 100
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( InventarDrive ), InventarDrive := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)
   aAdd(::aSysDrive, oXbp )


   oXbp := XbpPushButton():new( oXbp1, , {696,240}, {24,24}, { { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "..."
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {||  ::SelectDir( ::aSysDrive[7] , SELF ) }

   oXbp := XbpStatic():new( oXbp1, , {12,216}, {156,24} )
   oXbp:caption := "Vergangenheits Verzeichnis:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {180,216}, {492,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 100
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( HistoryDrive ), HistoryDrive := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)
   aAdd(::aSysDrive, oXbp )


   oXbp := XbpPushButton():new( oXbp1, , {696,216}, {24,24}, { { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "..."
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {||  ::SelectDir( ::aSysDrive[8] , SELF ) }

   oXbp := XbpStatic():new( oXbp1, , {12,192}, {156,24} )
   oXbp:caption := "Datenimport Verzeichnis:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {180,192}, {492,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 100
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( ImportDrive ), ImportDrive := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)
   aAdd(::aSysDrive, oXbp )

   oXbp := XbpPushButton():new( oXbp1, , {696,192}, {24,24}, { { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "..."
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {||  ::SelectDir( ::aSysDrive[9] , SELF ) }

   oXbp := XbpStatic():new( oXbp1, , {12,156}, {156,24} )
   oXbp:caption := "Verkaufsstandort:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {180,96}, {216,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj),  SetTimerEvent( Val( AppRefreshRate ) )  }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterElement(@oXbp, .t.,"022",0, PosLoged, "PosLoged")

   oXbp := XbpStatic():new( oXbp1, , {12,132}, {156,24} )
   oXbp:caption := "Lager Code:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {180,72}, {216,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterElement(@oXbp, .t.,"004",0, PosLager, "PosLager" )

   oXbp := XbpStatic():new( oXbp1, , {12,108}, {156,24} )
   oXbp:caption := "Zentrallager Code:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {180,36}, {216,96}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterElement(@oXbp, .t.,"004",0, ZenLager, "ZenLager" )

   ::bKillInputFocus := {| uNIL1, uNIL2, Obj |  NIL }
RETURN


METHOD AdminTask:AdvPage2(DrawingArea)
*--------------------------------------
   LOCAL aSize, aPos[2]
   LOCAL oXbp, oXbp1
   aSize    := Drawingarea:currentSize()
   aPos[1]  := 12
   aPos[2]  := 48
   aSize[1] := aSize[1] - 24
   aSize[2] := aSize[2] - 24 -36


   oXbp1 := XbpTabPage():new( drawingArea, , aPos, aSize, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE } } )
   oXbp1:caption := "System Einstellungen 1"
   oXbp1:minimized := .T.
   oXbp1:preOffset := 20
   oXbp1:postOffset := 60
   oXbp1:tabActivate := {|| ::AdvSetTabs(2) }
   oXbp1:create()
   aAdd(::aTabs, oXbp1)

   oXbp := XbpStatic():new( oXbp1, , {24,396}, {204,24} )
   oXbp:caption := "Max Recs Dokument suchen:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {240,336}, {84,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "MaxDocRec" )

   oXbp := XbpStatic():new( oXbp1, , {24,372}, {204,24} )
   oXbp:caption := "Max Recs Dokument Mitglieder suchen:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {240,312}, {84,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "MaxDocDebRec" )

   oXbp := XbpStatic():new( oXbp1, , {24,348}, {204,24} )
   oXbp:caption := "Max Recs Mitglieder suchen:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {240,288}, {84,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "MaxDebRec" )

   oXbp := XbpStatic():new( oXbp1, , {24,324}, {204,24} )
   oXbp:caption := "Max Recs Lieferanten suchen:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {240,264}, {84,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "MaxKreRec" )

   oXbp := XbpStatic():new( oXbp1, , {24,300}, {204,24} )
   oXbp:caption := "Max Recs Artikel suchen:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {240,240}, {84,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "MaxArtRec" )

   oXbp := XbpStatic():new( oXbp1, , {24,276}, {204,24} )
   oXbp:caption := "Max Recs Bestellung suchen:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {240,216}, {84,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "MaxOrdRec" )

   oXbp := XbpStatic():new( oXbp1, , {24,252}, {204,24} )
   oXbp:caption := "Max Recs Bestellung Lieferanten suchen:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {240,192}, {84,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "MaxOrdKreRec" )

   oXbp := XbpStatic():new( oXbp1, , {24,228}, {204,24} )
   oXbp:caption := "Max Recs SDB suchen:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {240,168}, {84,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "MaxSDBTabRec" )

   oXbp := XbpStatic():new( oXbp1, , {24,204}, {204,24} )
   oXbp:caption := "Max Dispositions Einträge:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {240,144}, {84,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "MaxDisRec" )

   oXbp := XbpStatic():new( oXbp1, , {24,168}, {204,24} )
   oXbp:caption := "Standard Browser Breite:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {240,108}, {84,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "MaxCalcQbSize" )


   oXbp := XbpStatic():new( oXbp1, , {24,144}, {204,24} )
   oXbp:caption := "Letzte Fenstergrösse behalten:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {240,84}, {84,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "DialogResizeAtStartup" )

   oXbp := XbpStatic():new( oXbp1, , {24,120}, {204,24} )
   oXbp:caption := "Minimale Fenstergrösse (%):"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {240,60}, {84,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "DialogMinSize" )

   oXbp := XbpStatic():new( oXbp1, , {24,96}, {204,24} )
   oXbp:caption := "System Refreshrate (1/100s):"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {240,36}, {84,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "AppRefreshRate" )

   oXbp := XbpStatic():new( oXbp1, , {24,60}, {204,24} )
   oXbp:caption := "Stücklisten beim Start prüfen:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {240,0}, {84,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "CheckForStkList" )

   oXbp := XbpStatic():new( oXbp1, , {24,36}, {204,24} )
   oXbp:caption := "Standart MWSt Code:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {240,-24}, {84,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "StdMWStCode" )

   oXbp := XbpStatic():new( oXbp1, , {24,12}, {204,24} )
   oXbp:caption := "Eigene MWSt Nummer:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {240,12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 20
   oXbp:Align := XBPSLE_RIGHT
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( MWStNr ), MWStNr := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)

   oXbp := XbpStatic():new( oXbp1, , {384,396}, {180,24} )
   oXbp:caption := "Artikel Nummernkreis:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {576,396}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 14
   oXbp:Align := XBPSLE_RIGHT
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( DbArtNr ), DbArtNr := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)

   oXbp := XbpStatic():new( oXbp1, , {384,372}, {180,24} )
   oXbp:caption := "Mitglieder Nummernkreis:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {576,372}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 8
   oXbp:Align := XBPSLE_RIGHT
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( DbDebNr ), DbDebNr := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)

   oXbp := XbpStatic():new( oXbp1, , {384,348}, {180,24} )
   oXbp:caption := "Lieferanten Nummernkreis:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {576,348}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 8
   oXbp:Align := XBPSLE_RIGHT
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( DbKreNr ), DbKreNr := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)

   oXbp := XbpStatic():new( oXbp1, , {384,324}, {180,24} )
   oXbp:caption := "Dokumente Nummernkreis:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {576,324}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 8
   oXbp:Align := XBPSLE_RIGHT
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( DbDocNr ), DbDocNr := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)

   oXbp := XbpStatic():new( oXbp1, , {384,300}, {180,24} )
   oXbp:caption := "Disposition Nummernkreis:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {576,300}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 8
   oXbp:Align := XBPSLE_RIGHT
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( DbDisNr ), DbDisNr := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)

   oXbp := XbpStatic():new( oXbp1, , {384,276}, {180,24} )
   oXbp:caption := "Bestellung Nummernkreis:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {576,276}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 8
   oXbp:Align := XBPSLE_RIGHT
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( DbOrdNr ), DbOrdNr := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)

   oXbp := XbpStatic():new( oXbp1, , {384,252}, {180,24} )
   oXbp:caption := "Bikes Nummernkreis:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {576,252}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 8
   oXbp:Align := XBPSLE_RIGHT
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( DbBikNr ), DbBikNr := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)

   oXbp := XbpStatic():new( oXbp1, , {384,228}, {180,24} )
   oXbp:caption := "Lagerbuchung Nummernkreis:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {576,228}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 8
   oXbp:Align := XBPSLE_RIGHT
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( DbLagNr ), DbLagNr := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)

   oXbp := XbpStatic():new( oXbp1, , {384,204}, {180,24} )
   oXbp:caption := "Stücklisten Nummernkreis:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {576,204}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 8
   oXbp:Align := XBPSLE_RIGHT
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( DbLagNr ), DbLagNr := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)

   oXbp := XbpStatic():new( oXbp1, , {384,180}, {180,24} )
   oXbp:caption := "Artikelnummer Erster Service:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {576,180}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 14
   oXbp:Align := XBPSLE_RIGHT
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( FirstServiceArtNr ), FirstServiceArtNr := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( oXbp1, , {384,168-24}, {180,24} )
   oXbp:caption := "Artikel Startindex:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()


   oXbp := XbpCombobox():new( oXbp1, , {576,108-24}, {144,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "ArtikelStartIndexFlag" )

   oXbp := XbpStatic():new( oXbp1, , {384,144-24}, {180,24} )
   oXbp:caption := "Kunden Startindex"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()


   oXbp := XbpCombobox():new( oXbp1, , {576,84-24}, {144,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "KundenStartIndexFlag" )

   oXbp := XbpStatic():new( oXbp1, , {384,120-24}, {180,24} )
   oXbp:caption := "Lieferanten Startindex:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {576,60-24}, {144,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "KreditorStartIndexFlag" )

   oXbp := XbpStatic():new( oXbp1, , {384,96-24}, {180,24} )
   oXbp:caption := "Dokumente Startindex:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {576,36-24}, {144,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "DokumentStartIndexFlag" )

   oXbp := XbpStatic():new( oXbp1, , {384,96-24-24-6}, {180,24} )
   oXbp:caption := "Standart Lagereinheit:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {576,36-24-24-6}, {144,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "StdLEBezug" )
RETURN


METHOD AdminTask:AdvPage3(DrawingArea)
*--------------------------------------
   LOCAL aSize, aPos[2]
   LOCAL oXbp, oXbp1
   aSize    := Drawingarea:currentSize()
   aPos[1]  := 12
   aPos[2]  := 48
   aSize[1] := aSize[1] - 24
   aSize[2] := aSize[2] - 24 -36


   oXbp1 := XbpTabPage():new( drawingArea, , aPos, aSize, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE } } )
   oXbp1:caption := "System Einstellungen 2"
   oXbp1:minimized := .T.
   oXbp1:preOffset := 40
   oXbp1:postOffset := 40
   oXbp1:tabActivate := {|| ::AdvSetTabs(3) }
   oXbp1:create()
   aAdd(::aTabs, oXbp1)

   oXbp := XbpStatic():new( oXbp1, , {24,396}, {204,24} )
   oXbp:caption := "Rüstzettel Reservation drucken:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {240,336}, {84,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "ReservationRuestZettel" )

   oXbp := XbpStatic():new( oXbp1, , {24,372}, {204,24} )
   oXbp:caption := "Rüstzettel Testfahrt drucken:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {240,312}, {84,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "TestFahrtRuestZettel" )
RETURN


METHOD AdminTask:AdvPage4(DrawingArea)
*--------------------------------------
   LOCAL aSize, aPos[2]
   LOCAL oXbp, oXbp1
   LOCAL i
   LOCAL PubVar
   aSize    := Drawingarea:currentSize()
   aPos[1]  := 12
   aPos[2]  := 48
   aSize[1] := aSize[1] - 24
   aSize[2] := aSize[2] - 24 -36


   oXbp1 := XbpTabPage():new( drawingArea, , aPos, aSize, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE } } )
   oXbp1:caption := "Programm Einstellungen"
   oXbp1:minimized  := .T.
   oXbp1:preOffset  := 60
   oXbp1:postOffset := 20
   oXbp1:tabStop := .T.
   oXbp1:tabActivate := {|| ::AdvSetTabs(4) }
   oXbp1:create()
   aAdd(::aTabs, oXbp1)

   ::SysData     := {}
   ::SysDataDet  := {}
   ::SysDataMark := {}

   oXbp := XbpListBox():new( oXbp1, , {24,24}, {300,372}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabStop := .T.
   oXbp:ItemMarked := {| uNIL1, uNIL2, obj | ::LoadTabData(obj) }
   oXbp:create()
   AAdd ( ::aListBox, oXbp )

   oXbp := XbpListBox():new( oXbp1, , {432,24}, {276,372}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabStop := .T.
   oXbp:MarkMode := XBPLISTBOX_MM_EXTENDED
   oXbp:ItemMarked := {| uNIL1, uNIL2, obj | ::GenMultiPublics(obj) }
   oXbp:create()
   AAdd ( ::aListBox, oXbp )

   AAdd ( ::sysdata,  {"Stammkunde Werbeträger", "StammKunde",2}  )
   AAdd ( ::sysdata,  {"Standart Werbeträger", "StdWerbetraeger",2} )
   AAdd ( ::sysdata,  {"Kunde bekommt Mailings", "StdDebMail",2} )
   AAdd ( ::sysdata,  {"Kunde ist aktiv", "StdDebStat",2} )
   AAdd ( ::sysdata,  {"Überprüfung Kundendaten nach", "DebDatAgeForValidate",2} )
   AAdd ( ::sysdata,  {"Mund zu Mund Werbeträger", "MundzuMundWerbetraeger",2}  )
   AAdd ( ::sysdata,  {"Ladenkunde Kundengruppe", "LadenKundenKGR",2} )
   AAdd ( ::sysdata,  {"Wiederverkäufer Kundengruppe", "WiederverkaufKGR",2}  )
   AAdd ( ::sysdata,  {"Kreditkarten Zahlart", "ZahlArtCC",2} )
   AAdd ( ::sysdata,  {"Bankkonto Zahlart","BankZahlung",2}  )
   AAdd ( ::sysdata,  {"Barzahlung Zahlart","BarZahlung",2}  )
   AAdd ( ::sysdata,  {"Markierte Wochentage Disposition","DispLocked",1}  )
   AAdd ( ::sysdata,  {"Blockierte Wochentage Disposition","LockWeekDays",1}  )
   AAdd ( ::sysdata,  {"Freitage Disposition", "LockHolidays",10} )
   AAdd ( ::sysdata,  {"Statistik Kundengruppe Ladenkunden","StatKgrPOS",2}  )
   AAdd ( ::sysdata,  {"Statistik Kundengruppen Wiederverkauf", "StatKgrGH",2} )
   AAdd ( ::sysdata,  {"Statistik Artikelgruppe mit EP Null", "StatAGREPNull",2} )
   AAdd ( ::sysdata,  {"Statistik Anzahl angezeigte Jahre","nStatistikJahre",1}  )
   AAdd ( ::sysdata,  {"ServiceTyp Erster Service", "FirstServiceCode",2}  )
   AAdd ( ::sysdata,  {"Nicht Lagerbewegende Lagerarten", "ArtNotLMove",2} )
   AAdd ( ::sysdata,  {"Produktegruppe für Abfrage Rahmennummer", "SerialNoFrames",2} )
   AAdd ( ::sysdata,  {"Produktegruppe für Abfrage Gabelnummer", "SerialNoForks",2} )
   AAdd ( ::sysdata,  {"Produktegruppe für Abfrage Elementnummer", "SerialNoElement",2} )
   AAdd ( ::sysdata,  {"Produktegruppe für Abfrage Bremsenummer", "SerialNoBrake",2} )
   AAdd ( ::sysdata,  {"Verkaufte Artikel Velos", "SalesBikesPGR",2} )
   AAdd ( ::sysdata,  {"Verkaufte Artikel Zubehör", "SalesSparesPGR",2} )
   AAdd ( ::sysdata,  {"Verkaufte Artikel Rahmen", "SalesFramesPGR",2} )
   AAdd ( ::sysdata,  {"Verkaufte Artikel Arbeit", "SalesLaborPGR",2} )

For i:= 1 to Len( ::sysdata )
  ::aListBox[1]:AddItem( ::SysData[i][1] )
  aAdd( ::SysDataDet , "" )
  PubVar   := ::sysdata[i][2]
  ::SysDataDet[i] := &PubVar
next

::aListBox[1]:setData( {1} )
::LoadTabData( ::aListBox[1] )
SetAppFocus( ::aListbox[1] )

RETURN

METHOD AdminTask:AdvPage5(DrawingArea)
*--------------------------------------
   LOCAL aSize, aPos[2]
   LOCAL oXbp, oXbp1
   LOCAL i
   LOCAL PubVar
   aSize    := Drawingarea:currentSize()
   aPos[1]  := 12
   aPos[2]  := 48
   aSize[1] := aSize[1] - 24
   aSize[2] := aSize[2] - 24 -36


   oXbp1 := XbpTabPage():new( drawingArea, , aPos, aSize, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE } } )
   oXbp1:caption := "FTP Einstellungen"
   oXbp1:minimized  := .T.
   oXbp1:preOffset  := 80
   oXbp1:postOffset := 0
   oXbp1:tabStop := .T.
   oXbp1:tabActivate := {|| ::AdvSetTabs(5) }
   oXbp1:create()
   aAdd(::aTabs, oXbp1)


   oXbp := XbpStatic():new( oXbp1, , {12,384}, {156,24} )
   oXbp:caption := "Lokales Web Bestandesfile:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {180,384}, {492,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 100

   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( FTPLocalFile ), FTPLocalFile := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( oXbp1, , {12,360}, {156,24} )
   oXbp:caption := "Remote Bestandesfile:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {180,360}, {492,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 100
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( FTPRemoteFile ), FTPRemoteFile := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( oXbp1, , {12,336}, {156,24} )
   oXbp:caption := "FTP Servername:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {180,336}, {492,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 100
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( FTPServerName ), FTPServerName := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( oXbp1, , {12,312}, {156,24} )
   oXbp:caption := "FTP Username:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {180,312}, {492,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 100
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( FTPUserName ), FTPUserName := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( oXbp1, , {12,288}, {156,24} )
   oXbp:caption := "FTP Passwort:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {180,288}, {492,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 100
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( FTPPassWord ), FTPPassWord := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( oXbp1, , {12,264}, {156,24} )
   oXbp:caption := "Remote UpdateRoutine:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {180,264}, {492,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 100
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( FTPUpdateCommand ), FTPUpdateCommand := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)

   oXbp := XbpStatic():new( oXbp1, , {12,240}, {156,24} )
   oXbp:caption := "Zeitintervall Datenübermittlung:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {180,180}, {120,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj), WebThread:setInterval(val(FTPInterVall)*6000)  }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "FTPIntervall" )

   oXbp := XbpStatic():new( oXbp1, , {12,216}, {156,24} )
   oXbp:caption := "Datenübermittlung aktivieren:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {180,156}, {120,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "FTPActivate" )

   * FTP Backup

   oXbp := XbpStatic():new( oXbp1, , {12,180}, {156,24} )
   oXbp:caption := "Lokales Backup File:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {180,180}, {492,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 100
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( FTPBackupLocalFile ), FTPBackupLocalFile := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( oXbp1, , {12,156}, {156,24} )
   oXbp:caption := "Remote Backup File:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( oXbp1, , {180,156}, {492,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 100
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( FTPBackupRemoteFile ), FTPBackupRemoteFile := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)

   oXbp := XbpStatic():new( oXbp1, , {12,132}, {156,24} )
   oXbp:caption := "Zeitintervall Datenübermittlung:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {180,72}, {120,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj), BackupThread:setInterval(val(FTPBackupInterVall)*6000)  }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "FTPBackupIntervall" )


   oXbp := XbpStatic():new( oXbp1, , {12,108}, {156,24} )
   oXbp:caption := "FTP Backup aktivieren:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( oXbp1, , {180,48}, {120,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:ItemSelected := {|mp1, mp2, obj| ::GenSinglePublics(obj) }
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterSysElement(oXbp, .t., "FTPBackupActivate" )


RETURN

METHOD AdminTask:SelectDir( oSLE, oOwner)
*---------------------------------------
LOCAL oDlg
LOCAL DirSelected := alltrim( oSLE:EditBuffer() )
LOCAL i := 1

   if ! ::ValidDrive( oSLE, 2 )
      DirSelected := CurDrive()+":\"
   endif


   oDlg := DirDialog():new( AppDesktop(),oOwner , {508,351}, {370,380}, , .F.)
   oDlg:taskList := .T.
   oDlg:title   := "Verzeichnis wählen"

   oDlg:Resize  := {| aOldSize, aNewSize, obj | ResizeDataDialog(obj, aOldSize, aNewSize, obj:aChildList) }
   oDlg:move    := {| aOldPos, aNewPos, obj | SaveDialogPosAndSize(Obj) }

   oDlg:create()
   oDlg:oOwner := oOwner

   drawingArea := oDlg:drawingArea
   drawingArea:setFontCompoundName( "8.Arial" )

   oDlg:Display(DrawingArea)
   oDlg:LoadDrives( Subs(DirSelected,1,1) )
   oDlg:LoadDir( DirSelected )
   RestoreDialogPosAndSize(oDlg)

   oDlg:setModalState( XBP_DISP_APPMODAL )
   oDlg:show()
   SetAppFocus(oDlg)

   nEvent := xbe_None
   DO WHILE nEvent <> xbeP_Close
      nEvent := AppEvent( @mp1, @mp2, @oXbp )
      if nEvent == xbeP_Close
         DirSelected := oDlg:DirSelected
      endif
      oXbp:handleEvent( nEvent, mp1, mp2 )
   ENDDO

Do Case
   Case DirSelected == NIL
        Return
   Case DirSelected == "Verzeichnis wählen"
        Return
   Case DirSelected == ""
        Return

   othe
        oSLE:SetData( DirSelected )
        ::ValidDrive( oSLE, 1 )
   EndCase


RETURN


METHOD AdminTask:GenMultiPublics(obj)
*-------------------------------
LOCAL nElement := iif( len( ::aListBox[1]:GetData() ) >0, ::aListBox[1]:GetData()[1], 1)
LOCAL aSelect  := Obj:GetData()
LOCAL TmpVar   := ""
LOCAL TmpDat   := ""
LOCAL i
LOCAL PubVar   := ::sysdata[nElement][2]
LOCAL VarLen   := ::sysdata[nElement][3]

For i:= 1 to len(aSelect) - 1
   TmpDat := Subs( obj:GetItem( aSelect[i] ),1, VarLen )
   TmpVar := TmpVar + TmpDat + ", "
Next

if len(aSelect) > 0
   TmpDat := Subs( obj:GetItem( aSelect[len(aSelect)] ),1, VarLen )
   TmpVar := TmpVar + TmpDat
endif

&PubVar := TmpVar
::SysDataDet[nElement] := TmpVar
Return

METHOD AdminTask:GenSinglePublics(obj)
*-------------------------------
LOCAL x := aScan( ::aComboBox[1], Obj )
LOCAL aCombo := ::aComboBox[1][x]:GetData()
LOCAL ComboField := ::aComboBox[3][x]
LOCAL ComboLen   := ::aComboBox[5][x]
      aCombo := iif( len(aCombo) == 0, {1}, aCombo  )
      &ComboField := Subs( ::aComboBox[1][x]:GetItem( aCombo[1] ),1,ComboLen)
Return


METHOD AdminTask:LoadTabData(obj)
*--------------------------------
LOCAL aSelect := obj:GetData()
LOCAL nSelect := iif( Len(aSelect) == 0, 1, aSelect[1] )
LOCAL aIni    := {}
LOCAL aMark   := {}
LOCAL aItems  := {}
LOCAL i
LOCAL CodeLen := 2

::aListBox[2]:Clear()
Do Case
   Case nSelect == 1
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_SINGLE
      ::MoveTabToListBox(@::aListBox[2], "016", "01" )
      aIni := GetaIni( StammKunde )
   Case nSelect == 2
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_SINGLE
      ::MoveTabToListBox(@::aListBox[2], "016", "01" )
      aIni :=  GetaIni( StdWerbetraeger )
   Case nSelect == 3
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_SINGLE
      ::MoveTabToListBox(@::aListBox[2], "024", "01" )
      aIni :=  GetaIni( StdDebMail )
   Case nSelect == 4
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_SINGLE
      ::MoveTabToListBox(@::aListBox[2], "023", "01" )
      aIni :=  GetaIni( StdDebStat )
   Case nSelect == 5
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_SINGLE
      ::MoveTabToListBox(@::aListBox[2], "050", "06" )
      aIni :=  GetaIni( DebDatAgeForValidate )
   Case nSelect == 6
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_SINGLE
      ::MoveTabToListBox(@::aListBox[2], "016", "01" )
      aIni :=  GetaIni( MundzuMundWerbetraeger )
   Case nSelect == 7
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveTabToListBox(@::aListBox[2], "017", "01" )
      aIni :=  GetaIni( LadenKundenKGR )
   Case nSelect == 8
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveTabToListBox(@::aListBox[2], "017", "01" )
      aIni :=  GetaIni( WiederverkaufKGR )
   Case nSelect == 9
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveTabToListBox(@::aListBox[2], "007", "01" )
      aIni :=  GetaIni( ZahlArtCC )
   Case nSelect == 10
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveTabToListBox(@::aListBox[2], "007", "01" )
      aIni :=  GetaIni( BankZahlung )
   Case nSelect == 11
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveTabToListBox(@::aListBox[2], "007", "01" )
      aIni :=  GetaIni( BarZahlung )
   Case nSelect == 12
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveVarToListBox(@::aListBox[2], "006",, @CodeLen )
      aIni :=  GetaIni( DispLocked )
   Case nSelect == 13
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveVarToListBox(@::aListBox[2], "006",, @CodeLen )
      aIni :=  GetaIni( LockWeekDays )
   Case nSelect == 14
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveVarToListBox(@::aListBox[2], "004",, @CodeLen )
      aIni :=  GetaIni( LockHolidays )
   Case nSelect == 15
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveTabToListBox(@::aListBox[2], "017", "01" )
      aIni :=  GetaIni( StatKgrPOS )
   Case nSelect == 16
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveTabToListBox(@::aListBox[2], "017", "01" )
      aIni :=  GetaIni( StatKgrGH )
   Case nSelect == 17
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveTabToListBox(@::aListBox[2], "001", "01" )
      aIni :=  GetaIni( StatAGREPNull )
   Case nSelect == 18
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_SINGLE
      ::MoveVarToListBox(@::aListBox[2], "005",, @CodeLen )
      aIni :=  GetaIni( nStatistikJahre )
   Case nSelect == 19
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_SINGLE
      ::MoveTabToListBox(@::aListBox[2], "018", "01" )
      aIni := GetaIni( FirstServiceCode )
   Case nSelect == 20
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveTabToListBox(@::aListBox[2], "019", "01" )
      aIni := GetaIni( ArtNotLMove )
   Case nSelect == 21
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveTabToListBox(@::aListBox[2], "002", "01" )
      aIni := GetaIni( SerialNoFrames )
   Case nSelect == 22
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveTabToListBox(@::aListBox[2], "002", "01" )
      aIni := GetaIni( SerialNoForks )
   Case nSelect == 23
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveTabToListBox(@::aListBox[2], "002", "01" )
      aIni := GetaIni( SerialNoElement )
   Case nSelect == 24
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveTabToListBox(@::aListBox[2], "002", "01" )
      aIni := GetaIni( SerialNoBrake )

   Case nSelect == 25
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveTabToListBox(@::aListBox[2], "002", "01" )
      aIni := GetaIni( SalesBikesPGR )

   Case nSelect == 26
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveTabToListBox(@::aListBox[2], "002", "01" )
      aIni := GetaIni( SalesSparesPGR )

   Case nSelect == 27
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveTabToListBox(@::aListBox[2], "002", "01" )
      aIni := GetaIni( SalesFramesPGR )

   Case nSelect == 28
      ::aListBox[2]:MarkMode := XBPLISTBOX_MM_EXTENDED
      ::MoveTabToListBox(@::aListBox[2], "002", "01" )
      aIni := GetaIni( SalesLaborPGR )

EndCase

For i := 1 to ::aListBox[2]:NumItems()
   aAdd( aItems, Subs( ::aListBox[2]:GetItem(i), 1, CodeLen) )
   ::aListBox[2]:SetData( {i}, .f. )
next

For i := 1 to Len(aIni)
   if aScan( aItems, aIni[i] ) > 0
      aAdd( aMark, aScan( aItems, aIni[i] ) )
   endif
next
::aListBox[2]:SetData( aMark )
Return


METHOD AdminTask:AdvRead()
*--------------------------

Return

METHOD AdminTask:AdvSave()
*--------------------------

Return





METHOD AdminTask:AdvSetTabs(TabId)
*------------------------

LOCAL i             := 1
LOCAL OldFocus := SetAppFocus()

if ::StartUp
   Return
Endif

if ::TabSelect == TabId
   Return .f.
Endif

if ::EditMode
   Return
endif

For i:= 1 to len(::aTabs)
  ::aTabs[i]:minimize()
Next

::aTabs[TabId]:Maximize()

Do case
   Case TabId == 1


   Case TabId == 2


   Case TabId == 3


   Case TabId == 4

   Case TabId == 5


Endcase
::aTabs[TabId]:Maximize()
::TabFocus := SetAppFocus()
*::RegisterOldButtons()
::TabSelect := TabID
Return .t.


METHOD AdminTask:RegisterSysElement(oXbp, isFlow, cMemVar )
*-------------------------------------------------------------------
LOCAL TabWa  := ::aArea[TABELLEN]
LOCAL VarLen := 2

if oXbp:isDerivedFrom( "XbpComboBox" )
   aAdd(::aComboBoxes, oXbp)

    Do Case
      case cMemVar == "StammKunde"
         ::MoveTabToListBox( @oXbp, "017", &cMemVar)
      case cMemVar == "StdWerbetraeger"
         ::MoveTabToListBox(@oXbp, "016", &cMemVar)
      case cMemVar == "MundzuMundWerbetraeger"
         ::MoveTabToListBox(@oXbp, "016", &cMemVar)
      case cMemVar == "StdMWStCode"
         ::MoveTabToListBox(@oXbp, "013", &cMemVar)
      case cMemVar == "FirstServiceCode"
         ::MoveTabToListBox(@oXbp, "018", &cMemVar)
      case cMemVar == "OrderTypLieferant"
         ::MoveTabToListBox(@oXbp, "026", &cMemVar)
      case cMemVar == "StdLEBezug"
         ::MoveTabToListBox(@oXbp, "030", &cMemVar)
      case cMemVar == "MaxSDBTabRec"
         ::MoveVarToListBox(@oXbp, "001", &cMemVar, @VarLen )
      case cMemVar == "MaxDocRec"
         ::MoveVarToListBox(@oXbp, "001", &cMemVar, @VarLen )
      case cMemVar == "MaxDocDebRec"
         ::MoveVarToListBox(@oXbp, "001", &cMemVar, @VarLen )
      case cMemVar == "MaxDebRec"
         ::MoveVarToListBox(@oXbp, "001", &cMemVar, @VarLen )
      case cMemVar == "MaxKreRec"
         ::MoveVarToListBox(@oXbp, "001", &cMemVar, @VarLen )
      case cMemVar == "MaxArtRec"
         ::MoveVarToListBox(@oXbp, "001", &cMemVar, @VarLen )
      case cMemVar == "MaxDisRec"
         ::MoveVarToListBox(@oXbp, "001", &cMemVar, @VarLen )
      case cMemVar == "MaxOrdRec"
         ::MoveVarToListBox(@oXbp, "001", &cMemVar, @VarLen )
      case cMemVar == "MaxOrdKreRec"
         ::MoveVarToListBox(@oXbp, "001", &cMemVar, @VarLen )
      case cMemVar == "MaxCalcQbSize"
         ::MoveVarToListBox(@oXbp, "001", &cMemVar, @VarLen )
      case cMemVar == "DialogMinSize"
         ::MoveVarToListBox(@oXbp, "001", &cMemVar, @VarLen )
      case cMemVar == "DialogMaxSize"
         ::MoveVarToListBox(@oXbp, "001", &cMemVar, @VarLen )
      case cMemVar == "CheckForStkList"
         ::MoveVarToListBox(@oXbp, "002", &cMemVar, @VarLen )
      case cMemVar == "DialogResizeAtStartup"
         ::MoveVarToListBox(@oXbp, "002", &cMemVar, @VarLen )
      case cMemVar == "ArtikelStartIndexFlag"
         ::MoveVarToListBox(@oXbp, "101", &cMemVar, @VarLen )
      case cMemVar == "KundenStartIndexFlag"
         ::MoveVarToListBox(@oXbp, "102", &cMemVar, @VarLen )
      case cMemVar == "KreditorStartIndexFlag"
         ::MoveVarToListBox(@oXbp, "103", &cMemVar, @VarLen )
      case cMemVar == "DokumentStartIndexFlag"
         ::MoveVarToListBox(@oXbp, "104", &cMemVar, @VarLen )
      case cMemVar == "AppRefreshRate"
         ::MoveVarToListBox(@oXbp, "003", &cMemVar, @VarLen )
      case cMemVar == "FTPIntervall"
         ::MoveVarToListBox(@oXbp, "001", &cMemVar, @VarLen )
      case cMemVar == "FTPActivate"
         ::MoveVarToListBox(@oXbp, "002", &cMemVar, @VarLen )
      case cMemVar == "FTPBackupIntervall"
         ::MoveVarToListBox(@oXbp, "001", &cMemVar, @VarLen )
      case cMemVar == "FTPBackupActivate"
         ::MoveVarToListBox(@oXbp, "002", &cMemVar, @VarLen )
      case cMemVar == "ReservationRuestZettel"
         ::MoveVarToListBox(@oXbp, "002", &cMemVar, @VarLen )
      case cMemVar == "TestFahrtRuestZettel"
         ::MoveVarToListBox(@oXbp, "002", &cMemVar, @VarLen )

   EndCase

   AAdd ( ::aComboBox[1], oXbp )
   AAdd ( ::aComboBox[2], {|| ""  } )
   AAdd ( ::aComboBox[3], cMemVar )
   AAdd ( ::aComboBox[4], NIL )
   AAdd ( ::aComboBox[5], VarLen )

Endif

if IsFlow
   oXbp:KeyBoard :=  {|nKey,x,obj| ::ValidKey( nKey, obj) }
       if ! oXbp:isDerivedFrom( "XbpPushbutton" )
          oXbp:lbClick  :=  ::bLbClick
       Endif
   AAdd ( ::aFlowControl, oXbp )
endif

Return


METHOD AdminTask:MoveVarToListBox(oXbp, Mode, cMemVar, Varlen )
*--------------------------------------------------------------
LOCAL i
LOCAL TabSelect := {1}
LOCAL TabArr    := {}
LOCAL TabWert   := cMemVar


Do Case
   Case Mode == "001"
      oXbp:Clear()
      For i:= 1 to 50
          oXbp:AddItem( Alltrim( Str( i * 10) ) )
          aAdd(TabArr, Alltrim( Str( i * 10)) )
      Next
      if !Tabwert == NIL
         VarLen := 3
         TabSelect[1] := iif( aScan(TabArr, TabWert) == 0, 1, aScan(TabArr, TabWert) )
         oXbp:setData( TabSelect )
      Endif

   Case Mode == "002"
      oXbp:Clear()
      oXbp:AddItem( "0 Nein" )
      oXbp:AddItem( "1 Ja" )
      aAdd(TabArr, "0" )
      aAdd(TabArr, "1" )
      if !Tabwert == NIL
         VarLen := 1
         TabSelect[1] := iif( aScan(TabArr, TabWert) == 0, 1, aScan(TabArr, TabWert) )
         oXbp:setData( TabSelect )
      Endif


   Case Mode == "003"
      oXbp:Clear()
      For i:= 0 to 50
          oXbp:AddItem( Alltrim( Str( i * 10) ) )
          aAdd(TabArr, Alltrim( Str( i * 10)) )
      Next
      if !Tabwert == NIL
         VarLen := 3
         TabSelect[1] := iif( aScan(TabArr, TabWert) == 0, 1, aScan(TabArr, TabWert) )
         oXbp:setData( TabSelect )
      Endif

   Case Mode == "004"
      VarLen := 10
      oXbp:Clear()
      For i:= 1 to 360
         oXbp:AddItem( dtoc( Date() + i - 1 ) + " " + cDow( Date() + i - 1 ))
      Next

   Case Mode == "005"
      VarLen := 1
      oXbp:Clear()
      oXbp:AddItem( "1 Jahr anzeigen"  )
      For i:= 2 to 9
         oXbp:AddItem( Str(i,1,0) + " Jahre anzeigen"  )
      Next

   Case Mode == "006"
      VarLen := 1
      oXbp:Clear()
      oXbp:AddItem( "1 Sonntag"  )
      oXbp:AddItem( "2 Montag"  )
      oXbp:AddItem( "3 Dienstag"  )
      oXbp:AddItem( "4 Mittwoch"  )
      oXbp:AddItem( "5 Donnerstag"  )
      oXbp:AddItem( "6 Freitag"  )
      oXbp:AddItem( "7 Samstag"  )

   Case Mode == "101"
      oXbp:Clear()
      oXbp:AddItem( "1 Nummer" )
      oXbp:AddItem( "2 Match Code" )
      oXbp:AddItem( "3 Liefer Code" )
      oXbp:AddItem( "4 Bezeichnung" )
      oXbp:AddItem( "5 Freie Suche" )

      aAdd(TabArr, "1" )
      aAdd(TabArr, "2" )
      aAdd(TabArr, "3" )
      aAdd(TabArr, "4" )
      aAdd(TabArr, "5" )

      if !Tabwert == NIL
         VarLen := 1
         TabSelect[1] := iif( aScan(TabArr, TabWert) == 0, 1, aScan(TabArr, TabWert) )
         oXbp:setData( TabSelect )
      Endif

   Case Mode == "102"
      oXbp:Clear()
      oXbp:AddItem( "1 Nummer" )
      oXbp:AddItem( "2 Match Code" )
      oXbp:AddItem( "3 Name" )
      oXbp:AddItem( "4 Freie Suche" )


      aAdd(TabArr, "1" )
      aAdd(TabArr, "2" )
      aAdd(TabArr, "3" )
      aAdd(TabArr, "4" )

      if !Tabwert == NIL
         VarLen := 1
         TabSelect[1] := iif( aScan(TabArr, TabWert) == 0, 1, aScan(TabArr, TabWert) )
         oXbp:setData( TabSelect )
      Endif

   Case Mode == "103"
      oXbp:Clear()
      oXbp:AddItem( "1 Nummer" )
      oXbp:AddItem( "2 Match Code" )
      oXbp:AddItem( "3 Name" )


      aAdd(TabArr, "1" )
      aAdd(TabArr, "2" )
      aAdd(TabArr, "3" )

      if !Tabwert == NIL
         VarLen := 1
         TabSelect[1] := iif( aScan(TabArr, TabWert) == 0, 1, aScan(TabArr, TabWert) )
         oXbp:setData( TabSelect )
      Endif

   Case Mode == "104"
      oXbp:Clear()

      oXbp:AddItem( "1 Kunden Nummer" )
      oXbp:AddItem( "2 Match Code" )
      oXbp:AddItem( "3 Name" )
      oXbp:AddItem( "4 Document Nummer" )
      oXbp:AddItem( "5 Freie Suche" )

      aAdd(TabArr, "1" )
      aAdd(TabArr, "2" )
      aAdd(TabArr, "3" )
      aAdd(TabArr, "4" )
      aAdd(TabArr, "5" )

      if !Tabwert == NIL
         VarLen := 1
         TabSelect[1] := iif( aScan(TabArr, TabWert) == 0, 1, aScan(TabArr, TabWert) )
         oXbp:setData( TabSelect )
      Endif


Endcase

Return .t.

METHOD AdminTask:SaveInit()
*--------------------------
LOCAL i
LOCAL aStdInit := SetStdSysPublVar()
LOCAL PublVar
LOCAL IniFile := "MGSystem.Ctr"

For i := 1 to Len(::aEditcontrols)
   ::aEditcontrols[i]:getData()
Next

For i := 2 to len( aStdInit )
   PublVar := aStdInit[i][1]
   aStdInit[i][2] := &PublVar
Next
WriteInit(IniFile, aStdInit)
SaveMem()
Return



METHOD AdminTask:RestoreInit()
*-----------------------------
   LOCAL aWinInit := {}
   LOCAL aScrInit := {}
   LOCAL aDBInit := {}
   *StandartWerte
   LOCAL acPublics := SetStdSysPublVar()
   *Standart zur Anpassung
   LOCAL aPublics  := SetStdSysPublVar()

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

   InitSysMem(aPublics)
   ::ReadData()
   ::LoadTabData( ::aListBox[1] )
   ::SaveInit()
Return


METHOD AdminTask:ValidDrive(obj, nMode)
*--------------------------------------
LOCAL SysDir    := Obj:EditBuffer()
LOCAL cSysDir   := Alltrim( SysDir )
LOCAL cDrive    := Subs(cSysDir,1,1)
LOCAL nPosition := iif( Rat( "\", cSysDir ) == Len( cSysDir ), Rat( "\", cSysDir ), Len( cSysDir ) )
LOCAL cDir      := Left( cSysDir, nPosition )
LOCAL ReturnVal := .t.

if  !IsDriveReady( cDrive )
    obj:Undo()
    ReturnVal := .f.
Else
   if ! File( cDir, "D" )
       MsgBox("Das Verzeichnis " + SysDir + " ist ungültig", "ValidDrive(SysDir)")
       obj:Undo()
       ReturnVal := .f.
   else
      if !Rat( "\", cDir ) == Len( cDir )
         cDir := cDir + "\"
      Endif
      obj:SetData( Upper( cDir ) )
   endif
Endif

if nMode == 1
   if !ReturnVal
      SetAppFocus(Obj)
   endif
endif

Return ReturnVal