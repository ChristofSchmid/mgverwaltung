 *********************************************************************
* MGMail 3.1.2009, 9.2.2009
*********************************************************************
#include "Gra.ch"
#include "Xbp.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "DMLB.ch"
#include "MGV.CH"
#include "Fileio.ch"
#include "activex.ch"

CLASS eMail FROM DataDialog
   EXPORTED:
     VAR aFilter
     VAR nEvent
     VAR IsWord

     METHOD Create
     METHOD Close
     METHOD MergePage
     METHOD ManageEvents
     METHOD FillListbox
     METHOD MoveListBoxElements
     METHOD MakeeMail
     METHOD MakePostMail
     METHOD StartWord

ENDCLASS


METHOD eMail:create( oParent, oOwner , ;
                          aPos   , aSize  , ;
                          aPParam, lVisible )

   ::DataDialog:create( oParent, oOwner , ;
                       aPos   , aSize  , ;
                       aPParam, lVisible )


RETURN self

METHOD eMail:Close()
   Select(::aArea[KUNDEN] )
   DbCloseArea()

   Select(::aArea[TABELLEN] )
   DbCloseArea()

   ::DataDialog:Close()
   ::Destroy()
Return SELF

METHOD eMail:ManageEvents()
*--------------------------
LOCAL n
::nEvent := 1
for n:= 1 to 3
   if ::aRadioButtons[n]:getData()
      ::nEvent := n
   endif
next

::FillListBox()

Return

METHOD eMail:FillListbox()
*--------------------------
LOCAL TabWa    := ::aArea[TABELLEN]
LOCAL TabId    := "017"
LOCAL TabWert  := "01"
LOCAL VarLen   := 2

::MoveTabToListBox(::aListBox[1], TabId, TabWert, Varlen)
::aListBox[2]:clear()
::aListBox[1]:SetData( {1} )

Return


METHOD eMail:MoveListBoxElements(oFrom, oTo)
*-------------------------------------------
LOCAL aSelected := oFrom:Getdata()
LOCAL n
LOCAl i := len( aSelected )

if i == 0
   return
endif

For n := 1 to i
  oTo:addItem( oFrom:getItem(aSelected[n]))
  oFrom:DelItem( aSelected[n] )
next

if oFrom:NumItems() > 0
   oFrom:SetData( {1} )
endif

RETURN



