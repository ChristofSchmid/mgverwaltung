///////////////////////////////////////////////////////////////////////////////
//
// Tabellenstamm 16.5.2002 CAS
//
///////////////////////////////////////////////////////////////////////////////

#include "Gra.ch"
#include "Xbp.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "DMLB.ch"
#include "inkey.ch"
#include "MGV.CH"
#pragma Library( "XppUi2.lib" )
#pragma Library( "Adac20b.lib" )


* Methoden

CLASS TabStamm FROM DataDialog
   EXPORTED:
     VAR aTabDat
     VAR aTabRec
     VAR TabFocus
     VAR pFilter
     VAR TabName

     METHOD Create
     METHOD Close
     METHOD CloseTab
     METHOD TabSuchPos
     METHOD AddTab
     METHOD GenTabNr
     METHOD Notify
     METHOD MutTab
     METHOD VWTab
     METHOD RWTab
     METHOD DelTab
     METHOD SaveTab
     METHOD ScrollVertical
     METHOD ValidSearchKey
     METHOD DataInEditMode
     METHOD RegisterSLEFocus
     METHOD PrintTab
     METHOD TabPage
     METHOD RegisterTabRecno


ENDCLASS


METHOD TabStamm:create( oParent, oOwner , ;
                          aPos   , aSize  , ;
                          aPParam, lVisible )

   ::DataDialog:create( oParent, oOwner , ;
                       aPos   , aSize  , ;
                       aPParam, lVisible )

   ::aTabDat         := { {"Leer","","","","","","",""} }
   ::aTabRec         := {}
   ::TabFocus        := SetAppFocus()
   ::TabName         := ""

RETURN self


METHOD TabStamm:Notify( nEvent, mp1, mp2 )
*-----------------------------------------

*  LOCAL cList
*  cList :=  DbClientList()

  *DBO_CLOSE_REQUEST  Datei in der Workarea wird geschlossen
  *DBO_BULK_REQUEST   Zeitaufwendige Datenbank-Operation beginnt
  *DBO_BULK_COMPLETE  Zeitaufwendige Datenbank-Operation ist abgeschlossen
  *DBO_CHANGE_ORDER   Ordnung, in der Datenätze vorliegen,wurde geändert (logische oder physikalische Ordnung)
  *DBO_TABLE_UPDATE   Daten im Datensatz wurden verändert
  *DBO_TABLE_DELETED  Datensatz wurde gelöscht
  *DBO_TABLE_APPEND   Neuer Datensatz wurde erzeugt
  *DBO_MOVE_PROLOG    Satzzeiger wird verändert
  *DBO_MOVE_DONE      Änderung des Satzzeigers ist abgeschlossen
  *DBO_GOBOTTOM       Satzzeiger wurde auf Anfang gesetzt
  *DBO_GOTOP          Satzzeiger wurde auf Ende gesetzt

   IF nEvent <> xbeDBO_Notify
      RETURN self                         // ** RETURN **
   ENDIF

   DbSuspendNotifications()

   DO CASE
   CASE mp1 == DBO_MOVE_PROLOG            // Satzzeiger wird bewegt


*        MsgBox( iif(DBInfo(DBO_SHARED),"SHARED","EXCLUSIV"), "Interne Meldung" )
*        MsgBox( DBInfo(DBO_DBENAME), "Interne Meldung" )

   CASE mp1 == DBO_MOVE_DONE

   CASE mp1 == DBO_MOVE_DONE .OR. ;       // Skip ist beendet
        mp1 == DBO_GOBOTTOM  .OR. ;
        mp1 == DBO_GOTOP


      DO CASE
         CASE mp1 == DBO_GOBOTTOM

         CASE mp1 == DBO_GOTOP

         CASE mp1 == DBO_MOVE_DONE

         OTHERWISE
      ENDCASE

   ENDCASE
   DbResetNotifications()

RETURN self



METHOD TabStamm:Close()
   ::CloseTab()
   ::DataDialog:Close()
   ::aTabDat         := { {"Leer","","","","","","",""} }
   ::aTabRec         := {}
   ::Destroy()
RETURN self





METHOD TabStamm:TabSuchPos()
*----------------
LOCAL aItem
LOCAL rPos
LOCAL RecToGo
LOCAL nPages
LOCAL OldFocus

