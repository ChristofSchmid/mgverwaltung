*********************************************************************
* ZForms 7.5.2003
*********************************************************************
#include "Gra.ch"
#include "Xbp.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "DMLB.ch"
#include "MGV.CH"


CLASS Forms FROM DataDialog
   EXPORTED:


     METHOD Create
     METHOD Close
     METHOD WebList
     METHOD AddressList
     METHOD DebNew
     METHOD DebOut
     METHOD DebList
     METHOD DebChange
     METHOD InfoInit


     VAR pFilter
     VAR InvStru
     VAR oFocus
     VAR oProgress
     VAR Info

     VAR aRefDAt


ENDCLASS


METHOD Forms:create( oParent, oOwner , ;
                          aPos   , aSize  , ;
                          aPParam, lVisible )

   ::DataDialog:create( oParent, oOwner , ;
                       aPos   , aSize  , ;
                       aPParam, lVisible )

   ::pFilter := { {},{},{},{},{},{} }
   ::InvStru := {}


RETURN self

METHOD Forms:Close()
   Select( ::aArea[TABELLEN] )
   DbCloseArea()

   PostAppEvent(xbeP_Close,,,SELF)

   ::DataDialog:Close()
   ::Destroy()


RETURN self


PROCEDURE ZForms(Form)
*---------------------
   LOCAL nEvent, mp1, mp2
   LOCAL DrawingArea
   LOCAL oDlg
   LOCAL oXbp, oXbp1, oXbp2, oXbp3
   LOCAL TabWa
   LOCAL RepWa
   LOCAL aProgrPos
   LOCAL aProgrSize
   LOCAL i := 1
   LOCAL bBlock

   aSize       := DialogSize()
   aPos        := DialogPos()

   OpenDb(DataDrive, TabellenFile, TabellenIndex, TabellenKey)
   TabWa := Select()


