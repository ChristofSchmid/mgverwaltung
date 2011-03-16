///////////////////////////////////////////////////////////////////////////////
//
// Kundenstamm 18.8.2001 CAS
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

CLASS DebStamm FROM DataDialog
   EXPORTED:
     VAR aDebDat
     VAR aDebRec
     VAR TabFocus
     VAR pFilter
     VAR DebMode
     VAR DebName
     VAR DebNr
     VAR TabSelect
     VAR DebIndexFlag
     VAR XbpElementPointer
     VAR DebIsSelection
     VAR aOldDeb
     VAR aNewDeb
     VAR aDebFields
     VAR oComboFilt

     METHOD Create
     METHOD Close
     METHOD CloseKunden
     METHOD RefreshDeb
     METHOD DebSuchPos
     METHOD AddDeb
     METHOD GenDebNr
     METHOD Notify
     METHOD SetTabs
     METHOD MutDeb
     METHOD VWDeb
     METHOD RWDeb
     METHOD DelDeb
     METHOD SaveDeb
     METHOD ScrollVertical
     METHOD ValidSearchKey
     METHOD DataInEditMode
     METHOD RegisterSLEFocus
     METHOD PrintKunden
     METHOD DebDebPage

     METHOD AutoEdit
     METHOD ValidOrt
     METHOD SendEMail
     METHOD UpdateDeb
     METHOD SetDebIndex
     METHOD SelectDebIndex
     METHOD CheckForChanges
     METHOD LogDebChange
     METHOD SetOldDebInfo
     METHOD SetNewDebInfo
     METHOD CheckEMailButton
     METHOD CheckDebStatus
     METHOD SetDebFilter

ENDCLASS


METHOD DebStamm:create( oParent, oOwner , ;
                          aPos   , aSize  , ;
                          aPParam, lVisible )

   ::DataDialog:create( oParent, oOwner , ;
                       aPos   , aSize  , ;
                       aPParam, lVisible )

   ::aDebDat           := { {"Leer","","","","","","",""} }
   ::aDebRec           := {}
   ::TabFocus          := SetAppFocus()
   ::DebMode           := KUNDEN
   ::DebName           := ""
   ::DebNr             := ""
   ::bLbClick          := {|nKey,x,obj| ::AutoEdit(obj),    iif(obj:isDerivedFrom( "XbpSLE" ),Obj:setMarked( {1,Obj:bufferLength + 1}  ), NIL )   }
   ::TabSelect         := 0
   ::DebIndexFlag      := Val(KundenStartIndexFlag)
   ::XbpElementPointer := 1
   ::DebIsSelection    := .f.
   ::aOldDeb           := {}
   ::aNewDeb           := {}
   ::aDebFields        := {}

RETURN self


METHOD DebStamm:Notify( nEvent, mp1, mp2 )
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



METHOD DebStamm:Close()
   ::CheckDebStatus()    //Austritte auf 99 setzen
   ::CloseKunden()
   ::DataDialog:Close()
   ::aDebDat         := { {"Leer","","","","","","",""} }
   ::aDebRec         := {}
   ::Destroy()
RETURN self



METHOD DebStamm:RefreshDeb()
*-----------------------------
LOCAL oldWa   := select()
LOCAL rCnt    := 1
LOCAL DebWa   := ::aArea[KUNDEN]
LOCAL cFarbe  := ""
LOCAL OldRec
LOCAL cInfo
LOCAL cDebNr  := Upper( Alltrim( iif(len(::aSearchControls) >= 1, ::aSearchControls[1]:editBuffer() ,"" ) ) )
LOCAL MaxRec  := Val(MaxDebRec)
LOCAL oProgress
LOCAL aProgrPos  := {::aListBox[1]:CurrentPos()[1],::aListBox[1]:CurrentPos()[2] + ::aListBox[1]:CurrentSize()[2] + 2}
LOCAL aProgrSize := {::aListBox[1]:CurrentSize()[1], 10 }

if ::Startup
   Return
Endif

::XbpElementPointer := ::aListBox[1]:getdata()

Select( DebWa )
OldRec  := Recno()
::aDebDat := {}
::aDebRec := {}

Do Case
   Case Empty(cDebNr)
   ::aDebDat := { {"Kein","","Suchbegriff","","","","",""} }
   ::aDebRec := {OldRec}
   Select(oldWa)
   ::AdjustXbpQuickBrowseCol( ::aListBox[1], .t., ::aDebDat, .f. )
   ::aListBox[1]:RefreshAll()
   ::DebSuchPos()
   ::DebIsSelection := .f.
   ::AbleButtons( {6,8}, {1,2,3,4,5,7} )
   ::aTabs[1]:Disable()
   RETURN
   Case Alltrim(cDebNr) == "*"
      cDebNr := Space(0)
      MaxRec := (DebWa)->(LastRec())
   Case val(cDebNr) > 0
      cDebNr := PadL( alltrim(cDebNr) , 8)
endcase



if ::DebIndexFlag == 4
   ::LoadDebData(cDebNr, SELF)