if ::StartUp .or. ::EditMode .or. len(::aTabRec) == 0
  Return
Endif

OldFocus := SetAppFocus()
aItem   := ::aListBox[1]:getdata()

if len(aItem) == 0
   Return
Endif

   RecToGo := ::aListBox[1]:getdata()[1]


Select(::aArea[TABELLEN])

if FileLock( ::aArea[TABELLEN] )
   DbGoto(::aTabRec[RecToGo])
   DbUnlock()
Endif



::ReadData()

Return


METHOD TabStamm:RegisterTabRecno(TabId)
*---------------------------------------
LOCAL TabWa     := ::aArea[TABELLEN]

::aTabRec := {}

Select(TabWa)
if FileLock(TabWa)
   DbSeek(TabId)
   DbUnlock()
endif

if Found()
   Do While Subs((TabWa)->TabCode,1, 3 ) = TabId .and. !Eof()
      AAdd(::aTabRec, Recno() )
      Skip
   Enddo
endif

Return


METHOD TabStamm:AddTab()
*----------------
LOCAL oldRec     := RecNo()
LOCAL nButton
LOCAL CopyFlag   := .f.
LOCAL DataToCopy := {}
LOCAL TabWa       := ::aArea[TABELLEN]
LOCAL DbTabNr
Select(TabWa)

::currentRec := RecNo()
RestoreMem()
if AppendBlank( TabWa )
   ::AppendMode := .t.
   ::AppendRec  := RecNo()


   DbTabNr := ::GenTabNr( DbTabNr )

   if RecLock( ::AppendRec )
       Replace TabCode  with   Subs( ::aListBox[2]:GetItem( ::aListbox[2]:GetData()[1] ) ,1,3 )
      DbRunLock(::AppendRec)
      SaveMem()
   else
      MsgBox( "Datensatz konnte nicht gesperrt werden.", "Datenbank Operation RecLock()")
      return .f.
   endif
Endif
Return .t.


METHOD TabStamm:GenTabNr(dbTabNr)
*----------------------------------
OrdSetFocus(1) &&TabNr
Do While .t.
   if FileLock( ::aArea[TABELLEN] )
      DbSeek(dbTabNr)
      DbUnlock()
   Endif
   if found()
      dbTabNr := PadL( Val( dbTabNr ) + 1,8, " " )
   else
      OrdSetFocus(3) &&Name
      if FileLock( ::aArea[TABELLEN] )
         DbGoto(::AppendRec )
         DbUnlock()
      Endif
      Return dbTabNr
   Endif
Enddo

RETURN ""


METHOD TabStamm:CloseTab()
*--------------------
LOCAL nButton
Select(::aArea[TABELLEN])

if ::EditMode
   nButton := ConfirmBox( ,  "Geänderte Daten Sichern?", "Tabellentamm schliessen", XBPMB_YESNO ,  XBPMB_QUESTION+XBPMB_APPMODAL+XBPMB_MOVEABLE )
   IF nButton == XBPMB_RET_YES
      ::SaveTab( .t.)
   ELSE
      ::SaveTab(.f.)
   ENDIF
Endif


Select(::aArea[TABELLEN] )
DbCloseArea()

Return .t.



METHOD TabStamm:MutTab(mStat)
*----------------
LOCAL xM, ym
LOCAL aL := 1
LOCAL aE := 1
LOCAL lVis
LOCAL mMark

   For xM := 1 to len(::aEditControls)
      mMark := ::aEditControls[xM]:bufferLength
      ::aEditControls[xM]:setMarked( iif(mStat, {1,mMark+1}, {0,0}) )
   Next

   ::AbleButtons( {1,2}, {3,4,5} )
   ::ChangeButtons( {1}, {"Sichern"}, { {|| ::SaveTab( .t.)  }  }  )
   ::ChangeButtons( {2}, {"Abbrechen"},   { {|| ::SaveTab( .f.)  }  }  )

::EditMode = mStat
if mStat
   SetAppFocus(::aFlowControl[1] )
Endif
Return .t.



METHOD TabStamm:VWTab()
*-----------
if ::DataInEditMode()
   Return .f.
Endif

FSkip(1)
if Eof()
   MsgBox( "Letzter Datensatz.", "Datenbank Operation FSkip()")
   FSkip(-1)
