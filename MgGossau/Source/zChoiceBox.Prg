*-------------
* 5.8.2001 CAS
*-------------


#include "Appevent.ch"
#include "Common.ch"
#include "Font.ch"
#include "Gra.ch"
#include "Xbp.ch"


/*
 * Modales Fenster, zur Datenauswahl
 */

FUNCTION SelectDataBox( oOwner, aPos, aSize, pFilter, cTitle )
   LOCAL nEvent   , mp1       , mp2     , oXbp
   LOCAL oDeskTop , oDlg      , oFocus
   LOCAL oBtnOK   , oBtnCancel, oListBox
   LOCAL bKeyboard, aSelect
   LOCAL nXsize   , nYsize
   LOCAL ALen
   LOCAL ADataSelect := {}
   LOCAL LReturn     := .f.
   LOCAL i,x,iMax
   LOCAL oStatic
   LOCAL aListBox := {}
   LOCAL TmpFilt2 := {}
   LOCAL lExit


*   DEFAULT oOwner    TO SetAppWindow(), ;
*           cTitle    TO " "

  /*
   * Dialogfenster fÅr die Listbox erzeugen
   */

   if len( pFilter[2] ) == 0
      Return .t.
   endif


   oDesktop       := AppDesktop()
*   oOwner         := SetAppWindow()

   oDlg           := XbpDialog():new( oDeskTop, oOwner, , , , .F. )
*   oDlg           := XbpDialog():new( oDeskTop, SetAppWindow(), , , , .F. )
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
   * Zwei Pushbuttons erzeugen
   */

   oBtnOk              := XbpPushButton():new( oDlg:drawingArea,,, { 72, 24 } )
   oBtnOk:caption      := "Ok"
   oBtnOk:tabStop      := .T.
   oBtnOk:keyBoard     := bKeyboard
   oBtnOk:activate     := {|| LReturn := .t., PostAppEvent( xbeP_Close,,, oDlg) }
   oBtnOk:lbUp         := {|mp1, mp2, obj| DrawSymbol(Obj) }
   oBtnOk:lbDown       := {|mp1, mp2, obj| DrawSymbol(Obj) }
   oBtnOk:create()


   oBtnCancel          := XbpPushButton():new( oDlg:drawingArea,, {72,0}, { 72, 24 } )
   oBtnCancel:caption  := "Abbruch"
   oBtnCancel:tabStop  := .T.
   oBtnCancel:keyBoard := bKeyboard
   oBtnCancel:lbUp     := {|mp1, mp2, obj| DrawSymbol(Obj) }
   oBtnCancel:lbDown   := {|mp1, mp2, obj| DrawSymbol(Obj) }
   oBtnCancel:activate := {|| LReturn := .f., PostAppEvent( xbeP_Close,,, oDlg) }
   oBtnCancel:create()


  /*
   * Grî·e fÅr das Dialogfenster einstellen und minimale Grî·e definieren.
   */
   nXsize  := 144 + 16
   nYsize  := 120 + 48
   mp1     := oDlg:calcFrameRect( { 0, 0, nXsize, nYsize } )
   oDlg:minSize := { mp1[3], mp1[4] }

   IF aSize == NIL
      nYsize := Max( 120 , Min( 500, 60 * Len( pFilter[2] ) ) ) + iif( len(pFilter[2]) == 1, 0, 100)
      nXsize := 144 + 140
      aSize  := oDlg:calcFrameRect( { 0, 0, nXsize, nYsize } )
      aSize  :=  { aSize[3], aSize[4] }
   ELSE
      aSize[1] := Max( aSize[1], oDlg:minSize[1] )
      aSize[2] := Max( aSize[2], oDlg:minSize[2] )
   ENDIF

   oDlg:setSize( aSize )
   MoveToOwner( oDlg, aPos )
   Resize( oDlg )

   for i := 1 to len(pFilter[2])

      oStatic            := XbpStatic():new( oDlg:drawingArea, , {8, (i * 60) + 20 }, {250,48} )
      oStatic:caption    := oOwner:GetTabText( "999" , pFilter[2][i][3] )
      oStatic:type       := XBPSTATIC_TYPE_GROUPBOX