else

   if ::Connect(cDebNr, DebWa, ::DebIndexFlag )
      oProgress         := ProgressBar():new( ::aTabs[2] ,, aProgrPos,  aProgrSize)
      oProgress:create()
      oProgress:minimum := 1
      oProgress:maximum := Lastrec()
      oProgress:color   := GRA_CLR_BLUE

      *Do while Subs(Upper((DebWa)->Name),1,Len(Alltrim(cDebNr)) ) == Alltrim(Upper(cDebNr)) .and. !Eof() .and. rCnt < MaxRec

      Do while Subs( Alltrim( &(KundenKey[::DebIndexFlag]) ), 1, Len(Alltrim(cDebNr) ) ) == Alltrim(Upper(cDebNr)) .and. !Eof() .and. rCnt < MaxRec

         if NextAppEvent( , , ::aSearchControls[1] ) == xbeP_Keyboard
            oProgress:destroy()
            return
         endif

         oProgress:increment()

         aadd(::aDebDat, {} )
         aadd(::aDebDat[ rCnt], (DebWa)->DebNr )
         aadd(::aDebDat[ rCnt], Alltrim( (DebWa)->Name ) )
         aadd(::aDebDat[ rCnt], Alltrim( (DebWa)->Strasse) )
         aadd(::aDebDat[ rCnt], Alltrim((DebWa)->Ort) )
         aadd(::aDebDat[ rCnt], dToc( (DebWa)->ErfDat ) )
         aadd(::aDebDat[ rCnt], AllTrim((DebWa)->Tel ) )
         aadd(::aDebDat[ rCnt], AllTrim((DebWa)->Natel ) )
         aadd(::aDebDat[ rCnt], AllTrim((DebWa)->EMail ) )
         aadd(::aDebRec, Recno() )
         rCnt := rCnt + 1
         FSkip(1)
      Enddo
      oProgress:Destroy()
   Endif
endif


if Len(::aDebDat) == 0
   ::aDebDat := { {"Leer","","","","","","",""} }
   ::aDebRec := {OldRec}
   ::DebIsSelection := .f.
   ::aTabs[1]:Disable()
   ::AbleButtons( {6,8}, {1,2,3,4,5,7} )
else
   ::DebIsSelection := .t.
   ::aTabs[1]:Enable()
   ::AbleButtons( {1,2,3,4,5,6,7,8}, {} )
endif

if FileLock( DebWa )
   DbGoto(OldRec)
   DbUnlock()
endif

Select(oldWa)
::AdjustXbpQuickBrowseCol( ::aListBox[1], .t., ::aDebDat, .f. )
::aListBox[1]:RefreshAll()

if ::XbpElementPointer > Len( ::aDebDat ) .or. ::XbpElementPointer == 0
   ::XbpElementPointer := 1
endif

::aListBox[1]:goToRecord( ::XbpElementPointer )
::aListBox[1]:ItemMarked( { ::XbpElementPointer, 1 } )

RETURN


METHOD DebStamm:DebSuchPos()
*----------------
LOCAL aItem
LOCAL rPos
LOCAL RecToGo
LOCAL nPages
LOCAL OldFocus

if ::StartUp .or. ::EditMode
  Return
Endif


OldFocus := SetAppFocus()
aItem   := ::aListBox[1]:itemMarked() &&LB
nPages  := ::aListBox[1]:DataLink:getPos()
RecToGo := ::aListBox[1]:getdata()
rPos    := aItem:RowPos
Select(::aArea[KUNDEN])

if RecToGo == NIL
 *  MsgBox("Fehler in Array Index RecToGo", "DebStamm:XbpQuickBrowse()" )
   ::aListBox[1]:goTop()
   RecToGo := ::aListBox[1]:getdata()
   RecToGo := iif(RecToGo == NIL, 1, RecToGo)
Endif

if FileLock( ::aArea[KUNDEN] )
   DbGoto(::aDebRec[RecToGo])
   DbUnlock()
Endif

::ReadData()
::RefreshStatic()
::CheckEmailButton()

SetAppFocus(::aSearchControls[1])

Return



METHOD DebStamm:AddDeb()
*----------------
LOCAL oldRec     := RecNo()
LOCAL nButton
LOCAL CopyFlag   := .f.
LOCAL DataToCopy := {}
LOCAL ApWa       := ::aArea[KUNDEN]
Select(ApWa)

*nButton := ConfirmBox( ,  "Diesen Kunden kopieren?", "Kunden erfassn/kopieren", XBPMB_YESNO ,  XBPMB_QUESTION+XBPMB_APPMODAL+XBPMB_MOVEABLE )
*IF nButton == XBPMB_RET_YES
*   DataToCopy := ::ReadDb()
*ENDIF
::currentRec := RecNo()
*OrdSetFocus(1)
RestoreMem()
if AppendBlank( ApWa )
   ::AppendMode := .t.
   ::AppendRec  := RecNo()

   ::SetOldDebInfo()

*   if nButton == XBPMB_RET_YES
*      ::WriteDb(DataToCopy)
*   endif

   DbDebNr := ::GenDebNr( DbDebNr )

   if RecLock( ::AppendRec )
      Replace Firma   with dbFirma
      Replace MwstArt with "I"
      Replace Zahlart with Barzahlung
      Replace Erfdat  with Date()
      Replace MutDat  with Date()
      Replace DebGDat with Date()
      Replace DebEDat with Date()
      Replace DebADat with ctod( "01.01.2100")
      Replace DebNr   with dbDebNr
      Replace DebStat with "01"
      Replace DebMail with "01"
      DbRunLock(::AppendRec)
      SaveMem()
   else
      MsgBox( "Datensatz konnte nicht gesperrt werden.", "Datenbank Operation RecLock()")
      return .f.
   endif
Endif
Return .t.


METHOD DebStamm:GenDebNr(dbDebNr)
*----------------------------------
OrdSetFocus(1) &&DebNr
dbDebNr := PadL( Val( dbDebNr ) ,8, " " )
Do While .t.
   if FileLock( ::aArea[KUNDEN] )
      DbSeek(dbDebNr)
      DbUnlock()
   Endif
   if found()
      dbDebNr := PadL( Val( dbDebNr ) + 1,8, " " )
   else
      OrdSetFocus(::DebIndexFlag) &&Name
      if FileLock( ::aArea[KUNDEN] )
         DbGoto(::AppendRec )
         DbUnlock()
      Endif
      Return dbDebNr
   Endif
Enddo

RETURN ""


METHOD DebStamm:CloseKunden()
*--------------------
LOCAL nButton
Select(::aArea[KUNDEN])

if ::EditMode
   nButton := ConfirmBox( ,  "Geänderte Daten Sichern?", "Mitgliederstamm schliessen", XBPMB_YESNO ,  XBPMB_QUESTION+XBPMB_APPMODAL+XBPMB_MOVEABLE )
   IF nButton == XBPMB_RET_YES
      ::SaveDeb( .t.)
   ELSE
      ::SaveDeb(.f.)
   ENDIF
