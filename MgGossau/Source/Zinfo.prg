*********************************************************************
* ZInfo 17.9.2002
*********************************************************************
#include "Gra.ch"
#include "Xbp.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "DMLB.ch"
#include "MGV.CH"
#include "os.ch"
#include "dll.ch"






CLASS Info FROM DataDialog
   EXPORTED:

     VAR aOsInfo
     VAR aAppInfo

     METHOD Create
     METHOD Close

ENDCLASS


METHOD Info:create( oParent, oOwner , ;
                          aPos   , aSize  , ;
                          aPParam, lVisible )

   ::DataDialog:create( oParent, oOwner , ;
                       aPos   , aSize  , ;
                       aPParam, lVisible )

   ::aOsInfo := {}
   ::aAppInfo := {}


RETURN self

METHOD Info:Close()
   ::DataDialog:Close()
   ::Destroy()
RETURN self



PROCEDURE ZInfo()
*---------------

   LOCAL nEvent, mp1, mp2
   LOCAL DrawingArea
   LOCAL oDlg
   LOCAL oXbp, oXbp1
   LOCAL aSize := {,}
   LOCAL aPos  := {,}
   LOCAL i
   LOCAL lVis
   LOCAL oOwner, oParent
   LOCAL cSysAlias
   LOCAL cClient := NetName()
   LOCAL aTasks  := {}
   LOCAL aResource := LoadResource(1, XPP_MOD_EXE, RES_VERSION)


   aSize    := AppDeskTop():currentSize()
   aPos[1]  := (aSize[1] - 477) / 2
   aPos[2]  := (aSize[2] - 400) / 2
   aSize[1] := 477
   aSize[2] := 450
   oParent  := AppDesktop()
   oOwner   := SetAppWindow()


   oDlg := Info():new( oParent ,oOwner , aPos, aSize, , .F.)

   lVis     := .f.

   oDlg:taskList := .T.
   oDlg:title := "System Info"
   oDlg:setDisplayFocus := {||    WinMenu():checkItem( oDlg )}
