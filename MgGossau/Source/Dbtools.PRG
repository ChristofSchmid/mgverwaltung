#include "Gra.ch"
#include "Xbp.ch"
#include "Appevent.ch"
#include "common.ch"
#include "Font.ch"
#include "DMLB.ch"
#include "MGV.CH"


* Methoden

CLASS DataDialog FROM XbpDialog
   PROTECTED:
     VAR keyControls             // Liste von XBPs fÅr Tastaturnavigation
     VAR keyboardBlock           // Codeblock fÅr xbeP_Keyboard Ereignisse
   EXPORTED:
     VAR area      READONLY      // aktueller Arbeitsbereich
     VAR AppendMode              // .f.
     VAR AppendRec
     VAR currentRec
     VAR aEditControls           // Xbp's
     VAR aDataCheckBoxes
     VAR aSearchControls
     VAR aFlowControl
     VAR aTabs
     VAR EditMode
     VAR aStaticText
     VAR aCheckBoxes
     VAR aStaticTab
     VAR aButtons
     VAR aOldButtons
     VAR aListBox
     VAR aComboBox
     VAR aComboBoxes
     VAR aComboBox1
     VAR aMemoBox
     VAR aRadioButtons
     VAR aArea
     VAR TabText
     VAR TabArr
     VAR StartUp
     VAR bLbClick
     VAR CallObj

     VAR bKillInputFocus
     VAR aRecs

     VAR Close                   // codeBlock "Fenster schliessen"
     VAR newTitle                // Codeblock um Titel zu Ñndern
     VAR contextMenu             // KontextmenÅ fÅr Datendialog
     VAR windowMenu              // Dynamisches FenstermenÅ
                                 // im Anwendungsfenster
     VAR currentControl          // Aktuelles Edit Control
     VAR currentArea
     VAR aChildList
     VAR SystemUser

     VAR aDebDat
     VAR aDebRec

     METHOD notify               // Nachricht von DBO verarbeiten
     METHOD create               // Registrieren area
     METHOD WriteData
     METHOD ReadData
     METHOD Destroy
     METHOD Close
     METHOD RefreshStatic
     METHOD GetDBKey
     METHOD GetTabText
     METHOD GetTabArr
     METHOD MoveTabToListBox
     METHOD Connect
     METHOD SoftConnect
     METHOD WriteDb
     METHOD ReadDb
     METHOD RegisterSLEFocus
     METHOD HandleFocus
     METHOD ValidKey
     METHOD AbleButtons
     METHOD ChangeButtons
     METHOD ResetButtons
     METHOD RegisterOldButtons
     METHOD RegisterKeyHandler
     METHOD RegisterElement
     METHOD ClearElements
     METHOD RestoreElements
     METHOD nValidate
     METHOD ValidnSLE
     METHOD AdjustXbpQuickBrowseCol
     METHOD DontChangeSLEValue
     METHOD GetVSTInfo
     METHOD FieldBlockTrimmed
     METHOD LoadDebData
     METHOD GetTabMemo

ENDCLASS


METHOD DataDialog:notify( nEvent, mp1, mp2 )
*  LOCAL cList
*  cList :=  DbClientList()

  *DBO_CLOSE_REQUEST  Datei in der Workarea wird geschlossen
  *DBO_BULK_REQUEST   Zeitaufwendige Datenbank-Operation beginnt
  *DBO_BULK_COMPLETE  Zeitaufwendige Datenbank-Operation ist abgeschlossen
  *DBO_CHANGE_ORDER   Ordnung, in der Daten‰tze vorliegen,wurde ge‰ndert (logische oder physikalische Ordnung)
  *DBO_TABLE_UPDATE   Daten im Datensatz wurden ver‰ndert
  *DBO_TABLE_DELETED  Datensatz wurde gelˆscht
  *DBO_TABLE_APPEND   Neuer Datensatz wurde erzeugt
  *DBO_MOVE_PROLOG    Satzzeiger wird ver‰ndert
  *DBO_MOVE_DONE      ƒnderung des Satzzeigers ist abgeschlossen
  *DBO_GOBOTTOM       Satzzeiger wurde auf Anfang gesetzt
  *DBO_GOTOP          Satzzeiger wurde auf Ende gesetzt

Return self


   IF !nEvent == xbeDBO_Notify
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


METHOD DataDialog:create( oParent, oOwner , ;
                          aPos   , aSize  , ;
                          aPParam, lVisible )

   ::xbpDialog:create( oParent, oOwner , ;
                       aPos   , aSize  , ;
                       aPParam, lVisible )



   ::appendMode      := .f.
   ::appendRec       := 0
   ::currentRec      := 0
   ::aEditControls   := {}
   ::aDataCheckBoxes := {}
   ::aSearchControls := {}
   ::aFlowControl    := {}
   ::aCheckBoxes     := {}
   ::aStaticText     := {}
   ::aStaticTab      := {}  && Tabellen
   ::aTabs           := {}  && TabPages
   ::aButtons        := {}
   ::aOldButtons     := {{},{},{}}
   ::aListBox        := {}
   ::aComboBox       := {{},{},{},{},{}}
   ::aComboBoxes     := {}
   ::aComboBox1      := {}
   ::aMemoBox        := {}
   ::aRadioButtons   := {}
   ::aArea           := Array(100)
   ::currentControl  := 0
   ::currentArea     := 0
   ::TabText         := ""
   ::TabArr          := {}
   ::EditMode        := .f.
   ::StartUp         := .t.
   ::bLbClick        := {|nKey,x,obj| NIL }
   ::bKillInputFocus := {| uNIL1, uNIL2, obj |::nValidate(obj) }
   ::aRecs           := {}
   ::aChildList      := NIL
   ::Resize          := {| aOldSize, aNewSize, obj | ResizeDataDialog(obj, aOldSize, aNewSize, obj:aChildList) }
   ::move            := {| aOldPos, aNewPos, obj | SaveDialogPosAndSize(Obj) }
   ::SystemUser      := ""
   ::CallObj         := NIL

   SetMousePointer(1, RootWindow() )

RETURN self


METHOD DataDialog:WriteData()
*-----------------------------
LOCAL OldWa       := Select()
LOCAL LenaControl := Len(::aEditcontrols)
LOCAL LencControl := Len(::aDataCheckBoxes)
LOCAL LenbControl := Len(::aComboBox[3])
LOCAL LenmControl := Len(::aMemoBox)
LOCAL aCombo      := {1}
LOCAL ComboField
LOCAL ComboLen    := 1
LOCAL dRecNo
LOCAL x