Endif

*if ::AppendMode
*   ::SaveDeb( .f.)
*Endif


Select(::aArea[KUNDEN] )
DbCloseArea()

Select(::aArea[TABELLEN] )
DbCloseArea()

Select(::aArea[DEBBEWEG] )
DbCloseArea()
Return .t.


METHOD DebStamm:SetTabs(TabId)
*------------------------
*LOCAL isSearchFocus := ::aSearchControls[1]:HasInputFocus()

if ::TabSelect == TabId
   Return .f.
Endif

if TabId <> 2
   if ::DataInEditMode()
       Return .f.
   Endif
Endif


if ::Startup
   Return .f.
endif

Select(::aArea[KUNDEN] )

Do case
   Case TabId == 1 &&Suchen

      if ::DataInEditMode()
         Return .t.
      Endif
      ::aTabs[2]:maximize()
      ::aTabs[1]:minimize()
      ::RefreshDeb()
      SetAppFocus( ::aSearchControls[1] )
      ::aSearchControls[1]:setMarked( {1, ::aSearchControls[1]:bufferLength + 1} )

   Case TabId == 2 &&Anzeigen
     ::aTabs[1]:maximize()
     ::aTabs[2]:minimize()
     ::DebSuchPos()
     if ::EditMode
        SetAppFocus(::aComboBox[1][1])
     else
        SetAppFocus( ::aTabs[1] )
     endif

Endcase
::TabFocus        := SetAppFocus()
::TabSelect := TabId
Return .t.


METHOD DebStamm:MutDeb(mStat)
*----------------
LOCAL xM, ym
LOCAL aL := 1
LOCAL aE := 1
LOCAL lVis
LOCAL mMark
LOCAL StartEControl := 3


For xM := StartEControl to len(::aEditControls)
   mMark := ::aEditControls[xM]:bufferLength
   ::aEditControls[xM]:setMarked( iif(mStat, {1,mMark+1}, {0,0}) )
Next
::ChangeButtons( {1}, {"Sichern"}, { {|| ::SaveDeb( .t.)  }  }  )
::ChangeButtons( {2}, {"Abbrechen"},   { {|| ::SaveDeb( .f.)  }  }  )
::AbleButtons( {1,2}, {3,4,5,6,7} )
::EditMode = mStat
SetAppFocus(::aComboBox[1][1])

Return .t.



METHOD DebStamm:VWDeb()
*-----------
LOCAL DebWa := ::aArea[KUNDEN]
if ::DataInEditMode()
   Return .f.
Endif
*::SetTabs( 2)
Select(DebWa)
FSkip(1)
if Eof()
   MsgBox( "Letzter Datensatz.", "Datenbank Operation FSkip()")
   FSkip(-1)
Endif
::ReadData()
::RefreshStatic()
::CheckEmailButton()
Return .t.

METHOD DebStamm:RWDeb()
*-----------
LOCAL DebWa := ::aArea[KUNDEN]

if ::DataInEditMode()
   Return .f.
Endif
*::SetTabs( 2)
Select(DebWa)
FSkip(-1)
if bof()
   MsgBox( "Erster Datensatz.", "Datenbank Operation FSkip()")
   DbGoTop()
Endif
::ReadData()
::RefreshStatic()
::CheckEmailButton()
Return .t.


METHOD  DebStamm:DelDeb( DelConfirm)
*----------
LOCAL nButton
LOCAL OldFocus := SetAppFocus()
LOCAL cDebNr   := (::aArea[KUNDEN] )->DebNr
LOCAL cDebName := (::aArea[KUNDEN] )->Name
::SetTabs( 2)
if DelConfirm
   nButton := ConfirmBox( ,  "Wollen Sie dieses Mitglied löschen ?", "Löschen", XBPMB_YESNO ,  XBPMB_QUESTION+XBPMB_APPMODAL+XBPMB_MOVEABLE )
   IF nButton == XBPMB_RET_NO
      Return .f.
   ENDIF
Endif
::LogDebChange(cDebNr,cDebName,"", "gelöscht")
if DelRec(::aArea[KUNDEN])
   Fskip(0)
   ::RefreshDeb()
Else
   MsgBox( "Datensatz konnte nicht gelöscht werden.", "Datenbank Operation DelRec()")
Endif
SetAppFocus(OldFocus)
return .t.


METHOD DebStamm:SaveDeb(SaveMode)
*-------------
* SaveMode .t. = Sichern, .f. = Abbrechen
LOCAL tTyp
LOCAL nTyp
LOCAL DebWa := ::aArea[KUNDEN]

if ::Startup
   Return
Endif

Select(::aArea[KUNDEN])

if SaveMode
   if !::AppendMode
      ::SetOldDebInfo()
   Endif
   ::WriteData()
   ::SetNewDebInfo()
   ::CheckForChanges()
   if RecLock( RecNo() )
      Replace MutDat with Date()
      DbrUnlock()
   Endif

   DbRefresh()
   ::MutDeb( .F.)
   ::AppendRec    := 0
   ::AppendMode   := .f.
   ::DebName := (::aArea[KUNDEN])->Name
   ::DebNr := (::aArea[KUNDEN])->DebNr
Else
   if ::AppendMode
      if FileLock( ::aArea[KUNDEN] )
         DbGoto(   ::AppendRec )
         DbUnlock()
      Endif
      ::DelDeb( .f.)
      if FileLock( ::aArea[KUNDEN] )
         DbGoto(   ::currentRec )
         DbUnlock()
      Endif
      ::AppendMode   := .f.
      ::AppendRec    := 0
      ::currentRec   := 0
   Endif

   ::MutDeb( .F.)
   ::ReadData()
   ::RefreshStatic()
Endif

