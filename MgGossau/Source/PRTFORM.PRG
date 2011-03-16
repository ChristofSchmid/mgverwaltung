#include "Appevent.ch"
#include "Common.ch"
#include "Font.ch"
#include "Gra.ch"
#include "Xbp.ch"
#include "XbpDev.ch"
#include "MGV.CH"


FUNCTION PRINTForm(Report, pFilter, oFrom, RequestInput, LPrintMode, oPrinter)
*-----------------------------------------------------------------------------
LOCAL oFocus  := SetAppFocus()
LOCAL Print        := .f.
LOCAL pRecNo
LOCAL i
LOCAL lMultiPrint := iif( len(pFilter) == 7, iif( len(pFilter[7]) > 0, .t., .f.), .f.)
LOCAL FormInfo
LOCAL FormPos := 0

if Type( "Pages" ) == "N"
   MsgBox("Print wird verwendet, bitte warten", "Printform()")
   SetAppFocus(oFocus)
   Return .f.
Endif

PUBLIC Page  := 1
PUBLIC Pages := 1
PUBLIC Date  := Date()
PUBLIC Today := Date()
PUBLIC cReport := Report
PUBLIC cFilter := ""

if ValType( oFrom:aArea[TABELLEN]) == "N"

   for i:= 1 to len(pFilter[2])
   *   cFilter := cFilter + iif(i == 1,"", " und " ) + pFilter[2][i][1] + " = " + pFilter[2][i][2]
      cFilter := cFilter + iif(i == 1,"", " und " ) + oFrom:GettabText(pFilter[2][i][3], pFilter[2][i][2])
   next

else

   for i:= 1 to len(pFilter[2])
      cFilter := cFilter + iif(i == 1,"", " und " ) + pFilter[2][i][1] + " = " + pFilter[2][i][2]
   next

Endif

*cFilter := pFilter[1][3] + " = " +  pFilter[1][4] + " / " + cFilter

if lMultiPrint
   for i:= 1 to len( pFilter[7])
      pFilter[7][i][3] := Upper( pFilter[7][i][3] )
   next

   FormPos := aScan( pFilter[7], Upper( Report ) )
   if FormPos > 0
      if !pFilter[7][FormPos][2] &&Formular Drucken ?
         LPrintMode   := 0
         RequestInput := .f.
      else
         RequestInput :=  pFilter[7][FormPos][4] &&RequstInput f¸r erstes Formular
      endif
   else
      LPrintMode   := 0
      RequestInput := .f.
   endif
Endif


if pCount() == 3
   RequestInput := .t.
   LPrintMode := 0
Endif

if Len(ReadForm(Report)) == 0
   LPrintMode   := 0
   RequestInput := .f.
Endif

if oPrinter == NIL
   oPrinter := NewPrinter(Report)
   if oPrinter == NIL
      MsgBox("Kein Drucker installiert", "PrintForm()" )
      Rele Pages
      Return .f.
   endif
Endif


if RequestInput
   oPrinter := GetPrinter(oPrinter, @LPrintMode, oFrom)
Endif


Do Case

   Case LPrintMode == 0 && Abbruch
      SetAppFocus(oFocus)

   Case LPrintMode == 1 && Vorschau
      Print := .f.
      ViewForm(Report, pFilter, oFrom, oPrinter, @Print)
      if Print
         ViewForm(Report, pFilter, oFrom, oPrinter, @Print)
      Endif

   Case LPrintMode == 2 && Drucken
      Print := .t.
      ViewForm(Report, pFilter, oFrom, oPrinter, @Print)

Endcase


*SetAppFocus(oFocus)
*SetappFocus(oFrom)
RELE Page
RELE PA
RELE Pages
RELE Date
RELE Today
*RELE cPOS
RELE cFilter

if lMultiPrint .and. FormPos > 0
   pFilter[7][FormPos][5] := Print
Endif

Return Print



PROCEDURE ViewForm(Report, pFilter, oFrom, oPrinter, Print)
   LOCAL nEvent, mp1, mp2
   LOCAL oDlg, oXbp, drawingArea, oView, aPos[2], aSize, BPos[6][2], BSize, PSize[2]
   LOCAL oInfo, InfoPos[2], InfoSize[2], xVal[7], pVal
   LOCAL oXbp1, aForms
   LOCAL oParent, oOwner
   LOCAL i, x
   LOCAL oProgress
   LOCAL Areas := oFrom:aArea
   LOCAL aAppDeskSize
   LOCAL DefVar, DbVar
   LOCAL BtnPrt, BtnCancel
   LOCAL BtnPrint

   aSize        := AppDeskTop():currentSize()
   aAppDeskSize := AppDeskTop():currentSize()

   aPos  := {12,50}

   aSize[1] := ( aSize[1] - 24)
   aSize[2] := ( aSize[2] - 50 - 12)


*   aAppDeskSize :=  AppDeskTop():currentSize()
*   aSize    := oFrom:currentSize()

*   aPos[1]  := ( 0.05 * aSize[1] ) + (  (aAppDeskSize[1] - aSize[1]) / 2)
*   aPos[2]  := ( 0.05 * aSize[2] ) + (  (aAppDeskSize[2] - aSize[2]) / 2)
*   aSize[1] *= 0.9
*   aSize[2] *= 0.9

if Print

   aPos[1]  := ( 0.2 * aSize[1] ) + (  (aAppDeskSize[1] - aSize[1]) / 2)
   aPos[2]  := ( 0.8 * aSize[2] ) + (  (aAppDeskSize[2] - aSize[2]) / 2)
   aSize[1] *= 0.6
   aSize[2] *= 0.15

Endif

   InfoSize := {120,120}
   BSize    := {80,24}
   PSize    := { aSize[1] - BSize[1] - 40, aSize[2] - 40 }

   for i := 1 to 6
      BPos[i]  := { aSize[1] - BSize[1] - 20 ,  aSize[2] - ( BSize[2] + 20 ) * i  - 40 }
   next


   InfoPos := { BPos[6][1] , BPos[6][2] -90 }


   oOwner         := oFrom
   oParent        := AppDesktop()


   oDlg := XbpDialog():new( oParent,oOwner , aPos, aSize, , .F.)
   oDlg:border    := XBPDLG_RAISEDBORDERTHICK_FIXED
   oDlg:title     := "Druck Vorschau"
*   oDlg:title     := iif(!Print, "Vorschau-Dialog", "Report wird gedruckt: " + Alltrim( oView:Printer:DevName ) )
   oDlg:minButton := .F.
   oDlg:maxButton := .F.
   oDlg:taskList  := .T.
   oDlg:create()

   *oDlg:setModalState( XBP_DISP_APPMODAL )

   drawingArea := oDlg:drawingArea
   drawingArea:setFontCompoundName( "8.Helv" )

   oView := XbpPreview():new( drawingArea, , {0,0}, PSize )

   oView:drawBlock := {|oPS, nPageNo, nNumRows| FormatPage(oPS, nPageNo, @nNumRows, oView, Report, Areas, pFilter, DrawingArea, Print) }
   oView:create()

   oView:pSize := pSize
   oView:ReportNo       := Report
   oView:pArea          := Areas
   oView:pFilter        := pFilter
   oView:oFrom          := oFrom


*   if ValType(oPrinter) == "O"
      oView:Printer := oPrinter
*   Endif

if !Print

   oXbp := XbpPushButton():new( drawingArea, , BPos[1], BSize )
   oXbp:caption := "Zoom ++"
   oXbp:create()
   oXbp:activate := {|| oView:zoom( oView:zoomFactor + 0.25 ) }

   oXbp := XbpPushButton():new( drawingArea, , BPos[2], BSize )
   oXbp:caption := "Zoom - -"
   oXbp:create()
   oXbp:activate := {|| oView:zoom( oView:zoomFactor - 0.25 ) }

   oXbp := XbpPushButton():new( drawingArea, , BPos[3], BSize )
   oXbp:caption := "Ausdrucken"
   oXbp:create()
   oXbp:activate := {|| print := .t. , PostAppEvent( xbeP_Close,,,oDlg ) }
   oXbp:keyBoard := {| nKeyCode, uNIL, Obj | iif( nKeyCode == 13, PostAppEvent( xbeP_Activate, NIL, NIL, Obj ), iif( nKeyCode == 27,  PostAppEvent(xbeP_Close,,,oDlg) ,NIL )) }
   btnPrint := oXbp

*   oXbp := XbpPushButton():new( drawingArea, , BPos[4], BSize )
*   oXbp:caption := "Drucker ‰ndern"
*   oXbp:create()
*   oXbp:activate := {|| oView:Printer := GetPrinter(oView:Printer), oView:PrinterChange() }

   oXbp := XbpPushButton():new( drawingArea, , BPos[5], BSize )
   oXbp:caption := "Beenden"
   oXbp:create()
   oXbp:activate := {|| PostAppEvent(xbeP_Close,,,oDlg) }
   btnCancel := oXbp

*   oXbp := XbpStatic():new( drawingArea, , InfoPos, InfoSize )
*   oXbp:caption := "Druckerinfo"
*   oXbp:Type  := XBPSTATIC_TYPE_GROUPBOX
*   oXbp:setFontCompoundName( "7.Arial" )
*   oXbp:create()

   oDlg:SetTitle(Alltrim( "Druck Vorschau f¸r " + oView:Printer:DevName ))

   oDlg:show()
   oView:Startup   := .f.
   oView:PrinterChange(.f.)
   *SetAppFocus( oDlg )
   SetAppFocus( BtnPrint )
   oDlg:setModalState( XBP_DISP_APPMODAL )
   nEvent := 0

