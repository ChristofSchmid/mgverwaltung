//////////////////////////////////////////////////////////////////////
//
//  ERRORSYS.PRG
//
//  Copyright:
//      Alaska Software, (c) 1997-2002. Alle Rechte vorbehalten.         
//  
//  Inhalt:
//      Standard-Fehlercodeblock installieren
//   
//  Bemerkungen:
//      Die Funktion ErrorsSys() wird bei jedem Programmstart automatisch
//      aufgerufen
//   
//////////////////////////////////////////////////////////////////////

#include "Xbp.ch"
#include "Error.ch"
#include "os.ch"

*#define  DEBUG
***********************************
* Name des Errorlogs ohne Erweiterung
***********************************
#define EHS_ERRORLOG "XPPERROR"

/*
 * Sprachspezifische Stringkonstanten die im Code verwendet werden 
 */
#define EHS_CANCEL            "Abbrechen"
#define EHS_EXIT_WITH_LOG     "Ende mit LOG-Datei"
#define EHS_RETRY             "Wiederholen"
#define EHS_IGNORE            "Ignorieren"
#define EHS_OS_ERROR          ";Betriebsystem Fehler : "
#define EHS_CALLED_FROM       "Aufgerufen von"
#define EHS_XPP_ERROR_MESSAGE "Xbase++ Fehlermeldung" 
#define EHS_ERROR             "Fehler "
#define EHS_WARNING           "Warnung "
#define EHS_DESCRIPTION       ";Beschreibung : "
#define EHS_FILE              ";Datei : "
#define EHS_OPERATION         ";Operation : "
#define EHS_LOG_OPEN_FAILED   "Datei f¸r Fehlerprotokoll kann nicht geˆffnet werden"
#define EHS_ERROR_LOG_OF      "FEHLERPROTOKOLL von "
#define EHS_DATE              " Datum:"
#define EHS_XPP_VERSION       "Xbase++ Version     :"
#define EHS_OS_VERSION        "Betriebssystem      :"
#define EHS_LOG_WRITTEN_TO(cFile) "Fehlerprotokoll wurde in die Datei "+ cFile +" geschrieben"

***********************************
* Install default error code block
***********************************
PROCEDURE ErrorSys()      
   ErrorBlock( {|o| StandardEH(o)} )
   *DbCloseAll()
RETURN



*************************************
* Standart Fehlerbehandlungsfunktion
*************************************
STATIC FUNCTION StandardEH( oError )
   LOCAL i, cMessage, aOptions, nOption, nSeverity
   LOCAL row, col
   LOCAL oDacSession, oSession
   LOCAL OpenWindows 

   oError:setErrorMode(ERR_MODE_GC ,ERR_ACTION_POPUP )
   oError:setErrorMode(ERR_MODE_GUI ,ERR_ACTION_POPUP )

   /* öberprÅfe, ob Standardkorrektur definiert ist */
   DO CASE

   /* Division durch Null ergibt Null */
   CASE oError:genCode == XPP_ERR_ZERODIV      
      RETURN 0                            

   /* Null durch Null ergibt Null, kann bei den Operationen
    * /, /=, % und %= auftreten
    */

   CASE oError:genCode == XPP_ERR_NUMERR         
      IF "/" $ oError:operation .OR. "%" $ oError:operation
          IF oError:args[-1] == 0 
             RETURN 0                        
          ENDIF
      ENDIF


   /* Zuwenig Memory
   CASE oError:genCode == 15  .AND. ;
        oError:SubCode  == 1005 &&.and. oError:tries == 0
        MsgBox("Der Speichr scheint knapp zu sein. ", EHS_XPP_ERROR_MESSAGE )
        oError:tries := 5
        oError:CanRetry := .t. 
      RETURN .F.


   /* Berechtigungsfehler Fehler beim schreiben einer Datei */
   CASE oError:genCode == 40  .AND. ;
        oError:osCode  == 5
        MsgBox("Die Datei konnte nicht geschrieben werden. Berechtigungen sind ungen¸gend.", EHS_XPP_ERROR_MESSAGE )
      RETURN(.F.)

   /* Fehler beim ôffnen einer Datei im Netzwerk */
   CASE oError:genCode == XPP_ERR_OPEN  .AND. ;
        oError:osCode  == 32            .AND. ;
        oError:canDefault                      
      RETURN(.F.)

   /* Keine Satz/Dateisperre vorhanden */
   CASE oError:genCode == XPP_ERR_APPENDLOCK .AND. ;
        oError:canDefault                        
      RETURN(.F.)

   ENDCASE

   oSession := DbSession()
   IF oSession = NIL .AND. IsFunction("DacSession", FUNC_CLASS)
      oDacSession := &("DacSession()")
      oSession := oDacSession:getDefault()
   ENDIF
   IF oSession != NIL
       IF oSession:getLastError() != 0
           oError:cargo := {oError:cargo, ;
                            oSession:getLastError(),;
                            oSession:getLastMessage() }
       ENDIF              
   ENDIF

   /* Keine Standardkorrektur definiert: Erzeuge Fehlermeldung */
   cMessage := ErrorMessage( oError )

   /* Array fÅr Auswahl */