Endif

Return .t.

METHOD TabStamm:RWTab()
*-----------
if ::DataInEditMode()
   Return .f.
Endif


FSkip(-1)
if bof()
   MsgBox( "Erster Datensatz.", "Datenbank Operation FSkip()")
   DbGoTop()
Endif
Return .t.

METHOD  TabStamm:DelTab( DelConfirm)
*----------
LOCAL OldFocus := SetAppFocus()
LOCAL nButton
LOCAL aSelect1 := ::aListbox[1]:GetData()
LOCAL aSelect2 := ::aListbox[2]:GetData()

if DelConfirm
   nButton := ConfirmBox( ,  "Wollen Sie diesen Eintrag löschen ?", "Löschen", XBPMB_YESNO ,  XBPMB_QUESTION+XBPMB_APPMODAL+XBPMB_MOVEABLE )
   IF nButton == XBPMB_RET_NO
      Return .f.
   ENDIF
Endif

if DelRec(::aArea[TABELLEN])
   Fskip(0)
   ::MoveTabToListBox(@::aListBox[2], "999", "" )
   ::aListbox[2]:SetData(aSelect2)
   ::MoveTabToListBox(@::aListBox[1], subs( ::aListBox[2]:getItem(::aListBox[2]:GetData()[1]),1,3 ), "" )
   ::aListbox[1]:SetData(aSelect1)
   ::RegisterTabrecNo(subs( ::aListBox[2]:getItem(::aListBox[2]:GetData()[1]),1,3 ) )
   ::TabSuchPos()

Else
   MsgBox( "Datensatz konnte nicht gelöscht werden.", "Datenbank Operation DelRec()")
   SetAppFocus(OldFocus)
Endif

return .t.


METHOD TabStamm:SaveTab(SaveMode)
*-------------
* SaveMode .t. = Sichern, .f. = Abbrechen
LOCAL tTyp
LOCAL fTyp
LOCAL TabWa := ::aArea[TABELLEN]
LOCAL aSelect1 := ::aListbox[1]:GetData()
LOCAL aSelect2 := ::aListbox[2]:GetData()

Select(TabWa)

if SaveMode
   ::WriteData()
   ::MutTab( .F.)
   ::ResetButtons()
   ::AppendRec    := 0
   ::AppendMode   := .f.
   ::MoveTabToListBox(@::aListBox[2], "999", "" )
   ::aListbox[2]:SetData(aSelect2)
   ::MoveTabToListBox(@::aListBox[1], subs( ::aListBox[2]:getItem(::aListBox[2]:GetData()[1]),1,3 ), "" )
   ::aListbox[1]:SetData(aSelect1)
   ::RegisterTabrecNo(subs( ::aListBox[2]:getItem(::aListBox[2]:GetData()[1]),1,3 ) )
   ::TabSuchPos()
Else
   if ::AppendMode
      if FileLock( TabWa )
         DbGoto(   ::AppendRec )
         DbUnlock()
      Endif
      ::DelTab( .f.)
      if FileLock( TabWa )
         DbGoto(   ::currentRec )
         DbUnlock()
      Endif
      ::AppendMode   := .f.
      ::AppendRec    := 0
      ::currentRec   := 0
   Endif

   ::MutTab( .F.)
   ::ReadData()
   ::ResetButtons()
Endif
Return .t.


METHOD TabStamm:scrollVertical( nScrlPos, nCommand )
*--------------------------------------------------------------------
LOCAL TabWa     := ::aArea[TABELLEN]
DO CASE
   CASE nCommand == XBPSB_PREVPOS
      FSkip(-1)
   CASE nCommand == XBPSB_NEXTPOS
      FSkip(1)
   CASE nCommand == XBPSB_PREVPAGE
      if FileLock(TabWa)
         DbGoPosition(nScrlPos)
         DbUnLock()
      endif
   CASE nCommand == XBPSB_NEXTPAGE
      if FileLock(TabWa)
         DbGoPosition(nScrlPos)
         DbUnLock()
      endif
   CASE nCommand == XBPSB_SLIDERTRACK
     if FileLock(TabWa)
         DbGoPosition(nScrlPos)
         DbUnLock()
      endif
   CASE nCommand == XBPSB_ENDTRACK
      if FileLock(TabWa)
         DbGoPosition(nScrlPos)
         DbUnLock()
      endif
   CASE nCommand == XBPSB_ENDSCROLL
      if FileLock(TabWa)
         DbGoPosition(nScrlPos)
         DbUnLock()
      endif