Else
      oDlg:show()
      SetAppFocus( oDlg )
      oView:Startup   := .f.
      oView:PrinterChange(.t.)
      oDlg:SetTitle( "Report wird gedruckt: " + Alltrim( oView:Printer:DevName ) )
      oView:print()
      PostAppEvent(xbeP_Close,,,oDlg)
Endif
*   oView:Startup   := .f.

   DO WHILE .t. &&nEvent <> xbeP_Close
      nEvent := AppEvent( @mp1, @mp2, @oXbp )

      if nEvent == xbeP_Close
         * Definitionen DH und DR entfernen
         ReleasePublic(oView,5,6)
         oDlg:setModalState( XBP_DISP_MODELESS )
         SetAppFocus(oFrom)
         oDlg:Destroy()
         nEvent := 0
         Return
      endif

      oXbp:handleEvent( nEvent, mp1, mp2 )
   ENDDO
RETURN



FUNCTION FormatPage(oPS, nPageNo, nNumRows, oView, ReportNo, Areas,  pFilter, DrawingArea, Print)
*------------------------------------------------------------------------------------------------
   LOCAL i,x       := 0
   LOCAL aPageSize := oPS:setPageSize()[1]
   LOCAL nY, xValue, pNy
   LOCAL nFontWidth, nFontHeight
   LOCAL nSegment
*   LOCAL pFilter    := GetPrtObj( { {},{},{},{},{},{} } )
   LOCAL hFields    := {}
   LOCAL nZeilen    := 0
   LOCAL ValidRecs  := 0
   LOCAL PageReg    := .f.
   LOCAL pageData   := {}
   LOCAL FiltLoop   := Array(0)
   LOCAL IsLoop     := .f.
   LOCAL y
   LOCAL SubDbKey   := ""
   LOCAL Incr       := 0
   LOCAL Font       := 1
   LOCAL aPosx      := {0,0}
   LOCAL aSize        := DrawingArea:CurrentSize()
   LOCAL ProgressPos  := {0,0}
   LOCAL ProgressSize := {0,0}
   LOCAL PgTxtPos     := {0,0}
   LOCAL PNewPage     := .f.
   LOCAL FFld
   LOCAL oFocus


   If oView:Startup
      Return 0
   Endif

   if Type("oPgTxt") == "U"
      PUBLIC oPgTxt
      if Print
         PUBLIC oProgress
         PUBLIC FirstProgress := .t.
      else
         PRIVATE oProgress
         Private FirstProgress := .t.
      Endif
   endif

   if !Print
      ProgressPos[1]  := aSize[1] - (0.95*aSize[1])
      ProgressPos[2]  := aSize[2] - (0.1*aSize[2])
      ProgressSize[1] := aSize[1] - (0.4*aSize[1])
      ProgressSize[2] := 12
      oProgress         := ProgressBar():new( DrawingArea ,, ProgressPos, ProgressSize)
      oProgress:create()
      oProgress:minimum := 1
      oProgress:color   := GRA_CLR_BLUE
   else
      ProgressPos[1]  := aSize[1] - (0.95*aSize[1])
      ProgressPos[2]  := aSize[2] - (0.90*aSize[2])
      ProgressSize[1] := aSize[1] - (0.10*aSize[1])
      ProgressSize[2] := 12
      PgTxtPos[1]     := ProgressPos[1]
      PgTxtPos[2]     := ProgressPos[2] + 20

      if ValType(oPgTxt) == "L"
         oPgTxt := XbpStatic():new( DrawingArea, , PgTxtPos, {ProgressSize[1],13} )
         oPgTxt:caption := "Seite " + Alltrim(Str(nPageNo))+ " von " + Alltrim(str( oView:numPages() )) + " Seiten wird gedruckt"
         oPgTxt:Type  := XBPSTATIC_TYPE_TEXT
         oPgTxt:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_LEFT
         oPgTxt:setFontCompoundName( "8.Arial" )
         oPgTxt:create()

         oProgress         := ProgressBar():new( DrawingArea ,, ProgressPos, ProgressSize)
         oProgress:create()
         oProgress:minimum := 1
         oProgress:color   := GRA_CLR_BLUE

      else

         oPgTxt:caption := "Seite " + Alltrim(Str(nPageNo))+ " von " + Alltrim(str( oView:numPages() )) + " Seiten wird gedruckt"
         oPgTxt:Configure()
      endif

   Endif

*   oProgress         := ProgressBar():new( DrawingArea ,, ProgressPos, ProgressSize)
*   oProgress:create()
*   oProgress:minimum := 1
*   oProgress:color   := GRA_CLR_BLUE

   // Maximale Hîhe und Breite eines Buchstabens
   // im aktuellen Font feststellen

   nFontWidth  := oPS:setFont():width
   nFontHeight := oPS:setFont():height

   Incr        := 0 &&nFontheight + 2
   aPosX[1]    := nFontWidth/2

   // Anzeige der grafischen Primitiven wÑhrend der Berechnung
   // der Seiten unterdrÅcken
   GraSegDrawMode( oPS, GRA_DM_RETAIN )

   //
   // Berechnung der Seite
   //
   // ôffne neues Segment
   nSegment := GraSegOpen( oPS )

   *nY  := aPageSize[2] - 2 * nFontHeight
   nY  := aPageSize[2] - 50
   pNy := nY

   *pageData := oView:GetPageInfo(oPS,ReportNo,Areas, pFilter, nY, oProgress)
   *pageData := iif( len(oView:Pages) >= 1, oView:Pages, oView:GetPageInfo(oPS,ReportNo,Areas, pFilter, nY, oProgress) )
   if Len(oView:pages) == 0
      pageData := oView:GetPageInfo(oPS,ReportNo,Areas, pFilter, nY, oProgress)
      *pageData := oView:GetPageInfo(oPS,ReportNo,Areas, pFilter, nY, oProgress)
   else
      pageData := oView:Pages
   Endif

   if len(PageData) < nPageNo
      oFocus := SetAppFocus()
      MsgBox("Fehler in der Seitenindexierung ::Pages, Bitte *.CTR File kontrillieren","PrtForm()")
      if Type("oPgTxt") == "O"
         oPgTxt:Destroy()
      endif
      SetAppFocus(oFocus)
      oProgress:Destroy()
      Rele oPgTxt
      Rele oProgress
      Rele FirstProgress
      PostAppEvent(xbeP_Activate,,, oView:oPrevPage)
      return nSegment
   Endif

   *Pages := oView:numPages()
   oProgress:maximum := pNy / (nFontHeight + 2)
   oProgress:Current(1)

   if Print .and. FirstProgress
      FirstProgress := .f.
      oProgress:maximum := pNy / (nFontHeight + 2) * oView:NumPages()
   Endif
           Select(Areas[ (pFilter[1][1]) ] )
           OrdSetFocus(pFilter[1][2] )
           if FileLock( Areas[ pFilter[1][1] ])
              DbGoto(pageData[nPageNo][1])
              DbUnlock()
           Endif

           if nPageNo > 1
              FSkip(1)
           endif

           PrintLine(1 ,.t., oPS, Font, Incr, @nY,  0, oView, oProgress)

           Ffld := pFilter[1][3]
*           Do While iif( Empty(pFilter[1][4]), .t.,Upper( Subs (Eval( FieldBlock( pFilter[1][3]) ),1,Len( pFilter[1][4]) ) )  == pFilter[1][4]) .and. !Eof()
           Do While iif( Empty(pFilter[1][4]), .t.,Upper( Subs (  &FFld ,1,Len( pFilter[1][4]) ) )  == pFilter[1][4]) .and. !Eof()

              if IsLoopDb(pFilter, 2, oProgress)
                 Fskip(1)
                 loop
              Endif

              if ! PrintLine(2, .t., oPS, Font, Incr, @nY, pFilter[1][1], oView , oProgress)
                 Exit
              Endif

              if ! len(pFilter[4]) == 0

                 SubDbKey := Eval( FieldWBlock( pFilter[4][4], Areas[ (pFilter[1][1]) ]) )

                 Select(Areas[ pFilter[4][1]] )
                 OrdSetFocus(pFilter[4][2] )

                 if FileLock( Areas[ pFilter[4][1] ])
                    DbSeek( SubDbKey )
                    DbUnlock()
                 Endif

                 if ! Found()
                    *MsgBox("Stufe 2 hat keine Resultate", "Ausdrucken" )
                    Select(Areas[ (pFilter[1][1]) ] )
                    OrdSetFocus(pFilter[1][2] )
                    FSkip(1)
                    Loop
                 Endif

                 Do While Eval( FieldWBlock( pFilter[4][3], Areas[ pFilter[4][1]]  ) ) == SubDbKey .and. !Eof()

                    if IsLoopDb(pFilter,5, oProgress)
                       Fskip(1)
                       loop
                    Endif

                    if !PrintLine(3, .t., oPS, Font, Incr, @nY, pFilter[4][1], oView, oProgress)
                       PNewPage := .t.
                       Exit
                    Endif
                    FSkip(1)
                 Enddo
                 ReleasePublic(oView,6,6)
                 Select(Areas[ pFilter[1][1]] )
                 OrdSetFocus(pFilter[1][2] )

                 if PNewPage
                    PNewPage := .f.
                    Exit
                 Endif

              Endif

              FSkip(1)
           Enddo

           if len( oView:pForm[9] ) > 0
              if Page == Pages
                 PrintLine(9 ,.t., oPS, Font, Incr, @nY,  0, oView, oProgress)
              Endif
           endif

           nY := iif( Page == Pages , PrintBlockSize(oView, 8), PrintBlockSize(oView, 4) )

           if Page == Pages
              PrintLine(8 ,.t., oPS, Font, Incr, @nY,  0, oView, oProgress)
           else
              PrintLine(4 ,.t., oPS, Font, Incr, @nY,  0, oView, oProgress)
           Endif

           if !Print
              oProgress:Destroy()
              Rele oPgTxt
           Endif

           if nPageNo == oView:NumPages() .and. Print
              oPgTxt:Destroy()
              oProgress:Destroy()
              Rele oPgTxt
              Rele oProgress
              Rele FirstProgress
           Endif

           Select(Areas[ pFilter[1][1]] )

           ASize( oView:segments, oView:numPages() )

           // Schlie·e Segment und zurÅcksetzen des
           // Segment Drawing Mode
           GraSegClose( oPS )

           GraSegDrawMode( oPS, GRA_DM_DRAWANDRETAIN )

