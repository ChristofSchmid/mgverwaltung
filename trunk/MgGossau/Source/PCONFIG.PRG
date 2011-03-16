//////////////////////////////////////////////////////////////////////
//
//  PCONFIG.PRG
//
//  Copyright:
//      Alaska Software GmbH, (c) 2000-2001. Alle Rechte vorbehalten.
//
//  Inhalt:
//      Benutzerdefinierte Klasse XbpPrinterConfig()
//
//  Bemerkungen:
//      Die Klasse zeigt ein modales XbpDialog Fenster an, in dem sich ein
//      XbpPrinter-Objekt vor den Start eines Druckjobs konfigurieren l„át.
//      Es kann konfiguriert werden:
//
//      - Papierformat          => XbpPrinter:setFormSize()
//      - Papierschacht         => XbpPrinter:setPaperBin()
//      - Druckaufl”sung        => XbpPrinter:setResolution()
//      - Anzahl der Kopien     => XbpPrinter:setNumCopies()
//      - Farbe oder Monochrom  => XbpPrinter:setColorMode()
//      - Ausgabe in Datei      => XbpPrinter:setPrintFile()
//      - Hoch/Querformat       => XbpPrinter:setOrientation()
//
//      Die Konfigurationswerte werden vom Druckertreiber bereitgestellt und
//      sind vom ausgew„hlten Drucker abh„ngig!
//
//////////////////////////////////////////////////////////////////////

#include "Gra.ch"
#include "Xbp.ch"
#include "Common.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "XbpDev.ch"


FUNCTION GetPrinter(oPrinter, LPrintMode, oFrom)


   LOCAL oDialog
   LOCAL i          := 1
   LOCAL pText      := ""
   LOCAL aPrinters  := XbpPrinter():new():List()

*    SetAppFocus(oFrom)

   oDialog  := XbpPrinterConfig():new():create(,ofrom)
   oDialog:setData( oPrinter )
   oDialog:show()

   oPrinter   := oDialog:oPrinter
   LPrintMode := oDialog:LPrintMode
   oDialog:Destroy()

RETURN oPrinter



/*
 * Zentrierte Position fr ein Fenster berechnen
 */
STATIC FUNCTION CenterPos( aSize, aRefSize )
RETURN { Int( (aRefSize[1]-aSize[1]) / 2 ), ;
         Int( (aRefSize[2]-aSize[2]) / 2 )  }


/*
 * Klasse zur Konfiguration eines XbpPrinter-Objekts
 */
CLASS XbpPrinterConfig FROM XbpDialog

   PROTECTED:
*   VAR oFocus               // Hierhin muá der Eingabefokus beim Schlieáen
*                            // des Fensters gesetzt werden

   VAR aPrinters            // Drucker
   VAR Printers
   VAR txtDrucker           // Text Drucker
   VAR WhatPrinter

   VAR aForms               // Verfgbare Papierformate
   VAR aBins                // Verfgbare Einzugssch„chte
   VAR aDPI                 // Verfgbare Druckaufl”sungen

   VAR grpBox1              // Groupbox    Druckereinstellungen
   VAR txtForms             // XbpStatic   Text
   VAR forms                // Combobox    Papierformate
   VAR txtBins              // XbpStatic   Text
   VAR Bins                 // Combobox    Papiersch„chte
   VAR txtDPI               // XbpStatic   Text
   VAR Dpi                  // Combobox    Druckaufl”sungen

   VAR grpBox2              // Groupbox    Druckjob Einstellungen
   VAR txtCopies            // XbpStatic   Text
   VAR numCopies            // Spinbutton  Anzahl der Kopien
   VAR useColor             // Checkbox    Farb/Monochromdruck
   VAR toFile               // Checkbox    Ausgabe in Datei

   VAR grpBox3              // Groupbox    Papierausrichtung
   VAR portrait             // RadioButton Hochformat
   VAR landscape            // Radiobutton Quesrformat

   VAR btnOK                // Pushbutton  OK
   VAR btnCancel            // PushButton  Abbrechen
   VAR btnView




   EXPORTED:

   VAR oFocus               // Hierhin muá der Eingabefokus beim Schlieáen
                            // des Fensters gesetzt werden


   VAR oPrinter             // Das XbpPrinter-Objekt
   VAR lPrintMode


   METHOD init              // Lebenszyklus-Methoden
   METHOD create            //

   METHOD ChangePrinter
   METHOD show              // Dialogfester anzeigen
   METHOD hide              // Fenster l”schen
   METHOD setData           // XbpPrinter Objekt zuweisen
   METHOD getData           // XbpPrinter Objekt konfigurieren und
                            // Fenster schlieáen