::ResetButtons()
if ::DebMode == KUNDEN
   if Empty( (::aArea[KUNDEN])->EMail )
      ::AbleButtons( {1,2,3,4,6,7,8}, {5} )
   else
      ::AbleButtons( {1,2,3,4,5,6,7,8}, {} )
   endif
Endif

SetUpdateRequest( "ZDEB01", SELF )

Return .t.


METHOD DebStamm:scrollVertical( nScrlPos, nCommand )
*--------------------------------------------------------------------
LOCAL DebWa     := ::aArea[KUNDEN]
::SetTabs( 2 )
DO CASE
   CASE nCommand == XBPSB_PREVPOS
      FSkip(-1)
   CASE nCommand == XBPSB_NEXTPOS
      FSkip(1)
   CASE nCommand == XBPSB_PREVPAGE
      if FileLock(DebWa)
         DbGoPosition(nScrlPos)
         DbUnLock()
      endif
   CASE nCommand == XBPSB_NEXTPAGE
      if FileLock(DebWa)
         DbGoPosition(nScrlPos)
         DbUnLock()
      endif
   CASE nCommand == XBPSB_SLIDERTRACK
     if FileLock(DebWa)
         DbGoPosition(nScrlPos)
         DbUnLock()
      endif
   CASE nCommand == XBPSB_ENDTRACK
      if FileLock(DebWa)
         DbGoPosition(nScrlPos)
         DbUnLock()
      endif
   CASE nCommand == XBPSB_ENDSCROLL
      if FileLock(DebWa)
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
::RefreshStatic()
RETURN


METHOD DebStamm:ValidSearchKey(Key, mp2, SearchControl)
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
           ::SetTabs( 2)

      Case Key == xbeK_LEFT

      Case Key == xbeK_RIGHT

      Case Key == xbeK_ESC

      othe

      ::RefreshDeb()
   Endcase

Return rVal


METHOD DebStamm:DataInEditMode()
*--------------------------
LOCAL nButton
LOCAL oFocus := SetAppFocus()

if ::EditMode
   nButton := ConfirmBox( ,  "Daten sichern ?", "Mitglieder erfassn/mutieren", XBPMB_YESNO ,  XBPMB_QUESTION+XBPMB_APPMODAL+XBPMB_MOVEABLE )
   SetAppFocus(oFocus)
   IF nButton == XBPMB_RET_YES
      ::SaveDeb( .t.)
      return .f.
   Else
      ::SaveDeb( .f.)
      Return .f.
   ENDIF
Endif
Return .f.


METHOD DebStamm:RegisterSLEFocus()
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



METHOD DebStamm:PrintKunden()
*----------------------------
*LOCAL SearchWord := Upper( Alltrim( iif(len(::aSearchControls) >= 1, ::aSearchControls[1]:editBuffer() ,"" ) ) )

LOCAL SearchWord := ""

::pFilter := { {},{},{},{},{},{} }
::pFilter[1] := {KUNDEN, 3, "Name", SearchWord }
::pFilter[2] := {{"KGR", , "017" }, {"DEBART",, "014"},{"DEBMAIL",, "024"}  }
::pFilter[3] := {}

::pFilter[4] := {}
::pFilter[5] := {}
::pFilter[6] := {}


If SelectDataBox(SELF,,,@::pFilter,"Mitglieder Auswahl")
   PrintForm("Deblist.For", ::pFilter, SELF)
Endif


Return .t.


PROCEDURE ZKUNDEN(DebMode, DebName, oFrom)
   LOCAL nEvent, mp1, mp2, oXbp
   LOCAL oDlg, DrawingArea
   LOCAL aPos[2], ASize
   LOCAL oOwner, oParent

   LOCAL oWinMenu
   LOCAL aContMenu := {}
   LOCAL DebWa
   LOCAL TabWa
   LOCAL LogWa
   LOCAL lVis
   LOCAL aLen
   LOCAL i
   LOCAL KeybEditCheck := .f.
   LOCAL aNewSize[2]

   oFrom := iif(oFrom == NIL, AppDeskTop(), oFrom)

   OpenDb(DataDrive, BewegungsFile, BewegungsIndex, BewegungsKey)
   LogWa := Select()
   OpenDb(DataDrive, TabellenFile, TabellenIndex, TabellenKey)
   TabWa := Select()
   OpenDb(DataDrive, KundenFile, KundenIndex, KundenKey)
   DebWa   := Select()

   aSize       := DialogSize()
   aPos        := DialogPos()
   oParent  := AppDesktop()
   oOwner   := AppDesktop()

   lVis     := .f.

*   // Anwendungsfenster erzeugen (application window)

   oDlg := DebStamm():new( oParent ,oOwner , aPos, aSize, , .F.)
   oDlg:taskList := .T.
   oDlg:title :=  "Mitgliederstamm"
   oDlg:setDisplayFocus := {||    WinMenu():checkItem( oDlg, KUNDEN )}
   oDlg:create()

   oDlg:aArea[DEBBEWEG]  := LogWa
   oDlg:aArea[TABELLEN]  := TabWa
   oDlg:aArea[KUNDEN]    := DebWa
   oDlg:DebMode          := DebMode

   drawingArea := oDlg:drawingArea
   drawingArea:setColorBG( GRA_CLR_BACKGROUND )
   drawingArea:setColorFG( GRA_CLR_BLACK      )
   drawingArea:setFontCompoundName( "8.Arial" )

   oDlg:DebDebPage(DrawingArea)

   oDlg:windowMenu  := WinMenu()
   WinMenu():addItem( oDlg,  NIL )
   WinMenu():checkItem( oDlg, KUNDEN )

   oDlg:RegisterOldButtons()

   SetAppFocus( oDlg )

   oDlg:Startup := .f.
   *oDlg:CheckDebStatus()  //Austritte auf 99 setzen

   oDlg:SetDebFilter(oDlg:oComboFilt) // Beinhaltet ::Refreshdeb()

   oDlg:SetTabs(1)

RETURN