RETURN nSegment


FUNC IsLoopDb(pFilter, point, oProgress)
*--------------------------------
LOCAL  IsLoop   := .f.
LOCAL  FiltLoop := {}
LOCAL  i

if Len(pFilter[point]) = 0
   Return .f.
Endif

For i := 1 to Len(pFilter[point] )
   if ! eval( FieldBlock( pFilter[point][i][1] ) ) ==  pFilter[point][i][2]
      aAdd( FiltLoop, .f.)
   endif
next

for i := 1 to Len(FiltLoop)
    IsLoop := !FiltLoop[i]
next

if IsLoop
   oProgress:Increment()
Endif

Return IsLoop



/*
 * Klassendeklaration
 */
CLASS XbpPreview FROM XbpStatic
   PROTECTED:
   VAR oView                      // XbpDialog als Anzeigebereich
   VAR oSquare                    // XbpStatic zum FÅllen der LÅcke zw. Scrollbars


   VAR aViewPort                  // Viewport zum zoomen
   VAR aPageSize                  // Seitengrî·e zum Drucken
   VAR aCharAttr                  // Attribute fÅr Strings (GRA_AS_BOX)
   VAR aAreaAttr                  // Attribute fÅr FlÑchen (GRA_AA_COLOR)
   VAR nPagePos                   // akt. Seitenposition
   VAR nRows                      // Anz. der Zeilen pro Seite

   METHOD setOrigin               // Ursprung fÅr Viewport setzen
   METHOD calcScrollBox           // Grî·e der ScrollBox bei Scrollbars berechnen

   METHOD startDoc                // Drucken beginnen
   METHOD endDoc                  // Drucken beenden

   EXPORTED:

   VAR oFont                      // XbpFont
   VAR oPresSpace                 // XbpPresSpace
   VAR aFont

   VAR pSize
   VAR hScroll    READONLY        // Horizontaler Scrollbar
   VAR vScroll    READONLY        // Vertikaler Scrollbar
   VAR oPagePos                   // Static zum Anzeigen der akt. Seitenposition
   VAR oNextPage                  // Button zum Anzeigen der naechsten Seite
   VAR oPrevPage                  // Button zum Anzeigen der vorigen Seite
   VAR ReportNo
   VAR pArea
   VAR pFilter
   VAR Pages
   VAR pData
   VAR pForm
   VAR oFrom
                                  ** Konfiguration
   VAR drawBlock                  // Codeblock ruft Func zum Zeichnen auf
   VAR printer                    // XbpPrinter
   VAR zoomFactor                 // Zoomfaktor von 1 bis n
   VAR segments                   // Array mit Segment IDs
   VAR StartUp
                                  ** Lebenszyklus
   METHOD init                    //
   METHOD create                  //
   METHOD Destroy                 //
                                  ** Anzeige
   METHOD setSize                 // Grî·e definieren
   METHOD hScroll                 // Horizontal scrollen
   METHOD vScroll                 // Vertical scrollen
   METHOD zoom                    // Zoomen
   METHOD presSpace               // Pesentation Space abfragen
   METHOD setViewPort             // Grî·e vom Viewport einstellen
   METHOD drawPage                // Zeichnen einer Seite
                                  ** Drucken
   METHOD print                   // Ausgeben der Seiten auf dem Drucker

   METHOD numPages                // Ermitteln der Anzahl der Seiten
   METHOD pageNo                  // Ermitteln der Nummer der akt. Seite

   METHOD drawNextPage            // Zeichnen der nÑchsten Seite
   METHOD drawPrevPage            // Zeichnen der vorigen Seite
   METHOD PrinterChange
   METHOD GetPageInfo
   METHOD SetPageData

ENDCLASS



/*
 * Objekt initialisieren
 */