*   // Anwendungsfenster erzeugen (application window)

   oDlg := Forms():new( AppDesktop(), , aPos, aSize, , .F.)
   oDlg:taskList := .T.
   oDlg:title := "Listen Drucken"
   oDlg:setDisplayFocus := {||    WinMenu():checkItem( oDlg, TEMP )}
   oDlg:KeyBoard        :=  {|nKey,x,obj| oDlg:ValidKey( nKey, obj ) }
   oDlg:create()

   DrawingArea := oDlg:DrawingArea
   drawingArea:setFontCompoundName( "8.Arial" )

   aProgrPos  := { 10, 60}
   aProgrSize := { aSize[1]-24, 12 }
   oDlg:oProgress         := ProgressBar():new( oDlg ,, aProgrPos, aProgrSize)
   oDlg:oProgress:create()
   oDlg:oProgress:minimum := 1
   oDlg:oProgress:color   := GRA_CLR_BLUE
   oDlg:oProgress:Hide()

   oDlg:Info := XbpStatic():new( DrawingArea,, {10, 80 }, {aProgrSize[1],24}  )
   oDlg:Info:caption := ""
   oDlg:Info:create()
   oDlg:Info:Hide()


   oDlg:aArea[TABELLEN] := TabWa

   oDlg:windowMenu  := WinMenu()
   WinMenu():addItem( oDlg )
   WinMenu():checkItem( oDlg, TEMP )


   oXbp := XbpPushButton():new( drawingArea, , { aSize[1] - 96 , 12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Beenden"
   oXbp:tabStop := .F.
   oXbp:create()
   oXbp:activate := {|| oDlg:Close()}
   oDlg:RegisterElement(@oXbp, .t.,,,)

   oDlg:oFocus := SetAppFocus( oDlg )
   oDlg:Startup :=  .f.
   oDlg:Hide()
   oDlg:oProgress:Hide()
   oDlg:Info:Hide()
   Do Case
      Case Form == NIL
         *MsgBox("Kein Formular gewählt","zForms()"    )
         OpenDb(DataDrive, ReportFile, ReportIndex, ReportKey)
         RepWa := Select()
         If FileLock(RepWa)
            DbGoTop()
            DbUnlock()
         Endif
         Do While !Eof()
            if (RepWa)->ReportTyp == "F"
               bBlock := "{|| " + (RepWa)->RFunction + "  }"
               oXbp := XbpPushButton():new( drawingArea, , {40 , aSize[2] - 50 - (i*36)}, {200,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
               oXbp:caption := (RepWa)->ReportName
               oXbp:tabStop := .F.
               oXbp:create()
               oXbp:activate := &bBlock
               *oDlg:RegisterElement(@oXbp, .t.,,,)
               i:= i + 1
            endif
            fSkip(1)
         Enddo
         Select(RepWa)
         DbCloseArea()
          *PostAppEvent(xbeP_Close,,,oDlg)
      Case Form == "WebList"
          oDlg:WebList()
          PostAppEvent(xbeP_Close,,,oDlg)
      Case Form == "AddressList"
          oDlg:AddressList()
          PostAppEvent(xbeP_Close,,,oDlg)
      Case Form == "DebNew"
          oDlg:DebNew()
          PostAppEvent(xbeP_Close,,,oDlg)
      Case Form == "DebOut"
          oDlg:DebOut()
          PostAppEvent(xbeP_Close,,,oDlg)
      Case Form == "DebChange"
          oDlg:DebChange()
          PostAppEvent(xbeP_Close,,,oDlg)
      Case Form == "DebList"
          oDlg:DebList()
          PostAppEvent(xbeP_Close,,,oDlg)

      othe
          PostAppEvent(xbeP_Close,,,oDlg)
   Endcase

* Test 7.5.2004
*  nEvent := xbe_None
*  DO WHILE nEvent <> xbeP_Close
*     nEvent := AppEvent( @mp1, @mp2, @oXbp )

*     Do Case

*        Case nEvent == xbeM_LbDown

*        Case nEvent == xbeP_Keyboard

*        Case nEvent == xbeP_Close
*         WinMenu():AbleItem( MENU01,1,.t.)

*     endcase

*    oXbp:handleEvent( nEvent, mp1, mp2 )
*  ENDDO

  RETURN


METHOD Forms:WebList()
*---------------------

LOCAL SearchWord := ""
LOCAL TmpWa
LOCAL RtoLock
LOCAL oDlg
LOCAL DebWa

PRIVATE FAbsZ1  := ::GetVSTInfo(1) &&"CSOS Velo Import AG"

OpenDb(DataDrive, KundenFile, KundenIndex, KundenKey)
DebWa   := Select()
::aArea[KUNDEN]     := DebWa

DbSetFilter( {|| (DebWa)->DebStat <> "99" .or. (DebWa)->DebADat > Date() } )

If FileLock(DebWa)
   DbGoTop()
   DbUnlock()
Endif

*::InfoInit("Kontaktliste Daten zum Druck aufbereiten")
::pFilter := { {},{},{},{},{},{} }

::pFilter[1] := {KUNDEN, 3, "Name", SearchWord }
::pFilter[2] := {{"KGR", "01", "017" }}
::pFilter[3] := {}

::pFilter[4] := {}
::pFilter[5] := {}
::pFilter[6] := {}

If SelectDataBox(SELF,,,@::pFilter,"Kontaktliste Mitglieder Auswahl")
   PrintForm("WebList.For", ::pFilter, SELF)
Endif

Select(DebWa)
DbCloseArea()

Return


METHOD Forms:AddressList()
*-------------------------

LOCAL SearchWord := ""
LOCAL TmpWa
LOCAL RtoLock
LOCAL oDlg
LOCAL DebWa

PRIVATE FAbsZ1  := ::GetVSTInfo(1) &&"CSOS Velo Import AG"

OpenDb(DataDrive, KundenFile, KundenIndex, KundenKey)
DebWa   := Select()
::aArea[KUNDEN]     := DebWa

DbSetFilter( {|| (DebWa)->DebStat <> "99" .or. (DebWa)->DebADat > Date() } )

If FileLock(DebWa)
   DbGoTop()
   DbUnlock()
Endif

*::InfoInit("Adressliste Daten zum Druck aufbereiten")
::pFilter := { {},{},{},{},{},{} }

::pFilter[1] := {KUNDEN, 3, "Name", SearchWord }
::pFilter[2] := {{"KGR","01","017" }}
::pFilter[3] := {}

::pFilter[4] := {}
::pFilter[5] := {}
::pFilter[6] := {}

If SelectDataBox(SELF,,,@::pFilter,"Adressliste Mitglieder Auswahl")
   PrintForm("AddressList.For", ::pFilter, SELF)
Endif

Select(DebWa)
DbCloseArea()

Return




METHOD Forms:DebNew()
*---------------------
LOCAL SearchWord := ""
LOCAL TmpWa
LOCAL RtoLock
LOCAL oDlg
LOCAL DebWa
LOCAL TabWa
LOCAL ThisYearEnd    := cTod( "31.12." + Str(Year( Date() ),4 ,0 ) )
LOCAL LastYearBeginn := cTod( "01.01." + Str(Year( Date() )-1,4 ,0 ) )

PRIVATE FAbsZ1  := ::GetVSTInfo(1) &&"CSOS Velo Import AG"

OpenDb(DataDrive, KundenFile, KundenIndex, KundenKey)
DebWa   := Select()

::aArea[KUNDEN]     := DebWa

DbSetFilter( {|| (DebWa)->DebEDat >= LastYearBeginn .and.  (DebWa)->DebEDat <= ThisYearEnd } )
*Set Filter to Str(Year((DebWa)->DebEDat,4,0)) == ThisYear .or. Str(Year((DebWa)->DebEDat,4,0)) == LastYear


If FileLock(DebWa)
   DbGoTop()
   DbUnlock()
Endif

::pFilter := { {},{},{},{},{},{} }
*::pFilter[1] := {KUNDEN, 3, "Name", SearchWord }
::pFilter[1] := {KUNDEN, 3, , }
::pFilter[2] := {}
::pFilter[3] := {}

::pFilter[4] := {}
::pFilter[5] := {}
::pFilter[6] := {}


If SelectDataBox(SELF,,,@::pFilter,"Mitglieder Auswahl")
   PrintForm("DebNew.For", ::pFilter, SELF)
Endif

Select(DebWa)
DbCloseArea()

Return


METHOD Forms:DebOut()
*---------------------
LOCAL SearchWord := ""
LOCAL TmpWa
LOCAL RtoLock
LOCAL oDlg
LOCAL DebWa
LOCAL TabWa
LOCAL ThisYearEnd    := cTod( "31.12." + Str(Year( Date() ),4 ,0 ) )
LOCAL LastYearBeginn := cTod( "01.01." + Str(Year( Date() )-1,4 ,0 ) )

PRIVATE FAbsZ1  := ::GetVSTInfo(1) &&"CSOS Velo Import AG"

OpenDb(DataDrive, KundenFile, KundenIndex, KundenKey)
DebWa   := Select()

::aArea[KUNDEN]     := DebWa

DbSetFilter( {|| (DebWa)->DebADat >= LastYearBeginn .and.  (DebWa)->DebADat <= ThisYearEnd } )

If FileLock(DebWa)
   DbGoTop()
   DbUnlock()
Endif

::pFilter := { {},{},{},{},{},{} }
::pFilter[1] := {KUNDEN, 3, "Name", SearchWord }
::pFilter[2] := {}
::pFilter[3] := {}

::pFilter[4] := {}
::pFilter[5] := {}
::pFilter[6] := {}


If SelectDataBox(SELF,,,@::pFilter,"Mitglieder Auswahl")
   PrintForm("DebOut.For", ::pFilter, SELF)
Endif

Select(DebWa)
DbCloseArea()

Return


METHOD Forms:DebChange()
*---------------------
LOCAL SearchWord := ""
LOCAL TmpWa
LOCAL RtoLock
LOCAL oDlg
LOCAL ThisYearEnd    := cTod( "31.12." + Str(Year( Date() ),4 ,0 ) )
LOCAL LastYearBeginn := cTod( "01.01." + Str(Year( Date() )-1,4 ,0 ) )
LOCAL DebWa
LOCAL TabWa
LOCAL LogWa

PRIVATE FAbsZ1  := ::GetVSTInfo(1) &&"CSOS Velo Import AG"


OpenDb(DataDrive, BewegungsFile, BewegungsIndex, BewegungsKey)
LogWa := Select()
OpenDb(DataDrive, KundenFile, KundenIndex, KundenKey)
DebWa   := Select()

::aArea[DEBBEWEG]  := LogWa
::aArea[KUNDEN]    := DebWa

Select(LogWa)
DbSetFilter( {|| (LogWa)->MutDat >= LastYearBeginn .and.  (LogWa)->MutDat <= ThisYearEnd } )

If FileLock(LogWa)
   DbGoTop()
   DbUnlock()
Endif

::pFilter := { {},{},{},{},{},{} }
::pFilter[1] := {DEBBEWEG, 1, "DebNr", SearchWord }
::pFilter[2] := {}
::pFilter[3] := {}

::pFilter[4] := {}
::pFilter[5] := {}
::pFilter[6] := {}


If SelectDataBox(SELF,,,@::pFilter,"Mitglieder Auswahl")
   PrintForm("DebChange.For", ::pFilter, SELF)
Endif

Select(DebWa)
DbCloseArea()

Select(LogWa)
DbCloseArea()

Return

METHOD Forms:DebList()
*---------------------
LOCAL SearchWord := ""
LOCAL TmpWa
LOCAL RtoLock
LOCAL oDlg
LOCAL DebWa
LOCAL TabWa

PRIVATE FAbsZ1  := ::GetVSTInfo(1) &&"CSOS Velo Import AG"

OpenDb(DataDrive, KundenFile, KundenIndex, KundenKey)
DebWa   := Select()
::aArea[KUNDEN]     := DebWa

DbSetFilter( {|| (DebWa)->DebStat <> "99" .or. (DebWa)->DebADat > Date() } )

If FileLock(DebWa)
   DbGoTop()
   DbUnlock()
Endif

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

Select(DebWa)
DbCloseArea()

Return


METHOD Forms:InfoInit( InfoText )
*--------------------------------
InfoText := iif(InfoText == NIL, "", InfoText)
::oProgress:maximum := Lastrec()
::oProgress:Current := 0
::oProgress:Show()

::Info:SetCaption(InfoText)
::Info:Show()
Return