dRecNo := Recno()
if RecLock(dRecNo)

   For x := 1 to LenaControl
     ::aEditcontrols[x]:getData()
   Next


   For x := 1 to LencControl
      ::aDataCheckBoxes[x]:GetData()
   Next

   For x := 1 to LenbControl
       if ::aComboBox[1][x]:XbpSLE:Editable
          aCombo := ::aComboBox[1][x]:GetData()
          aCombo := iif( len(aCombo) == 0, {1}, aCombo  )
          ComboField := ::aComboBox[3][x]
          ComboLen   := ::aComboBox[5][x]

          if !::aComboBox[4][x] == NIL
             Repl &ComboField with Subs( ::aComboBox[1][x]:GetItem( aCombo[1] ),1,ComboLen)
          else
             &ComboField := Subs( ::aComboBox[1][x]:GetItem( aCombo[1] ),1,ComboLen)
          endif

          *if ComboField <> NIL
          *   Repl &ComboField with Subs( ::aComboBox[1][x]:GetItem( aCombo[1] ),1,2)
          *Endif
       endif
   Next

   For x := 1 to LenmControl
      ::aMemoBox[x]:getData()
   Next

   DbRUnlock(dRecNo)
   DbCommit()
   fSkip(0)
else
   MsgBox("Record konnte nicht geschrieben werden", "Interne Meldung")
   Return .f.
Endif

Select(OldWa)
Return .t.


METHOD DataDialog:ReadData()
*----------------------------
LOCAL LenaControl := Len(::aEditControls)
LOCAL aComboID
LOCAL nComboItems
LOCAL x, i
LOCAL TabSelect := {0}
LOCAL A,B,C

For x := 1 to LenaControl
   if ::aEditcontrols[x]:Changed()
   *    MSGBOX("ƒnderung im Feld "+Alltrim(Str(x)) + " nicht gespeichert","Datenbank Operation")
   endif
   ::aEditcontrols[x]:Clear()
   ::aEditcontrols[x]:SetData()
Next

LenaControl := Len(::aDataCheckBoxes)

For x := 1 to LenaControl
   ::aDataCheckBoxes[x]:SetData()
Next

LenaControl := Len(::aComboBox[1])
For x := 1 to LenaControl
    nComboItems := ::aComboBox[1][x]:numItems()
    TabSelect[1] := 1
    For i:= 1 to nComboItems
        *if At( Eval( ::aComboBox[2][x] ), ::aComboBox[1][x]:getItem(i) ) > 0

          if !::aComboBox[4][x] == NIL
             if Eval(FieldWBlock( ::aComboBox[3][x],::aComboBox[4][x] )) $ ::aComboBox[1][x]:getItem(i)
                TabSelect[1] := i
                ::aComboBox[1][x]:setData( TabSelect )
                i := nComboItems + 1
             Endif
          else

             if Eval(MemVarBlock( ::aComboBox[3][x] )) $ ::aComboBox[1][x]:getItem(i)
                TabSelect[1] := i
                ::aComboBox[1][x]:setData( TabSelect )
                i := nComboItems + 1
             Endif

          endif

    Next
    ::aComboBox[1][x]:setData( TabSelect )
Next

For x := 1 to Len(::aMemoBox)
   ::aMemoBox[x]:Clear()
   ::aMemoBox[x]:SetData()
Next


Return .t.



METHOD DataDialog:close()
*------------------------
*LOCAL i
*for i := 1 to len(::aArea)
*   if !::aArea[i] == NIL
*      Select( ::aArea[i] )
*      if Used()
*         DbCloseArea()
*      endif
*   endif
*Next

::Destroy()
Return self


METHOD DataDialog:destroy()
*--------------------------
   LOCAL i := 0

   IF ::Status() == XBP_STAT_INIT
      RETURN self
   ENDIF

   IF ! Empty( ::windowMenu )
      if ::getModalState() == XBP_DISP_APPMODAL
         ::setModalState( XBP_DISP_MODELESS )
      endif
      ::windowMenu:delItem( self ) //
      ::windowMenu := NIL
   ENDIF

   ::xbpDialog:destroy()
   ::aArea           := Array(100)
   ::appendMode      := .F.
   ::appendRec       := 0
   ::currentRec      := 0
   ::aEditControls   := {}
   ::aDataCheckBoxes := {}
   ::aSearchControls := {}
   ::aFlowControl    := {}
   ::aListBox        := {}
   ::aComboBox       := {{},{},{},{}}
   ::aComboBox1      := {}
   ::aMemoBox        := {}
   ::aStaticText     := {}
   ::aCheckBoxes     := {}
   ::aTabs           := {}  && TabPages
   ::aButtons        := {}
   ::aOldButtons     := {{},{},{}}
   ::aStaticTab      := {}
   ::newTitle        := {|obj| obj:getTitle() }
   ::EditMode        := .f.
   ::StartUp         := .t.
   ::SystemUser      := ""

RETURN self


METHOD DataDialog:RefreshStatic()
*--------------------------------
LOCAL i
LOCAL tLen   := len( ::aStaticText )

For i := 1 to tLen
   ::aStaticText[i]:SetCaption( Eval( ::aStaticTab[i] ) )
Next

RETURN


METHOD DataDialog:GetTabText(TabId, TabWert)
*-----------------------------------------------------
LOCAL cTabText  := ""
LOCAL oldWa     := Select()
LOCAL TabWa     := ::aArea[TABELLEN]
LOCAL TabSearch := Alltrim(TabID + TabWert)

If TabWert == ""
   ::TabText := ""
   Return ::TabText
Endif

Select(TabWa)
if FileLock(TabWa)
   DbSeek(TabSearch)
   DbUnlock()
endif
if Found()
   ::TabText := Alltrim( (TabWa)->TabText )
else
   ::TabText := ""
endif
Select(oldWa)
Return ::TabText

METHOD DataDialog:GetTabMemo(TabId, TabWert)
*-----------------------------------------------------
LOCAL cTabText  := ""
LOCAL oldWa     := Select()
LOCAL TabWa     := ::aArea[TABELLEN]
LOCAL TabSearch := Alltrim(TabID + TabWert)
LOCAL MemoLines := 0
LOCAL i := 0


If TabWert == ""
   ::TabText := ""
   Return ::TabText
Endif

Select(TabWa)
if FileLock(TabWa)
   DbSeek(TabSearch)
   DbUnlock()
endif
if Found()
   ::TabText := (TabWa)->GText
else
   ::TabText := ""
endif
Select(oldWa)
Return ::TabText


METHOD DataDialog:GetTabArr(TabId, Varlen)
*-----------------------------------------------------
LOCAL oldWa     := Select()
LOCAL TabWa     := ::aArea[TABELLEN]
LOCAL TabSearch := Alltrim(TabID)
VarLen := 0
::TabArr := {}
If TabSearch == ""
   Return ::TabArr
