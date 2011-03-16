*----------------------------------------
* ZMenu, MenuSteuerung ZLager f¸r Windows
* 12.5.2001
*----------------------------------------

#include "Xbp.ch"
#include "FCH.ch"
#include "MGV.CH"
#include "Appevent.ch"


/*
 * MenÅsystem im Menubar des Dialogs erzeugen
 */
PROCEDURE MenuCreate( oMenuBar )
   LOCAL oMenu, oSubMenu


   oMenu := SubMenuNew( oMenuBar, "~Datei" )
   oMenu:setName( MENU01 )
*   oMenu:addItem( { "~Artikelstamm" ,   {|| ZARTIKEL()  } } )
   oMenu:addItem( { "~Mitgliederstamm",     {|| ZKUNDEN(KUNDEN)  } } )
*   oMenu:addItem( { "~Lieferantenstamm",{|| ZLIEFERANTEN(LIEFERANTEN)  } } )
   oMenu:addItem( { "~Tabellenstamm",   {|| TabellenStamm()  } } )
*   oMenu:addItem( { "~Konditionenstamm",   {|| ZKondition()  } } )

   oMenu:addItem( MENUITEM_SEPARATOR )
   *oMenu:addItem( { "~Dienstprogramme",   {|| ZReorg()  } } )
       oSubMenu := SubMenuNew( oMenu, "~Dienstprogramme" )
           oSubMenu:addItem( { "~Reorganisation",   {|| ZReorg() } } )
           oSubMenu:addItem( { "~MG Verwaltung Netzwerkweit schliessen",   {|| ZAdminTask("CloseNetApp") } } )
           oSubMenu:addItem( { "~System Log freigeben",   {|| ZAdminTask("FreeLog") } } )
           *oSubMenu:addItem( { "~Mitglieder Status pr¸fen",   {|| ZAdminTask("ReplaceDebNr") } } )
           oSubMenu:addItem( { "~Programm Optionen",   {|| ZAdminTask("SetAdvanced") } } )

*         oSubMenu:addItem( { "~Error",   {|| Errorsys() } } )

*           oSubMenu:addItem( { "~Test 1",   {|| BackupToFTP() } } )
*           oSubMenu:addItem( { "~Test 2",   {|| DebIndexExpr( "Van de weetring Jan", 2 ) } } )
*           oSubMenu:addItem( { "~Test 3 ",   {|| DebIndexExpr( "Van de weetring Jan", 3 ) } } )
*       oMenu:addItem( {oSubMenu, NIL} )

*       oSubMenu := SubMenuNew( oMenu, "~Tagesendprogramme" )
*           oSubMenu:addItem( { "~Kassenbuch",   {|| ZKASSE()  } } )

       oMenu:addItem( {oSubMenu, NIL} )

   oMenu:addItem( MENUITEM_SEPARATOR )
   oMenu:addItem( { "~Ende" , {|| AppQuit(.t.) } } )
   oMenuBar:addItem( {oMenu, NIL} )

*   oMenu := SubMenuNew( oMenuBar, "~Bestellwesen" )
*   oMenu:setName( MENU02 )
*   oMenu:addItem( { "~Bestellungen bearbeiten ",   {|| zOrder()  } } )
*   oMenuBar:addItem( {oMenu, NIL} )

*   oMenu := SubMenuNew( oMenuBar, "~Lager" )
*   oMenu:setName( MENU03 )
*   oMenu:addItem( { "~Lagerarbeiten",   {|| LagerBuchung()  } } )
*   oMenu:addItem( { "~Lagerbuchungen abfragen",   {|| LagerBuchungInfo()  } } )

*      oSubMenu := SubMenuNew( oMenu, "~Inventar" )
*         oSubMenu:addItem( { "~Inventur Formulare drucken",      {|| zForms("Inventarliste")  } } )
         *oSubMenu:addItem( { "~Inventur Formular Konsignation",  {|| dummy()  } } )
*         oSubMenu:addItem( { "~Inventar erfassen",               {|| InputInv() } } )
         *oSubMenu:addItem( { "~Inventarbewertung drucken",       {|| dummy()  } } )
         *oSubMenu:addItem( MENUITEM_SEPARATOR )
         *oSubMenu:addItem( { "~Inventar Preise bewerten",        {|| dummy()  } } )
         *oSubMenu:addItem( { "~Inventarwert rechnen",            {|| dummy()  } } )
 *     oMenu:addItem( {oSubMenu, NIL} )