METHOD XbpPreview:init( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::XbpStatic:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::xbpStatic:type  := XBPSTATIC_TYPE_RAISEDRECT

   ::oView           := XbpDialog():new( self )

   ::vScroll         := XbpScrollbar():new( self )
   ::vScroll:type    := XBPSCROLL_VERTICAL
   ::vScroll:cargo   := 0
   ::vScroll:autoTrack := .F.

   ::oPagePos        := XbpPushButton():new( self )
   ::oPagePos:activate := { || MsgBox("Springe zu Seite n (nicht implementiert)") }

   ::oNextPage       := XbpPushButton():new( self )
   ::oNextPage:caption := "+"
   ::oNextPage:activate := { || ::drawNextPage() }
   ::oPrevPage       := XbpPushButton():new( self )
   ::oPrevPage:caption := "-"
   ::oPrevPage:activate := { || ::drawPrevPage() }

   ::hScroll         := XbpScrollbar():new( self )
   ::hScroll:type    := XBPSCROLL_HORIZONTAL
   ::hScroll:cargo   := 0
   ::hScroll:autoTrack := .F.

   ::oSquare         := XbpStatic():new( self )
   ::oSquare:type    := XBPSTATIC_TYPE_RECESSEDBOX

   // Initialisieren des Presentation Space fÅr die
   // Ausgabe der Vorschau. Um genaue Textausgabe
   // sicherzustellen, wird hier explizit der Modus
   // "hohe TextprÑzision" eingestellt

   ::oPresSpace      := XbpPresSpace():new()
   ::oPresSpace:mode := XBPPS_MODE_HIGH_PRECISION

   ::zoomFactor      := 1
   ::segments        := {}
   ::nPagePos        := 1
   ::nRows           := 0
   ::ReportNo        := 0
   ::Pages           := Array(0,3)
   ::pData           := Array(0)
   ::pForm           := array(6,0,0)
   ::pArea           := Array(100)
   ::pFilter         := {1=1}
   ::StartUp         := .t.

   // Standard Drucker bereitstellen
   ::printer         := XbpPrinter():New() &&GetPrinter()
   ::aFont           := {}

    // Beende Applikation wenn kein Drucker installiert ist.
*   IF ::printer:list() == NIL
*      MsgBox( "Fehler - Es sind keine Drucker installiert!", "Ausdruck" )
*      QUIT
*   ENDIF
RETURN self



/*
 * Systemresourcen anfordern
 */
METHOD XbpPreview:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL oFont, i, imax, aFontList

   // XbpStatic ist Parent fÅr alle weiteren XBPs
   ::xbpStatic:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   // Printer erzeugen
   ::printer:create()
*   ::Printer := GetPrinter(::Printer)

   // XbpDialog wird ohne Titel angezeigt
   ::oView:minButton := .F.
   ::oView:maxButton := .F.
   ::oView:sysMenu   := .F.
   ::oView:titleBar  := .F.
   ::oView:border    := XBPDLG_THINBORDER
   ::oView:create()


   ::oPagePos:create()
   ::oPagePos:setFontCompoundName( "7.Arial" )
   ::oPagePos:paint  := { || ::oPagePos:setCaption( AllTrim(Str(::pageNo())) +;
                             "/" + AllTrim(Str(::numPages())) ) }

   ::oNextPage:create()
   ::oNextPage:setFontCompoundName( "7.Arial" )
   ::oPrevPage:create()
   ::oPrevPage:setFontCompoundName( "7.Arial" )

   // Scrollbars und FÅllquadrat zw. Scrollbars erzeugen
   ::oSquare:create()
   ::hScroll:create()
   ::vScroll:create()

   ::hScroll:scroll := {|mp1| ::hScroll( mp1 ) }
   ::vScroll:scroll := {|mp1| ::vScroll( mp1 ) }

   // Grî·e der XBPs wird in :setSize() eingestellt
   ::setSize( ::currentSize() )

   // Grî·e der Druckseite abz¸glich nicht bedruckbarer R‰nder berechnen
   // Die Einheit ist 1/10 mm
   aSize       := ::printer:paperSize()
   ::aPageSize := { aSize[5]-aSize[3], aSize[6]-aSize[4] }

   // Presentation Space mit Drucker Device Context verknÅpfen
   // Der PS bekommt die metrische Einheit 1/10 mm
   ::oPresSpace:create( ::printer, ::aPageSize, GRA_PU_LOMETRIC )

   IF ::oFont == NIL
      // Default Font bereitstellen -> kleiner Nichtproportionalfont
      ::oFont := XbpFont():new( ::oPresSpace )
      ::oFont:familyName := "Courier New"
      ::oFont:nominalPointSize := 8

      *::oFont:familyName := "Courier New"
      *::oFont:nominalPointSize := 10
      ::oFont:generic := .T.
      ::oFont:create()
      aAdd(::aFont, {"F0", ::oFont} )
   ENDIF
   ::pForm          := ReadForm(cReport)
   ::aFont          := SetFonts( SELF, ::pForm )


   // Presentation Space mit Window Device Context verkn?pfen
   ::oPresSpace:configure( ::oView:drawingArea:winDevice() )


   // Beim Repaint wird alles mit einer wei·en Box Åbermalt
   ::aCharAttr := Array( GRA_AS_COUNT )
   ::aAreaAttr := Array( GRA_AA_COUNT )
   ::aAreaAttr [ GRA_AA_COLOR ] := GRA_CLR_WHITE
   ::oPresSpace:setAttrArea( ::aAreaAttr )

   ::oPresSpace:setFont( ::oFont )

   // Beende Applikation, wenn kein Codeblock zugewiesen wurde
   IF ValType( ::drawBlock ) != "B"
      MsgBox( ":drawBlock ist ungÅltig!" )
      QUIT
   ENDIF

   // Evaluieren des Codeblocks in ":drawBlock" zum Formatieren
   // der ersten Seite. Dieser mu· eine Routine aufrufen, die
   // die Anzeige durchfÅhrt, siehe Funktion "FormatPage()"

  AAdd( ::segments, Eval(::drawBlock, ::oPresSpace, 1, @::nRows) )
  ASize( ::segments, ::numPages() )

   // Viewport initialisieren
   aSize       := ::oView:drawingArea:currentSize()
   ::aViewPort := { 0, 0, aSize[1], aSize[2] }
   ::oView:drawingArea:paint := {|| ::drawPage() }
   ::zoom()

RETURN self



/*
 * Systemresourcen freigeben
 */
METHOD XbpPreview:Destroy()
   LOCAL i
   ::xbpStatic:destroy()
   ::aViewPort := ;
   ::aPageSize := ;
   ::oFont     := NIL
   For i := 1 to len (::aFont)
      ::aFont[i][2]:Destroy()
   next
   ::aFont     := {}
RETURN self



/*
 * Grî·e von XbpStatic und enthaltenen XBPs Ñndern
 */
METHOD XbpPreview:setSize( aSize )

*   ::xbpStatic:setSize( aSize )

   aSize := ::currentSize()

   ::oPagePos:setPos ( { 0, 0 } )
   ::oPagePos:setSize( { 40, 16 } )
   ::oNextPage:setPos ( { 40, 0 } )
   ::oNextPage:setSize( { 20, 16 } )
   ::oPrevPage:setPos ( { 60, 0 } )
   ::oPrevPage:setSize( { 20, 16 } )

   ::hScroll:setPos ( { 80, 0 } )
   ::hScroll:setSize( { aSize[1]-16-80, 16 } )
   ::vScroll:setPos ( { aSize[1]-16, 16 } )
   ::vScroll:setSize( { 16, aSize[2]-16 } )
   ::oSquare:setPos ( { aSize[1]-16,  0 } )
   ::oSquare:setSize( { 16, 16 } )
   ::oView  :setPos ( { 0 , 16 } )
   ::oView  :setSize( { aSize[1]-16, aSize[2]-16 } )

RETURN self



/*
 * Horizontal scrollen
 */
METHOD XbpPreview:hScroll( mp1 )
   LOCAL nScrollPos := mp1[1]
   LOCAL nCommand   := mp1[2]
   LOCAL nScroll

   IF (nScrollPos == 0                               .AND. ;
       ::hScroll:getData() == 0)                     .OR.  ;
      (nScrollPos == ::hScroll:setRange()[2]         .AND. ;
       ::hScroll:getData() == ::hScroll:setRange()[2] )
       RETURN self
   ENDIF

   DO CASE
   CASE nCommand == XBPSB_PREVPOS
      nScroll = ::hScroll:getData() - ::hScroll:setScrollBoxSize()
      ::hScroll:setData( Max(nScroll, 0) )
      ::setOrigin( ::hScroll:getData(), ::vScroll:getData() )
   CASE nCommand == XBPSB_NEXTPOS
      nScroll = ::hScroll:getData() + ::hScroll:setScrollBoxSize()
      ::hScroll:setData( Min(nScroll, ::hScroll:setRange()[2]) )
      ::setOrigin( ::hScroll:getData(), ::vScroll:getData() )
   CASE nCommand == XBPSB_PREVPAGE
      ::hScroll:setData( nScrollPos )
      ::setOrigin( ::hScroll:getData(), ::vScroll:getData() )
   CASE nCommand == XBPSB_NEXTPAGE
      ::hScroll:setData( nScrollPos )
      ::setOrigin( ::hScroll:getData(), ::vScroll:getData() )
   CASE nCommand == XBPSB_ENDTRACK
      ::hScroll:setData( nScrollPos )
      ::setOrigin( ::hScroll:getData(), ::vScroll:getData() )
   ENDCASE

RETURN self



/*
 * Vertikal scrollen
 */
METHOD XbpPreview:vScroll( mp1 )
   LOCAL nScrollPos := mp1[1]
   LOCAL nCommand   := mp1[2]
   LOCAL nScroll

   IF (nScrollPos == 0                               .AND. ;
       ::vScroll:getData() == 0)                     .OR.  ;
      (nScrollPos == ::vScroll:setRange()[2]         .AND. ;
       ::vScroll:getData() == ::vScroll:setRange()[2] )
       RETURN self
   ENDIF

   DO CASE
   CASE nCommand == XBPSB_PREVPOS
      nScroll = ::vScroll:getData() - ::vScroll:setScrollBoxSize()
      ::vScroll:setData( Max(nScroll, 0) )
      ::setOrigin( ::hScroll:getData(), ::vScroll:getData() )
   CASE nCommand == XBPSB_NEXTPOS
      nScroll = ::vScroll:getData() + ::vScroll:setScrollBoxSize()
      ::vScroll:setData( Min(nScroll, ::vScroll:setRange()[2]) )
      ::setOrigin( ::hScroll:getData(), ::vScroll:getData() )
   CASE nCommand == XBPSB_PREVPAGE
      ::vScroll:setData( nScrollPos )
      ::setOrigin( ::hScroll:getData(), ::vScroll:getData() )
   CASE nCommand == XBPSB_NEXTPAGE
      ::vScroll:setData( nScrollPos )
      ::setOrigin( ::hScroll:getData(), ::vScroll:getData() )
   CASE nCommand == XBPSB_ENDTRACK
      ::vScroll:setData( nScrollPos )
      ::setOrigin( ::hScroll:getData(), ::vScroll:getData() )
   ENDCASE

RETURN self



/*
 * Ursprung vom Viewport setzen (nach Scrollen)
 */
METHOD XbpPreview:setOrigin( nX, nY )
   LOCAL aSize       := ::oView:drawingArea:currentSize()
   LOCAL nViewWidth  := aSize[1]
   LOCAL nViewHeight := aSize[2]
   LOCAL nZoomWidth  := nViewWidth  * ::zoomFactor
   LOCAL nZoomHeight := nViewHeight * ::zoomFactor

   // X Ursprung ist immer <= 0
   nX := - Abs( nX )

   IF nZoomWidth <= nViewWidth
      nX := 0
   ELSEIF nViewWidth - nX >= nZoomWidth
      nX := nViewWidth - nZoomWidth
   ENDIF

   ::aViewPort[1] := nX
   ::aViewPort[3] := nX + nZoomWidth

   // Y Ursprung ist immer <= 0
   // Es mu· die Differenz zwischen Gesamthîhe und
   // sichtbarem Bereich berÅcksichtigt werden
   nY := Abs( nY ) - ( nZoomHeight - nViewHeight )

   IF nY > 0 .OR. nZoomHeight <= nViewHeight
      nY := 0
   ELSEIF nViewHeight - nY >= nZoomHeight
      nY := nViewHeight - nZoomHeight
   ENDIF

   ::aViewPort[2] := nY
   ::aViewPort[4] := nY + nZoomHeight

   ::setViewPort( ::aViewPort )
   ::drawPage()

RETURN self



/*
 * Grî·e der ScrollBox und Range fÅr beide Scrollbars berechnen
 */
METHOD XbpPreview:calcScrollBox()
   LOCAL aSize       := ::oView:drawingArea:currentSize()
   LOCAL nViewWidth  := aSize[1]
   LOCAL nViewHeight := aSize[2]
   LOCAL nZoomWidth  := aSize[1] * ::zoomFactor
   LOCAL nZoomHeight := aSize[2] * ::zoomFactor

   // Werte fÅr horizontalen Scrollbar berechnen
   ::hScroll:setRange( { 0, Int(nZoomWidth - nViewWidth) } )
   IF nZoomWidth > nViewWidth
      ::hScroll:setScrollBoxSize( (nZoomWidth-nViewWidth) * (nViewWidth/nZoomWidth) )
   ELSE
      ::hScroll:setScrollBoxSize( nViewWidth )
   ENDIF

   // Werte fÅr vertikalen Scrollbar berechnen
   ::vScroll:setRange( { 0, Int(nZoomHeight - nViewHeight) } )
   IF nZoomHeight > nViewHeight
      ::vScroll:setScrollBoxSize( (nZoomHeight-nViewHeight) * (nViewHeight/nZoomHeight) )
   ELSE
      ::vScroll:setScrollBoxSize( nViewHeight )
   ENDIF

RETURN self



/*
 * Viewport zoomen
 */
METHOD XbpPreview:zoom( nZoomFactor )
   LOCAL aSize  := ::oView:drawingArea:currentSize()
   LOCAL aPos   := ::oView:drawingArea:currentPos()

   DEFAULT nZoomFactor TO ::zoomFactor

   ::zoomFactor := Max( 1, nZoomFactor )

   // Viewport neu berechnen
   aSize[1] := Int( aSize[1] * nZoomFactor )
   aSize[2] := Int( aSize[2] * nZoomFactor )

   ::aViewPort  := {aPos[1], aPos[2], aSize[1], aSize[2]}
   ::calcScrollBox()

   // Ursprung vom Viewport neu definieren
   ::setOrigin( ::hScroll:getData(), ::vScroll:getData() )

RETURN self



/*
 * Presentation Space abfragen
 */
METHOD XbpPreview:presSpace
RETURN ::oPresSpace



/*
 * Viewport setzen
 */
METHOD XbpPreview:setViewPort( aViewPort )
   LOCAL aOldViewPort := ::oPresSpace:setViewPort()

   IF Valtype( aViewPort ) == "A"
      ::aViewPort := aViewPort
      ::oPresSpace:setViewPort( aViewPort )
   ENDIF
RETURN aOldViewPort



/*
 * Zeichnen der angegebenen Seite
 */
METHOD XbpPreview:drawPage( nPageNo )

   DEFAULT nPageNo TO ::nPagePos

   * Page ist public und kann im Doc definiert werden
   Page   := nPageNo
   *Datum  := dtoc( Date() )

   IF Len(::segments) == 0
      RETURN self
   ENDIF

   // Zeichnung wird durch Ausgabe einer wei· gefÅllten Box gelîscht
   GraBox( ::oPresSpace, {0,0}, ::aPageSize, GRA_FILL )

   IF nPageNo != 0 .AND. nPageNo <= ::numPages()
      IF ::segments[nPageNo] == NIL
         ::segments[nPageNo] := Eval( ::drawBlock,  ;
                                      ::oPresSpace, ;
                                      nPageNo,      ;
                                      @::nRows )
      ENDIF

      IF ::segments[nPageNo] != 0
         GraSegDraw( ::presSpace(), ::segments[nPageNo] )
      ENDIF
   ENDIF
RETURN self



/*
 * Druckausgabe beginnen
 * - Der Presentation Space wird mit dem Print Device Context assoziiert
 */
METHOD XbpPreview:startDoc

   ::oPresSpace:configure( ::printer )

   // Ab jetzt wird die Ausgabe in :oPresSpace auf den Spooler umgeleitet
   ::printer:startDoc()

   // Font und Attribute gehen nach :configure() verloren -> neu setzen
   ::oPresSpace:setFont( ::oFont )
   ::oPresSpace:setAttrArea( ::aAreaAttr )
   ::oPresSpace:setAttrString( ::aCharAttr )

RETURN self



/*
 * Druckausgabe beenden
 * - Der Presentation Space wird wieder mit dem Window Device Context assoziiert
 */
METHOD XbpPreview:endDoc

   // Spooler schlie·en
   ::printer:endDoc()

   // PS wieder mit Window Device verknÅpfen
   ::oPresSpace:configure( ::oView:drawingArea:winDevice() )

   // Font und Attribute gehen nach :configure() verloren -> neu setzen
   ::oPresSpace:setFont( ::oFont )
   ::oPresSpace:setAttrArea( ::aAreaAttr )
   ::oPresSpace:setAttrString( ::aCharAttr )

   // Viewport fÅr Window setzen
   ::zoom()

RETURN self



/*
 * Ausgabe aller Seiten auf dem Drucker
 */

METHOD XbpPreview:print()
   LOCAL i

   IF Len(::segments) == 0
      RETURN self
   ENDIF

   ::startDoc()

   // Lîschen Sie die folgenden Kommentare,
   // um das Drucken der gesamt Datenbank zu
   // erlauben. In diesem Beispiel wird nur die
   // aktuelle Seite gedruckt.
   *::drawPage( ::nPagePos )

    FOR i:=1 TO ::numPages()
      ::drawPage( i )

      IF i +1 <= ::numPages()
         ::printer:newPage()
      ENDIF
    NEXT

   ::endDoc()

RETURN self



/*
 * Ermitteln der Seitenanzahl
 */
METHOD XbpPreview:numPages()
   LOCAL nPages

   if Len(::Pages) == 0
      nPages := 1
   else
      nPages := Len(::Pages)
   Endif


*   IF ::nRows == 0
*      nPages := 1
*   ELSE
*      nPages := Int( RecCount() / ::nRows ) + ;
*                IIF( RecCount() % ::nRows != 0, 1, 0 )
*   ENDIF

RETURN nPages



/*
 * Ermitteln der Nummer der akt. Seite
 */
METHOD XbpPreview:pageNo()
RETURN ::nPagePos
/*
 * Anzeigen der nÑchsten Seite
 */

METHOD XbpPreview:drawNextPage()
   IF ::nPagePos +1 <= ::numPages()
      ::nPagePos++
      ::Hide()
      ::drawPage()
      ::Show()
      ::oPagePos:invalidateRect()
   ENDIF
RETURN self



/*
 * Anzeigen der vorhergehenden Seite
 */
METHOD XbpPreview:drawPrevPage()
   IF ::nPagePos -1 > 0
      ::nPagePos--
      ::drawPage()
      ::oPagePos:invalidateRect()
   ENDIF
RETURN self


METHOD XbpPreview:PrinterChange(Print)
*--------------------------------
LOCAL aSize
LOCAL bPos := 0
LOCAL hPos := 0
LOCAL bPrt
LOCAL hPrt
LOCAL bBS  := ::pSize[1]
LOCAL hBS  := ::pSize[2]
LOCAL hFak := 0
LOCAL bFak := 0

::Hide()

aSize       := ::printer:paperSize()
::aPageSize := { aSize[5]-aSize[3], aSize[6]-aSize[4] }

bPrt := ::aPageSize[1]
hPrt := ::aPageSize[2]

hFak := bPrt / hPrt * hBS / bBS
hBS  := Abs( hBS / hFak )

if hBS > ::pSize[2]
   bBS  := ::pSize[1]
   hBS  := ::pSize[2]

   bFak := hPrt / bPrt * bBS / hBS
   bBS  := Abs( bBS / bFak )
Endif

bPos := Abs( (::pSize[1] - bBS ) / 2 )
hPos := Abs( (::pSize[2] - hBS ) / 2 )


::SetPosAndSize({bPos,hPos}, {bBS,hBS},.t. )

::SetSize()

::oPresSpace:Configure( ::oView:drawingArea:winDevice(), ::aPageSize, GRA_PU_LOMETRIC )
::oPresSpace:setFont( ::oFont )
::oPresSpace:setAttrArea( ::aAreaAttr )
::oPresSpace:setAttrString( ::aCharAttr )

::aViewPort := { 0, 0, ::aPageSize[1], ::aPageSize[2] }

::Segments := {NIL}
::pData    := Array(0)



if !Print
  ::zoom()
  ::Show()
else

Endif

Return .t.





METHOD XbpPreview:GetPageInfo(oPS, ReportNo,  Areas, pFilter, nY, oProgress)
*-------------------
   LOCAL hFields     := {}
   LOCAL nZeilen     := 0
   LOCAL ValidRecs   := 0
   LOCAL StartRec    := 1
   LOCAL PageReg     := .f.
   LOCAL KLines      := 0
   LOCAL HLines      := 0
   LOCAL H1Lines     := 0
   LOCAL FLines      := 0
   LOCAL nPages      := 0
   LOCAL nLines      := 0
   LOCAL HRecs       := {}
   LOCAL nFontHeight := oPS:setFont():height
   LOCAL pNy         := 0
   LOCAL Filt1, Filt2
   LOCAL FiltLoop    := Array(0)
   LOCAL IsLoop      := .f.
   Local x, y
   LOCAL SubDbKey    := ""
   LOCAL Incr        := 0
   LOCAL Font        := 1
   LOCAL Ffld        := NIL
   LOCAL i

if len( ::pData ) == 0
   ::Pages  := Array(0,3)
            Select(Areas[ (pFilter[1][1]) ] )
            OrdSetFocus(pFilter[1][2] )

            oProgress:Maximum := LastRec()
            oProgress:Current(1)

            if Len(::Pages) == 0
               if FileLock( Areas[ pFilter[1][1] ])
                  if !Empty(pFilter[1][4])
                     DbSeek( pFilter[1][4] )
                  else
                     DbGotop()
                  Endif
                  DbUnlock()
                  pNy := 0
                  nPages :=  1
                  ::SetPageData(  Areas[ pFilter[1][1] ] , nPages)
               Endif
            else
               FSkip(1)
            endif


           if ! PrintLine(1 ,.f., oPS, Font, Incr, @nY,  0, Self, oProgress)
              nPages := nPages + 1
              ::SetPageData(  Areas[ pFilter[1][1] ] , nPages)
           Endif


           Ffld := pFilter[1][3]
*           Do While iif( Empty(pFilter[1][4]), .t.,Upper( Subs (Eval( FieldBlock( pFilter[1][3]) ),1,Len( pFilter[1][4]) ) )  == pFilter[1][4]) .and. !Eof()
            Do While iif( Empty(pFilter[1][4]), .t.,Upper( Subs (  &FFld ,1,Len( pFilter[1][4]) ) )  == pFilter[1][4]) .and. !Eof()

              if IsLoopDb(pFilter, 2, oProgress)
                 Fskip(1)
                 loop
              Endif

              if !nPages == 1
                 ::Pages[nPages - 1][3] := 1
              endif

              if ! PrintLine (2, .f., oPS, Font, Incr, @nY, pFilter[1][1], Self , oProgress)
                 nPages := nPages + 1
                 ::SetPageData(  Areas[ pFilter[1][1] ] , nPages)

                 if ! PrintLine(1 ,.f., oPS, Font, Incr, @nY,  0, Self, oProgress)
                      nPages := nPages + 1
                      ::SetPageData(  Areas[ pFilter[1][1] ] , nPages)
                 Endif
              Endif

              if ! len(pFilter[4]) == 0

                 SubDbKey := Eval( FieldBlock( pFilter[4][4]) )

                 Select(Areas[ pFilter[4][1]] )
                 OrdSetFocus(pFilter[4][2] )

                 if FileLock( Areas[ pFilter[4][1] ])
                    DbSeek( SubDbKey )
                    DbUnlock()
                 Endif

                 if ! Found()
                    *MsgBox(" hat keine Resultate", "Ausdrucken" )
                    Select(Areas[ (pFilter[1][1]) ] )
                    OrdSetFocus(pFilter[1][2] )
                    FSkip(1)
                    Loop
                 Endif

                 Do While Eval( FieldBlock( pFilter[4][3]) ) == SubDbKey .and. !Eof()

                    if IsLoopDb(pFilter,5, oProgress)
                       Fskip(1)
                       loop
                    Endif

                    if ! PrintLine(3, .f., oPS, Font, Incr, @nY, pFilter[4][1], Self, oProgress)
                       nPages := nPages + 1
                       ::SetPageData(  Areas[ pFilter[1][1] ] , nPages)
                    Endif
                    FSkip(1)
                 Enddo

                 Select(Areas[ pFilter[1][1]] )
                 OrdSetFocus(pFilter[1][2] )
              Endif

              FSkip(1)
           Enddo

           if len( ::pForm[9] ) > 0 && Wenn Fliesstext angegeben wurde
                 if !nPages == 1 .and. ::Pages[nPages - 1][3] == 0
                    ::Pages[nPages - 1][3] := 1
                 endif

              if !PrintLine(9 ,.f., oPS, Font, Incr, @nY,  0, Self, oProgress)
                 nPages := nPages + 1
                 ::SetPageData(  Areas[ pFilter[1][1] ] , nPages)
                 ::Pages[nPages - 1][3] := 1
              Endif
           endif

           if Page == Pages
              PrintLine(8 ,.f., oPS, Font, Incr, @nY,  0, Self, oProgress)
           else
              PrintLine(4 ,.f., oPS, Font, Incr, @nY,  0, Self, oProgress)
           endif

   ::pData := {1,1,1,1}

Endif

for i := 1 to 4
  nLines := nLines + ::pData[i]
next


nPages := Len(::Pages)

if nPages > 1
   if ::Pages[nPages-1][3] == 0
      ARemove(::Pages, nPages)
   endif
Endif

if len( ::pForm[9] ) == 0 && wenn kein Fliesstext da ist
   for i := 1 to len(::Pages)
      if ::Pages[i][1] == 0
         ARemove(::Pages, i)
      endif
   next
Endif

nPages := Len(::Pages)

RETURN ::Pages


METHOD XbpPreview:SetPageData(Area, Page)
*------------------------------
LOCAL oldWa := Select()
Select(Area)
aAdd(::Pages, { Recno(), Page, 0 } )
Select(oldWa)

Return SELF



FUNCTION ReadForm(Report)
*---------------------------------

LOCAL FLines     := 0
LOCAL SegLines   := {0,0,0,0,0,0,0,0,0}
LOCAL FLine      := Space(0)
LOCAL LineLen    := 200
LOCAL FString    := Space(0)
LOCAL FVar       := Space(0)
LOCAL xFPos      := Array(2)
LOCAL yFPos      := 0
LOCAL xPaper     := 0
LOCAL yPaper     := 0

LOCAL i,x        := 0
LOCAL PageSeg    := 0
LOCAL FirstVar   := 0
LOCAL oForm      := array(9,0,0)
LOCAL LAttr      := ""

if File(FormDrive + Report)
   FString := MemoRead(FormDrive + Report)
else
   MSGBox("Das Formular "+FormDrive + Report +" konnte nicht gefunden werden","PrintForm()" )
   Return {}
Endif
FLines = MLCount(FString)

For i := 1 to FLines
    FLine := MemoLine(FString, LineLen, i)

    Do Case
       Case Subs(FLine,1,1) == "K" &&Kopfzeile
          PageSeg := 1
       Case Subs(FLine,1,1) == "H" &&Hauptzeile
          PageSeg := 2
       Case Subs(FLine,1,1) == "R" &&Relationszeile zu Hauptzeile
          PageSeg := 3
       Case Subs(FLine,1,1) == "F" &&FussZeile
          PageSeg := 4
       Case Subs(FLine,1,2) == "DH" &&Definitionen Hauptzeile
          PageSeg := 5
       Case Subs(FLine,1,2) == "DR" &&Definitionen Relationszeile
          PageSeg := 6
       Case Subs(FLine,1,2) == "DF" &&Definitionen von Fonts
          PageSeg := 7
       Case Subs(FLine,1,1) == "E" &&Endzeile
          PageSeg := 8
       Case Subs(FLine,1,1) == "S" &&FliessText (Memo)
          PageSeg := 9

          *Code Def Lines

       othe
          loop
    Endcase

          SegLines[PageSeg] += 1
          aadd(oForm[PageSeg], {})

          if PageSeg >= 1 .and. PageSeg <=4 .or. PageSeg == 8 .or. PageSeg == 9 &&nur K,H,R,F,E,S
             LAttr := Alltrim( Subs(FLine,2,4) )
             *aadd(oForm[PageSeg][SegLines[PageSeg] ], {"LDEF",LAttr, {0,0}} )
             aadd(oForm[PageSeg][SegLines[PageSeg] ], {"LDEF",LAttr, {0,0},0} )
          Endif

          FLine := Subs(FLine,7, LineLen)
          FirstVar := At( "#", FLine ) && Erstes #
          Do While At( "#", FLine ) > 0
             xFPos[1] := At("#", Fline )
             FLine := Stuff(FLine, xFpos[1], 1," ")
             xFPos[2] := At("#", FLine )
             FLine := Stuff(FLine, xFpos[2], 1," ")
             FVar := Alltrim(Subs( FLine, xFPos[1], xFPos[2] - xFPos[1] + 1) )
             FLine := Stuff(FLine, xFPos[1] + 1 , xFPos[2] - xFPos[1] , Space(xFPos[2] - xFPos[1]) )
             aadd(oForm[PageSeg][SegLines[PageSeg] ], {"VAR",FVar, {xFpos[1] - 1,xFpos[2]} })
          Enddo

          * Textelemente, Beginn mit Koordinaten
          xFPos[1] := Len(FLine) - len(Ltrim(FLine))
          aadd(oForm[PageSeg][SegLines[PageSeg] ], {"TEXT",Alltrim(FLine) , {xFPos[1],0}} )


          * Textelemente, Beginn am linken Rand Koordinaten
          *aadd(oForm[PageSeg][SegLines[PageSeg] ], {"TEXT",Subs(FLine,1, len(RTrim(FLine)) ), {0,0}} )

next
Return oForm


FUNC PrintLine(Form, pStat, oPS, Font, Incr, nY, DB, oView, oProgress)
*--------------------------------------------------------------------

* Form:
* 1 = K Kopfzeile
* 2 = H Hauptzeile , DefForm 5 -> Zeilenspezifische Definitionen von Tabelle & Public ect
* 3 = R RelationZeile , DefForm 6 -> Zeilenspezifische Definitionen von Tabelle & Public ect
* 4 = F Fusszeile
* 7 = DF Formularweite Definitionen von Fonts (F1 - ??, Wiederholen in Zeile -> Font wird f¸r Zeile verwendet.
* 8 = E Endzeile
* 9 = S Fliesstext




* FORM    "K" , "H", "R", "F", "E"
* Typ     "GRAPH", "TEXT", "DB"
* xValue  Ausgabe
* pStat   .t. = Drucken, .f. = Rechnen

LOCAL aPageSize    := oPS:setPageSize()[1]
LOCAL nFontHeight  := oPS:setFont():height
LOCAL nFontWidth   := oPS:setFont():width
*LOCAL pnY          := aPageSize[2] - 2 * nFontHeight
LOCAL pnY          := aPageSize[2] - 50

LOCAL pNx          := 0
LOCAL pEndPos      := 0
LOCAL pIncr        := Incr
LOCAL i,x, n
LOCAL dbVar        := ""
LOCAL DefVar       := ""
LOCAL LastPageLine := .f.
LOCAL DefFunc
LOCAL DefVar4Func
LOCAL DefFVar1     := ""
LOCAL DefFVar2     := ""
LOCAL DFStr        := ""
LOCAL DefPoint     := 0
LOCAL VarLen       := 0
LOCAL FontId
LOCAL PVar
LOCAL pTyp
LOCAL pRepeat
LOCAL pData
LOCAL pString
LOCAL pMemo         := .f.

GraSetFont(oPs, oView:aFont[1][2] )
oView:oFont := oView:aFont[1][2]

aPageSize    := oPS:setPageSize()[1]
nFontHeight  := oPS:setFont():height
nFontWidth   := oPS:setFont():width
pnY          := aPageSize[2] - 2 * nFontHeight

Do Case
   Case Form == 2 .or. Form == 9
     DefPoint := 5
   Case Form == 3
     DefPoint := 6
Endcase

For i := 1 to FCount()
   DbVar := FieldName(i)
   PRIVATE &DbVar := FieldGet(i)
next


if pStat .and. DefPoint > 0
   for i := 1 to len( oView:pForm[DefPoint] )
      Do case
         case oView:pForm[DefPoint][i][1][2] == "PUBLIC"
            DbVar  := oView:pForm[DefPoint][i][2][2]
            DefVar := Alltrim( Subs(DbVar,1, At(":", DbVar) - 1) )
            if Type( DefVar ) == "U"
               PUBLIC &DefVar
               DefVar :=  "{ || "  + oView:pForm[DefPoint][i][2][2] + "}"
               eval( &DefVar  )
            endif

            DefVar := "{ || "  + oView:pForm[DefPoint][i][3][2] + "}"
            eval( &DefVar  )


         case oView:pForm[DefPoint][i][1][2] == "TABELLE"

            if isMethod( oView:oFrom, "GetTabText" )


               DbVar  := oView:pForm[DefPoint][i][2][2]
               DefVar := Alltrim( Subs(DbVar,1, At(":", DbVar) - 1) )
               if Type( DefVar ) == "U"
                  PUBLIC &DefVar
                  DefVar :=  "{ || "  + oView:pForm[DefPoint][i][2][2] +  " }"
                  eval( &DefVar  )
               endif

               DFStr       := oView:pForm[DefPoint][i][3][2]
               DefFunc     := Alltrim( Subs( DFStr,1, At( "(",DFStr ) -1  ) )
               DefFVar1    := Alltrim( Subs( DFStr, At( "(",DFStr ) + 1, 5 ) )
               DefFVar2    := Alltrim( Subs( DFStr, At( ",",DFStr ) + 1, At( ")",DFStr ) - At( ",",DFStr ) - 1 ) )
               DefVar      := Alltrim( Subs(DbVar,1, At(":", DbVar) - 1) )
               &DefVar := oView:oFrom:&DefFunc.( &( DefFVar1 ) ,  &( DefFVar2 ) )

            Endif

         case oView:pForm[DefPoint][i][1][2] == "ATTR"


         case oView:pForm[DefPoint][i][1][2] == "HLINE"

         case oView:pForm[DefPoint][i][1][2] == "LDEF"

      endcase
   next
Endif

Pages  := oView:numPages()
PA     := Padl( Alltrim(Str(Page)) + "/" + Alltrim(str(Pages)),4)

For i := 1 to  len(oView:pForm[Form] )
    If oView:pForm[Form][i][1][1] == "LDEF"
       FontId := aScan( oView:aFont, oView:pForm[Form][i][1][2] )
       If FontId > 0

          GraSetFont(oPs, oView:aFont[FontId][2] )
          oView:oFont := oView:aFont[FontId][2]

          * Hˆhe un Breite f¸r zeilen Font neu einstellen
          nFontHeight  := oView:oFont:height
          nFontWidth   := oView:oFont:width
          *pnY          := aPageSize[2] - 2 * nFontHeight
          oView:pForm[Form][i][1][4] := nFontHeight
       Endif
    endif


   Do Case
      Case Form == 9


      For x := 2 to len(oView:pForm[Form][i] )

         pVar := oView:pForm[Form][i][x]

         if pVar[1] == "TEXT"
            pTyp    := "DB"
            pRepeat := 1
         else
            if Type( pVar[2] ) == "U"
               pTyp    := "DB"
               pRepeat := 1
            else
               VarLen  := oView:pForm[Form][i][x][3][2] - oView:pForm[Form][i][x][3][1]
               pTyp    := "FT"
               pData   := xToChar( Eval( MemVarBlock( pVar[2] ) ) , VarLen)[1]
               pRepeat := MLCount(pData, VarLen)
               pMemo   := .t.

            Endif
         Endif


        if ! pMemo
           pnX     := oView:pForm[Form][i][x][3][1] * nFontWidth
           pEndPos := oView:pForm[Form][i][x][3][2] * nFontWidth

           if PStat
              VarLen := oView:pForm[Form][i][x][3][2] - oView:pForm[Form][i][x][3][1]
              PrintString("DB", oPS,{pnX, nY },{pEndPos - pnx,nY }, oView:pForm[Form][i][x], VarLen )
           endif
           if !pIncr( @nY, pNy, nFontHeight, 0, Form, oView, @LastPageLine, oProgress, i  )
              Exit
           endif

        else
           for n:= 1 to pRepeat
              pString := MemoLine( pData ,VarLen , n)

              pnX     := oView:pForm[Form][i][x][3][1] * nFontWidth
              pEndPos := oView:pForm[Form][i][x][3][2] * nFontWidth

              if PStat
                 PrintString("FT", oPS,{pnX, nY },{pEndPos - pnx,nY }, {pVar[1],pString }, VarLen )
                 nY := nY - Int( ( nFontHeight + 2 ) )
              endif

           Next
           if !pIncr( @nY, pNy, nFontHeight, 0, Form, oView, @LastPageLine, oProgress, 1, pRepeat  )
              if LastPageLine
                 nY := pNy
              Endif
              Return iif(nY == pNy, .f., .t.)
           endif

        endif
      next


      othe

      For x := 2 to len(oView:pForm[Form][i] )

        pnX     := oView:pForm[Form][i][x][3][1] * nFontWidth
        pEndPos := oView:pForm[Form][i][x][3][2] * nFontWidth

        if PStat
           VarLen := oView:pForm[Form][i][x][3][2] - oView:pForm[Form][i][x][3][1]
           PrintString("DB", oPS,{pnX, nY },{pEndPos - pnx,nY }, oView:pForm[Form][i][x], VarLen )
        endif
      next

      if !pIncr( @nY, pNy, nFontHeight, 0, Form, oView, @LastPageLine, oProgress, i  )
         Exit
      endif

   EndCase

Next

if LastPageLine
   nY := pNy
Endif

Return iif(nY == pNy, .f., .t.)


FUNC PrintString(Typ, oPS, aPos, aSize, pVar, pVarLen)
*-----------------------------------------------------
LOCAL MLines
LOCAL MData
LOCAL iCnt

LOCAL xValue
LOCAL aTextBox
LOCAL xValSize
LOCAL aAttr := GraSetAttrString( oPS )

Do Case
   Case Typ == "TEXT"
      *xValue :=  hFields[i][10]
      aAttr[ GRA_AS_HORIZALIGN ]:= GRA_HALIGN_LEFT
      GraSetAttrString( oPS, aAttr )
      GraStringAt( oPS, aPos, xValue)

   Case Typ == "LINE"
      aAttr[ GRA_AS_HORIZALIGN ]:= GRA_HALIGN_LEFT
      GraSetAttrString( oPS, aAttr )
      GraLine( oPS, aPos, {aPos[1] + aSize[1], aPos[2]} )

   Case Typ == "BOX"
      aAttr[ GRA_AS_HORIZALIGN ]:= GRA_HALIGN_LEFT
      GraSetAttrString( oPS, aAttr )
      GraBox( oPS, aPos, {aPos[1]+ aSize[1],aPos[2] + aSize[2]} )

   Case Typ == "FT"
         aAttr[ GRA_AS_HORIZALIGN ]:= GRA_HALIGN_LEFT
         GraSetAttrString( oPS, aAttr )
         xValue := pVar[2]
         GraStringAt( oPS, aPos, xValue )

   Case Typ == "DB"

      if pVar[1] == "TEXT"
         aAttr[ GRA_AS_HORIZALIGN ]:= GRA_HALIGN_LEFT
         GraSetAttrString( oPS, aAttr )
         xValue := pVar[2]

      else
         if Type( pVar[2] ) == "U"
            aAttr[ GRA_AS_HORIZALIGN ]:= GRA_HALIGN_LEFT
            GraSetAttrString( oPS, aAttr )
            *xValue :=  "U: " + pVar[2]
            xValue :=  pVar[2]

         else
            xValue   :=  xToChar( Eval( MemVarBlock( pVar[2] ) ) , pVarLen)
            Do Case
            Case xValue[2] == "N"
               *rechtsb¸ndig f¸r Zahlen
               aAttr[ GRA_AS_HORIZALIGN ]:= GRA_HALIGN_RIGHT
               GraSetAttrString( oPS, aAttr )
               aPos[1] :=  aPos[1] + aSize[1]

            Case xValue[2] == "D"
               aAttr[ GRA_AS_HORIZALIGN ]:= GRA_HALIGN_LEFT
               GraSetAttrString( oPS, aAttr )

            Case xValue[2] == "L"
               aAttr[ GRA_AS_HORIZALIGN ]:= GRA_HALIGN_LEFT
               GraSetAttrString( oPS, aAttr )

            Case xValue[2] == "M"
               aAttr[ GRA_AS_HORIZALIGN ]:= GRA_HALIGN_LEFT
               GraSetAttrString( oPS, aAttr )

            Case xValue[2] == "C"
               aAttr[ GRA_AS_HORIZALIGN ]:= GRA_HALIGN_LEFT
               GraSetAttrString( oPS, aAttr )

            EndCase
            xValue := xValue[1]
         endif
      endif

      GraStringAt( oPS, aPos, xValue )

      * Linksb¸ndig ist Standart

   CASE Typ == "SPACE"

ENDCASE

Return .t.


FUNC pIncr(nY, pNy, nFontHeight, pIncr, Form, oView, LastPageLine, oProgress, LineCnt, TotLines )
*-----------------------------------------------------------------------------------------------
LOCAL i, x
LOCAL pForm         :=  oView:pForm
LOCAL EndBlockSize  :=  PrintBlockSize(oView, 8)
LOCAL FootBlockSize :=  PrintBlockSize(oView, 4)
LOCAL HBlockSize    :=  PrintBlockSize(oView, 2, LineCnt)
LOCAL SBlockSize    :=  PrintBlockSize(oView, 9, 1, TotLines )

*LOCAL PrintBlockSize  := iif( Page == Pages , PrintBlockSize(oView, 8), PrintBlockSize(oView, 4) )
*nY := nY - Int( ( nFontHeight + 2 ) ) - Int( ( nFontHeight + 2 ) * pIncr )

nY := nY - Int( ( nFontHeight + 2 ) )

oProgress:Increment()

For i := 1 to pIncr
   oProgress:Increment()
next

   Do Case
      Case Form ==1
         If nY <=  EndBlockSize
           LastPageLine = .t.
         endif

      Case Form ==2
         If nY <=   Max( EndBlockSize, FootBlockSize) + HBlockSize
           LastPageLine = .t.
         endif

      Case Form ==3
         If nY <=  Max( EndBlockSize, FootBlockSize) + HBlockSize
           LastPageLine = .t.
         endif

      Case Form ==4
         If nY <=  FootBlockSize
           if nY <= ( nFontHeight + 2 )
              LastPageLine = .t.
              Return .f.
           Endif
         Endif

      Case Form ==5

      Case Form ==6

      Case Form ==7

      Case Form ==8
         If nY <=  EndBlockSize
           if nY <= ( nFontHeight + 2 )
              LastPageLine = .t.
              Return .f.
           Endif
         endif

      Case Form == 9

         If nY <=   Max( EndBlockSize, FootBlockSize) + SBlockSize
           *if nY <= ( nFontHeight + 2 )
              LastPageLine = .t.
              Return .f.
           *Endif
         endif

   EndCase
Return .t.


FUNC xToChar(xValue, pVarLen)
*--------------------------
*msgbox( type(xvalue) ,"")

LOCAL varType  := ValType(xValue)
LOCAL Numflag1 := .f.
LOCAL NumFlag2 := .f.
LOCAL IntLen   := 0
LOCAL TotLen   := 0
LOCAL NegFlag  := .f.

xValue := Alltrim( Var2LChar(xValue) )

DO CASE
   CASE varType == "L"
      xValue := padr(xValue, pVarLen)
   CASE varType == "M"
      xValue := xValue &&padr(xValue, pVarLen)
   CASE varType == "N"
      if Val(xValue) == 0
         xValue := ""
      else
         NegFlag := iif( val(xValue) < 0, .t., .f.)
         xValue := iif(NegFlag, AllTrim(Str(ABS( val(xValue))) ), xValue)
         IntLen := len( Alltrim( Subs( xValue,1, at(".", xValue) ) ) ) - 1
         TotLen := len( Alltrim( xValue ))
         Do case
            Case Intlen > 3 .and. Intlen < 7
               xValue := Subs( xValue, 1, IntLen - 3) + "'" + right(xValue,TotLen - IntLen + 3)
            Case Intlen >= 7 .and. Intlen < 10
               xValue := Subs( xValue, 1, IntLen - 6) + "'" + right(xValue,TotLen - IntLen + 6)
               xValue := Subs( xValue, 1, IntLen - 2) + "'" + right(xValue,TotLen - IntLen + 3)
         Endcase
         xValue := iif(NegFlag, "-" + AllTrim(xValue), xValue)

         if len(xValue) > pVarLen
            xValue := replicate("*", pVarlen - 3) + ".**"
         else
            xValue := padl( alltrim(xValue) , pVarLen)
         endif
      endif
   CASE varType == "D"
      xValue := padl(xValue, pVarLen)
   CASE varType == "C"
      xValue := padr(xValue, pVarLen)
      xValue := Subs(xValue, 1, pVarlen)

ENDCASE

Return {xValue, VarType}


FUNC ReleasePublic(oView,xFrom,xTo)
*----------------------------
LOCAL DefVar
LOCAL DbVar
LOCAL i, x

   for x := xFrom to xTo
      for i := 1 to len( oView:pForm[x] )
         Do case
            case oView:pForm[x][i][1][2] == "PUBLIC"
               DbVar  := oView:pForm[x][i][2][2]
               DefVar := Alltrim( Subs(DbVar,1, At(":", DbVar) - 1) )
               RELE &DefVar
            case oView:pForm[x][i][1][2] == "TABELLE"
               DbVar  := oView:pForm[x][i][2][2]
               DefVar := Alltrim( Subs(DbVar,1, At(":", DbVar) - 1) )
               RELE &DefVar

            case oView:pForm[x][i][1][2] == "ATTR"

            case oView:pForm[x][i][1][2] == "HLINE"

         endcase
      next
   next
   Return .t.


   FUNC NewPrinter(Report)
   *----------------------

   LOCAL aPrinters    := XbpPrinter():new():List()
   LOCAL aForms
   LOCAL aCForms      := {}
   LOCAL PaperId      := 0
   LOCAL aReportForm  := ReadForm(Report)
   LOCAL cPrinterName := ""
   LOCAL oPrinter
   LOCAL i
   LOCAL TrimPrinters := {}
   LOCAL cPrinter     := ""
   LOCAL nPosition    := 0
   LOCAL nPrinterPos  := 0

   if aPrinters == NIL
      Return NIL
   endif

   if len(aReportForm) == 0
      Return XbpPrinter():New():Create()
   Endif


   if len(aReportForm[5]) > 0 .and. upper( aReportForm[5][1][1][2] ) == "PRINTER"
      for i := 1 to len( aPrinters )
         cPrinter := aPrinters[i]

         nPosition := Rat( "\", cPrinter )
         IF nPosition > 0
            cPrinter := right( cPrinter, len( cPrinter ) - nPosition )
         ENDIF
         aAdd(TrimPrinters, cPrinter)
      next
      nPrinterPos := aScan(TrimPrinters, aReportForm[5][1][2][2] )
      if nPrinterPos > 0
         cPrinterName  := aPrinters[nPrinterPos]
      endif
   Endif

   oPrinter := XbpPrinter():New():Create(cPrinterName)

   if len(aReportForm[5]) > 0
      aForms  := oPrinter:Forms()

      for i:= 1 to len(aForms )
         aAdd(aCForms, Alltrim(aForms[i][2] )  )
      Next

      PaperId := aScan(aCForms, aReportForm[5][1][3][2])
      if PaperId > 0
         oPrinter:setFormSize(aForms[PaperId][1])
      Endif
      Do Case
         Case Upper( aReportForm[5][1][4][2]) == "HOCH"
            oPrinter:setOrientation(XBPPRN_ORIENT_PORTRAIT)
         Case Upper( aReportForm[5][1][4][2]) == "QUER"
            oPrinter:setOrientation(XBPPRN_ORIENT_LANDSCAPE)
      EndCase
   endif
   Return oPrinter

   FUNCTION SetFonts( oView, aForm )
   *-------------------------------------
   LOCAL i
   LOCAL x
   LOCAL oFont
   LOCAL oPS     := oView:oPresSpace
   LOCAL StdFont := oView:aFont[1]
   LOCAL aFont   := {}
   aAdd(aFont, StdFont )
   For i := 1 to len( aForm[7] )
      oFont                  := XbpFont():new( oPS )
      oFont:familyName       := aForm[7][i][3][2]
      oFont:bold             := iif( aForm[7][i][5][2] == "bold", .t., .f.)
      oFont:Italic           := iif( aForm[7][i][6][2] == "italic", .t., .f.)
      oFont:underscore       := iif( aForm[7][i][7][2] == "underline", .t., .f.)
      oFont:generic          := .T.
      oFont:width            := 0
      oFont:height           := 0
      oFont:nominalPointSize := val(aForm[7][i][4][2])
      oFont:create()
      aAdd(aFont, {"F" + Var2Char(i), oFont} )
    next
    Return aFont



FUNC PrintBlockSize(oView, Form, LineCnt, FormLen)
*-------------------------------------------------
LOCAL i
LOCAL PrintBlockSize  := 0
LOCAL pForm           := oView:pForm
LOCAL FontId

FormLen := iif( FormLen == NIL, 1, FormLen )
LineCnt := iif(LineCnt == NIL, 1, LineCnt)

   For i := LineCnt to len(pForm[Form]) && Alle Z
       If pForm[Form][i][1][1] == "LDEF"
          if !oView:pForm[Form][i][1][4] == 0
             PrintBlockSize := PrintBlockSize + oView:pForm[Form][i][1][4] + 2
          else
             FontId := aScan( oView:aFont, pForm[Form][i][1][2] )
             If FontId > 0
                PrintBlockSize := PrintBlockSize + oView:aFont[FontId][2]:height + 2
             Endif
          endif
       endif
   Next

if Form == 4 .or. Form == 8
   PrintBlockSize := PrintBlockSize + 10
Endif

if Form == 9
   PrintBlockSize := (PrintBlockSize * FormLen) + 10
Endif

Return PrintBlockSize