#ifdef DEBUG
   aOptions := { EHS_CANCEL, EHS_EXIT_WITH_LOG }
#else
   aOptions := { EHS_CANCEL }
#endif

   IF oError:canRetry
      AAdd( aOptions, EHS_RETRY )
   ENDIF

   IF oError:canDefault
      AAdd( aOptions, EHS_IGNORE )
   ENDIF

   IF ! Empty( oError:osCode )
      cMessage += EHS_OS_ERROR + LTrim(Str(oError:osCode)) +;
                  ";" + DosErrorMessage(oError:osCode)
   ENDIF

   IF AppType() <> APPTYPE_PM

      /* Anzeige mit Alert() Box mîglich ?*/
      IF SetAppWindow() != NIL
         i   := 0
         row := Row()
         col := Col()
         DO WHILE i == 0                     
            i := Alert( cMessage, aOptions )
         ENDDO
         SetPos( row, col )

         /* GewÑhlte Option ausfÅhren */
         IF ! Empty( i )            
       DO CASE
       CASE aOptions[i] == EHS_IGNORE
          RETURN .F.
       CASE aOptions[i] == EHS_RETRY
          RETURN .T.
       CASE aOptions[i] == EHS_CANCEL
          ErrorLog( oError, 2 )
          Break( oError )
       CASE aOptions[i] == EHS_EXIT_WITH_LOG
          ErrorLog( oError, 2 )
       ENDCASE
    ENDIF
      ELSE
         /* Keine Console-Fenster vorhanden */
#ifdef DEBUG
    ErrorLog( oError, 2 )
#endif
      ENDIF

      /*
       * Programm kann oder soll nicht fortgesetzt werden
       * Errorlevel setzen und Programm beenden ! 
       */

      ErrorLevel(1)
      QUIT 
   ENDIF

   IF oError:canDefault .AND. oError:canRetry
      nOption := XBPMB_ABORTRETRYIGNORE
   ELSEIF oError:canRetry
      nOption := XBPMB_RETRYCANCEL
   ELSEIF oError:canDefault
      nOption := XBPMB_OKCANCEL
   ELSE
      nOption := XBPMB_CANCEL
   ENDIF

   i := 1
   DO WHILE ! Empty( ProcName(++i) )
      cMessage+= ";" + EHS_CALLED_FROM +" " + Trim( ProcName(i) )   + "(" + ;
                             LTrim( Str( ProcLine(i) ) ) + ")"
   ENDDO

   i := 0
   /* Auswahl des Icons fÅr ConfirmBox() */
   DO CASE
      CASE oError:severity == XPP_ES_FATAL
           nSeverity := XBPMB_CRITICAL
      CASE oError:severity == XPP_ES_ERROR
           nSeverity := XBPMB_CRITICAL
      CASE oError:severity == XPP_ES_WARNING
           nSeverity := XBPMB_WARNING
      OTHERWISE
           nSeverity := XBPMB_INFORMATION
   ENDCASE

 *  /* Anzeige mit ConfirmBox() */
 *  i := ConfirmBox( , StrTran( cMessage, ";", Chr(13) ), ;
 *                   EHS_XPP_ERROR_MESSAGE , ;
 *                   nOption , ;
 *                   nSeverity + XBPMB_APPMODAL+XBPMB_MOVEABLE )

 *  DO CASE
 *  CASE i == XBPMB_RET_RETRY
 *     RETURN (.T.)
 *  CASE i == XBPMB_RET_IGNORE
 *     RETURN (.F.)
 *  CASE i == XBPMB_RET_CANCEL
*#ifdef DEBUG
*         IF ConfirmBox(, EHS_EXIT_WITH_LOG, EHS_XPP_ERROR_MESSAGE, XBPMB_YESNO,;
*                  XBPMB_WARNING+XBPMB_APPMODAL+XBPMB_MOVEABLE ) != XBPMB_RET_YES
*              Break( oError )
*         ENDIF
*#else
*         Break( oError )
*#endif