ENDCLASS


METHOD XbpPrinterConfig:ChangePrinter(WhatPrinter )

LOCAL oPrinter
LOCAL xVal

::WhatPrinter := WhatPrinter

if ::WhatPrinter == 0
   xVal        := ::oPrinter:DevName
   WhatPrinter := AScan( ::aPrinters,  xVal  )
Endif

::Printers:XbpSle:setData( ::aPrinters[::WhatPrinter] )
::oPrinter := XbpPrinter():new():create(::aPrinters[::WhatPrinter])
::aForms    := ::aBins     := ::aDPI      := NIL
::forms:clear()
::bins:clear()
::dpi:clear()
::setData( ::oPrinter )

Return .t.




/*
 * Objekt initialisieren
 */
METHOD XbpPrinterConfig:init( oParent, oOwner )
   LOCAL aPos, aSize, aPP

   DEFAULT oParent  TO AppDesktop(), ;
           oOwner   TO SetAppwindow()

   aPP     := { { XBP_PP_COMPOUNDNAME, FONT_HELV_SMALL } }

   ::lPrintMode := 0

   ::aPrinters   := XbpPrinter():new():List()
   ::oPrinter    := XbpPrinter():new():create()

   ::WhatPrinter := 0

   ::XbpDialog:init( oParent, oOwner, aPos, aSize, aPP, .F. )


   ::XbpDialog:sysMenu   := .F.
   ::XbpDialog:minButton := .F.
   ::XbpDialog:maxButton := .F.
   ::XbpDialog:border    := XBPDLG_DLGBORDER
   ::XbpDialog:title     := "Drucker Konfiguration"
   ::XbpDialog:close     := {|mp1, mp2, obj| obj:hide() }

   ::grpBox1             := XbpStatic():new( ::drawingArea, , {8,192}, {264,162} )
   ::grpBox1:caption     := "Drucker Einstellungen"
   ::grpBox1:type        := XBPSTATIC_TYPE_GROUPBOX


   ::txtDrucker            := XbpStatic():new( ::grpBox1, , {8,112}, {80,24} )
   ::txtDrucker:caption    := "Drucker:"
   ::txtDrucker:options    := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT

   ::Printers               := XbpCombobox():new( ::grpBox1, , {96,22}, {160,112} )
   ::Printers:type          := XBPCOMBO_DROPDOWNLIST
   ::Printers:ItemSelected  := {|uNIL1,uNIL2,obj| ::ChangePrinter(obj:Getdata()[1] ) }
   ::Printers:tabStop       := .T.


   ::txtForms            := XbpStatic():new( ::grpBox1, , {8,72}, {80,24} )
   ::txtForms:caption    := "Papierformat"
   ::txtForms:options    := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT

   ::forms               := XbpCombobox():new( ::grpBox1, , {96,-16}, {160,112} )
   ::forms:type          := XBPCOMBO_DROPDOWNLIST
   ::forms:tabStop       := .T.

   ::txtBins             := XbpStatic():new( ::grpBox1, , {8,40}, {80,24} )
   ::txtBins:caption     := "Papiereinzug"
   ::txtBins:options     := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT

   ::bins                := XbpCombobox():new( ::grpBox1, , {96,-50}, {160,112} )
   ::bins:type           := XBPCOMBO_DROPDOWNLIST
   ::bins:tabStop        := .T.

   ::txtDPI              := XbpStatic():new( ::grpBox1, , {8,8}, {80,24} )
   ::txtDPI:caption      := "Druckauflösung"
   ::txtDPI:options      := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT

   ::dpi                 := XbpCombobox():new( ::grpBox1, , {96,-82}, {160,112} )
   ::dpi:type            := XBPCOMBO_DROPDOWNLIST
   ::dpi:tabStop         := .T.

   ::grpBox2             := XbpStatic():new( ::drawingArea, , {8,104}, {264,80} )
   ::grpBox2:caption     := "Druckjob Einstellungen"
   ::grpBox2:type        := XBPSTATIC_TYPE_GROUPBOX

   ::txtCopies           := XbpStatic():new( ::grpBox2, , {16,40}, {104,24} )
   ::txtCopies:caption   := "Anzahl an Kopien"
   ::txtCopies:options   := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_RIGHT

   ::numCopies           := XbpSpinbutton():new( ::grpBox2, , {154,40}, {64,24} )
   ::numCopies:tabStop   := .T.

   ::useColor            := XbpCheckBox():new( ::grpBox2, , {32,8}, {104,24} )
   ::useColor:caption    := "Farbdruck"
   ::useColor:tabStop    := .T.

   ::toFile              := XbpCheckBox():new( ::grpBox2, , {154,8}, {104,24} )
   ::toFile:caption      := "Ausgabe in Datei"
   ::toFile:tabStop      := .T.

   ::grpBox3             := XbpStatic():new( ::drawingArea, , {8,48}, {264,48} )
   ::grpBox3:caption     := "Papierausrichtung"
   ::grpBox3:type        := XBPSTATIC_TYPE_GROUPBOX

   ::portrait            := XbpRadiobutton():new( ::grpBox3, , {32,8}, {88,24} )
   ::portrait:caption    := "Hochformat"
   ::portrait:tabStop    := .T.
   ::portrait:selection  := .T.

   ::landscape           := XbpRadiobutton():new( ::grpBox3, , {154,8}, {88,24} )
   ::landscape:caption   := "Querformat"
   ::landscape:tabStop   := .T.

   ::btnView               := XbpPushButton():new( ::drawingArea, , {4,8}, {90,24} )
   ::btnView:caption       := "Vorschau"
   ::btnView:activate      := {|| ::lPrintMode := 1, ::getData(), ::hide() }
   ::btnView:tabStop       := .T.

   ::btnOK               := XbpPushButton():new( ::drawingArea, , {98,8}, {90,24} )
   ::btnOK:caption       := "Drucken"
   ::btnOK:keyBoard      := {| nKeyCode, uNIL, Obj | iif( nKeyCode == 13, PostAppEvent( xbeP_Activate, NIL, NIL, Obj ), iif( nKeyCode == 27,  ::Hide() ,NIL )) }
   *::btnOK:keyBoard      := {| nKeyCode, uNIL, Obj | iif( nKeyCode == 27,  ::Hide() ,NIL ) }
   ::btnOK:activate      := {|| ::lPrintMode := 2, ::getData(), ::hide() }
   ::btnOK:tabStop       := .T.

   ::btnCancel           := XbpPushButton():new( ::drawingArea, , {192,8}, {90,24} )
   ::btnCancel:caption   := "Abbrechen"
   ::btnCancel:activate  := {|| ::hide() }
   ::btnCancel:tabStop   := .T.