*      oStatic:options    := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT
      oStatic:Create()

      oListBox               := XbpCombobox():new( oDlg:DrawingArea, , {20, (i * 60) - 60  }, {210,112} )
      oListBox:type          := XBPCOMBO_DROPDOWNLIST
      oListBox:ItemSelected  := {|uNIL1,uNIL2,obj| dummy() }
      oListBox:tabStop       := .T.
      oListBox:Create()
      aAdd( aListBox, oListBox)

      aAdd(aDataSelect, oOwner:GetTabArr( pFilter[2][i][3] ) )


      IF aDataSelect == NIL .or. len(aDataSelect[i]) == 0
         oListBox:xbpSle:setData( "" )
         oListBox:disable()
      ELSE
         oListBox:enable()
*         oListBox:xbpSle:setData( "" )
         imax := Len( aDataSelect[i] )
         FOR x:=1 TO imax
            oListBox:addItem( aDataSelect[i][x] )
         NEXT

         if !pFilter[2][i][2] == NIL
            if AScan( aDataSelect[i], pFilter[2][i][2] ) > 0
               oListBox:xbpListbox:SetData( {AScan( aDataSelect[i], pFilter[2][i][2] )} )
            endif
         endif

      ENDIF
   next




  /*
   * Dialog modal schalten und Fokus auf die Listbox setzen
   * Die Event loop wird hier gebraucht, weil die Funktion einen
   * RÅckgabewert hat.
   */
   oDlg:setModalState( XBP_DISP_APPMODAL )
   oDlg:show()
   oFocus := SetAppFocus( oDlg )

   nEvent := xbe_None
   DO WHILE nEvent <> xbeP_Close
      nEvent := AppEvent( @mp1, @mp2, @oXbp )
      oXbp:handleEvent( nEvent, mp1, mp2 )
   ENDDO


   for i := 1 to len(aListBox)
      aSelect :=  aListBox[i]:GetData()
      if len( aSelect) > 0
         pFilter[2][i][2] := Subs( aDataSelect[i][ aSelect[1] ] ,1,2 )
         aAdd(TmpFilt2, pFilter[2][i] )
      endif
   next

   pFilter[2] := TmpFilt2


  /*
   * Modalen Status aufheben, Dialogresourcen freigeben und Fokus zurÅcksetzen
   */


   oDlg:setModalState( XBP_DISP_MODELESS )
   SetAppFocus( oFocus )
   oDlg:destroy()
   SetAppFocus( oOwner )

*   msgbox(iif( len(aSelect) == 0, "aselect ist null", aDataSelect[ aSelect[1] ] ),"")

RETURN LReturn




FUNCTION SelectFormBox( oOwner, aPos, aSize, pFilter, cTitle )
   LOCAL nEvent   , mp1       , mp2     , oXbp
   LOCAL oDeskTop , oDlg      , oFocus
   LOCAL oBtnOK   , oBtnCancel, oCheckBox
   LOCAL bKeyboard, aSelect
   LOCAL nXsize   , nYsize
   LOCAL ALen
   LOCAL ADataSelect := {}
   LOCAL LReturn     := .f.
   LOCAL i,x,iMax
   LOCAL oStatic
   LOCAL aCheckBox := {}
   LOCAL TmpFilt2 := {}
   LOCAL pPrintJobs := pFilter[7]
   LOCAL OneHit     := .t.
   LOCAL lExit

*   DEFAULT oOwner    TO SetAppWindow(), ;
*           cTitle    TO " "

  /*
   * Dialogfenster fÅr die Listbox erzeugen
   */


   oDesktop       := AppDesktop()
*   oOwner         := SetAppWindow()

   oDlg           := XbpDialog():new( oDeskTop, oOwner, , , , .F. )
