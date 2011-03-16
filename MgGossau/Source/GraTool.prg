#include "Appevent.ch"
#include "Gra.ch"
#include "Xbp.ch"



CLASS ProgressBar FROM XbpStatic, Signal
   PROTECTED:
   VAR    squares, every, _current
   METHOD displayHoriz, displayVert

   EXPORTED:
   VAR           maxWait, color 
   VAR           minimum, current, maximum
   VAR           oThread
   ASSIGN METHOD minimum, current, maximum 

   METHOD init   , create , destroy , setSize
   METHOD display, execute, increment
ENDCLASS



/*
 * Objekt initialisieren und Thread:interval() auf 0 setzen.
 * Dadurch wird :execute() automatisch wiederholt ausgefÅhrt.
 */

METHOD ProgressBar:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::oThread := Thread():New()
   ::oThread:setInterval( 0 )
   ::oThread:atStart := {|| ::xbpStatic:show() }

   ::Signal:init()

   ::xbpStatic:init( oParent, oOwner, aPos, aSize, aPP, lVisible )
   ::xbpStatic:type  := XBPSTATIC_TYPE_RAISEDBOX
   ::xbpStatic:paint := {|| ::display() }

   ::color   := GRA_CLR_BLUE
   ::squares := 1
   ::current := 0
   ::every   := 1
   ::maxWait := 100
   ::minimum := 0
   ::maximum := 100
RETURN



/*
 * Systemresourcen anfordern, Anzahl der Quadrate berechnen (:squares),
 * die in den ProgressBar hineinpassen und Thread starten.
 */

METHOD ProgressBar:create( oParent, oOwner, aPos, aSize, aPP, lVisible )
         
   ::xbpStatic:create( oParent, oOwner, aPos, aSize, aPP, lVisible )

   aSize     := ::currentSize()
   ::squares := Int( aSize[1] / (aSize[2]+1) )
   ::oThread:start( {|| ::execute() })

RETURN



/*
 * Thread vom ProgressBar stoppen und Systemresourcen freigeben
 */

METHOD ProgressBar:destroy

  /*
   * Automatische Wiederholung von :execute() abschalten.
   */
   ::oThread:setInterVal( NIL )


   IF ::oThread:active
     /*
      * Thread ist noch aktiv.
      * Signal auslîsen, damit :wait() verlassen wird.
      */
      ::signal()
   ENDIF


   IF !ThreadObject() == ::oThread
     /*
      * Der aktuelle Thread ist nicht der Thread von ProgressBar (self).
      * Daher mu· der aktuelle Thread auf das Ende von self:thread
      * warten.
      */
      ::oThread:synchronize(0)
   ENDIF


  /*
   * Systemresourcen werden nach dem Ende von self:thread freigegeben
   */
   ::oThread := NIL  
   ::xbpStatic:destroy()
RETURN self



/*
 * Grî·e vom ProgressBar Ñndern und zuvor alles mit der
 * Hintergrundfarbe Åbermalen.
 */
METHOD ProgressBar:setSize( aSize )
   LOCAL oPS, aAttr[ GRA_AA_COUNT ], _aSize

   oPS       := ::lockPS()
   _aSize    := ::currentSize()
   _aSize[1] -= 2
   _aSize[2] -= 2
   aAttr [ GRA_AA_COLOR ] := GRA_CLR_BACKGROUND
   GraSetAttrArea( oPS, aAttr )
   GraBox( oPS, {1,1}, _aSize, GRA_FILL )
   ::unlockPS( oPS )
   ::xbpStatic:setSize( aSize )

RETURN self



/*
 * ASSIGN Methode fÅr :minimum
 */
METHOD ProgressBar:minimum( nMinimum )

   IF ::maximum <> NIL .AND. nMinimum > ::maximum
      ::minimum := ::maximum
      ::maximum := nMinimum
   ELSE
      ::minimum := nMinimum  
   ENDIF

   ::current := ::minimum 
RETURN self



/*
 * ASSIGN Methode fÅr :current
 */
METHOD ProgressBar:current( nCurrent )

   IF Valtype( nCurrent ) == "N"
      ::current := nCurrent

      IF Valtype( ::maximum ) + Valtype( ::minimum ) == "NN"
         ::every    := Int( ( ::maximum - ::minimum ) / ::squares )
         ::_current := ::current
      ENDIF
   ENDIF

RETURN ::current



/*
 * ASSIGN Methode fÅr :maximum
 */
METHOD ProgressBar:maximum( nMaximum )

   IF ::minimum <> NIL .AND. nMaximum < ::minimum
      ::maximum := ::minimum
      ::minimum := nMaximum
   ELSE
      ::maximum := nMaximum  
   ENDIF

   ::current := ::minimum 

RETURN self



/*
 * Aktuellen Wert inkrementieren und gegebenenfalls
 * die Anzeige aktualisieren
 */