*   oDlg:KeyBoard        :=  {|nKey,x,obj| oDlg:ValidKey( nKey, obj ) }
   oDlg:create()

   aAdd( oDlg:aOsInfo, "OS Beschreibung :" + Chr(9) +   os( OS_DESCRIPTION ) )
   aAdd( oDlg:aOsInfo, "OS Plattform :" + Chr(9) +   os( OS_PLATFORM    ) )
   aAdd( oDlg:aOsInfo, "OS Familie :" + Chr(9) +  os( OS_FAMILY      ) )
   aAdd( oDlg:aOsInfo, "OS Produkt :" + Chr(9) +   os( OS_PRODUCT     ) )
   aAdd( oDlg:aOsInfo, "OS Name :" + Chr(9) +   os( OS_FULLNAME    ) )
   aAdd( oDlg:aOsInfo, "OS Version :" + Chr(9) +   os( OS_VERSION     ) )
   aAdd( oDlg:aOsInfo, "OS Service Pack :" + Chr(9) +   os( OS_PATCH       ) )
   aAdd( oDlg:aOSInfo, "Verfügbarer Platz :" + Chr(9) + Str( DiskSpace()/1000000 ,5,0 )+ " MB")
   aAdd( oDlg:aOSInfo, "Virtuelles RAM verfügbar :" + Chr(9) + Str( Memory(MEM_VIRT_AVAIL)/1000 ,5,0 )+ " MB")
   aAdd( oDlg:aOSInfo, "Virtuelles RAM Total :" + Chr(9) + Str( Memory(MEM_VIRT_TOTAL)/1000 ,5,0 )+ " MB")
   aAdd( oDlg:aOSInfo, "RAM verfügbar :" + Chr(9) +  Str( Memory(MEM_RAM_AVAIL)/1000 ,5,0 )+ " MB")
   aAdd( oDlg:aOSInfo, "RAM installiert :" + Chr(9) + Str( Memory(MEM_RAM_TOTAL)/1000 ,5,0 )+ " MB" )

   for i := 1 to len( aResource )
      aAdd( oDlg:aAppInfo, aResource[i][1] + " :" + Chr(9) + aResource[i][2] )
   next

   aAdd( oDlg:aAppInfo, "" )
   aAdd( oDlg:aAppInfo, "Aktive Programme" )

   if !SysDbRequest()
      MsgBox("Die System Datenbank konnte nicht angefordert werden.","FreeSysLog()" )
   else
      cSysAlias := SysAlias()
      Select( cSysAlias )
      DbRefresh()
      if FileLock ( cSysAlias )
         DbGoTop()
         DbUnlock()
         Do While !eof()
            if (cSysAlias)->Open == "1"
               aAdd(aTasks, Alltrim( (cSysAlias)->Client ) + " -> " + Alltrim( (cSysAlias)->TaskName ) )
            endif
            fSkip(1)
         Enddo
      endif
      DbRelease( cSysAlias )
   endif

   aTasks := aSort( aTasks )
   for i:= 1 to len( aTasks)
       aAdd( oDlg:aAppInfo, aTasks[i] )
   next
   aAdd( oDlg:aAppInfo, "")
   aAdd( oDlg:aAppInfo, "System Information" )
   aAdd( oDlg:aAppInfo, "Computer Name:" + Chr(9) + NetName() )
   aAdd( oDlg:aAppInfo, "Compiler Version :" + Chr(9) + Version(1) )
   aAdd( oDlg:aAppInfo, "Compiler Release :" + Chr(9) + Version(2) )
   aAdd( oDlg:aAppInfo, "Compiler Build :" + Chr(9) + Version(3) )
   aAdd( oDlg:aAppInfo, "")
   aAdd( oDlg:aAppInfo, "Laufwerke und Verzeichnisse")
   aAdd( oDlg:aAppInfo, "Haupt Laufwerk :" + Chr(9) + CurDrive() )
   aAdd( oDlg:aAppInfo, "Haupt Verzeichnis :" + Chr(9) + CurDir() )
   aAdd( oDlg:aAppInfo, "Programm Laufwerk :" + Chr(9) + MainDrive )
   aAdd( oDlg:aAppInfo, "Disketten Laufwerk :" + Chr(9) + DiscDrive )
   aAdd( oDlg:aAppInfo, "Daten Anbindung Laufwerk :" + Chr(9) + RemoteDrive )
   aAdd( oDlg:aAppInfo, "Daten Verzeichnis :" + Chr(9) + DataDrive )
   aAdd( oDlg:aAppInfo, "Formular Verzeichnis :" + Chr(9) + FormDrive )
   aAdd( oDlg:aAppInfo, "Dokument Verzeichnis :" + Chr(9) + DocDrive )
   aAdd( oDlg:aAppInfo, "Inventar Verzeichnis :" + Chr(9) + InventarDrive )
   aAdd( oDlg:aAppInfo, "Nachrichten Verzeichnis :" + Chr(9) + MessageDrive )
   aAdd( oDlg:aAppInfo, "Vergangenheit Verzeichnis :" + Chr(9) + HistoryDrive )
   aAdd( oDlg:aAppInfo, "Auswertungs Verzeichnis :" + Chr(9) + AuswertDrive )
   aAdd( oDlg:aAppInfo, "Import Verzeichnis :" + Chr(9) + ImportDrive )


   DrawingArea := oDlg:DrawingArea

   oXbp1 := XbpStatic():new( drawingArea, , {12 ,48}, {aSize[1] - 24 ,aSize[2] - 96},,.f. )
   oXbp1:caption := "Gruppe"
   oXbp1:clipSiblings := .T.
   oXbp1:type := XBPSTATIC_TYPE_RAISEDBOX
   oXbp1:create()

   oXbp := XbpListBox():new( oXbp1, , {12,12}, {aSize[1]  -24 - 24  ,aSize[2] -96 - 24}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:create()
   oXbp:setTabStops( {130 } )

   oXbp:addItem("Applikations Info ")
   For i:= 1 to len(oDlg:aAppInfo)
      oXbp:addItem(oDlg:aAppInfo[i] )
   Next

   oXbp:addItem("")

   oXbp:addItem("Betribssystem Info ")
   For i:= 1 to len(oDlg:aOSInfo)
      oXbp:addItem(oDlg:aOSInfo[i] )
   Next

   oXbp:SetData({1})
   oXbp:ItemSelected := {|mp1, mp2, obj| NIL }

   oXbp := XbpPushButton():new( drawingArea, , { aSize[1] - 96 , 12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Beenden"
   oXbp:tabStop := .F.
   oXbp:create()
   oXbp:activate := {|| PostAppEvent(xbeP_Close,,,oDlg)}

   oDlg:windowMenu  := WinMenu()
   WinMenu():addItem( oDlg )
   WinMenu():checkItem( oDlg )

*   oDlg:Show()
*   SetAppFocus( oDlg )

*   oDlg:Show()
    oXbp1:Show()
    SetAppFocus( oDlg )

  RETURN