METHOD DebStamm:DebDebPage(DrawingArea)
*---------------------------------------

   LOCAL oXbp
   LOCAL oTab
   LOCAL oListBox
   LOCAL aContMenu := {}
   LOCAL DebWa       := ::aArea[KUNDEN]
   LOCAL TabWa     := ::aArea[TABELLEN]
   LOCAL lVis      := .t.
   LOCAL aLen
   LOCAL aData
   LOCAL i
   LOCAL vPos := -30
   LOCAL KeybEditCheck := .f.
   LOCAL aDebHead    := { 'KD Nummer','Name','Strasse','Ort','Erfasst', 'Telefon', 'Natel', 'EMail' }
   LOCAL aSize
   LOCAL aPos[2]


   aSize    := Drawingarea:currentSize()
   aPos[1]  := 12
   aPos[2]  := 12
   aSize[1] := aSize[1] - 24
   aSize[2] := aSize[2] - 24


   oTab := XbpTabPage():new( drawingArea, , aPos, aSize )

   oTab:caption := "Anzeigen"
   oTab:clipSiblings := .T.
   oTab:minimized := .F.
   oTab:preOffset := 20
   oTab:postOffset := 60
   oTab:tabActivate := {|| ::SetTabs(2) }
   oTab:create()
   oTab:disable()
   AAdd ( ::aTabs, oTab )

   *ZResize(  DrawingArea:CurrentSize(), oTab, {}, {700,490}, 24)


   oTab := XbpTabPage():new( drawingArea, , aPos, aSize )
   oTab:caption := "Suchen"
   oTab:clipSiblings := .T.
   oTab:minimized := .F.
   oTab:preOffset := 0
   oTab:postOffset := 80
   oTab:tabActivate := {|| ::SetTabs(1) }
   oTab:create()
   AAdd ( ::aTabs, oTab )

   *ZResize(  DrawingArea:CurrentSize(), oTab, {}, {700,490}, 24)


   * KUNDENInfo

   DrawingArea := ::aTabs[1]

   oXbp := XbpStatic():new( drawingArea, , {48,444 + vPos}, {60,24} )
   oXbp:caption := "Firma:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {120,444 + vPos}, {36,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 3
   oXbp:editable := .F.
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( (DebWa)->FIRMA ), (DebWa)->FIRMA := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .f., , ,)

   oXbp := XbpStatic():new( drawingArea, , {48,420 + vPos}, {60,24} )
   oXbp:caption := "MitgliedNr:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {120,420 + vPos}, {60,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 8
   oXbp:editable := .F.
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( (DebWa)->DEBNR ), (DebWa)->DEBNR := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpStatic():new( drawingArea, , {48,384 + vPos}, {60,24} )
   oXbp:caption := "Anrede:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()


   oXbp := XbpCombobox():new( drawingArea, , {120,324 + vPos}, {132,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabStop := .F.
   oXbp:Type    := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterElement(@oXbp, .t., "010", DebWa, "Anrede")

   oXbp := XbpStatic():new( drawingArea, , {48,360 + vPos}, {60,24} )
   oXbp:caption := "Name:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {120,360 + vPos}, {180,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 30
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( (DebWa)->NAME ), (DebWa)->NAME := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( drawingArea, , {24,336 + vPos}, {84,24} )
   oXbp:caption := "Bezeichnung 1:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {120,336 + vPos}, {180,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 30
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( (DebWa)->BEZ1 ), (DebWa)->BEZ1 := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( drawingArea, , {24,312 + vPos}, {84,24} )
   oXbp:caption := "Bezeichnung 2:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {120,312 + vPos}, {180,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 30
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( (DebWa)->BEZ2 ), (DebWa)->BEZ2 := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( drawingArea, , {48,288 + vPos}, {60,24} )
   oXbp:caption := "Strasse:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {120,288 + vPos}, {180,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 30
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( (DebWa)->STRASSE ), (DebWa)->STRASSE := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)

   oXbp := XbpStatic():new( drawingArea, , {48,264 + vPos}, {60,24} )
   oXbp:caption := "Plz Ort:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {120,264 + vPos}, {180,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 30
   oXbp:tabStop := .F.
   oXbp:validate:= {|Obj|  ::ValidOrt( Obj )  }
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( (DebWa)->ORT ), (DebWa)->ORT := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( drawingArea, , {48,240 + vPos}, {60,24} )
   oXbp:caption := "Matchcode:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {120,240 + vPos}, {48,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 8
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( (DebWa)->MATCHCODE ), (DebWa)->MATCHCODE := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( drawingArea, , {48,204 + vPos}, {60,24} )
   oXbp:caption := "Land:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( drawingArea, , {120,144 + vPos}, {132,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabStop := .F.
   oXbp:Type    := XBPCOMBO_DROPDOWNLIST

   oXbp:create()
   ::RegisterElement(@oXbp, .t., "006", DebWa, "Land")

   oXbp := XbpStatic():new( drawingArea, , {24,180 + vPos}, {84,24} )
   oXbp:caption := "Mitglied Gruppe:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( drawingArea, , {120,120 + vPos}, {132,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabStop := .F.
   oXbp:Type    := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterElement(@oXbp, .t., "017", DebWa, "KGR")

   oXbp := XbpStatic():new( drawingArea, , {48,156 + vPos}, {60,24} )
   oXbp:caption := "Mitglied Art:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( drawingArea, , {120,96 + vPos}, {132,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabStop := .F.
   oXbp:Type    := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterElement(@oXbp, .t., "014", DebWa, "DebArt")

   oXbp := XbpStatic():new( drawingArea, , {48,132 + vPos}, {60,24} )
   oXbp:caption := "Zahl Art:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( drawingArea, , {120,72 + vPos}, {132,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabStop := .F.
   oXbp:Type    := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterElement(@oXbp, .t., "007", DebWa, "ZahlArt")


   oXbp := XbpStatic():new( drawingArea, , {48,108 + vPos}, {60,24} )
   oXbp:caption := "Status:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( drawingArea, , {120,48 + vPos}, {132,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabStop := .F.
   oXbp:Type    := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterElement(@oXbp, .t., "023", DebWa, "DebStat")

   oXbp := XbpStatic():new( drawingArea, , {48,84 + vPos}, {60,24} )
   oXbp:caption := "Mailings:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpCombobox():new( drawingArea, , {120,24 + vPos}, {132,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabStop := .F.
   oXbp:Type    := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::RegisterElement(@oXbp, .t., "024", DebWa, "DebMail")

   oXbp := XbpStatic():new( drawingArea, , {360,384 + vPos}, {60,24} )
   oXbp:caption := "Telelefon P:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {432,384 + vPos}, {120,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 17
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( (DebWa)->TEL ), (DebWa)->TEL := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( drawingArea, , {360,360 + vPos}, {60,24} )
   oXbp:caption := "Telefon G:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {432,360 + vPos}, {120,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 17
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( (DebWa)->TELG ), (DebWa)->TELG := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( drawingArea, , {360,336 + vPos}, {60,24} )
   oXbp:caption := "Natel:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {432,336 + vPos}, {120,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 17
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( (DebWa)->NATEL ), (DebWa)->NATEL := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( drawingArea, , {360,312 + vPos}, {60,24} )
   oXbp:caption := "Fax:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {432,312 + vPos}, {120,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 17
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( (DebWa)->FAX ), (DebWa)->FAX := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( drawingArea, , {360,288 + vPos}, {60,24} )
   oXbp:caption := "E Mail:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {432,288 + vPos}, {240,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 50
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, Trim( (DebWa)->EMAIL ), (DebWa)->EMAIL := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( drawingArea, , {360,252 + vPos}, {60,24} )
   oXbp:caption := "Geburtstag:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {432,252 + vPos}, {64,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 10
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, DtoC( (DebWa)->DebGDat ), (DebWa)->DebGDat := CtoD(x) ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( drawingArea, , {360,228 + vPos}, {60,24} )
   oXbp:caption := "Eintritt:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {432,228 + vPos}, {64,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 10
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, DtoC( (DebWa)->DebEDat ), (DebWa)->DebEDat := CtoD(x) ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( drawingArea, , {360,204 + vPos}, {60,24} )
   oXbp:caption := "Austritt:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {432,204 + vPos}, {64,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 10
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, DtoC( (DebWa)->DebADat ), (DebWa)->DebADat := CtoD(x) ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpStatic():new( drawingArea, , {360,168 + vPos}, {60,24} )
   oXbp:caption := "Notitz:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpMle():new( drawingArea, , {432,84 + vPos}, {192,108}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, (DebWa)->NOTIZ, (DebWa)->NOTIZ := x ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpPushButton():new( drawingArea, , {12,12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Erfassen"
   oXbp:tabStop := .F.
   oXbp:create()
   oXbp:activate := {|| ::AddDeb(), ::ReadData(), ::MutDeb(.t.) }
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpPushButton():new( drawingArea, , {96,12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Mutieren"
   oXbp:tabStop := .F.
   oXbp:create()
   oXbp:activate := {|| ::MutDeb(.t.) }
   ::RegisterElement(@oXbp, .t.,,,)


   oXbp := XbpPushButton():new( drawingArea, , {180,12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Löschen"
   oXbp:tabStop := .F.
   oXbp:create()
   oXbp:activate := {|| ::DelDeb(.t.), ::ReadData() }
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpPushButton():new( drawingArea, , {264,12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Drucken"
   oXbp:tabStop := .F.
   oXbp:create()
   oXbp:activate := {|| ::PrintKunden() }
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpPushButton():new( drawingArea, , {348,12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "EMail"
   oXbp:tabStop := .F.
   oXbp:create()
   oXbp:activate := {|| ::SendEMail()  }
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpPushButton():new( drawingArea, , {432,12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "<<"
   oXbp:tabStop := .F.
   oXbp:create()
   oXbp:activate := {|| ::RwDeb()  }
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpPushButton():new( drawingArea, , {516,12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := ">>"
   oXbp:tabStop := .F.
   oXbp:create()
   oXbp:activate := {|| ::VwDeb()  }
   ::RegisterElement(@oXbp, .f.,,,)


   oXbp := XbpPushButton():new( drawingArea, , {::aTabs[1]:CurrentSize()[1]-96,12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Beenden"
   oXbp:tabStop := .F.
   oXbp:create()
   oXbp:activate := {|| WinMenu():AbleItem( MENU01,2,.t.), PostAppEvent(xbeP_Close,,,SELF) }
   ::RegisterElement(@oXbp, .f.,,,)


   oXbp := XbpStatic():new( drawingArea, , {360,444 + vPos}, {60,24} )
   oXbp:caption := "Erfasst:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpStatic():new( drawingArea, , {360,420 + vPos}, {60,24} )
   oXbp:caption := "Mutiert:"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
   oXbp:create()

   oXbp := XbpSLE():new( drawingArea, , {432,444 + vPos}, {64,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 10
   oXbp:editable := .F.
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, DtoC( (DebWa)->ERFDAT ), (DebWa)->ERFDAT := CtoD(x) ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpSLE():new( drawingArea, , {432,420 + vPos}, {64,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:bufferLength := 10
   oXbp:editable := .F.
   oXbp:tabStop := .F.
   oXbp:dataLink := {|x| IIf( PCOUNT()==0, DtoC( (DebWa)->MUTDAT ), (DebWa)->MUTDAT := CtoD(x) ) }
   oXbp:create():setData()
   ::RegisterElement(@oXbp, .f.,,,)


* KUNDEN suchen

   oXbp := XbpCombobox():new( ::aTabs[2], , {213,380 + vPos}, {150,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:Type    := XBPCOMBO_DROPDOWNLIST
   oXbp:create()

   oXbp:addItem("Mitgliednummer suchen")
   oXbp:addItem("Matchcode suchen")
   oXbp:addItem("Name suchen")
   oXbp:addItem("Freie Suche")

   oXbp:SetData({Val(KundenStartIndexFlag)})
   oXbp:ItemSelected := {|mp1, mp2, obj| ::SelectDebIndex(Obj) }


   oXbp := XbpCombobox():new( ::aTabs[2], , {373,380 + vPos}, {150,84}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:Type    := XBPCOMBO_DROPDOWNLIST
   oXbp:create()
   ::MoveTabToListBox(@oXbp, "017", "01", 2)
   oXbp:SetData({1})
   oXbp:ItemSelected := {|mp1, mp2, obj| ::SetDebFilter(Obj) }
   ::oComboFilt := oXbp

   oXbp := XbpSLE():new( ::aTabs[2], , {12,440 + vPos}, {192,24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:clipSiblings := .T.
   oXbp:KeyBoard := {|Key,x,obj| ::ValidSearchKey(Key,obj,1) }
   oXbp:create()
   oXbp:SetData("*")
   oXbp:SetMarked({1,1})
   AAdd ( ::aSearchControls, oXbp )

   oListBox := XbpQuickBrowse():new( ::aTabs[2], , {12,48}, {aSize[1]-24 ,371 + vPos} )
   oListBox:dataLink := DacPagedDataStore():new(::aDebDat)
   oListBox:itemSelected := {|| ::SetTabs(2) }
   oListBox:Style      := XBP_STYLE_PLAIN
   oListBox:hScroll    := .F.
   oListBox:vScroll    := .F.
   oListBox:create()
   oListBox:setHeader( aDebHead )
   oListBox:setFontCompoundName( "7.Arial" )
   oListBox:setRowHeight( 14 )
   oListbox:SetColWidth ( 45, 1 )
   olistBox:dataArea:setAlignment( 1, XBPALIGN_RIGHT + XBPALIGN_VCENTER )
   oListBox:heading:setAlignment( 1, XBPALIGN_RIGHT + XBPALIGN_VCENTER )

   For i := 2 to 4
     oListbox:SetColWidth ( 90, i )
     olistBox:dataArea:setAlignment( i, XBPALIGN_LEFT + XBPALIGN_VCENTER )
     oListBox:heading:setAlignment( i, XBPALIGN_LEFT + XBPALIGN_VCENTER )
   next
   For i := 5 to 5
     oListbox:SetColWidth ( 60, i )
     olistBox:dataArea:setAlignment( i, XBPALIGN_LEFT + XBPALIGN_VCENTER )
     oListBox:heading:setAlignment( i, XBPALIGN_LEFT + XBPALIGN_VCENTER )
   next

   For i := 6 to 7
     oListbox:SetColWidth ( 80, i )
     olistBox:dataArea:setAlignment( i, XBPALIGN_RIGHT + XBPALIGN_VCENTER )
     oListBox:heading:setAlignment( i, XBPALIGN_RIGHT + XBPALIGN_VCENTER )
   next

   For i := 8 to 8
     oListbox:SetColWidth ( 156, i )
     olistBox:dataArea:setAlignment( i, XBPALIGN_LEFT + XBPALIGN_VCENTER )
     oListBox:heading:setAlignment( i, XBPALIGN_LEFT + XBPALIGN_VCENTER )
   next


   AAdd( ::aListBox, oListBox, 1 )

   oXbp := XbpPushButton():new( ::aTabs[2], , {12,12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Drucken"
   oXbp:tabStop := .F.
   oXbp:create()
   oXbp:activate := {|| ::PrintKunden() }
   ::RegisterElement(@oXbp, .f.,,,)


   oXbp := XbpPushButton():new( ::aTabs[2], , {::aTabs[2]:CurrentSize()[1]-96,12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Beenden"
   oXbp:tabStop := .F.
   oXbp:create()
   oXbp:activate := {|| WinMenu():AbleItem( MENU01,2,.t.), PostAppEvent(xbeP_Close,,, SELF) }
   ::RegisterElement(@oXbp, .f.,,,)
   *::SetDebFilter(::oComboFilt) // Beinhaltet ::Refreshdeb()
   *::RefreshDeb()  && Datalink
   oListBox:show()


RETURN


METHOD DebStamm:AutoEdit(obj)
*----------------------------

if ! ::EditMode
   ::MutDeb(.t.)
   SetAppFocus(obj)
Endif

Return


METHOD DebStamm:ValidOrt(Obj)
*----------------------------
LOCAL PlzWa
LOCAL SDB    := Obj:EditBuffer()
LOCAL SDB2   := SDB

* Das erste Feld (KreNr) wird mit der Länge (10) zurückgegeben.
* Suchlauf über (SDB), Index (2) in (KreWa)

if Empty(SDB)
   MSGBox("Kein leerer Suchbegriff erlaubt","ValidOrt()")
   Return .f.
endif

OpenDb(DataDrive, PlzFile, PlzIndex, PlzKey)
PlzWa := Select()
::aArea[POSTLEITZAHL] := Select()
::GetDBKey(@SDB, PlzWa, {1, len(PlzKey)}, {"plzort"}, 30, "Ort auslesen" )

Select(PlzWa)
DbCloseArea()

if Empty(SDB)
   Obj:SetData(SDB2)
   MSGBox("Postleitzahl und Ort sind ungültig","ValidOrt()")
   Return .t.
else
   Obj:SetData(SDB)
   Return .t.
Endif

Return


METHOD DebStamm:SendEMail()
*--------------------------
LOCAL DebWa := ::aArea[KUNDEN]
*LOCAL exeStr := "/C START mailto:"+(DebWa)->EMail
LOCAL exeStr := "/C START mailto:"+(DebWa)->EMail

*RunShell( '""', "%ProgramFiles%\Outlook Express\msimn.exe" )
*RunShell( "/c /q START EXPLORER.EXE")
RunShell( exeStr,,.t. )
Return

METHOD DebStamm:UpdateDeb()
*--------------------------
LOCAL DebWa := ::aArea[KUNDEN]

if ::Startup .or. ::EditMode
   Return
Endif

if ::TabSelect == 2
   Select(DebWa)
   FSkip(0)
   ::ReadData()
   ::RefreshStatic()
Endif

Return


METHOD DebStamm:SelectDebIndex(Obj)
*----------------------------------
LOCAL Selection
Selection := obj:getData()
::SetDebIndex( iif(len(Selection)<1,1,Selection[1]) )
Return


METHOD DebStamm:SetDebIndex(Index)
*--------------------------------------
LOCAL nDebRec
LOCAL DebWa := ::aArea[KUNDEN]
Select( DebWa )
nDebRec := RecNo()
OrdSetFocus(Index)
::DebIndexFlag := Index
::RefreshDeb()

Return .t.

METHOD DebStamm:CheckForChanges()
*--------------------------------

LOCAL nDebFields       := len(::aOldDeb)
LOCAL x                := 1
LOCAL DebWa            := ::aArea[KUNDEN]
LOCAL LogWa            := ::aArea[DEBBEWEG]
LOCAL cDebNr           := ""
LOCAL cDebName         := ""
LOCAL cDebFieldContent := ""

Select( DebWa )
cDebNr   := (DebWa)->Debnr
cDebName := (DebWa)->Name

For x := 1 to nDebFields
   if !( ::aOldDeb[x] == ::aNewDeb[x])
      Do Case
         Case ValType( ::aOldDeb[x] ) ==  "C"
            cDebFieldContent := ::aOldDeb[x] + " -> " + ::aNewDeb[x]
         Case ValType( ::aOldDeb[x] ) ==  "N"
            cDebFieldContent := Str( ::aOldDeb[x] ) + " -> " + Str( ::aNewDeb[x] )
         Case ValType( ::aOldDeb[x] ) ==  "M"
            cDebFieldContent := ::aOldDeb[x] + " -> " + ::aNewDeb[x]
         Case ValType( ::aOldDeb[x] ) ==  "D"
            cDebFieldContent := DToC( ::aOldDeb[x]) + " -> " + DToC( ::aNewDeb[x] )
         Case ValType( ::aOldDeb[x] ) ==  "L"
            cDebFieldContent := Transform( ::aOldDeb[x], "L" ) + " -> " + Transform( ::aNewDeb[x], "L")
      EndCase
   ::LogDebChange(cDebNr, cDebName, ::aDebFields[x], cDebFieldContent  )
   endif

Next

Return



METHOD DebStamm:LogDebChange(cDebNr, cDebName, cDebfield, cDebNewValue )
*-------------------------------------------------------------

LOCAL DebWa := ::aArea[KUNDEN]
LOCAL LogWa := ::aArea[DEBBEWEG]
LOCAL nRec
LOCAL cDebOldValue

if Empty( cDebNr)
   Return
endif


Select(LogWa)
if AppendBlank( LogWa )
   nRec := RecNo()
   if RecLock( nRec )
      Replace DebNr   with cDebNr
      Replace DebName with cDebName
      Replace FName   with cDebField
      Replace FValue  with cDebNewValue
      Replace MutDat  with Date()
      Replace MutTime with Time()
      DbRunLock(nRec)
   else
      MsgBox( "Datensatz konnte nicht gesperrt werden.", "Datenbank Operation RecLock()")
   endif
Endif
Select( DebWa )
Return


METHOD DebStamm:SetOldDebInfo()
*---------------------
LOCAL i := 0
LOCAL DebWa := ::aArea[KUNDEN]
Select(DebWa)
::aOldDeb    := Array (FCount())
::aDebFields := Array (FCount())
For i:= 1 to len(::aOldDeb)
   ::aOldDeb[i]    := FieldGet(i)
   ::aDebFields[i] := FieldName(i)
next
Return

METHOD DebStamm:SetNewDebInfo()
*---------------------
LOCAL i := 0
LOCAL DebWa := ::aArea[KUNDEN]
Select(DebWa)
::aNewDeb   := Array (FCount())
For i:= 1 to len(::aNewDeb)
   ::aNewDeb[i] := FieldGet(i)
next
Return



METHOD DebStamm:CheckEMailButton()
*---------------------------------
if Empty( (::aArea[KUNDEN])->EMail )
   ::AbleButtons( {}, {5} )
else
   ::AbleButtons( {5}, {} )
endif
Return


METHOD DebStamm:CheckDebStatus()
*---------------------
LOCAL RecNo := 0
LOCAL nRec  := 0
LOCAL DebWa := ::aArea[KUNDEN]

Select(DebWa)
RecNo := RecNo()
DbGoTop()
Do While !Eof()
   nRec := RecNo()
   if !Empty(DebADat) .and. DebADat < Date()
      If RecLock(nRec)
         Replace DebStat with "99"
         DbRunLock(nRec)
      Endif
   endif
   if Empty(Email) .and. DebMail <> "99"
      If RecLock(nRec)
         Replace DebMail with "99"
         DbRunLock(nRec)
      Endif
   endif
   fSkip(1)
Enddo

if FileLock( DebWa )
   DbGoto(RecNo)
   DbUnlock()
endif
Return


METHOD DebStamm:SetDebFilter(Obj)
*-----------------------------------
LOCAL i
LOCAL ComboMarked := Obj:GetData()
LOCAL nComboItems := 0
LOCAL cKGR := "01"
LOCAL DebWa := ::aArea[KUNDEN]

If ::StartUp
   Return
Endif

if len( ComboMarked ) <> 1
   Return
else
   nMarked := ComboMarked[1]
Endif

cKGR := Subs( Obj:GetItem( nMarked ),1,2)

Select(DebWa)
DbSetFilter( {|| (DebWa)->KGR == cKGR } )

If FileLock(DebWa)
   DbGoTop()
   DbUnlock()
Endif

::SetTitle("Mitgliederstamm -> Auswahl " + Alltrim( ::GetTabText("017", cKGR) )  )
::RefreshDeb()
RETURN