MsgBox("Ein Fehler ist aufgetreten. Alle Fenster werden geschlossen. Die Daten werden erhalten.", EHS_XPP_ERROR_MESSAGE )
rele Pages && Wenn Fehler aus Print kommt, erneuter Druck freigeben 9.6.2004

  * ENDCASE

#ifdef DEBUG
   ErrorLog( oError, 2 )
#endif

   /* Errorlevel setzen und Programm beenden ! */
   ErrorLevel(1)
   OpenWindows := WinMenu():Stack()
   
   for i := len(OpenWindows) to 1 step -1
      OpenWindows[i]:Close()
   next 

   *Do While len(OpenWindows) > 0
   *    OpenWindows[1]:Close(.t.)
   *Enddo

   dbcloseall()

   Break
   *QUIT

RETURN .F. /* Der Compiler erwartet einen Return Wert */



***************************************
STATIC FUNCTION ErrorMessage( oError )
*
*  Erzeugt einen string mit den wichtigsten Informationen 
*  aus dem Error-Object
***************************************

   /* öberprÅfen, ob Fehler oder Warnung generiert wurde */
   LOCAL cMessage := ;                           
         IIf( oError:severity > XPP_ES_WARNING, ;
                          EHS_ERROR, EHS_WARNING )

   /* Name des SubSystems anhÑngen */
   IF Valtype( oError:subSystem ) == "C"        
      cMessage += oError:subSystem              
   ELSE
      cMessage += "????"                       
   ENDIF

   /* spezifischen Fehlercode des SubSystem anhÑngen */
   IF Valtype( oError:subCode ) == "N"           
      cMessage += "/"+ LTrim(Str(oError:subCode))
   ELSE
      cMessage += "/????"                        
   ENDIF

   /* Optional: Errorcode des SubSystem anhÑngen */
   IF Valtype( oError:description ) == "C"
      cMessage += EHS_DESCRIPTION + ;   
                   oError:description
   ENDIF

   /* Optional: Name der Datei bei deren Bearbeitung der Fehler auftrat */
   IF ! Empty( oError:fileName )               
      cMessage += EHS_FILE + oError:fileName 
   ENDIF

   /* Optional: Name der Operation bei deren AusfÅhrung der Fehler auftrat */
   IF ! Empty( oError:operation )       
      cMessage += EHS_OPERATION + oError:operation
   ENDIF

   /* ID des Threads, auf dem der Fehler auftrat */
   cMessage += ";Thread ID : " + ;         
                LTrim(Str(oError:thread))  

   IF Valtype(oError:cargo)="A" .AND. len(oError:cargo) == 3
      cMessage += ";" +  LineSplit(oError:cargo[3], 50)
   ENDIF
RETURN cMessage