*   oDlg           := XbpDialog():new( oDeskTop, SetAppWindow(), , , , .F. )
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
   * Zwei Pushbuttons erzeugen
   */

   oBtnOk              := XbpPushButton():new( oDlg:drawingArea,,, { 72, 24 } )
   oBtnOk:caption      := "Ok"
   oBtnOk:tabStop      := .T.
   oBtnOk:keyBoard     := bKeyboard
   oBtnOk:activate     := {|| LReturn := .t., PostAppEvent( xbeP_Close,,, oDlg) }
   oBtnOk:lbUp         := {|mp1, mp2, obj| DrawSymbol(Obj) }
   oBtnOk:lbDown       := {|mp1, mp2, obj| DrawSymbol(Obj) }
   oBtnOk:create()


   oBtnCancel          := XbpPushButton():new( oDlg:drawingArea,, {72,0}, { 72, 24 } )
   oBtnCancel:caption  := "Abbruch"
   oBtnCancel:tabStop  := .T.
   oBtnCancel:keyBoard := bKeyboard
   oBtnCancel:lbUp     := {|mp1, mp2, obj| DrawSymbol(Obj) }
   oBtnCancel:lbDown   := {|mp1, mp2, obj| DrawSymbol(Obj) }
   oBtnCancel:activate := {|| LReturn := .f., PostAppEvent( xbeP_Close,,, oDlg) }
   oBtnCancel:create()



  /*
   * Grî·e fÅr das Dialogfenster einstellen und minimale Grî·e definieren.
   */
   nXsize  := 144 + 16
   nYsize  := 120 + 48
   mp1     := oDlg:calcFrameRect( { 0, 0, nXsize, nYsize } )
   oDlg:minSize := { mp1[3], mp1[4] }

   IF aSize == NIL
      nYsize := ( 36 * Len( pPrintJobs )) + 100
      nXsize := 144 + 140
      aSize  := oDlg:calcFrameRect( { 0, 0, nXsize, nYsize } )
      aSize  :=  { aSize[3], aSize[4] }
   ELSE
      aSize[1] := Max( aSize[1], oDlg:minSize[1] )
      aSize[2] := Max( aSize[2], oDlg:minSize[2] )
   ENDIF

   oDlg:setSize( aSize )
   MoveToOwner( oDlg, aPos )
   Resize( oDlg )
   x := len(pPrintJobs)
   for i := 1 to x

      oCheckBox              := XbpCheckBox():new( oDlg:DrawingArea, , {20, ( (x-i) * 36) + 65 }, {210,24} )
      oCheckBox:caption      := pPrintJobs[i][1] + " drucken"
      oCheckBox:Selection    := pPrintJobs[i][2]
      oCheckBox:Create()
      aAdd( aCheckBox, oCheckBox)

   next

   oDlg:setModalState( XBP_DISP_APPMODAL )
   oDlg:show()
   oFocus := SetAppFocus( oDlg )
   nEvent := xbe_None
   DO WHILE nEvent <> xbeP_Close
      nEvent := AppEvent( @mp1, @mp2, @oXbp )
      oXbp:handleEvent( nEvent, mp1, mp2 )
   ENDDO


   for i := 1 to len(pPrintJobs)
      if len( pPrintJobs[i] ) == 3
         aAdd(  pPrintJobs[i], .f. )
      endif
      if len( pPrintJobs[i] ) == 4
         aAdd(  pPrintJobs[i], .f. )
      endif
      pPrintJobs[i][4] := .f.
      pPrintJobs[i][2] := iif( lReturn, aCheckBox[i]:EditBuffer(), .f.)
      if pPrintJobs[i][2] .and. OneHit
         OneHit := .f.
         pPrintJobs[i][4] := .t.
      endif
   next

   pFilter[7] := pPrintJobs
   oDlg:setModalState( XBP_DISP_MODELESS )
   SetAppFocus( oFocus )
   oDlg:destroy()
   SetAppFocus( oOwner )

RETURN pFilter


STATIC PROCEDURE Resize( oDlg )
   LOCAL aDaSize    := oDlg:drawingArea:currentSize()
   LOCAL aChild     := oDlg:drawingArea:childList()
*   LOCAL oListBox   := aChild[1]
   LOCAL oBtnOk     := aChild[1]
   LOCAL oBtnCancel := aChild[2]
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
*   oListBox:setSize( aLbSize, .F. )

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
STATIC FUNCTION CenterPos( aSize, aRefSize )
RETURN { Int( (aRefSize[1] - aSize[1]) / 2 ) ;
       , Int( (aRefSize[2] - aSize[2]) / 2 ) }