Endif

Select(TabWa)
if FileLock(TabWa)
   DbSeek(TabSearch)
   DbUnlock()
endif
if Found()
   Varlen := (TabWa)->TabSys
   Do While Subs((TabWa)->TabCode,1, 3 ) = TabSearch .and. !Eof()
      AAdd(::TabArr, (Subs((TabWa)->TabCode,4,(TabWa)->TabSys) + " " + (TabWa)->TabText) )
      Skip
   Enddo
endif
Select(oldWa)
Return ::TabArr


METHOD DataDialog:MoveTabToListBox(oListBox, TabId, TabWert, Varlen)
*-------------------------------------------------------------------
LOCAL TabArr    := ::GetTabArr(TabId, @Varlen)
LOCAL TabText   := ::GetTabText(TabId, TabWert)
LOCAL TabWa     := ::aArea[TABELLEN]
LOCAL OldWa     := Select()
LOCAL TabArrId  := {}
LOCAL i
LOCAL TabSelect := {0}
Select(TabWa)
For i:= 1 to Len(TabArr)
    aAdd(TabArrId, Subs( TabArr[i],1, Len(TabWert) )  )
Next
oListBox:Clear()
For i:= 1 to Len(TabArr)
    oListBox:AddItem( Alltrim( TabArr[i]) )
Next
TabSelect[1] := iif( aScan(TabArrId, TabWert) == 0, 1, aScan(TabArrId, TabWert) )
oListBox:setData( TabSelect )
Select(OldWa)
Return oListBox


METHOD DataDialog:GetDBKey(TabWert, TabWa, Index, aFields, Keylen, cTitle )
*--------------------------------------------------------------------------
   LOCAL tArray    := {}
   LOCAL TabSelect := ""
   LOCAL oldWa     := Select()
   LOCAL TabSearch
   LOCAL SearchLen
   LOCAL addExpr   := ""
   LOCAL i, x
   LOCAL n := 0
   LOCAL rRec := {}
   LOCAL nRec, nPos
   LOCAL aTabs := {}
   LOCAL TabMaxRec := Val( MaxSDBTabRec )
   LOCAL cField
   LOCAL aFieldLen := {}
   LOCAL aRefLen
   LOCAL aFieldDat := {}
   LOCAL oPS
   LOCAL aPoints
   LOCAL nSpaceLen
   LOCAL nRefItems
   LOCAL oListBox

   oListBox := XbpListBox():new():Create()
   oListBox:SetFontCompoundName( FONT_HELV_SMALL )
   oPS       := oListBox:LockPS()
   nSpaceLen :=  GraQueryTextBox( oPS, " " )[4][1] - GraQueryTextBox( oPS, " " )[2][1]


   *TabWert   := iif(TabWert == "", ::aEditControls[::currentControl]:EditBuffer(), TabWert )

   if val(TabWert) > 0
      Do Case
      Case TabWa == ::aArea[TABELLEN]
         TabSearch := TabWert
      Case TabWa == ::aArea[POSTLEITZAHL]
         TabSearch := Upper(Alltrim(TabWert))
      Othe
         TabSearch := PadL( alltrim(TabWert) , KeyLen )
      Endcase
   else
      TabSearch := Upper(Alltrim(TabWert))
   Endif
   SearchLen := len(TabSearch)

   Select(TabWa)
   *For i:= 1 to len(aFields)
   *   aAdd(aTabs, len( &(aFields[i]) )* 5  )
   *Next
   n := 0
   For x := Index[1] to Index[2]

      if ::Connect(TabSearch, TabWa, x)
         *If Found()
            Do while Subs( Alltrim( &(IndexKey(x)) ), 1, Len(Alltrim(TabSearch) ) ) == Alltrim(Upper(TabSearch)) .and. !Eof()

               AAdd(rRec, Recno() )
               aAdd(aFieldLen, {} )
               aAdd(aFieldDat, {} )
               n := n +1
               For i:= 1 to len(aFields)
                  aAdd( aFieldLen[n], {} )
                  aAdd( aFieldDat[n], {} )
                  cField :=  Rtrim( Eval( FieldWBlock( Var2Char(aFields[i]), TabWa ) )  ) + Space(5)
                  aFieldDat[n][i] := cField
                  aPoints := GraQueryTextBox( oPS, cField )
                  aFieldLen[n][i] := aPoints[4][1] - aPoints[2][1] &&+ (nSpaceLen)
               Next

               if len(rRec) > TabMaxRec
                  Exit
               endif

               FSkip(1)
            enddo
         *Endif
      Endif
   next
   oListBox:UnlockPS(oPS)

   For i := 1 to len(rRec)
      nRec := rRec[i]
      nPos := aScan(rRec,nRec, i + 1)
      if nPos > 0
         aRemove(rRec, nPos)
         aRemove(aFieldDat, nPos)
         aRemove(aFieldLen, nPos)
         i := 0
      endif
   next

if len( aFieldDat ) > 0

   aRefLen := Array( len(aFieldDat[1]) )
   AFill( aRefLen, 0)
   for n := 1 to len(aFieldDat)
      for i:= 1 to len(aFieldDat[n])
         aRefLen[i] := Max( aRefLen[i], aFieldLen[n][i] )
      next
   next
   TArray := {}
   for n := 1 to len(aFieldDat)
      AAdd(TArray, "" )
      for i:= 1 to len(aFieldDat[n])
         aFieldDat[n][i] := aFieldDat[n][i] + Space( int( ( aRefLen[i] - aFieldLen[n][i]) / nSpaceLen ) )
         TArray[n] := TArray[n] + aFieldDat[n][i] + iif( i < len(aFieldDat[n]), Chr(9),"")
      next
   next

   nRefItems := len(aReflen)
   aRemove(aRefLen, nRefItems)

   *for i:= 1 to len(aRefLen)
   *   aRefLen[i] := aRefLen[i]
   *next

   aTabs := aRefLen

endif


   Do case
   Case len(TArray) == 0
      *MsgBox("Der Begriff " + Alltrim(TabWert) + " konnte nicht gefunden werden","GetDbKey()" )
      TabWert := ""
   Case  len(TArray) == 1
      TabWert := Subs(TArray[1],1,KeyLen)
   Case  len(TArray) > 1
      TabWert :=   ChoiceBox( SELF,,, TArray, cTitle,, KeyLen, aTabs)

   EndCase

   Select(oldWa)
Return


METHOD DataDialog:Connect(cWert , cWa, cIndex )
*-------------------------------
   LOCAL oldWa     := Select()
   LOCAL cFound    := .f.
   Select(cWa)
   OrdSetFocus(cIndex)
   if FileLock(cWa)
      DbSeek(cWert)
      DbUnLock()
   Endif
   cFound := Found()
   Select(oldWa)
   Return cFound

