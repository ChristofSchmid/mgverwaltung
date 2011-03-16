///////////////////////////////////////////////////////////////////////////////
//
//  Vom Xbase++ FormDesigner erstellter Funktions Code
//    Erstellt am: 10.02.2009 Zeit: 20:51:03
//
///////////////////////////////////////////////////////////////////////////////

#include "Gra.ch"
#include "Xbp.ch"
#include "Appevent.ch"
#include "Font.ch"

#PRAGMA LIBRARY( "ASCOM10.LIB" )

PROCEDURE Main
   LOCAL nEvent, mp1, mp2, aSize
   LOCAL oDlg, oXbp, drawingArea, aEditControls := {}

   IF IsMemberVar(XbpDialog(),"ClientSize") == .T.
      aSize := {0,0}
   ELSE
      aSize := {803,550}
   ENDIF
   
   oDlg := XbpDialog():new( AppDesktop(), , {558,326}, aSize, , .F.)
   IF aSize[1] == 0 .AND. aSize[2] == 0
      oDlg:ClientSize := {795,516}
   ENDIF
   oDlg:taskList := .T.
   oDlg:title := "Neues Formular"
   oDlg:create()

   drawingArea := oDlg:drawingArea
   drawingArea:setFontCompoundName( "8.Arial" )

   oXbp := XbpStatic():new( drawingArea, , {36,468}, {84,24}, { { XBP_PP_BGCLR, -255 } } )
   oXbp:caption := "Event"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER
   oXbp:create()

   oXbp := XbpRadioButton():new( drawingArea, , {36,432}, {96,24}, { { XBP_PP_BGCLR, -255 } } )
   oXbp:caption := "Chlaush”ck"
   oXbp:selection := .T.
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:selected := {|| NIL }

   oXbp := XbpRadioButton():new( drawingArea, , {36,396}, {96,24}, { { XBP_PP_BGCLR, -255 } } )
   oXbp:caption := "GV"
   oXbp:selection := .T.
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:selected := {|| NIL }

   oXbp := XbpRadioButton():new( drawingArea, , {36,360}, {96,24}, { { XBP_PP_BGCLR, -255 } } )
   oXbp:caption := "Mitteilung"
   oXbp:selection := .T.
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:selected := {|| NIL }

   oXbp := XbpStatic():new( drawingArea, , {180,468}, {180,24}, { { XBP_PP_BGCLR, -255 } } )
   oXbp:caption := "m”gliche Auswahl"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER
   oXbp:create()

   oXbp := XbpListBox():new( drawingArea, , {180,204}, {180,252}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabStop := .T.
   oXbp:create()

   oXbp := XbpStatic():new( drawingArea, , {468,468}, {180,24}, { { XBP_PP_BGCLR, -255 } } )
   oXbp:caption := "gew„hlt"
   oXbp:clipSiblings := .T.
   oXbp:options := XBPSTATIC_TEXT_VCENTER
   oXbp:create()

   oXbp := XbpListBox():new( drawingArea, , {468,204}, {180,252}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabStop := .T.
   oXbp:create()

   oXbp := XbpPushButton():new( drawingArea, , {396,372}, {36,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := ">"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| NIL }

   oXbp := XbpPushButton():new( drawingArea, , {396,336}, {36,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "<"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| NIL }

   oXbp := XbpPushButton():new( drawingArea, , {12,12}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "EMail Datei"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| NIL }

   oXbp := XbpPushButton():new( drawingArea, , {120,12}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Post Mail Datei"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| NIL }

   oXbp := XbpPushButton():new( drawingArea, , {684,12}, {96,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Zrck"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| PostAppEvent( xbeP_Close ) }

   oDlg:show()
   SetAppFocus(oDlg)

   nEvent := xbe_None
   DO WHILE nEvent <> xbeP_Close
      nEvent := AppEvent( @mp1, @mp2, @oXbp )
      oXbp:handleEvent( nEvent, mp1, mp2 )
   ENDDO
RETURN