ENDCASE

if Eof()
   MsgBox( "Letzter Datensatz.", "Datenbank Operation FSkip()")
   FSkip(-1)
Endif

if bof()
   MsgBox( "Erster Datensatz.", "Datenbank Operation FSkip()")
   DbGoTop()
Endif


::ReadData()
RETURN


METHOD TabStamm:ValidSearchKey(Key, mp2, SearchControl)
*-------------------------------------------------
LOCAL rVal   := .t.
LOCAL mMark  := .t.

   Do Case

      Case Key == xbeK_TAB

      Case Key == xbeK_PGUP
           ::aListBox[1]:PageUp(mMark)

      Case Key == xbeK_PGDN
           ::aListBox[1]:PageDown(mMark)

      Case Key == xbeK_UP
           ::aListBox[1]:Up(mMark)

      Case Key == xbeK_DOWN
           ::aListBox[1]:Down(mMark)

      Case Key == xbeK_ENTER

      Case Key == xbeK_LEFT

      Case Key == xbeK_RIGHT

      Case Key == xbeK_ESC


      othe

   Endcase

Return rVal


METHOD TabStamm:DataInEditMode()
*--------------------------
LOCAL nButton
LOCAL oldControl := ::CurrentControl

if ::EditMode
   nButton := ConfirmBox( ,  "Daten sichern ?", "Tabellen erfassn/mutieren", XBPMB_YESNO ,  XBPMB_QUESTION+XBPMB_APPMODAL+XBPMB_MOVEABLE )
   IF nButton == XBPMB_RET_YES
      ::SaveTab( .t.)
      return .f.
   Else
      ::SaveTab( .f.)
      Return .f.
   ENDIF
Endif
Return .f.


METHOD TabStamm:RegisterSLEFocus()
*-------------------------------------
LOCAL i := 0
LOCAL aElements := len(::aEditControls)

::CurrentControl := 0
for i := 1 to aElements
    if ::aEditControls[i]:hasInputFocus()
       ::CurrentControl := i
       i := aElements
    endif
next
Return .t.



METHOD TabStamm:PrintTab()
*-----------------------------
LOCAL SearchWord := Upper( Alltrim( iif(len(::aSearchControls) >= 1, ::aSearchControls[1]:editBuffer() ,"" ) ) )

::pFilter := { {},{},{},{},{},{} }

::pFilter[1] := {TABELLEN, 1, "TabCode", SearchWord }
::pFilter[2] := {}
::pFilter[3] := {}

* Dieser Block wird zwar DB m„ssig verarbeitet und die Forml„nge berprft,
* kann aber nicht korrekt ausgegeben werden. Msste pForm, Form anpassen mit
* H1 - Hx und DB zuweisung wir im Lglist.for Bsp.
* nicht Prio !, Mal sehen bei Fakturen!

::pFilter[4] := {}
::pFilter[5] := {}
::pFilter[6] := {}


If SelectDataBox(SELF,,,@::pFilter,"Tabellen Auswahl")
   PrintForm("Tablist.For", ::pFilter, SELF)
Endif


Return .t.