METHOD DataDialog:SoftConnect(cWert , cWa, cIndex )
*-------------------------------
   LOCAL oldWa     := Select()
   LOCAL cFound    := .f.
   Select(cWa)
   Set SoftSeek on
   OrdSetFocus(cIndex)
   if FileLock(cWa)
      DbSeek(cWert)
      DbUnLock()
   Endif
   cFound := !Eof()
   Set SoftSeek Off
   Select(oldWa)
   Return cFound



METHOD DataDialog:WriteDb(RecData)
*---------------------------------
LOCAL FldCnt  := Len(RecData)
LOCAL i       := 1
LOCAL RtoLock := Recno()
If RecLock(RToLock)
   For i := 1 to FldCnt
      FieldPut(i,RecData[i] )
   Next
   dbRUnlock(RToLock)
endif
DbCommit()
Return .t.


METHOD DataDialog:ReadDb()
*-------------------------
LOCAL FldCnt  := FCount()
LOCAL i       := 1
LOCAL RecData := Array(FldCnt)

For i := 1 to FldCnt
    RecData[i] := FieldGet(i)
Next

Return RecData


METHOD DataDialog:RegisterSLEFocus()
*-------------------------------------
LOCAL i := 0
LOCAL nElements := len(::aEditControls)

::CurrentControl := 0
for i := 1 to nElements
    if ::aEditControls[i]:hasInputFocus()
       ::CurrentControl := i
       i := nElements
    endif
next
Return SELF


METHOD DataDialog:HandleFocus(MoveFocus, Obj)
*---------------------------------------------------
LOCAL nElements := len(::aFlowControl)
LOCAL mFoc      := iif(MoveFocus == NIL, 0, MoveFocus)
LOCAL newFocus  := 0
LOCAL Element   := ascan(::aFlowControl, Obj)

if nElements == 0 .or. Element == 0
   SetAppFocus()
   Return
Endif

::CurrentControl := 0

if Obj:isDerivedFrom( "XbpSLE" )
   if ! Obj:Validate()
      ::aFlowControl[Element]:setMarked( {1,::aFlowControl[Element]:bufferLength + 1}  )
      ::CurrentControl := Element
      SetAppFocus(::aFlowControl[Element])
      Return SELF
   Endif
Endif

* nur f¸r Faktura Enddoc -> Validierung bei Enter
if obj:isDerivedFrom( "XbpComboBox" )
   PostAppEvent( xbeLB_ItemSelected , NIL, NIL, obj )
Endif


Do Case
   Case Element + MoveFocus > nElements
      NewFocus := Element + MoveFocus - nElements
   Case Element + MoveFocus < 1
      NewFocus := Element + MoveFocus + nElements
   othe
      NewFocus := Element + MoveFocus
Endcase

if ::aFlowControl[NewFocus]:isDerivedFrom( "XbpRadiobutton" ) .and. ::aFlowControl[Element]:isDerivedFrom( "XbpRadiobutton" )
   ::aFlowControl[Element]:setData(.f.)
   ::aFlowControl[NewFocus]:setData(.t.)
Endif

if ::aFlowControl[NewFocus]:isDerivedFrom( "XbpSLE" )
   ::aFlowControl[NewFocus]:setMarked( {1,::aFlowControl[NewFocus]:bufferLength + 1}  )
Endif

SetAppFocus(::aFlowControl[NewFocus])
::CurrentControl := NewFocus

Return SELF


METHOD DataDialog:ValidKey(Key, Obj)
*-----------------
LOCAL i

   Do Case

      Case Key == xbeK_PGUP

      Case Key == xbeK_PGDN

      Case Key == xbeK_UP

      Case Key == xbeK_DOWN

      Case Key == xbeK_ENTER
         Do case
            Case obj:isDerivedFrom( "XbpPushbutton" )
                 PostAppEvent( xbeP_Activate, NIL, NIL, obj )
            Case obj:isDerivedFrom( "XbpRadiobutton" )

            othe
               ::HandleFocus(1,obj)
         EndCase

      Case Key == xbeK_TAB
          ::HandleFocus(1,obj)

      Case Key == xbeK_SH_TAB
          ::HandleFocus(-1,obj)

      Case Key == xbeK_ESC
           for i:= 1 to len(::aButtons)

               if ::aButtons[i]:caption == "Abbrechen"
                  PostAppEvent( xbeP_Activate, NIL, NIL, ::aButtons[i] )
               Endif

*               if ::aButtons[i]:caption == "Beenden"
*                  PostAppEvent( xbeP_Activate, NIL, NIL, ::aButtons[i] )
*               Endif

           next

   Endcase

Return

METHOD DataDialog:RegisterKeyHandler(aFlowControl)
*------------------------------------------------
LOCAL i

for i:= 1 to len(aFlowControl)
    aFlowControl[i]:KeyBoard :=  {|nKey,x,obj| ::ValidKey( nKey, obj ) }
Next
Return


METHOD DataDialog:RegisterElement(oXbp, isFlow, TabId, Wa, DbField, cMemVar)
*--------------------------------------------------------------------------
LOCAL TabWa := ::aArea[TABELLEN]
LOCAL TabVarLen
Do case
   Case oXbp:isDerivedFrom( "XbpStatic" )
       aAdd(::aStaticText, oXbp)
       isFlow := .f.

   Case oXbp:isDerivedFrom( "XbpPushbutton" )

       aAdd(::aButtons, oXbp)
       oXbp:paint := {| aRect, uNIL, Obj | DrawSymbol(Obj) }


   Case oXbp:isDerivedFrom( "XbpMLE" )
       aAdd(::aMemoBox, oXbp)

   Case oXbp:isDerivedFrom( "XbpRadioButton" )
       aAdd(::aRadioButtons, oXbp)

   Case oXbp:isDerivedFrom( "XbpCheckBox" )
       aAdd(::aDataCheckBoxes, oXbp)



   Case oXbp:isDerivedFrom( "XbpComboBox" )
       aAdd(::aComboBoxes, oXbp)


       if TabId <> NIL
          if Wa == 0
             if cMemVar == NIL
                ::MoveTabToListBox(@oXbp, TabId, DbField, @TabVarLen  )
                AAdd ( ::aComboBox[1], oXbp )
                AAdd ( ::aComboBox[2], {|| ::GetTabText(TabId, DbField )  } )
                AAdd ( ::aComboBox[3], DbField )
                AAdd ( ::aComboBox[4], NIL )
                AAdd ( ::aComboBox[5], TabVarLen )
             else
                ::MoveTabToListBox(@oXbp, TabId, DbField, @TabVarLen  )
                AAdd ( ::aComboBox[1], oXbp )
                AAdd ( ::aComboBox[2], {|| ::GetTabText(TabId, DbField )  } )
                AAdd ( ::aComboBox[3], cMemVar )
                AAdd ( ::aComboBox[4], NIL )
                AAdd ( ::aComboBox[5], TabVarLen )
             endif
          else
             ::MoveTabToListBox(@oXbp, TabId, (Wa)->&DbField, @TabVarLen )
             AAdd ( ::aComboBox[1], oXbp )
             AAdd ( ::aComboBox[2], {|| ::GetTabText(TabId, (Wa)->&DbField )  } )
             AAdd ( ::aComboBox[3], DbField )
             AAdd ( ::aComboBox[4], Wa )
             AAdd ( ::aComboBox[5], TabVarLen )
          Endif
       Endif

    Case oXbp:isDerivedFrom( "XbpSLE" )
         oXbp:killInputFocus := ::bKillInputFocus
         aAdd(::aEditControls, oXbp)

    * Muss nach Combobox stehen!
    Case oXbp:isDerivedFrom( "XbpListBox" )
       aAdd(::aListBox, oXbp)