RETURN self


/*
 * Systemresourcen anfordern
 */
METHOD XbpPrinterConfig:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
   LOCAL i
   LOCAL iMax

   aSize   := {288,393}
   aPos    := CenterPos( aSize, oOwner:currentSize() )
   aPos[1] += oOwner:currentPos()[1]
   aPos[2] += oOwner:currentPos()[2]

   ::XbpDialog:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   ::grpBox1:create()
   ::txtDrucker:create()
   ::Printers:create()
   ::txtForms:create()
   ::forms:create()
   ::txtBins:create()
   ::Bins:create()
   ::txtDPI:create()
   ::dpi:create()

   ::grpBox2:create()
   ::txtCopies:create()
   ::numCopies:create()
   ::numCopies:setNumLimits( 1, 99 )
   ::useColor:create()
   ::toFile :create()

   ::grpBox3:create()
   ::portrait:create()
   ::landscape:create()

   ::btnOK:create()
   ::btnCancel:create()
   ::btnView:create()

   IF ::aPrinters == NIL
      ::Printers:xbpSle:setData( "" )
      ::Printers:disable()
   ELSE
      ::Printers:enable()
      ::Printers:xbpSle:setData( "" )

      imax := Len( ::aPrinters )
      FOR i:=1 TO imax
         ::Printers:addItem( ::aPrinters[i] )
      NEXT

   ENDIF