METHOD TabStamm:TabPage(DrawingArea)
   LOCAL oXbp,oXbp1, oXbp2, oXbp3, oXbp4, oXbp5, oXbp6
   LOCAL oTab
   LOCAL oListBox
   LOCAL aContMenu := {}
   LOCAL TabWa     := ::aArea[TABELLEN]
   LOCAL lVis      := .t.
   LOCAL aLen
   LOCAL aData
   LOCAL i
   LOCAL KeybEditCheck := .f.
   LOCAL TabVal := "01"
   LOCAL HFactor := 200
   LOCAL aSize  := Drawingarea:currentSize()
   LOCAL aPos   := {,}
   aPos[1]  := 12
   aPos[2]  := 12
   aSize[1] := aSize[1] - 24
   aSize[2] := aSize[2] - 24

   oXbp := XbpListBox():new( drawingArea, , {216,60}, {156,204 + HFactor}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabStop := .T.
   oXbp:ItemMarked   := {| uNIL1, uNIL2, obj | ::TabSuchPos() }
   oXbp:ItemSelected := {| uNIL1, uNIL2, obj | ::MutTab(.t.) }
   oXbp:create()
   AAdd ( ::aListBox, oXbp )

   oXbp := XbpListBox():new( drawingArea, , {36,60}, {156,204 + HFactor}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabStop := .T.
   oXbp:ItemMarked := {| uNIL1, uNIL2, obj | ::MoveTabToListBox(@::aListBox[1], subs( obj:getItem(obj:GetData()[1]),1,3 ), "" ), ::RegisterTabrecNo(subs( obj:getItem(obj:GetData()[1]),1,3 ) ), ::TabSuchPos()}
   oXbp:create()
   ::MoveTabToListBox(@oXbp, "999", "001" )
   AAdd ( ::aListBox, oXbp )


   oXbp := XbpStatic():new( drawingArea, , {480,240 + HFactor}, {72,24} )
   oXbp:caption := "Tabellen Code:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {564,240 + HFactor}, {48,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 9
   oXbp:tabStop := .T.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( (TabWA)->TABCODE ), (TabWA)->TABCODE := x ) }
   oXbp:create():setData()
   AAdd ( ::aEditControls, oXbp )
   AAdd ( ::aFlowControl, oXbp )

   oXbp := XbpStatic():new( drawingArea, , {480,216 + HFactor}, {72,24} )
   oXbp:caption := "Tabsys:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {564,216 + HFactor}, {48,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 15
   oXbp:tabStop := .T.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Transform( (TabWa)->TABSYS, '@N' ), (TabWa)->TABSYS := Val(x) ) }
   oXbp:create():setData()
   AAdd ( ::aEditControls, oXbp )
   AAdd ( ::aFlowControl, oXbp )

   oXbp := XbpStatic():new( drawingArea, , {480,192 + HFactor}, {72,24} )
   oXbp:caption := "Tabellen Text"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {564,192 + HFactor}, {188,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 28
   oXbp:tabStop := .T.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( (TabWA)->TABTEXT ), (TabWA)->TABTEXT := x ) }
   oXbp:create():setData()
   AAdd ( ::aEditControls, oXbp )
   AAdd ( ::aFlowControl, oXbp )

   oXbp := XbpMle():new( drawingArea, , {480,60}, {272,120 + HFactor}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabStop := .T.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, (TabWA)->GTEXT, (TabWA)->GTEXT := x ) }
   oXbp:create():setData()
   AAdd ( ::aMemoBox, oXbp )
   AAdd ( ::aFlowControl, oXbp )


   oXbp := XbpStatic():new( drawingArea, , {36,276 + HFactor}, {84,24} )
   oXbp:caption := "Tabellen"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER
   oXbp:create()

   oXbp := XbpStatic():new( drawingArea, , {216,276 + HFactor}, {84,24} )
   oXbp:caption := "Tabellen Einträge"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER
   oXbp:create()

   oXbp := XbpPushButton():new( drawingArea, , {36,12}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Erfassen"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| ::AddTab(), ::ReadData(), ::MutTab(.t.) }
   AAdd ( ::aButtons, oXbp )
   AAdd ( ::aFlowControl, oXbp )

   oXbp := XbpPushButton():new( drawingArea, , {132,12}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Mutieren"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| ::MutTab(.t.) }
   AAdd ( ::aButtons, oXbp )

   oXbp := XbpPushButton():new( drawingArea, , {228,12}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Löschen"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| ::DelTab(.t.), ::ReadData() }
   AAdd ( ::aButtons, oXbp )


   oXbp := XbpPushButton():new( drawingArea, , {324,12}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Drucken"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| NIL }
   AAdd ( ::aButtons, oXbp )

   oXbp := XbpPushButton():new( drawingArea, , {aSize[1] - 96,12}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Beenden"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {||  WinMenu():AbleItem( MENU01,2,.t.), ::Close(), PostAppEvent(xbeP_Close,,,DrawingArea) }
   AAdd ( ::aButtons, oXbp )

   *ersten Eintrag einlesen
   ::MoveTabToListBox(@::aListBox[1], subs( ::aListBox[2]:getItem(::aListBox[2]:GetData()[1]),1,3 ), "" )
   ::RegisterTabrecNo(subs( ::aListBox[2]:getItem(::aListBox[2]:GetData()[1]),1,3 ) )
   ::TabSuchPos()

Return .t.



PROCEDURE TABELLENSTAMM(TabName)
   LOCAL nEvent, mp1, mp2, oXbp
   LOCAL oDlg, DrawingArea
   LOCAL aPos[2], ASize

   LOCAL oWinMenu
   LOCAL aContMenu := {}
   LOCAL TabWa
   LOCAL lVis
   LOCAL aLen
   LOCAL i
   LOCAL KeybEditCheck := .f.

   OpenDb(DataDrive, TabellenFile, TabellenIndex, TabellenKey)
   TabWa := Select()

   OrdSetFocus(3) &&Name
   if FileLock(TabWa)
      DbGoTop()
      Dbunlock()
   Endif

   aSize       := DialogSize()
   aPos        := DialogPos()
   lVis     := .f.

*   // Anwendungsfenster erzeugen (application window)

   oDlg := TabStamm():new( AppDesktop(), , aPos, aSize, , .F.)
   oDlg:taskList := .T.
   oDlg:title := "Tabellenstamm"
   oDlg:setDisplayFocus := {||    WinMenu():checkItem( oDlg, TABELLEN )}
   oDlg:create()

   oDlg:aArea[TABELLEN]  := TabWa

   drawingArea := oDlg:drawingArea
   drawingArea:setColorBG( GRA_CLR_BACKGROUND )
   drawingArea:setColorFG( GRA_CLR_BLACK      )
   drawingArea:setFontCompoundName( "8.Arial" )

   oDlg:TabPage(DrawingArea)
   oDlg:show()

   oDlg:windowMenu  := WinMenu()
   WinMenu():addItem( oDlg )
   WinMenu():checkItem( oDlg, TABELLEN )
   oDlg:RegisterOldButtons()
   SetAppFocus( oDlg )
   oDlg:Startup := .f.
   LogOn(oDlg, "Administrator")

   nEvent := xbe_None

  DO WHILE nEvent <> xbeP_Close

      nEvent := AppEvent( @mp1, @mp2, @oXbp )


   Do Case


   Case nEvent == xbeM_LbDown .and. ! oDlg:EditMode
           for i := 1  to len( oDlg:aEditControls )
           if oDlg:aEditControls[i]  == oXbp

              nEvent := xbe_None

              *msgbox("Nicht Im Edit Mode","")
              oDlg:MutTab(.t.)
              SetAppFocus(oDlg:aEditControls[i])

              loop
           Endif
           next
           for i := 1  to len( oDlg:aComboBox[1] )
           if oDlg:aComboBox[1][i]  == oXbp
              nEvent := xbe_None

              *msgbox("Nicht Im Edit Mode","")
              oDlg:MutTab(.t.)
              SetAppFocus(oDlg:aComboBox[1][i])

              loop

           Endif
           next

         for i := 1  to len( oDlg:aMemoBox )
           if oDlg:aMemoBox[i]  == oXbp
              nEvent := xbe_None
              oDlg:MutTab(.t.)
              SetAppFocus(oDlg:aMemoBox[i])
              loop
           Endif
           next


   Case nEvent == xbeP_Keyboard


      if ( oDlg:aButtons[2]:HasInputFocus() .or. oDlg:aButtons[1]:HasInputFocus() ) .and. mp1 == xbeK_ENTER
         PostAppEvent( xbeP_Activate, NIL, NIL, oXbp )
         nEvent := xbe_None
      endif

            oDlg:ValidKey(mp1, oXbp)

           if mp1 == xbeK_TAB
                 nEvent := xbe_None
           Endif

           if mp1 == xbeK_SH_TAB
                 nEvent := xbe_None
           Endif

           if mp1 == xbeK_ENTER
                 nEvent := xbe_None
           Endif


   Case nEvent == xbeP_Close
         WinMenu():AbleItem( MENU01,1,.t.)

   endcase

         oXbp:handleEvent( nEvent, mp1, mp2 )


   ENDDO

TabName := oDlg:TabName
RETURN