Endcase

if IsFlow
   oXbp:KeyBoard :=  {|nKey,x,obj| ::ValidKey( nKey, obj) }
       if !oXbp:isDerivedFrom( "XbpPushbutton" ) .and. !oXbp:isDerivedFrom( "XbpRadiobutton" )
          oXbp:lbClick  :=  ::bLbClick
       Endif
   AAdd ( ::aFlowControl, oXbp )
endif

Return


METHOD DataDialog:ClearElements()
*--------------------------------
LOCAL aSave := {{},{},{},{},{}}
aSave[1] := ::aButtons
aSave[2] := ::aMemoBox
aSave[3] := ::aComboBox
aSave[4] := ::aEditControls
aSave[5] := ::aFlowControl

::aButtons      := {}
::aMemoBox      := {}
::aComboBox     := {{},{},{},{},{}}
::aEditControls := {}
::aFlowControl  := {}

Return aSave

METHOD DataDialog:RestoreElements(aSave)
*--------------------------------
::aButtons      := aSave[1]
::aMemoBox      := aSave[2]
::aComboBox     := aSave[3]
::aEditControls := aSave[4]
::aFlowControl  := aSave[5]

Return



METHOD DataDialog:AbleButtons(aEnable, aDisable)
*---------------------------------------
LOCAL i
LOCAL iCnt
iCnt := Len(aEnable)
For i := 1 to iCnt
   ::aButtons[aEnable[i]]:Enable()
   DrawSymbol( ::aButtons[aEnable[i]] )
next

iCnt := Len(aDisable)
For i := 1 to iCnt
   ::aButtons[aDisable[i]]:Disable()

next
Return SELF

METHOD DataDialog:ChangeButtons( aButton, aText, aCodeBlock)
*-----------------------------------------------------------
LOCAL i
LOCAL iCnt


iCnt := Len(aButton)
For i := 1 to iCnt
   * Kann Codeblocks nicht vergleichen (nicht mˆglich) 24.3.2004
   if ::aButtons[ aButton[i] ]:Caption == aText[ i ]
      loop
   endif

   ::aButtons[ aButton[i] ]:Caption  := aText[ i ]
   ::aButtons[ aButton[i] ]:activate := aCodeBlock[i]
   ::aButtons[ aButton[i] ]:configure()
next

RETURN SELF

METHOD DataDialog:ResetButtons()
*-------------------------------
LOCAL i
LOCAL iCnt
iCnt := Len(::aOldButtons[1])
For i := 1 to iCnt
   ::aButtons[i]:caption  := ::aOldButtons[1,i]
   ::aButtons[i]:activate := ::aOldButtons[2,i]
   ::aButtons[i]:configure()
   if ::aOldButtons[3,i]
      ::aButtons[i]:Enable()
   else
      ::aButtons[i]:Disable()
   endif
next

::DataDialog:EditMode := .f.
SetAppFocus( SELF )
RETURN SELF


METHOD DataDialog:RegisterOldButtons()
*----------------------------
LOCAL i
LOCAL iCnt := Len(::aButtons)
::aOldButtons     := {{},{},{}}
For i := 1 to iCnt
   aAdd(::aOldButtons[1], ::aButtons[i]:caption )
   aAdd(::aOldButtons[2], ::aButtons[i]:activate )
   aAdd(::aOldButtons[3], ::aButtons[i]:isEnabled() )
Next
Return SELF


METHOD DataDialog:nValidate(obj)
*--------------------------------
LOCAL Content := obj:EditBuffer()
LOCAL cVal    := ""
LOCAL Decimal := 0
LOCAL cType   := "C"

** muss noch def werden 27.5.2002
*if At("@N",  Var2Char( obj:DataLink) ) > 0
*   cVal := str(val(Content),obj:bufferLength, 2)
*   obj:SetData(cVal)
*endif

Return


METHOD DataDialog:ValidnSle(Obj, nMin, nMax)
*----------------------------
Return ValidnSle(Obj, nMin, nMax)



METHOD DataDialog:DontChangeSLEValue(Obj)
*----------------------------------------
LOCAL FlowElement   := ascan(::aFlowControl, Obj)
LOCAL EditElement   := ascan(::aEditControls, Obj)
LOCAL nValue    := Val( Obj:EditBuffer() )
LOCAL i

*if !Obj:Changed
*   Return .t.
*Endif

Obj:Undo()
*Obj:setData()

*For i := EditElement to len(::aEditControls)
*   If ascan(::aFlowControl, ::aEditControls[i]) > 0
*      SetAppFocus( ::aFlowControl[i] )
*      return .f.
*   endif
*Next
SetAppFocus( ::aFlowControl[iif( ::CurrentControl > 0, ::CurrentControl, 1 )] )
Return .f.




* FUNKTIONEN
*-------------

FUNC DelRec(nWa)
*------------
Select(nWa)
if FileLock(nWa)
   DbDelete()
   DbUnlock()
   Return .t.
else
   MsgBox( "Datensatz in "+ str(select())+ " konnte nicht gelˆscht werden", "Interne Meldung DB " + Alias() )
   Return .f.
Endif
Return .t.

FUNC RecLock(RToLock)
*-------------
RToLock := iif(RToLock == NIL, RecNo(), RToLock )

for x := 1 to 10
   if DbRLock(RToLock)
*   if RLock()
      return .t.
   endif
   Sleep(10)