************************************************
STATIC PROCEDURE ErrorLog( oError, nStackStart )
*
*  Erzeugt einen string mit den wichtigsten Informationen 
*  aus dem Error-Object
************************************************
   LOCAL i:=0, bError := ErrorBlock( {|e| Break(e)} )
   LOCAL cErrorLog
   LOCAL cExtension:= "LOG"
   LOCAL lPrint, lConsole, cAlternate, lAlternate, lExtra
   LOCAL MemVirtAvail := Str( Memory(MEM_VIRT_AVAIL) )
   LOCAL MemVirtTotal := Str( Memory(MEM_VIRT_TOTAL) )
   LOCAL MemRamAvail  := Str( Memory(MEM_RAM_AVAIL) )
   LOCAL MemRamTotal  := Str( Memory(MEM_RAM_TOTAL) )


   /* Aktuelle Drucker-Einstellungen sichern und Drucker ausschalten */
   lPrint     := Set( _SET_PRINTER )
   lConsole   := Set( _SET_CONSOLE )
   cAlternate := Set( _SET_ALTFILE )
   lAlternate := Set( _SET_ALTERNATE )
   lExtra     := Set( _SET_EXTRA, .F. )

   SET PRINTER OFF
   SET CONSOLE ON

   IF SetAppWindow() == NIL ;
     .OR. .NOT. SetAppWindow():isDerivedFrom( RootCrt() )
      SET CONSOLE OFF
   ENDIF 

   /* Fehler, beim îffnen der ALTERNATE Datei abfangen */
   DO WHILE .T.                        
      cErrorLog := MessageDrive + EHS_ERRORLOG + "." + cExtension

      Do while file(cErrorLog)
         cExtension := PadL(++i,3,"0")        
         cErrorLog := MessageDrive + EHS_ERRORLOG + "." + cExtension
      enddo  

      BEGIN SEQUENCE                    
        SET ALTERNATE TO (cErrorLog)
        SET ALTERNATE ON
      RECOVER
        /* 
         * ALTERNATE Datei konnte nicht geîffnet werden: 
         * anderen Dateinamen verwenden.
         */
        cExtension := PadL(++i,3,"0")  
        IF i > 999
           IF AppType() <> APPTYPE_PM
              TONE(660,5)
              ? EHS_LOG_OPEN_FAILED 
              IF !Set( _SET_CONSOLE )
                  OutErr( CHR(10)+CHR(13) + EHS_LOG_OPEN_FAILED )
              ENDIF
           ELSE
              MsgBox( EHS_LOG_OPEN_FAILED )
           ENDIF
           ErrorLevel(1)
           QUIT
        ENDIF
        LOOP
      END SEQUENCE
      EXIT
   ENDDO

   ErrorBlock( bError )

   ? Replicate( "-", 78 )
   ? EHS_ERROR_LOG_OF +'"'+ appName(.T.) +'"'+ EHS_DATE, Date(), Time()
   ?
   ? EHS_XPP_VERSION , Version()+"."+Version(3)
   ? EHS_OS_VERSION  , Os()
   ? Replicate( "-", 78 )
   ? "oError:args         :"
   IF Valtype(oError:Args)=="A"
      AEval( oError:Args, ;
             {|x,y| Qout( Space(9),"-> VALTYPE:", y:=Valtype(x) )  , ;
                     IIf( y=="O", QQout( " CLASS:", x:className() ), ;
                                  QQout( " VALUE:", Var2Char(x) ) ) } )
   ELSE
      Qout( Space(10),"-> NIL" )
   ENDIF

   ? "oError:canDefault   :" , oError:canDefault
   ? "oError:canRetry     :" , oError:canRetry
   ? "oError:canSubstitute:" , oError:canSubstitute
   ? "oError:cargo        :" , oError:cargo
   ? "oError:description  :" , oError:description
   ? "oError:filename     :" , oError:filename
   ? "oError:genCode      :" , oError:genCode
   ? "oError:operation    :" , oError:operation
   ? "oError:osCode       :" , oError:osCode
   ? "oError:severity     :" , oError:severity
   ? "oError:subCode      :" , oError:subCode
   ? "oError:subSystem    :" , oError:subSystem
   ? "oError:thread       :" , oError:thread
   ? "oError:tries        :" , oError:tries

   ? Replicate( "-", 78 )
   ? "CALLSTACK:"
   ? Replicate( "-", 78 )

   i := nStackStart
   DO WHILE ! Empty( ProcName(++i) )  
      ? EHS_CALLED_FROM, Trim( ProcName(i) )   + "(" + ;
                 LTrim( Str( ProcLine(i) ) ) + ")"
   ENDDO
   ?
   ? Replicate( "-", 78 )
   ? "Memory Status:"
   ? Replicate( "-", 78 )
   ? "Virtuelles Memory verf¸gbar  :" , MemVirtAvail
   ? "Virtuelles Memory total      :" ,MemVirtTotal
   ? "Physisches Memory verf¸gbar  :" ,MemRamAvail 
   ? "Physisches Memory total      :" ,MemRamTotal 

   SET ALTERNATE TO
   SET ALTERNATE OFF

   
   MsgBox( EHS_LOG_WRITTEN_TO(cErrorLog)  )
   

   /* Einstellungen wiederherstellen */
   Set( _SET_PRINTER,   lPrint)
   Set( _SET_CONSOLE,   lConsole)
   Set( _SET_ALTFILE,   cAlternate)
   Set( _SET_ALTERNATE, lAlternate)
   Set( _SET_EXTRA,     lExtra)

RETURN



/* Lange Zeile fÅr Ausgabe in Alert() vorbereiten */
FUNCTION LineSplit(cMessage, nMaxCol)
LOCAL i
LOCAL cLines := ""
LOCAL nLines

   nLines := MlCount(cMessage, nMaxCol,, .T.)
   FOR i:= 1 TO nLines
        cLines += MemoLine(cMessage, nMaxCol, i,,.T.) +";"
   NEXT
RETURN cLines