METHOD EMail:MergePage()
*-----------------------
LOCAL DrawingArea

   drawingArea := ::drawingArea
   drawingArea:setFontCompoundName( "8.Arial" )

   oXbp := XbpStatic():new( drawingArea, , {36,468}, {84,24}, { { XBP_PP_BGCLR, -255 } } )
   oXbp:caption := "Event"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER
   oXbp:create()
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpRadioButton():new( drawingArea, , {36,432}, {96,24}, { { XBP_PP_BGCLR, -255 } } )
   oXbp:caption := "Mitteilung"
   oXbp:selection := .T.
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:selected := {|| ::ManageEvents() }
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpRadioButton():new( drawingArea, , {36,396}, {96,24}, { { XBP_PP_BGCLR, -255 } } )
   oXbp:caption := "Chlaushöck"
   oXbp:selection := .F.
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:selected := {|| ::ManageEvents() }
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpRadioButton():new( drawingArea, , {36,360}, {96,24}, { { XBP_PP_BGCLR, -255 } } )
   oXbp:caption := "GV"
   oXbp:selection := .F.
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:selected := {|| ::ManageEvents() }
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpStatic():new( drawingArea, , {180,468}, {180,24}, { { XBP_PP_BGCLR, -255 } } )
   oXbp:caption := "mögliche Auswahl"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER
   oXbp:create()
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpListBox():new( drawingArea, , {180,204}, {180,252}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabStop := .T.
   oXbp:ItemSelected := {|| ::MoveListBoxElements(::aListBox[1],::aListBox[2]) }
   *oXbp:MarkMode := XBPLISTBOX_MM_EXTENDED
   oXbp:create()
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpStatic():new( drawingArea, , {468,468}, {180,24}, { { XBP_PP_BGCLR, -255 } } )
   oXbp:caption := "gewählt"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER
   oXbp:create()
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpListBox():new( drawingArea, , {468,204}, {180,252}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabStop := .T.
   oXbp:ItemSelected := {|| ::MoveListBoxElements(::aListBox[2],::aListBox[1]) }
   *oXbp:MarkMode := XBPLISTBOX_MM_EXTENDED
   oXbp:create()
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpPushButton():new( drawingArea, , {396,372}, {36,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := ">"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| ::MoveListBoxElements(::aListBox[1],::aListBox[2])  }
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpPushButton():new( drawingArea, , {396,336}, {36,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "<"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| ::MoveListBoxElements(::aListBox[2],::aListBox[1]) }
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpPushButton():new( drawingArea, , {12,12}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "EMail Datei"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| ::MakeEmail() }
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpPushButton():new( drawingArea, , {120,12}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Post Mail Datei"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| ::MakePostMail() }
   ::RegisterElement(@oXbp, .f.,,,)

   oXbp := XbpPushButton():new( drawingArea, , {684,12}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Zurück"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| ::Close() }
   ::RegisterElement(@oXbp, .f.,,,)

Return SELF


METHOD EMail:MakeEMail()
*----------------------------------
LOCAL DebWa       := ::aArea[KUNDEN]
LOCAL SemiColon   := ";"
LOCAL CRLF        := Chr(13)+Chr(10)
LOCAL cRecepients := ""
LOCAL nElements   := ::aListBox[2]:NumItems()
LOCAL i
LOCAL bFilter     := "{|| ( DebStat <> '99' .or. DebADat > Date() ) .and. ( "
LOCAL nHandle     := FCreate(DocDrive + "Vorlagen\DEBeMail.txt")

if nHandle < 0
   MsgBox("Systemfehler, Fcreate() konnte nicht ausgeführt werden", "Low Level")
   Return
Endif

if nElements = 0
   MsgBox("Keine Auswahl getroffen","Make eMail")
   FClose( nHandle )
   Return
endif

for i := 1 to nElements
   if i == 1
      bFilter := bFilter + " KGR == '" + Subs( ::aListBox[2]:GetItem(i),1,2 )+"'"
   else
      bFilter := bFilter + " .or. KGR == '" + Subs( ::aListBox[2]:GetItem(i),1,2 )+"'"
   endif
next

bFilter := bFilter + ") }"
Select(DebWa)
DbSetFilter(  &bFilter   )

if FileLock(DebWa)
   DbGoTop()
   DbUnlock()
Endif
FWrite( nHandle, "Anrede" + SemiColon + "Name" + SemiColon + "Strasse" + SemiColon + "Ort" + SemiColon + "eMail" + CRLF )
Do While !eof()
   if !empty( (debWa)->Email )
      cRecepients := cRecepients + Alltrim( (debWa)->eMail) + SemiColon
      FWrite( nHandle, Alltrim( ::GetTabText("010", (DebWa)->Anrede) )+ SemiColon + Alltrim( (DebWa)->name) + SemiColon + + Alltrim( (DebWa)->Strasse) + SemiColon + Alltrim( (DebWa)->Ort) + SemiColon + Alltrim( (DebWa)->eMail) + CRLF )
   endif
   fSkip(1)
enddo
FClose( nHandle )
*msgbox(cRecepients)

::StartWord("Versand EMail","DEBeMail.txt",3)
if ! ::IsWord
    MsgBox("Datei " + DocDrive + "Vorlagen\DEBeMail.txt erstellt", "MakeEMail File" )
endif

Return


METHOD EMail:MakePostMail()
*--------------------------
LOCAL DebWa       := ::aArea[KUNDEN]
LOCAL SemiColon   := ";"
LOCAL CRLF        := Chr(13)+Chr(10)
LOCAL nElements   := ::aListBox[2]:NumItems()
LOCAL i
LOCAL bFilter     := "{|| ( DebStat <> '99' .or. DebADat > Date() ) .and. ( "
LOCAL nHandle     := FCreate(DocDrive + "Vorlagen\DebPostMail.txt")


if nHandle < 0
   MsgBox("Systemfehler, Fcreate() konnte nicht ausgeführt werden", "Low Level")
   Return
Endif

if nElements = 0
   MsgBox("Keine Auswahl getroffen","Make PostMail")
   FClose( nHandle )
   Return
endif

for i := 1 to nElements
   if i == 1
      bFilter := bFilter + " KGR == '" + Subs( ::aListBox[2]:GetItem(i),1,2 )+"'"
   else
      bFilter := bFilter + " .or. KGR == '" + Subs( ::aListBox[2]:GetItem(i),1,2 )+"'"
   endif
next

bFilter := bFilter + ") }"
Select(DebWa)
DbSetFilter(  &bFilter   )

if FileLock(DebWa)
   DbGoTop()
   DbUnlock()
Endif

FWrite( nHandle, "Anrede" + SemiColon + "Name" + SemiColon + "Strasse" + SemiColon + "Ort" + CRLF )
Do While !eof()
   if empty( (debWa)->Email )
      FWrite( nHandle, Alltrim( ::GetTabText("010", (DebWa)->Anrede) )+ SemiColon + Alltrim( (DebWa)->name) + SemiColon + Alltrim( (DebWa)->Strasse) + SemiColon + Alltrim( (DebWa)->Ort) + CRLF )
   endif
   fSkip(1)
enddo
FClose( nHandle )
*msgbox(cRecepients)
::StartWord("Versand Post", "DebPostMail.txt",4)
if ! ::IsWord
   MsgBox("Datei " + DocDrive + "Vorlagen\DebPostMail.txt erstellt", "MakePostMail File" )
endif

Return


PROCEDURE MailMerge()
   LOCAL nEvent, mp1, mp2, oXbp
   LOCAL oDlg, DrawingArea
   LOCAL aPos[2], ASize

   LOCAL oWinMenu
   LOCAL aContMenu := {}
   LOCAL DebWa
   LOCAL TabWa

   OpenDb(DataDrive, KundenFile, KundenIndex, KundenKey)
   DebWa   := Select()
   OpenDb(DataDrive, TabellenFile, TabellenIndex, TabellenKey)
   TabWa := Select()


   aSize       := DialogSize()
   aPos        := DialogPos()
*   // Anwendungsfenster erzeugen (application window)

   oDlg := EMail():new( AppDesktop(), , aPos, aSize, , .F.)
   oDlg:taskList := .T.
   oDlg:title := "Mail Merge"
   oDlg:setDisplayFocus := {||    WinMenu():checkItem( oDlg, KUNDEN )}
   oDlg:create()

   oDlg:aArea[KUNDEN]  := DebWa
   oDlg:aArea[TABELLEN]  := TabWa

   drawingArea := oDlg:drawingArea
   drawingArea:setColorBG( GRA_CLR_BACKGROUND )
   drawingArea:setColorFG( GRA_CLR_BLACK      )
   drawingArea:setFontCompoundName( "8.Arial" )

   oDlg:windowMenu  := WinMenu()
   WinMenu():addItem( oDlg )
   WinMenu():checkItem( oDlg, KUNDEN )
   oDlg:MergePage()
   oDlg:FillListBox()
   oDlg:show()
   SetAppFocus(oDlg)

   RETURN



METHOD eMail:StartWord(cFile, cDataFile, nButton)
  LOCAL cDotFile, cSaveAs, oWord, oMerge, oDoc
  LOCAL cDatFile
  LOCAL aData := {}
  ::IsWord := .t.

  cDotFile := DocDrive + "Vorlagen\"  + cFile + ".Dot"
  cDatFile := DocDrive + "Vorlagen\"  + cDataFile
  cSaveAs  := DocDrive + "Dokumente\" + GenFileName(cFile)

  ::AbleButtons({},{nButton} )

  oWord := CreateObject("Word.Application")
  IF Empty( oWord )
    MsgBox( "Microsoft Word ist nicht installiert" )
    ::IsWord := .f.
    Return
  ENDIF

  oWord  := oWord:dynamicCast( ActiveXObject() )

  oWord:quit := {|| ::AbleButtons({nButton},{} )}
  oWord:visible := .T.
  oWord:documents:open( cDotFile )
  oDoc := oWord:ActiveDocument
  oDoc:MailMerge:OpenDataSource(cDatFile)
  oDoc:saveas(cSaveAs)
  *oWord:destroy()
  RETURN


FUNCTION GenFileName(cDoc)
LOCAL i := 1
LOCAL ci
LOCAL NewDoc :=  cDoc + " " + dtoc(date())+ ".Doc"

Do while File( DocDrive + "Dokumente\" + NewDoc )
   ci := Alltrim(Str(i))
   NewDoc := cDoc + " " + dtoc(date())+ " - " + ci + ".Doc"
   i := i +1
Enddo

Return NewDoc