RETURN self


/*
 * XbpPrinter Objekt zuweisen und aktuelle Druckerkonfiguration
 * in die eingebetteten XbaseParts bertragen
 */
METHOD XbpPrinterConfig:setData( oPrinter )
   LOCAL i, imax, xVal, n, x
   LOCAL lValidDpi := .t.
   xVal := oPrinter:DevName
   ::WhatPrinter    := AScan( ::aPrinters,  xVal  )
   ::Printers:XbpSle:setData( ::aPrinters[::WhatPrinter] )

   ::oPrinter :=  oPrinter

   ::aForms    := ::oPrinter:forms()
   ::aBins     := ::oPrinter:paperBins()
   ::aDpi      := ::oPrinter:resolutions()


   IF ::aForms == NIL
      ::forms:xbpSle:setData( "" )
      ::forms:disable()
   ELSE
      ::forms:enable()
      imax := Len( ::aForms )
      FOR i:=1 TO imax
         ::forms:addItem( ::aForms[i,2] )
      NEXT

      xVal := ::oPrinter:setFormSize()
      i    := AScan( ::aForms, {|a| a[1] == xVal } )
      i := iif( i > 0 .and. i <= len(::aForms) , i, 1)
      ::forms:XbpSle:setData( ::aForms[i,2] )
   ENDIF

   IF ::aBins == NIL
      ::bins:xbpSle:setData( "" )
      ::bins:disable()
   ELSE
      ::bins:enable()
      imax := Len( ::aBins )

      if imax <> 0
         FOR i:=1 TO imax
            ::bins:addItem( ::aBins[i,2] )
         NEXT

         xVal := ::oPrinter:setPaperBin()
         i    := AScan( ::aBins, {|a| a[1] == xVal } )
         if xVAL <> NIL
            ::bins:XbpSle:setData( ::aBins[i,2] )
         endif
      ELSE
         ::bins:xbpSle:setData( "" )
         ::bins:disable()
      ENDIF
   ENDIF

   IF ::aDpi == NIL
      ::dpi:xbpSle:setData( "" )
      ::dpi:disable()
   ELSE
      *DPI Array auf numerische Gültigkeit prüfen
      lValidDpi := .t.
      for i := 1 to len(::aDpi)
         for x := 1 to Len(::aDpi[i])
             if ! ValType( ::aDpi[i][x] ) == "N"
                ::dpi:xbpSle:setData( "" )
                ::dpi:disable()
                lValidDpi := .f.
             endif
         next
      next

      if lValidDpi
         ::dpi:enable()
         imax := Len( ::aDpi )
         FOR i:=1 TO imax
            ::dpi:addItem( LTrim( Str(::aDpi[i,1]) ) + " x " + LTrim( Str(::aDpi[i,2]) ) + " dpi" )
         NEXT

         xVal := ::oPrinter:setResolution()
         i    := AScan( ::aDpi, {|a|  a[1] == xVal[1] .AND. a[2] == xVal[2] } )
         if i == 0
            i := AScan( ::aDpi, {|a|  a[1] == xVal[2] .AND. a[2] == xVal[1] } )
         endif
         ::dpi:XbpSle:setData( LTrim( Str(::aDpi[i,1]) ) + " x " + LTrim( Str(::aDpi[i,2]) ) + " dpi" )
      endif
   ENDIF

   xVal := ::oPrinter:setNumCopies()
   IF xVal == NIL
      ::numCopies:setData( 1 )
      ::numCopies:disable()
   ELSE
      ::numCopies:enable()
      ::numCopies:setData( xVal )
   ENDIF

   xVal := ::oPrinter:setColorMode()
   IF xVal == NIL
      ::useColor:setData( .F. )
      ::useColor:disable()
   ELSE
      ::useColor:enable()
      ::useColor:setData( xVal == XBPPRN_COLORMODE_ON )
   ENDIF

   xVal := ::oPrinter:setPrintFile()
   IF xVal == NIL
      ::toFile:setData( "" )
      ::toFile:disable()
   ELSE
      ::toFile:enable()
      ::toFile:setData( .NOT. Empty(xVal) )
   ENDIF

   xVal := ::oPrinter:setOrientation()
   IF xVal == NIL
      ::portrait:setData( .F. )
      ::landscape:setData( .F. )
      ::portrait:disable()
      ::landscape:disable()
   ELSE
      ::portrait:enable()
      ::landscape:enable()
      ::portrait:setData( xVal == XBPPRN_ORIENT_PORTRAIT )
      ::landscape:setData( xVal <> XBPPRN_ORIENT_PORTRAIT )
   ENDIF