*      oSubMenu := SubMenuNew( oMenu, "~Logistik"
*         oSubMenu:addItem( { "~Abrechnung Logistik",              {|| AbrechnungLogistik()  } } )
*         oSubMenu:addItem( { "~Transport Kosten",                {|| zForms("TransportAbrechnung")  } } )

*      oMenu:addItem( {oSubMenu, NIL} )

*   oMenu:addItem( { "~Abrechnung Logistik",   {|| AbrechnungLogistik()  } } )
*   oMenuBar:addItem( {oMenu, NIL} )

*   oMenu := SubMenuNew( oMenuBar, "~Dokumente" )
*   oMenu:setName( MENU04 )
*   oMenu:addItem( { "~Dokumente bearbeiten",   {|| ZFaktura()  } } )
*   oMenuBar:addItem( {oMenu, NIL} )

*   oMenu := SubMenuNew( oMenuBar, "~Service" )
*   oMenu:setName( MENU05 )
*   oMenu:addItem( { "~Disposition",   {|| ZDisposition()  } } )
*   oMenuBar:addItem( {oMenu, NIL} )

*   oMenu := SubMenuNew( oMenuBar, "~Info" )
*   oMenu:setName( MENU06 )
*   oMenu:addItem( { "~History Kundendaten",   {|| ZHistory()  } } )
*   oMenu:addItem( { "~Umsatz Analyse",        {|| ZUmsatz()  } } )
*   oMenu:addItem( { "~Verkaufte Artikel",     {|| SoldGoods()  } } )
   *oMenu:addItem( { "~Budget",                {|| Dummy()  } } )
   *oMenu:addItem( { "~Unterdeckung abfragen", {|| Dummy()  } } )
   *oMenu:addItem( { "~Marge rechnen",         {|| Dummy()  } } )

*   oMenuBar:addItem( {oMenu, NIL} )

   oMenu := SubMenuNew( oMenuBar, "~Druckarbeiten" )
   oMenu:setName( MENU07 )

   oMenu:addItem( { "~Kontaktliste Aktive",   {|| zForms("WebList")  } } )
   oMenu:addItem( { "~Adressliste Aktive",    {|| zForms("AddressList")  } } )
   oMenu:addItem( { "~Mitgliederliste",       {|| zForms("DebList")  } } )
   oMenu:addItem( MENUITEM_SEPARATOR )
   oMenu:addItem( { "~Eintritte",             {|| zForms("DebNew")  } } )
   oMenu:addItem( { "~Austritte",             {|| zForms("DebOut")  } } )
   oMenu:addItem( { "~Mutationen",            {|| zForms("DebChange")  } } )


   *oMenu:addItem( MENUITEM_SEPARATOR )
   *oMenu:addItem( { "~Verk‰ufe nach Artikelgruppen",  {|| dummy()  } } )
   *oMenu:addItem( { "~Verkaufsdetail Lager",          {|| dummy()  } } )
   *oMenu:addItem( { "~Verkaufsdetail Fakturen",       {|| dummy()  } } )
   oMenuBar:addItem( {oMenu, NIL} )


   oMenu := SubMenuNew( oMenuBar, "B~eenden" )
   oMenu:addItem( { "~Beenden",   {|| AppQuit(.t.)  } } )
   oMenuBar:addItem( {oMenu, NIL} )

   oMenu := SubMenuNew( oMenuBar, "~Hilfe" )
   oMenu:addItem( { "~Info",   {|| ZInfo()  } } )
   oMenuBar:addItem( {oMenu, NIL} )


RETURN


FUNC dummy( )

Return .t.

/*
 * UntermenÅ in einem MenÅ erzeugen
 */
FUNCTION SubMenuNew( oMenu, cTitle )
   LOCAL oSubMenu := XbpMenu():new( oMenu )
   oSubMenu:title := cTitle
RETURN oSubMenu:create()


/*
 * Men¸ zur Verwaltung offener Fenster erzeugen
 */
FUNCTION WinMenu()
   STATIC soMenu
   IF soMenu == NIL
      soMenu := WindowMenu():new( AppMenu() ):create()
   ENDIF
RETURN soMenu



/*
 *
 */
CLASS WindowMenu FROM XbpMenu
   PROTECTED:
     CLASS VAR windowStack, winCount, offset, aObjects
   EXPORTED:
     CLASS METHOD initClass, setWindowFocus, closeWindows, cascadeWindows
     CLASS VAR currentWin READONLY
     VAR   editMenu
     METHOD init, create, addItem, delItem, setItem, checkItem, ableItem
     METHOD Items, Stack


ENDCLASS



/*
 * Member-Variablen des Klassenobjekts initialisieren (Klassenvariablen)
 */
CLASS METHOD WindowMenu:initClass
   ::windowStack := {}
   ::winCount    := 0
   ::offset      := 0
   ::aObjects    := {}
RETURN self



/*
 * Fokus auf ein Fenster anhand seiner Ordinalposition im MenÅ setzen
 */
CLASS METHOD WindowMenu:setWindowFocus( nItem )
   LOCAL oDlg := ::windowStack[ nItem - ::offset ]

   IF oDlg:getFrameState() == XBPDLG_FRAMESTAT_MINIMIZED
      oDlg:setFrameState( XBPDLG_FRAMESTAT_NORMALIZED )
   ENDIF

   SetAppFocus( oDlg )
RETURN self



/*
 * Fenster anordnen
 */
CLASS METHOD WindowMenu:cascadeWindows
   LOCAL i, aDlgSize, aDaSize, nX, nY, nDY

   ::windowStack[1]:setFrameState( XBPDLG_FRAMESTAT_NORMALIZED )
   aDlgSize := ::windowStack[1]:currentSize()
   aDaSize  := ::windowStack[1]:drawingArea:currentSize()
   nDY      := aDlgSize[2] - aDAsize[2]
   nX       := -1
   nY       := -1

   FOR i:=1 TO ::winCount
      aDlgSize := ::windowStack[i]:currentSize()
      IF i == 1 .OR. nY < 0
         nX := 0
         nY := AppDeskTop():currentSize()[2] - aDlgSize[2]
      ELSE
         ::windowStack[i]:setFrameState( XBPDLG_FRAMESTAT_NORMALIZED )
         aDlgSize := ::windowStack[i]:currentSize()
         nX       += nDY
         nY       := ::windowStack[i-1]:currentPos() [2] + ;
                     ::windowStack[i-1]:currentSize()[2] - ;
                     aDlgSize[2] - nDY
      ENDIF
      ::windowStack[i]:setPos( {nX, nY} )
      ::windowStack[i]:toFront()
   NEXT
   SetAppFocus( ATail( ::windowStack ) )
RETURN self



/*
 * Alle Child-Fenster schlie·en (inaktiv CAS)
 */
CLASS METHOD WindowMenu:closeWindows
   DO WHILE ! Empty( ::windowStack )
      ATail(::windowStack):destroy()
*      ADel(::windowStack, LEN(::windowStack))
   ENDDO
RETURN self



/*
 * Objekt initialisieren und UntermenÅ fÅr standardisierte
 * Datenbankoperationen anfÅgen
 */
METHOD WindowMenu:init( oParent, aPresParam, lVisible )
   ::xbpMenu:init( oParent, aPresParam, lVisible )
   ::title    := "~Fenster"
*---
*   ::editMenu := DataDialogMenu():new( oParent, aPresParam, lVisible )
*---
RETURN self



/*
 * Systemresourcen anfordern und Standard-MenÅeintrÑge anfÅgen
 */
METHOD WindowMenu:create( oParent, aPresParam, lVisible )
   ::xbpMenu:create( oParent, aPresParam, lVisible )
   ::itemSelected := {|nItem| ::setWindowFocus( nItem ) }

*   ::editMenu:create( oParent, aPresParam, lVisible )


   ::xbpMenu:addItem( { "~Anordnen"      , {|| ::cascadeWindows() } } )

*   ::xbpMenu:addItem( { "Alle ~Schlie·en", {|| ::closeWindows()   } } )

   ::xbpMenu:addItem( MENUITEM_SEPARATOR )
   ::offset := 2


RETURN self


/*
 * Titel eines Dialogfensters als Text fÅr den MenÅeintrag verwenden
 */
METHOD WindowMenu:addItem( oDlg, CallObj )
   LOCAL cItem := oDlg:getTitle()
   LOCAl i := 0
   LOCAL lUsed := .f.
   *LOCAL nAreas := len( oDlg:aArea )

   AAdd( ::windowStack, oDlg )
   AAdd( ::aObjects, {oDlg,CallObj } )
   ::winCount ++
   *cItem := "~" + Ltrim( Str( ::winCount ) ) + Chr(9) + cItem
   cItem := "~" + Ltrim( Str( ::winCount ) ) + "  " + cItem
   ::xbpMenu:addItem( { cItem, NIL} )
   IF ::numItems() == ::offset + 1
      ::setParent():insItem( ::setParent():numItems() , {self, NIL} )
      ::setParent():insItem( 2, { ::editMenu, NIL} )
   ENDIF
   RestoreDialogPosAndSize(oDlg)

   *For i:= 1 to nAreas
   *   Select ( (i) )
   *   if used()
   *      dbRegisterClient(oDlg)
   *   endif
   *next

   RegisterNetworkParts(oDlg)

RETURN self

METHOD WindowMenu:Items()
*---------------------------
Return Len(::WindowStack)

METHOD WindowMenu:Stack()
*---------------------------
Return ::WindowStack


/*
 * GeÑnderten Titel des Dialogfensters in MenuItem Åbertragen
 */
METHOD WindowMenu:setItem( oDlg )
   LOCAL aItem, i := AScan( ::windowStack, oDlg )

   IF i == 0
      ::addItem( oDlg )
   ELSE
      aItem    := ::xbpMenu:getItem( i + ::offset )
      *aItem[1] := "~" + Ltrim( Str(i) ) + Chr(9) + oDlg:getTitle()
      aItem[1] := "~" + Ltrim( Str(i) ) + "  " + oDlg:getTitle()
      ::xbpMenu:setItem( i + ::offset, aItem )
      IF oDlg == ::currentWin
         ::checkItem( oDlg )
      ENDIF
   ENDIF

RETURN self



/*
 * Dialogfenster wieder aus WindowStack und MenÅ entfernen
 */
METHOD WindowMenu:delItem( oDlg )
   LOCAL i     := AScan( ::windowStack, oDlg )
   LOCAL nPos  := ::setParent():numItems()-1
   LOCAL oCall := ::aObjects[i][2]

   IF i > 0
      ::xbpMenu:delItem( i + ::offset )

      IF ::currentWin ==  ::windowStack[i]
         ::currentWin := NIL
      ENDIF

      ADel( ::windowStack, i )
      ARemove( ::aObjects, i )

      ::winCount --
      Asize( ::windowStack, ::winCount )

      IF i <= ::winCount
         AEval( ::windowStack, {|o| ::setItem( o ) }, i )
      ENDIF

      IF ::numItems() == ::offset
         ::setParent():delItem( nPos )
         ::setParent():delItem( 2 )
      ELSEIF ::currentWin == NIL
         if oCall == NIL
            SetAppFocus( Atail( ::windowStack ) )
         else
            ::checkItem( oCall )
            SetAppFocus( oCall )
         endif
      ENDIF
   ENDIF

   SaveDialogPosAndSize(oDlg)
   UnRegisterNetworkParts(oDlg)

RETURN self



/*
 * Men¸eintrag fÅr das aktuelle Fenster markieren
 */
METHOD WindowMenu:checkItem( oDlg, WhatDb )
   LOCAL i := AScan( ::windowStack, oDlg ) + ::offset

   IF ::currentWin <> NIL
      ::xbpMenu:checkItem( AScan(::windowStack, ::currentWin ) + ::offset , .F. )
   ENDIF

   ::currentWin := oDlg
   *Select(oDlg:aArea[WhatDb])
   ::xbpMenu:checkItem( i, .T. )
   SetMousePointer(0, RootWindow() )

RETURN self

/*
 * MenÅeintrag enable/disable
 */
METHOD WindowMenu:ableItem( nMain, nSub, led )

If led
   SetAppWindow():childFromName( nMain ):EnableItem(nSub)
else
   SetAppWindow():childFromName( nMain ):DisableItem(nSub)
Endif

RETURN self


FUNC ContextMenu(oDlg,oXbpNr,TabId )
*----------------------
LOCAL oXbp := oDlg:aEditControls[oXbpNr]
LOCAL i
LOCAL oMenu

oDlg:currentControl := oXbpNr

if !oDlg:EditMode
   SetAppFocus( oDlg )
   oMenu := XbpMenu():new():create()
   oMenu:AddItem( { "~Keine Auswahl", { || Dummy() } } )
   Return oMenu
Endif

SetAppFocus( oXbp )

*for i := 1 to len(oDlg:aEditControls)
*   if oDlg:aEditControls[i]:hasInputFocus()
*      oDlg:currentControl := i
*      i :=  len(oDlg:aEditControls)
*   endif
*Next

oMenu := XbpMenu():new():create()
oMenu:AddItem( { "~Tabelle anzeigen", { || oDlg:Tabelle( TabId,"  " ) } } )
oMenu:addItem( MENUITEM_SEPARATOR )
oMenu:AddItem( { "~Ausschneiden" , { || oXbp:CutMarked()    } } )
oMenu:AddItem( { "~Kopieren"     , { || oXbp:CopyMarked()    } } )
oMenu:AddItem( { "~Einf¸gen"     , { || oXbp:PasteMarked()  } } )
oMenu:AddItem( { "~R¸ckg‰ngig"   , { || oXbp:undo() } } )
Return oMenu