Next
   MsgBox( "Datensatz " + Alltrim( Str(Recno())) + " konnte nicht gesperrt werden", "Interne Meldung DB " + Alias()+ " " + ProcName() + " " + Str(ProcLine()) )
   WriteErrorLog()

Return .f.


FUNC FileLock( nWa )
*--------------
LOCAL MsgInfo := iif( ValType(nWa) == "N", Str(nWa,3), nWa)
Select( nWa )
*FSkip(0) && Keine Ahnung, ohne gehts nicht obwohl kein R und keine DB gesperrt sind.
for x := 1 to 10
   if FLock()
      return .t.
   endif
   Sleep(20)
Next
   MsgBox( "File in "+ MsgInfo + " konnte nicht gesperrt werden", "Interne Meldung " +Alias() )
Return .f.


FUNC FSkip(SPoint)
*---------
LOCAL RtoLock := Recno()
if RecLock(RToLock)
*   if Eof() .or. BOF()
*      MsgBox(iif(Eof(),"End","Beginn") + " of File!" ,"FSkip" )
*   endif
   DbSkip(SPoint)
   DbRUnlock(RToLock)
Else
   MsgBox(iif(Eof(),"Eof()","!Eof()") + " Kein RecLock erfolgt" ,"Interne Meldung FSkip DB " + Alias()+ " " + ProcName() + " " + Str(ProcLine()) )
   WriteErrorLog()
Endif

Return .t.


FUNC AppendBlank(nWa)
*---------
Select(nWa)
if FileLock(nWa)
    DbAppend()
    DbUnlock()
else
   MsgBox( "Datensatz konnte nicht angef¸gt werden", "Interne Meldung " +Alias() )
   return .f.
Endif
Return .t.


FUNC IndCnt()
*------------
Return .t.


Func ValidDate( Obj )
*---------------------------------
LOCAL dVar  := obj:editBuffer()
LOCAL dVonD := date()
LOCAL dBisD := date() + 365

Do Case
   Case ctod(dVar) == ctod("  .  .  ")
        MsgBox("Ung¸ltiges Datum " + dVar,"Validierung Datum")

   Case ctod(dVar) < dVonD
        MsgBox("Datum " + dVar + " zu klein","Validierung Datum")

   Case ctod(dVar) > dBisD
        MsgBox("Datum " + dVar + " zu gross","Validierung Datum")

   Case dow(ctod(dVar)) == 1
        MsgBox("Datum " + dVar + " ist ein Sonntag","Validierung Datum")

   othe
        Return .t.
Endcase
Obj:setMarked( {1,Obj:bufferLength + 1}  )
Return .f.





/*
 * Modales Fenster, das eine Listbox fÅr einfache oder mehrfache Auswahl anzeigt
 */
FUNCTION ChoiceBox( oOwner, aPos, aSize, aStrings, cTitle, nMarkMode, ReturnLen, aTabs )
   LOCAL nEvent   , mp1       , mp2     , oXbp
   LOCAL oDeskTop , oDlg      , oFocus
   LOCAL oBtnOK   , oBtnCancel, oListBox
   LOCAL bKeyboard, aSelect
   LOCAL nXsize   , nYsize
   LOCAL ALen
   LOCAL i
   LOCAL ADataSelect := {}
   LOCAL oPS

   DEFAULT oOwner    TO SetAppWindow(), ;
           cTitle    TO " "           , ;
           nMarkMode TO XBPLISTBOX_MM_SINGLE,;
           aTabs     TO {}

  /*
   * Dialogfenster fÅr die Listbox erzeugen
   */


   oDesktop       := AppDesktop()
   oOwner         := iif(oOwner == NIL, SetAppWindow(), oOwner)
   oDlg           := XbpDialog():new( oDeskTop, oOwner, , , , .F. )
   oDlg:taskList  := .F.
   oDlg:sysMenu   := .F.
   oDlg:minButton := .F.
   oDlg:maxButton := .F.
   oDlg:title     := cTitle
   oDlg:border    := 2 &&XBPDLG_SIZEBORDER
   oDlg:resize    := {|mp1,mp2,obj| Resize( obj ) }
   oDlg:close     := {|mp1,mp2,obj| lExit := .T. }
   oDlg:create()
   oDlg:drawingArea:SetFontCompoundName( FONT_HELV_SMALL )



  /*
   * Listbox erzeugen und Codeblock fÅr Tastaturereignisse verwenden
   */
   bKeyboard               := {|nKey,x,obj| KeyHandler( nKey, obj, oDlg ) }
   oListBox                := XbpListBox():new( oDlg:drawingArea, , { 8,48} )
   oListBox:tabStop        := .T.
   oListBox:adjustHeight   := .T.
   oListBox:horizScroll    := .F.
   oListBox:markMode       := nMarkMode
   oListBox:keyBoard       := bKeyboard
   oListBox:itemSelected   := {|| PostAppEvent( xbeP_Activate,,, oBtnOk) }
   oListBox:create()