RETURN ::oPrinter


/*
 * šbertrage die von Benutzer gew„hlten Konfiguratonsdaten in das
 * XbpPrinter-Objekt
 */
METHOD XbpPrinterConfig:getData()
   LOCAL xVal

   IF ::oPrinter == NIL
      RETURN self
   ENDIF

   IF ::forms:isEnabled()
      xVal := ::forms:getData()
      IF .NOT. Empty( xVal )
         ::oPrinter:setFormSize( ::aForms[ xVal[1], 1 ] )
      ENDIF
   ENDIF

   IF ::bins:isEnabled()
      xVal := ::bins:getData()
      IF .NOT. Empty( xVal )
         ::oPrinter:setPaperBin( ::aBins[ xVal[1], 1 ] )
      ENDIF
   ENDIF

   IF ::dpi:isEnabled()
      xVal := ::dpi:getData()
      IF .NOT. Empty( xVal )
         ::oPrinter:setResolution( ::aDpi[ xVal[1] ] )
      ENDIF
   ENDIF

   IF ::numCopies:isEnabled()
      ::oPrinter:setNumCopies( ::numCopies:getData() )
   ENDIF

   IF ::useColor:isEnabled()
      IF ::useColor:getData()
         ::oPrinter:setColorMode( XBPPRN_COLORMODE_ON )
      ELSE
         ::oPrinter:setColorMode( XBPPRN_COLORMODE_OFF )
      ENDIF
   ENDIF

   IF ::toFile:isEnabled()
      IF ::toFile:getData()
         ::oPrinter:setPrintFile( XBPPRN_FILE_PROMPT )
      ELSE
         ::oPrinter:setPrintFile( "" )
      ENDIF
   ENDIF

   IF ::portrait:isEnabled()
      IF ::portrait:getData()
         ::oPrinter:setOrientation( XBPPRN_ORIENT_PORTRAIT )
      ELSE
         ::oPrinter:setOrientation( XBPPRN_ORIENT_LANDSCAPE )
      ENDIF
   ENDIF

RETURN SELF


/*
 * Zeige das Fenster modal an (Event Loop!)
 */
METHOD XbpPrinterConfig:show()
   LOCAL nEvent, mp1, mp2, oXbp
   LOCAL oFocus

   *oFocus := SetAppFocus()
   ::setModalState( XBP_DISP_APPMODAL )
   ::XbpDialog:show()

   *SetAppFocus( ::Printers )
   SetAppFocus( ::btnOK)
   DO WHILE ::isVisible()
      nEvent := AppEvent( @mp1, @mp2, @oXbp )
      oXbp:handleEvent( nEvent, mp1, mp2 )
   ENDDO
   ::setModalState( XBP_DISP_MODELESS )
*   SetAppFocus(oFocus)

RETURN SELF


/*
 * Fenster l”schen und Konfigurationsdaten freigeben
 */
METHOD XbpPrinterConfig:hide()
   ::XbpDialog:hide()
   ::aForms    := ;
   ::aBins     := ;
   ::aDPI      := ;
   ::oFocus    := NIL
   ::forms:clear()
   ::bins:clear()
   ::dpi:clear()
RETURN self