METHOD ProgressBar:increment( nIncrement )

   IF Valtype( nIncrement ) <> "N"
      nIncrement := 1
   ENDIF

  /*
   * WÑhrend der Fortschrittsanzeige wird PROTECTED VAR :_current
   * inkrementiert, um den Overhead der ASSIGN Methode :current()
   * zu umgehen.
   */
   ::_current += nIncrement
   

   IF Int( ::_current % ::every ) == 0
     /*
      * Dies unterbricht die ::wait( ::maxWait ) Methode in :execute().
      * ProgressBar wird dann sofort in seinem eigenen Thread aktualisiert.
      * Da die Anzeige in einem separaten Thread erfolgt, wird der aktuelle
      * Prozess, dessen Fortschritt visualisiert wird, nicht durch die
      * Anzeige verlangsamt. Wird beispielsweise eine Index-Datei erzeugt,
      * so wird die Anzeige nicht in dem Thread aktualisiert, in dem der
      * Index generiert wird. Vielmehr wird lediglich ein Signal fÅr
      * self:thread ausgelîst.
      */
      ::signal()
   ENDIF
RETURN



/*
 * ProgressBar automatisch alle ::maxWait / 100 Sekunden anzeigen.
 * Die Methode wird in self:thread ausgefÅhrt und wird automatisch
 * wiederholt, da :setInterval() auf Null gesetzt ist.
 */
METHOD ProgressBar:execute

   ::wait( ::maxWait )
   ::display()

RETURN self



/*
 * Aktuellen Status eines fortlaufenden Prozesses visualisieren
 */
METHOD ProgressBar:display
   LOCAL oPS   := ::lockPS()
   LOCAL aSize := ::currentSize()
   LOCAL aAttr [ GRA_AA_COUNT ]

   aSize[1] -= 2    
   aSize[2] -= 2

   IF aSize[1] > aSize[2]
      ::displayHoriz( oPS, aSize, aAttr )
   ELSE
      ::displayVert ( oPS, aSize, aAttr )
   ENDIF

   ::unlockPS( oPS )
RETURN self



/*
 * Quadrate von links nach rechts anzeigen (horizontale Anzeige)
 */
METHOD ProgressBar:displayHoriz( oPS, aSize, aAttr )
   LOCAL nX, aPos1, aPos2, nCenter

  /*
   * Maximale X Koordinate fÅr Quadrate
   */
   nX := aSize[1] * ::_current / ( ::maximum - ::minimum )
   nX := Min( nX, aSize[1] )

  /*
   * Bereich rechts von den Quadraten mit Hintergrundfarbe fÅllen
   */
   aAttr [ GRA_AA_COLOR ] := GRA_CLR_BACKGROUND
   GraSetAttrArea( oPS, aAttr )
   GraBox( oPS, {1+nX,1}, {aSize[1],aSize[2]}, GRA_FILL )

  /*
   * FÅllfarbe fÅr die Quadrate definieren
   */
   aAttr [ GRA_AA_COLOR ] := ::color
   GraSetAttrArea( oPS, aAttr )

  /*
   * Position fÅr erstes (linkes) Quadrat berechnen
   */
   aPos1     := { 2, 2 }   
   ::squares := Int( aSize[1] / (aSize[2]+1) )
   nCenter   := 2 + ( aSize[1] - (::squares * (aSize[2]+1)) ) / 2
   aPos1[1]  := Max( 2, nCenter )
   aPos2     := { aPos1[1]+2 , aSize[2]-1 }   

  /*
   * Quadrate zeichnen
   */
   DO WHILE aPos2[1] < nX
      GraBox( oPS, aPos1, aPos2, GRA_FILL )
      aPos1[1] += 2
      aPos2[1] += 2
   ENDDO

   IF aPos2[1] < aSize[1]
      GraBox( oPS, aPos1, aPos2, GRA_FILL )
   ENDIF

RETURN self



/*
 * Quadrate von unten nach oben anzeigen (vertikale Anzeige)
 */
METHOD ProgressBar:displayVert( oPS, aSize, aAttr )
   LOCAL nY, aPos1, aPos2, nCenter

  /*
   * Maximale Y Koordinate fÅr Quadrate
   */
   nY := aSize[2] * ::_current / ( ::maximum - ::minimum )
   nY := Min( nY, aSize[2] )

  /*
   * Bereich oberhalb der Quadrate mit Hintergrundfarbe fÅllen
   */
   aAttr [ GRA_AA_COLOR ] := GRA_CLR_BACKGROUND
   GraSetAttrArea( oPS, aAttr )
   GraBox( oPS, {1,nY}, {aSize[1],aSize[2]}, GRA_FILL )

  /*
   * FÅllfarbe fÅr die Quadrate definieren
   */
   aAttr [ GRA_AA_COLOR ] := ::color
   GraSetAttrArea( oPS, aAttr )

  /*
   * Position fÅr erstes (unterstes) Quadrat berechnen
   */
   aPos1     := { 2, 2 }   
   ::squares := Int( aSize[2] / (aSize[1]+1) )
   nCenter   := 2 + (aSize[2] - (::squares * (aSize[1]+1)) ) / 2
   aPos1[2]  := Max( 2, nCenter )
   aPos2     := { aSize[1]-1, aPos1[2]+aSize[1]-2 }   

  /*
   * Quadrate zeichnen
   */
   DO WHILE aPos2[2] < nY
      GraBox( oPS, aPos1, aPos2, GRA_FILL )
      aPos1[2] += aSize[1]+1
      aPos2[2] += aSize[1]+1
   ENDDO

   IF aPos2[2] < aSize[2]
      GraBox( oPS, aPos1, aPos2, GRA_FILL )
   ENDIF

RETURN self