*   oListBox:setFontCompoundName( FONT_DEFFIXED_MEDIUM )
   oListBox:SetTabStops(aTabs)

   *AEval( aStrings, {|c| oListBox:addItem( c ) } )
   For ALen := 1 to Len(aStrings)
       oListBox:addItem(aStrings[Alen] )
       aadd(aDataSelect, Subs(aStrings[Alen],1,ReturnLen) )
   next
   oListBox:setData( {1}, .T. )
   oListBox:setTopItem(1)

  /*
   * Zwei Pushbuttons erzeugen
   */
   oBtnOk              := XbpPushButton():new( oDlg:drawingArea,,, { 72, 24 } )
   oBtnOk:caption      := "Ok"
   oBtnOk:tabStop      := .T.
   oBtnOk:keyBoard     := bKeyboard
   oBtnOk:activate     := {|| aSelect := oListBox:getData() , ;
                              PostAppEvent( xbeP_Close,,, oDlg) }
   oBtnOk:create()

   oBtnCancel          := XbpPushButton():new( oDlg:drawingArea,, {72,0}, { 72, 24 } )
   oBtnCancel:caption  := "Abbruch"
   oBtnCancel:tabStop  := .T.
   oBtnCancel:keyBoard := bKeyboard
   oBtnCancel:activate := {|| PostAppEvent( xbeP_Close,,, oDlg) }
   oBtnCancel:create()


  /*
   * Grî·e fÅr das Dialogfenster einstellen und minimale Grî·e definieren.
   */
   nXsize  := 144 + 16
   nYsize  := 120 + 48
   mp1     := oDlg:calcFrameRect( { 0, 0, nXsize, nYsize } )
   oDlg:minSize := { mp1[3], mp1[4] }

   oPS := oListBox:LockPS()
   nXSize := GraQueryTextBox( oPS, aStrings[1] )[4][1] - GraQueryTextBox( oPS, aStrings[1] )[2][1]
   oListBox:UnlockPS(oPS)

   *For i:=1 to len(aTabs)
   *  nXSize := nXSize + aTabs[i]
   *next

   IF aSize == NIL
      nYsize := Max( 120 , Min( 240, 24 * Len( aStrings ) ) ) + 48
      *nXsize := 144 + 140
      *nXsize := 144 + iif(len(aStrings) > 0, 6*len(aStrings[1])-144 , 140)
      nXSize := Max(nXSize * 1.2, 288)

      aSize  := oDlg:calcFrameRect( { 0, 0, nXsize, nYsize } )
      aSize  :=  { aSize[3], aSize[4] }
   ELSE
      aSize[1] := Max( aSize[1], oDlg:minSize[1] )
      aSize[2] := Max( aSize[2], oDlg:minSize[2] )
   ENDIF

   oDlg:setSize( aSize )
   MoveToOwner( oDlg, aPos )
   Resize( oDlg )


  /*
   * Dialog modal schalten und Fokus auf die Listbox setzen
   * Die Event loop wird hier gebraucht, weil die Funktion einen
   * RÅckgabewert hat.
   */
   oDlg:setModalState( XBP_DISP_APPMODAL )
   oDlg:show()
   oFocus := SetAppFocus( oListBox )

   aSelect := {}

   DO WHILE nEvent <> xbeP_Close
      nEvent := AppEvent( @mp1, @mp2, @oXbp )
      oXbp:handleEvent( nEvent, mp1, mp2 )
   ENDDO

  /*
   * Modalen Status aufheben, Dialogresourcen freigeben und Fokus zurÅcksetzen
   */
   oDlg:setModalState( XBP_DISP_MODELESS )
   oDlg:destroy()
   SetAppFocus( oFocus )

*   msgbox(iif( len(aSelect) == 0, "aselect ist null", aDataSelect[ aSelect[1] ] ),"")

RETURN ( iif( len(aSelect) == 0, "", aDataSelect[ aSelect[1] ] ) )



/*
 * Grî·e und Position vom Inhalt des Dialogfensters aktualisieren
 * Die Prozedur wird Åber den :resize Codeblock aufgerufen, der
 * ausgefÅhrt wird, nachdem Rahmen des Fensters mit der Maus grî·er
 * oder kleiner gezogen wurde.
 */


STATIC PROCEDURE Resize( oDlg )
   LOCAL aDaSize    := oDlg:drawingArea:currentSize()
   LOCAL aChild     := oDlg:drawingArea:childList()
   LOCAL oListBox   := aChild[1]
   LOCAL oBtnOk     := aChild[2]
   LOCAL oBtnCancel := aChild[3]
   LOCAL aPos, aPbSize, aLbSize, nDist

   aPbSize := oBtnOK:currentSize()

  /*
   * Distanz zwischen Pushbuttons ist variabel
   */
   nDist   := Min( 24, Max( 0, aDaSize[1] - 16 - 2 * aPbSize[1] ) )


  /*
   * Pushbuttons zentrieren
   */
   aPos    := CenterPos( { nDist + 2 * aPbSize[1] ,     aPbSize[2] }, ;
                         { aDaSize[1]             , 2 * aPbSize[2] }  )

   oBtnOk:setPos( aPos, .F. )

   aPos[1] += ( nDist + aPbSize[1] )
   oBtnCancel:setPos( aPos, .F. )


  /*
   * Die Listbox wird mit 8 Pixel Abstand zum Rahmen zentriert
   */
   aLbSize := { aDaSize[1] - 16, aDaSize[2] - 8 - 2 * aPbSize[2] }
   oListBox:setSize( aLbSize, .F. )

   oDlg:drawingArea:invalidateRect()
   DrawSymbol(oBtnOk)
   DrawSymbol(oBtnCancel)
RETURN



/*
 * Return und Esc Taste verarbeiten
 */
STATIC PROCEDURE KeyHandler( nKey, oXbp, oDlg )

   DO CASE
   CASE nKey == xbeK_RETURN
      IF oXbp:isDerivedFrom( "XbpPushbutton" )
         PostAppEvent( xbeP_Activate,,, oXbp )
      ENDIF

   CASE nKey == xbeK_ESC
      PostAppEvent( xbeP_Close,,, oDlg )

   ENDCASE

RETURN



/*
 * Fenster innerhalb Parent-Window verschieben wobei der Bezugspunkt fÅr
 * die Koordinaten das Owner-Windows ist. StandardmÑ·ig wird ein
 * Fenster auf seinem Owner zentriert.
 */
STATIC PROCEDURE MoveToOwner( oDlg, aPos )
   LOCAL oOwner  := oDlg:setOwner()
   LOCAL oParent := oDlg:setParent()
   LOCAL aPos1, nWidth

   DEFAULT aPos TO CenterPos( oDlg:currentSize(), oOwner:currentSize() )

   DO WHILE oOwner <> oParent
      aPos1   := oOwner:currentPos()

      aPos[1] += aPos1[1]
      aPos[2] += aPos1[2]

      IF oOwner:isDerivedFrom( "XbpDialog" )
         // adjust for thickness of frame
         nWidth  := ( oOwner:currentSize()[1] - oOwner:drawingArea:currentSize()[1] ) / 4
         aPos[1] -= nWidth
         aPos[2] -= nWidth
      ENDIF
      oOwner := oOwner:setParent()
   ENDDO

   oDlg:setPos( aPos )
RETURN



/*
 * Zentrierte Position fÅr ein Fenster aus der Fenstergrî·e und einer
 * Referenzgrî·e berechnen
 */
FUNCTION CenterPos( aSize, aRefSize )
RETURN { Int( (aRefSize[1] - aSize[1]) / 2 ) ;
       , Int( (aRefSize[2] - aSize[2]) / 2 ) }


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


FUNCTION ResizeDataDialog(oDlg, aOldWSize, aNewWSize, aChildList)
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

* XP Sp3
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

* XP Sp3
*oDlg:lockUpdate(.T.)

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

     Case aChildList[1][i]:isDerivedFrom( "XbpMLE" )
 *         aChildList[1][i]:setPosAndSize( aNewPos, aNewSize)
          aChildList[1][i]:configure( , , aNewPos  , aNewSize , , )

      othe
         aChildList[1][i]:setFontCompoundName( NewFont )
         aChildList[1][i]:setPosAndSize( aNewPos, aNewSize)

   EndCase
 next

 * XP Sp3
*oDlg:lockUpdate(.F.)
*oDlg:invalidateRect()

oDlg:Show()
SaveDialogPosAndSize(oDlg)
Return .t.

METHOD DataDialog:AdjustXbpQuickBrowseCol(Obj, isNewData, aArtDat, FileChanged )
*-------------------------------------------------------------------------------
LOCAL oPs  := ::LockPs()
LOCAL i, n, x
LOCAL aTextBox
LOCAL nCols := Obj:ColCount
LOCAL nRows := 0
LOCAL aQbArtColWidth[nCols]
LOCAL aActualColWidth[nCols]
LOCAL nActualTotalWidth := 0
LOCAL nNewTotalWidth := 0
LOCAL aSize := Obj:CurrentSize()
LOCAL xFactor := 1
LOCAL IsResizeColWidth := .f.


aFill(aQbArtColWidth, 10)
FileChanged := iif(FileChanged == NIL, .f., FileChanged )

For i := 1 to nCols
   aActualColWidth[i] := obj:GetColWidth( i )
   nActualTotalWidth := nActualTotalWidth + aActualColWidth[i]
next

If !isNewData
   Do Case
      Case aSize[1] > nActualTotalWidth
         xFactor := aSize[1] / nActualTotalWidth
      Case aSize[1] <= nActualTotalWidth
         xFactor := aSize[1] / nActualTotalWidth
   Endcase

   For i := 1 to nCols
      obj:SetColWidth( aActualColWidth[i] * xFactor, i )
   next
   obj:DataLink:setAbsolutePageSize(Obj:RowCount)
   RETURN
Endif

x := Min( len(aArtDat), Val(MaxCalcQbSize) )
for i:= 1 to x
   for n := 1 to nCols
      aTextBox := GraQueryTextBox(oPs, aArtDat[i][n] )
      aQbArtColWidth[n] := iif(aTextBox[3][1] - aTextBox[1][1] +10 > aQbArtColWidth[n] , aTextBox[3][1] - aTextBox[1][1]+10, aQbArtColWidth[n] )
   Next
Next
::UnLockPs()

For i := 1 to nCols
   nNewTotalWidth := nNewTotalWidth + aQbArtColWidth[i]
next

Do Case
   Case aSize[1] > nNewTotalWidth
      xFactor := aSize[1] / nNewTotalWidth
   Case aSize[1] <= nNewTotalWidth
      xFactor := aSize[1] / nNewTotalWidth
Endcase

For i := 1 to nCols
   aQbArtColWidth[i] := aQbArtColWidth[i] * xFactor
   if Int( Round( aQbArtColWidth[i], -1) ) > Int( Round(aActualColWidth[i], -1) )
      IsResizeColWidth := .t.
   endif
next

if IsNewData
   obj:dataLink := DacPagedDataStore():new( aArtDat )
   obj:DataLink:setAbsolutePageSize(Obj:RowCount)
Endif

if Len(aArtDat) > 0 .and. IsResizeColWidth
   obj:lockUpdate(.T.)
   For i := 1 to nCols
      obj:SetColWidth( aQbArtColWidth[i] , i )
   next
   obj:lockUpdate(.F.)
   obj:invalidateRect()

Endif

Return

METHOD DataDialog:GetVSTInfo(Line)
*---------------------------------
LOCAL TabWa := ::aArea[TABELLEN]
LOCAL OldWa := Select()
LOCAL cText
LOCAL nLines
if TabWa == NIL
   Return ""
Endif
Select(TabWa)
if !::Connect("022" + PosLoged, TabWA, 1)
   Select(OldWa)
   return ""
else
   cText := (TabWa)->GText
   nLines := MlCount(cText)
   Select(OldWa)
   Return MemoLine( cText, ,Line)
 Endif

Return ""


METHOD DataDialog:FieldBlockTrimmed( cFieldName, cType, Wa )
*-----------------------------------------------------------
   LOCAL bBlock
   Select(Wa)
   IF ! FieldPos( cFieldName ) == 0
      IF ! "->" $ cFieldName
         cFieldName := "FIELD->"+cFieldName
      ENDIF
      IF cType = "C"
         bBlock := &( "{|x| IIf(x==NIL,RTrim("+cFieldName+"),"+cFieldName+":=x) }" )
      ELSE
         bBlock := &( "{|x| IIf(x==NIL,"+cFieldName+","+cFieldName+":=x) }" )
      ENDIF
   ENDIF
RETURN bBlock



METHOD DataDialog:LoadDebData(cDebNr, Obj)
*------------------------------------
LOCAL oldWa      := select()
LOCAL rCnt       := 1
LOCAL DebWa      := ::aArea[KUNDEN]
LOCAL HisWa      := ::aArea[HISTORY]
LOCAL cFarbe     := ""
LOCAL OldRec
LOCAL cInfo
LOCAL cSizeField := "  "
LOCAL cLDebNr    := Space(8)
LOCAL MaxRec     := val(MaxDebRec)
LOCAL QBOffSet   := 0
LOCAL oFrame
LOCAL oProgress
LOCAL aProgrPos  := {::aListBox[1]:CurrentPos()[1],::aListBox[1]:CurrentPos()[2] + ::aListBox[1]:CurrentSize()[2] + 2}
LOCAL aProgrSize := {::aListBox[1]:CurrentSize()[1], 10 }
LOCAL i
LOCAL nRec
LOCAL nPos
LOCAL nDocs

if ::Startup
   Return
Endif

Select( DebWa )
OldRec  := Recno()
::aDebDat  := {}
::aDebRec  := {}
QBOffSet := 0


for i:= 1 to Len(KundenIndex)

if val(cDebNr) > 0 .and. i == 1
   cDebNr := PadL( alltrim(cDebNr) , 8 )
else
   cDebNr := alltrim(cDebNr)
Endif


if ::Connect( cDebNr, DebWa, i )
   oProgress         := ProgressBar():new( ::aTabs[1] ,, aProgrPos, aProgrSize)
   oProgress:create()
   oProgress:minimum := 1
   oProgress:maximum := Lastrec()
   oProgress:color   := GRA_CLR_BLUE

   Do while Subs( Alltrim( &(KundenKey[i]) ), 1, Len(Alltrim(cDebNr) ) ) == Alltrim(Upper(cDebNr)) .and. !Eof() .and. rCnt < MaxRec

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
      Select( DebWa )
      FSkip(1)
   Enddo
   oProgress:Destroy()
Endif

Next

For i := 1 to len(::aDebRec)
   nRec := ::aDebRec[i]
   nPos := aScan(::aDebRec,nRec, i + 1)
   if nPos > 0
      aRemove(::aDebRec, nPos)
      aRemove(::aDebDat, nPos)
      i:= 0
   endif
next

obj:aDebDat := ::aDebDat
obj:aDebRec := ::aDebRec

Return
