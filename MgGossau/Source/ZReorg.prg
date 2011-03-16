*********************************************************************
* ZReorg 10.8.2002
*********************************************************************
#include "Gra.ch"
#include "Xbp.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "DMLB.ch"
#include "MGV.CH"
#include "DelDbe.ch"
#include "Directry.ch"




CLASS Reorg FROM DataDialog
   EXPORTED:

     VAR aFileList
     VAR aArtFiles
     VAR aKreFiles
     VAR aHisFiles

     METHOD Create
     METHOD Close
     METHOD ReorgIndex
*     METHOD ReorgDoc
     METHOD PackZlager
*     METHOD GenKreAllArt
*     METHOD SelectKreFile
*     METHOD ListBoxRefresh
*     METHOD SelectHisFile
*     METHOD YearEnd
*     METHOD YearEndDoc
*     METHOD GenSoldFile
*     METHOD StrapLagBew
*     METHOD CheckDisp
*     METHOD CheckOrder
*     METHOD CheckKasse
*     METHOD AppendNewDeb
     METHOD ExecBackup
     METHOD SetView
     METHOD ResetView
     METHOD ClearLog


ENDCLASS


METHOD Reorg:create( oParent, oOwner , ;
                          aPos   , aSize  , ;
                          aPParam, lVisible )

   ::DataDialog:create( oParent, oOwner , ;
                       aPos   , aSize  , ;
                       aPParam, lVisible )

   ::aFileList := {}
   ::aArtFiles := {}
   ::aKreFiles := {}
   ::aHisFiles := {}

RETURN self

METHOD Reorg:Close()
    if !::aArea[TEMP] == NIL
       Select(::aArea[TEMP] )
       DbCloseArea()
    Endif
    FErase(AuswertDrive + "TEMP.DBF")
    FErase(DataDrive + "MGInReorg.SYS")
   ::DataDialog:Close()
   ::Destroy()
   ReorgActive := .f.
RETURN self



PROCEDURE ZReorg
*---------------

   LOCAL nEvent, mp1, mp2
   LOCAL DrawingArea
   LOCAL oDlg
   LOCAL oXbp, oXbp1, oXbp2, oXbp3, oXbp4
   LOCAL cAlias
   LOCAL nIndex
   LOCAL oDraw
   LOCAL oStatic
   LOCAL cDataDr := DataDrive
   LOCAL cDbName
   LOCAL aIndex
   LOCAL aKey
   LOCAL test := .f.
   LOCAL i, n
   LOCAL Wa
   LOCAL aSize
   LOCAL aPos := {,}
   LOCAL TmpFile   := "Temp.Dbf"
   Local TmpIndex  := {}
   Local TmpKey    := {}
   LOCAL TmpWa
   LOCAL aStructure := { { "Action" , "C",  20, 0 } }
   LOCAL nHandle := 0
   LOCAL cText
   LOCAL aArtFiles   := {}
   LOCAL aHisFiles   := {}
   LOCAL nTaskCount  := 0
   LOCAL cClient     := ""


   if !UniqueTask(@cClient)
      MsgBox("Für die Dienstprogramme müsssen alle Anwendungen auf allen Arbeitsstationen geschlossen sein", "Task offen auf " + cClient )
      Return
   endif

   DbCreate( AuswertDrive+TmpFile, aStructure, "DBFNTX" )

   OpenDb(DataDrive, KundenFile, KundenIndex, KundenKey) &&Indexe müssen bekannt sein
   DbCloseArea()

   OpenDb(AuswertDrive, TmpFile, TmpIndex, TmpKey)
   TmpWa := Select()

   ReorgActive     := .t.

   aSize       := DialogSize()
   aPos        := DialogPos()

   nHandle := FCreate(DataDrive + "MGInReorg.SYS")

   if nHandle < 0
      MsgBox("Systemfehler, Fcreate() konnte nicht ausgeführt werden", "Low Level")
      Return
   Endif

   FWrite( nHandle, "MG in Reorganisation " + dtoc(Date()) + " " + Time() )
   FClose( nHandle )


*   // Anwendungsfenster erzeugen (application window)

   oDlg := Reorg():new( AppDesktop(), , aPos, aSize, , .F.)
   oDlg:taskList := .T.
   oDlg:title := "Dienstprogramme"
   oDlg:setDisplayFocus := {||    WinMenu():checkItem( oDlg, TEMP )}
   oDlg:KeyBoard        :=  {|nKey,x,obj| oDlg:ValidKey( nKey, obj ) }
   oDlg:create()

   DrawingArea := oDlg:DrawingArea
   drawingArea:setFontCompoundName( "8.Arial" )

   cText := "Achtung, während dieses Fenter geöffnet ist, kann an keiner Arbeitsstation;"   + ;
            "gearbeitet werden. Alle Programme für alle Benutzer sind bis zum Schliessen;"  + ;
            "dieses Fensters gesperrt."

   oXbp := XbpStatic():new(drawingArea, ,{20 ,aSize[2] - 100}, {400,60} )
   oXbp:options := XBPSTATIC_TEXT_VCENTER + XBPSTATIC_TEXT_LEFT + XBPSTATIC_TEXT_WORDBREAK
   oXbp:caption := StrTran( cText, ";", Chr(13) )
   oXbp:create()

   oDlg:aArea[TEMP] := TmpWa

   oDlg:windowMenu  := WinMenu()
   WinMenu():addItem( oDlg )
   WinMenu():checkItem( oDlg, TEMP )

   if WinMenu():Items() > 1
      MsgBox("Für die Dienstprogramme müsssen alle Fenster geschlossen sein", "Reindex" )
      oDlg:Close()
      Return
   Endif

   aAdd(oDlg:aFileList, {KundenFile, KundenIndex, KundenKey} )
   aAdd(oDlg:aFileList, {BewegungsFile, BewegungsIndex, BewegungsKey} )
   aAdd(oDlg:aFileList, {TabellenFile, TabellenIndex, TabellenKey} )
   aAdd(oDlg:aFileList, {ReportFile, ReportIndex, ReportKey} )
   aAdd(oDlg:aFileList, {PlzFile, PlzIndex, PlzKey} )
   aAdd(oDlg:aFileList, {SystemFile, SystemIndex, SystemKey} )

   For i := 1 to len(oDlg:aFileList) -1
      DbUseArea( .t. ,  , DataDrive + oDlg:aFileList[i][1] , , .f. , .f. )
      if NetErr()
         MsgBox("Die Datei " + DataDrive + oDlg:aFileList[i][1] + " wird verwendet.","Startup Reorg" )
         DbCloseArea()
         oDlg:Close()
         Return
      Endif
      DbCloseArea()
   Next

   oDlg:aArtFiles    := aArtFiles
   oXbp2 := XbpStatic():new( drawingArea, , {24 + 24 + 264 ,48}, {264,384},,.f. )
   oXbp2:caption := "Gruppe"
   oXbp2:clipSiblings := .T.
   oXbp2:type := XBPSTATIC_TYPE_RAISEDBOX
   oXbp2:create()

   oXbp := XbpListBox():new( oXbp2, , {12,48}, {240,324}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )

   oXbp:MarkMode := XBPLISTBOX_MM_EXTENDED
   oXbp:tabstop := .T.
   oXbp:create()
   For i:= 1 to len(oDlg:aArtFiles)
      oXbp:addItem(oDlg:aArtFiles[i][1] )
   Next

   oXbp:SetData({1})
   oXbp:ItemSelected := {|mp1, mp2, obj| oDlg:SelectKreFile(Obj) }
   aAdd(oDlg:aListBox, oXbp)

   oDlg:aHisFiles    := aHisFiles

   oXbp3 := XbpStatic():new( drawingArea, , {24 + 24 + 264 ,48}, {264,384},,.f. )
   oXbp3:caption := "Gruppe"
   oXbp3:clipSiblings := .T.
   oXbp3:type := XBPSTATIC_TYPE_RAISEDBOX
   oXbp3:create()

   oXbp := XbpListBox():new( oXbp3, , {12,48}, {240,324}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )

   oXbp:MarkMode := XBPLISTBOX_MM_EXTENDED
   oXbp:tabstop := .T.
   oXbp:create()
   For i:= 1 to len(oDlg:aHisFiles)
      oXbp:addItem(oDlg:aHisFiles[i][1] )
   Next
   oXbp:SetData({1})
   oXbp:ItemSelected := {|mp1, mp2, obj| oDlg:SelectHisFile(Obj) }
   aAdd(oDlg:aListBox, oXbp)


   oXbp4 := XbpStatic():new( drawingArea, , {24 + 24 + 264 ,48}, {264,384},,.f. )
   oXbp4:caption := "Gruppe"
   oXbp4:clipSiblings := .T.
   oXbp4:type := XBPSTATIC_TYPE_RAISEDBOX
   oXbp4:create()

   oXbp := XbpRadiobutton():new( oXbp4, , {24,340}, {168,24} )
   oXbp:caption := "Backup erstellen"
   oXbp:selection := .T.
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:selected := {|| NIL }
   oDlg:RegisterElement(@oXbp, .t.,,,)

   oXbp := XbpRadiobutton():new( oXbp4, , {24,316}, {168,24} )
   oXbp:caption := "Backup zurückladen"
   oXbp:selection := .f.
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:selected := {|| NIL }
   oDlg:RegisterElement(@oXbp, .t.,,,)

   oXbp := XbpRadiobutton():new( oXbp4, , {24,292}, {168,24} )
   oXbp:caption := "Backup auf FTP erstellen"
   oXbp:selection := .f.
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:selected := {|| NIL }
   iif( BackupToFTPallowed == "1" , oXbp:Enable() , oXbp:Disable() )
   oDlg:RegisterElement(@oXbp, .t.,,,)

   oXbp := XbpRadiobutton():new( oXbp4, , {24,268}, {168,24} )
   oXbp:caption := "Backup von FTP zurückladen"
   oXbp:selection := .f.
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:selected := {|| NIL }
   oDlg:RegisterElement(@oXbp, .t.,,,)


   oXbp1 := XbpStatic():new( drawingArea, , {24,48}, {264,384} )
   oXbp1:caption := "Gruppe"
   oXbp1:clipSiblings := .T.
   oXbp1:type := XBPSTATIC_TYPE_RAISEDBOX
   oXbp1:create()

   * Button 1
   oXbp := XbpPushButton():new( oXbp1, , {12,336}, {240,36}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Neu Indexieren"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := { | uNIL1, uNIL2, oPb| oDlg:SetView(oPb), oDlg:ReorgIndex(), oDlg:ResetView()  }
   oDlg:RegisterElement(@oXbp, .t.,,,)

   * Button 2
   oXbp := XbpPushButton():new( oXbp1, , {12,300}, {240,36}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Daten rekonstruieren"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {| uNIL1, uNIL2, oPb| oDlg:SetView(oPb), oDlg:PackZlager(), oDlg:ResetView() }
   oDlg:RegisterElement(@oXbp, .t.,,,)

   * Button 3
   oXbp := XbpPushButton():new( oXbp1, , {12,264}, {240,36}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Mutationsliste löschen"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {| uNIL1, uNIL2, oPb| oDlg:SetView(oPb),  oDlg:ClearLog(), oDlg:ResetView() }
   oDlg:RegisterElement(@oXbp, .t.,,,)

   * Button 4
   oXbp := XbpPushButton():new( oXbp1, , {12,228}, {240,36}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Datensicherung"
   oXbp:tabStop := .T.
   oXbp:create()
*  oXbp:activate := {|| SaveData("ZData.LST", "ZData.Zip") }
   oXbp:activate := {| uNIL1, uNIL2, oPb| oDlg:SetView(oPb), oXbp4:Show() }
   oDlg:RegisterElement(@oXbp, .t.,,,)

   * Button 5
   oXbp := XbpPushButton():new( oXbp2, , { oXbp2:CurrentSize()[1] - 96 , 12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Beenden"
   oXbp:tabStop := .F.
   oXbp:create()
   oXbp:activate := {|| oXbp2:Hide(), oDlg:ResetView()}
   oDlg:RegisterElement(@oXbp, .t.,,,)

   * Button 6
   oXbp := XbpPushButton():new( oXbp2, , {12 , 12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Einlesen"
   oXbp:tabStop := .F.
   oXbp:create()
   oXbp:activate := {|| oDlg:SelectKreFile(oDlg:aListbox[1]), oXbp2:Hide(), oDlg:ResetView() }
   oDlg:RegisterElement(@oXbp, .t.,,,)

   *History
   * Button 7
   oXbp := XbpPushButton():new( oXbp3, , { oXbp3:CurrentSize()[1] - 96 , 12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Beenden"
   oXbp:tabStop := .F.
   oXbp:create()
   oXbp:activate := {|| oXbp3:Hide(), oDlg:ResetView()}
   oDlg:RegisterElement(@oXbp, .t.,,,)

   * Button 8
   oXbp := XbpPushButton():new( oXbp3, , {12 , 12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Einlesen"
   oXbp:tabStop := .F.
   oXbp:create()
   oXbp:activate := {|| oDlg:SelectHisFile(oDlg:aListbox[2]), oXbp3:Hide(), oDlg:ResetView() }
   oDlg:RegisterElement(@oXbp, .t.,,,)

   *Backup
   * Button 9
   oXbp := XbpPushButton():new( oXbp4, , {12 , 12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Ausführen"
   oXbp:tabStop := .F.
   oXbp:create()
   oXbp:activate := {|| oDlg:ExecBackup(), oXbp4:Hide(), oDlg:ResetView() }
   oDlg:RegisterElement(@oXbp, .t.,,,)

   * Button 10
   oXbp := XbpPushButton():new( oXbp4, , { 264 - 96 , 12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Beenden"
   oXbp:tabStop := .F.
   oXbp:create()
   oXbp:activate := {|| oXbp4:Hide(), oDlg:ResetView() }
   oDlg:RegisterElement(@oXbp, .t.,,,)

   * Button 11
   oXbp := XbpPushButton():new( drawingArea, , { aSize[1] - 96 , 12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Beenden"
   oXbp:tabStop := .F.
   oXbp:create()
   oXbp:activate := {|| PostAppEvent(xbeP_Close,,,oDlg)}
   oDlg:RegisterElement(@oXbp, .t.,,,)


   oDlg:Show()
   oDlg:Startup :=  .f.

   SetAppFocus( oDlg )

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

*  oDlg:Close()
*  ReorgActive     := .f.

  RETURN


METHOD Reorg:ExecBackup()
*------------------------
LOCAL aSize := {0,0}
LOCAL aPos  := {0,0}
LOCAL oDlg
LOCAL oStatic
LOCAL oDlg1  := XbpFiledialog():New()
LOCAL cFile  := ""
LOCAL nHandle

   aSize    := AppDesktop():currentSize()

   aPos[1]  := (aSize[1] - 400) / 2   && {330,345}
   aPos[2]  := (aSize[2] - 100) / 2   && {330,345}

   aSize := {400,100}

   oDlg := xbpDialog():new( AppDesktop(),SELF , aPos, aSize, , .F.)
   oDlg:taskList := .T.
   oDlg:title := "Datensicherung"
   oDlg:create()

   oDlg:setModalState( XBP_DISP_APPMODAL )

   oStatic := XbpStatic():new(oDlg:drawingArea, ,{18,40}, {400,20} )
   oStatic:type := XBPSTATIC_TYPE_TEXT
   oStatic:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_LEFT
   oStatic:caption := ""
   oStatic:create()


Do Case
   Case ::aRadioButtons[1]:GetData()
      oStatic:SetCaption("Erstellen der Datensicherung läuft...")
      oDlg:Show()
      SetAppFocus( oDlg )
      SaveData("MGAllData.LST", "MGAllData.Zip")
      oDlg:Destroy()

   Case ::aRadioButtons[2]:GetData()
      oDlg1:Title := "Datensicherungssatz auswählen"
      oDlg1:Create()
      oDlg1:defExtension := "zip"
      oDlg1:fileFilters         := { {"Backup Datenfile", "*.zip"} }

      cFile := oDlg1:Open( DiscDrive + "*.zip" )

      if !cFile == NIL
         oStatic:SetCaption("Zurückladen der Datensicherung läuft...")
         oDlg:Show()
         SetAppFocus( oDlg )
         if RestoreData( cFile )
            ::ReorgIndex()
            ZAdminTask("FreeLogAuto")
         endif

      endif
      oDlg1:Destroy()
      oDlg:Destroy()

   Case ::aRadioButtons[3]:GetData()
      oStatic:SetCaption("Erstellen der Datensicherung auf FTP läuft...")
      oDlg:Show()
      SetAppFocus( oDlg )
      BackupToFTP()
      oDlg:Destroy()

   Case ::aRadioButtons[4]:GetData()
      oStatic:SetCaption("Zurückladen der Datensicherung von FTP läuft...")
      oDlg:Show()
      SetAppFocus( oDlg )

      if RestoreFromFTP()
         ::ReorgIndex()
         ZAdminTask("FreeLogAuto")
      endif

      oDlg:Destroy()

   Endcase
Return

METHOD Reorg:SetView(oButton)
*------------------------------
LOCAL i
LOCAL nButton
nButton := AScan( ::aButtons, oButton)
::AbleButtons( {nButton}, {1,2,3,4} )
::AbleButtons( {nButton}, {} )
RETURN

METHOD Reorg:ResetView()
*------------------------------
::AbleButtons( {1,2,3,4}, {} )
RETURN


METHOD Reorg:ReorgIndex()
*-------------------
   LOCAL nEvent, mp1, mp2
   LOCAL oDlg
   LOCAL cAlias
   LOCAL nIndex
   LOCAL oDraw
   LOCAL oStatic
   LOCAL cDataDr := DataDrive
   LOCAL cDbName
   LOCAL aIndex
   LOCAL aKey
   LOCAL test := .f.
   LOCAL i, n
   LOCAL Wa
   LOCAL aSize
   LOCAL aPos := {,}
   LOCAL cClient     := ""

   nIndex := 1

   *if !UniqueTask(@cClient)
   *   MsgBox("Für die neu Indexierung müsssen alle Anwendungen auf allen Arbeitsstationen geschlossen sein", "Task offen auf " + cClient )
   *   Return
   *endif

   if !SysDbRequest()
      Return
   endif
   Select( SysAlias() )
   DbCloseArea()

   aSize    := AppDesktop():currentSize()

   aPos[1]  := (aSize[1] - 400) / 2   && {330,345}
   aPos[2]  := (aSize[2] - 100) / 2   && {330,345}

   aSize := {400,100}

   oDlg := xbpDialog():new( AppDesktop(),SELF , aPos, aSize, , .F.)
   oDlg:taskList := .T.
   oDlg:title := "Indexierung"
   oDlg:create()

   oDlg:setModalState( XBP_DISP_APPMODAL )

   oStatic := XbpStatic():new(oDlg:drawingArea, ,{18,40}, {400,20} )
   oStatic:type := XBPSTATIC_TYPE_TEXT
   oStatic:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_LEFT
   oStatic:caption := ""
   oStatic:create()



   oDlg:Show()


   SetAppFocus( oDlg )
   * Standard DB's
   for i := 1 to len(::aFileList)
      cDbName := ::aFileList[i][1]
      aIndex  := ::aFileList[i][2]
      aKey    := ::aFileList[i][3]

      For n := 1 to len(aIndex)
          FErase(DataDrive + aIndex[n])
      Next

      oStatic:SetCaption(  "Indexierung von " + cDbName )
      DbUseArea( .t. ,  , cDataDr+cDbName , , .t. , .f. )
      Wa := Select()
      if NetErr()
         MsgBox("Die Datei " + cDataDr+cDbName + " kann nicht geöffnet werden" )
         Break()
      Endif

      cAlias := Alias()
      For nIndex := 1 to len(aIndex)
         if !File(cDataDr + aIndex[nIndex] )
            oStatic:Setcaption("Indexierung von " + cDbName + " nach " + aKey[nIndex] )
            NewIndex(oDlg, cDataDr, cAlias, aIndex[nIndex], aKey[nIndex])
         Endif
      next
      OrdListClear()
      DbCloseArea()
   Next

   *Externe DB's
   cDataDr := ImportDrive
   for i := 1 to len(::aArtFiles)
      cDbName := ::aArtFiles[i][2]
      aIndex  := ::aArtFiles[i][3]
      aKey    := ::aArtFiles[i][4]

      For n := 1 to len(aIndex)
          FErase(ImportDrive + aIndex[n])
      Next

      oStatic:SetCaption(  "Indexierung von " + cDbName )
      DbUseArea( .t. ,  , cDataDr+cDbName , , .t. , .f. )
      Wa := Select()
      if NetErr()
         MsgBox("Die Datei " + cDataDr+cDbName + " kann nicht geöffnet werden" )
         Break()
      Endif

      cAlias := Alias()
      For nIndex := 1 to len(aIndex)
         if !File(cDataDr + aIndex[nIndex] )
            oStatic:Setcaption("Indexierung von " + cDbName + " nach " + aKey[nIndex] )
            NewIndex(oDlg, cDataDr, cAlias, aIndex[nIndex], aKey[nIndex])
         Endif
      next
      OrdListClear()
      DbCloseArea()
   Next
   OpenDb(DataDrive, SystemFile, SystemIndex, SystemKey, .t., .f.)
   SysAlias( Select() )
   DbRelease( SysAlias() )

   oDlg:setModalState( XBP_DISP_MODELESS )
   oDlg:Destroy()
   RETURN


METHOD Reorg:PackZlager()
*-------------------
   LOCAL nEvent, mp1, mp2
   LOCAL oDlg
   LOCAL cAlias
   LOCAL nIndex
   LOCAL oDraw
   LOCAL oStatic
   LOCAL cDataDr := DataDrive
   LOCAL cDbName
   LOCAL cBtName
   LOCAL aIndex
   LOCAL aKey
   LOCAL test := .f.
   LOCAL i, n
   LOCAL Wa
   LOCAL aSize
   LOCAL aPos := {,}
   LOCAL oProgress

   nIndex := 1

   if WinMenu():Items( ) > 1
      MsgBox("Für die Reorganisation müsssen alle Fenster geschlossen sein", "Reindex" )
      Return
   Endif

   if !SysDbRequest()
      Return
   endif
   Select( SysAlias() )
   DbCloseArea()

   aSize    := AppDesktop():currentSize()

   aPos[1]  := (aSize[1] - 400) / 2   && {330,345}
   aPos[2]  := (aSize[2] - 100) / 2   && {330,345}

   aSize := {400,100}



   oDlg := xbpDialog():new( AppDesktop(),SELF , aPos, aSize, , .F.)
   oDlg:taskList := .F.
   oDlg:title := "Reorganisation Daten"
   oDlg:create()

   oStatic := XbpStatic():new(oDlg:drawingArea, ,{18,40}, {400,20} )
   oStatic:type := XBPSTATIC_TYPE_TEXT
   oStatic:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_LEFT
   oStatic:caption := ""
   oStatic:create()

   oProgress         := ProgressBar():new( oDlg:drawingArea,, {12,10},  {367, 12})
   oProgress:create()
   oProgress:minimum := 1
   oProgress:maximum := 1 &&Lastrec()
   oProgress:color   := GRA_CLR_BLUE

   oDlg:Show()

   SetAppFocus( oDlg )

   oDlg:setModalState( XBP_DISP_APPMODAL )


   for i := 1 to len(::aFileList)
      oDlg:Show()
      cDbName := ::aFileList[i][1]
      cBtName := subs(cDbName, 1, At(".", cDbName)-1) + ".DBT"
      aIndex  := ::aFileList[i][2]
      aKey    := ::aFileList[i][3]

      For n := 1 to len(aIndex)
          FErase(DataDrive + aIndex[n])
      Next

      oStatic:SetCaption(  "Packen von " + cDbName )
      * Exclusive öffnen
      DbUseArea( .t. ,  , cDataDr+cDbName , , .f. , .f. )
      oProgress:maximum := Lastrec()

      Wa := Select()
      if NetErr()
         MsgBox("Die Datei " + cDataDr+cDbName + " kann nicht geöffnet werden" )
         Break()
      Endif

      DbGoTop()

      DbExport( DataDrive + "$"+cDbName,,{|| oProgress:increment(), .t. } )

      DbCloseArea()

      FRename( DataDrive + cDbName, AusWertDrive + "rTemp.bak" )
      FRename( DataDrive + cBtName, AusWertDrive + "rTemp.tbk" )

      if !FRename( DataDrive + "$"+cDbName, DataDrive + cDbName ) == -1
         FErase( AusWertDrive + "rTemp.bak" )
      else
         MsgBox("Fehler in der Reorganisation, " + DataDrive + "$" + cDbName + " jetzt manuell sichern","FRename()")
      Endif

      FRename( DataDrive + "$"+cBtName, DataDrive + cBtName )
      FErase( AusWertDrive + "rTemp.tbk" )

      DbUseArea( .t. ,  , cDataDr+cDbName , , .f. , .f. )

      cAlias := Alias()
      For nIndex := 1 to len(aIndex)
         if !File(cDataDr + aIndex[nIndex] )
            oStatic:Setcaption("Indexierung von " + cDbName + " nach " + aKey[nIndex] )
            NewIndex(oDlg, cDataDr, cAlias, aIndex[nIndex], aKey[nIndex])
            SetAppFocus( oDlg )
         Endif
      next
      OrdListClear()
      DbCloseArea()

   Next

   OpenDb(DataDrive, SystemFile, SystemIndex, SystemKey, .t., .f.)
   SysAlias( Select() )
   DbRelease( SysAlias() )

   oProgress:Destroy()
   oDlg:setModalState( XBP_DISP_MODELESS )
   oDlg:Destroy()
   RETURN


FUNCTION SaveData(LSTFile, SaveFile, FTP)
*---------------------------------------
*LOCAL SaveFile       := "Zdata.Zip"
*LOCAL LSTFile        := "zData.Lst"
LOCAL ZipProgram     := MainDrive + "7Za.Exe"
*LOCAL ZipProgram     := "7Za.Exe"
LOCAL SaveDir        := dtos( date() )
LOCAL ComandLine     := ' a -tZip "' + MainDrive + SaveFile + '" "@' + MainDrive + LSTFile + '"'
LOCAL WinMainDrive   := Subs( MainDrive, 1, len( Alltrim(MainDrive) ) -1 )
LOCAL ActDrive       := CurDir()
LOCAL TargetDrive    := DiscDrive
LOCAL aSaveFileHist  := {}
LOCAL SaveFileHName  := iif( Rat(".", SaveFile) >0, Left(SaveFile, Rat(".", SaveFile)-1 ), SaveFile )
LOCAL i              := 1

For i := 1 to 7
   AAdd( aSaveFileHist, SaveFileHName + Str(i,1)+ ".zip")
next

if FTP == NIL
   FTP := .f.
endif

if FTP
   TargetDrive    := AuswertDrive
endif

if !FTP
   if  !IsDriveReady( Subs(DiscDrive,1,1) )
      Return .f.
   Endif
Endif

CurDir( WinMainDrive )

if File(ZipProgram)
   *CreateDir( DiscDrive + SaveDir)

   if !FTP
      SysDbRequest()
      Select( SysAlias() )
      DbCloseArea()
   Endif

   RunShell( ComandLine, ZipProgram, .f., .t. )

   if !FTP
      OpenDb(DataDrive, SystemFile, SystemIndex, SystemKey, .t., .f.)
      SysAlias( Select() )
      DbRelease( SysAlias() )
   Endif

   if File( MainDrive + SaveFile )
      ERASE ( TargetDrive + SaveFile )
      ERASE ( TargetDrive + aSaveFileHist[Dow(Date())])
      if FRename( MainDrive + SaveFile, TargetDrive + SaveFile ) == 0
         COPY FILE (TargetDrive + SaveFile) TO (TargetDrive + aSaveFileHist[Dow(Date())])
         *ERASE ( MainDrive + "ZSave.7z" )
         if !FTP
            MsgBox( "Datensicherung erfolgreich. " + SaveFile + " in " + TargetDrive + " erstellt." , "SaveData()" )
         endif
      else
         MsgBox( "Datensicherung fehlgeschlagen. Auf Laufwerk " + TargetDrive + " konnte nicht geschrieben werden." , "SaveData()" )
         Return .f.
      endif
   else
      MsgBox( "Datensicherung fehlgeschlagen.", "SaveData()" )
      Return .f.
   endif
else
   MsgBox("Das Sicherungsprogramm fehlt","SaveData()")
   Return .f.
Endif

Return .t.



FUNCTION RestoreData(SaveFile)
*-------------------------------------------
LOCAL ZipProgram     := MainDrive + "7Za.Exe"
LOCAL SaveDir        := dtos( date() )
LOCAL ComandLine     := ' x -yr "' + SaveFile + '" " -o' + MainDrive + '" *.* -x!*.CTR'
LOCAL WinMainDrive   := Subs( MainDrive, 1, len( Alltrim(MainDrive) ) -1 )
LOCAL ActDrive       := CurDir()
LOCAL aDirectory
LOCAL i

CurDir( WinMainDrive )

if File(ZipProgram)

   SysDbRequest()
   Select( SysAlias() )
   DbCloseArea()

   RunShell( ComandLine, ZipProgram, .f., .t. )

   OpenDb(DataDrive, SystemFile, SystemIndex, SystemKey, .t., .f.)
   SysAlias( Select() )
   DbRelease( SysAlias() )


   aDirectory := Directory(MainDrive + "*.NTX")
   aEval( aDirectory, { |a| FErase( MainDrive + a[ F_NAME ] ) } )

   aDirectory := Directory(DataDrive + "*.NTX")
   aEval( aDirectory, { |a| FErase( DataDrive + a[ F_NAME ] ) } )

   aDirectory := Directory(ImportDrive + "*.NTX")
   aEval( aDirectory, { |a| FErase( ImportDrive + a[ F_NAME ] ) } )

   aDirectory := Directory(InventarDrive + "*.NTX")
   aEval( aDirectory, { |a| FErase( InventarDrive + a[ F_NAME ] ) } )

   aDirectory := Directory(AuswertDrive + "*.NTX")
   aEval( aDirectory, { |a| FErase( AuswertDrive + a[ F_NAME ] ) } )

   aDirectory := Directory(DataDrive + "*.DB?")
   for i := 1 to len( aDirectory )
      if file( RemoteDrive + aDirectory[i][ F_NAME ] )
         COPY FILE (RemoteDrive + aDirectory[i][ F_NAME ]) TO (DataDrive + aDirectory[i][ F_NAME ])
       endif
   next
   aDirectory := Directory(RemoteDrive + "*.DB?")
   aEval( aDirectory, { |a| FErase( RemoteDrive + a[ F_NAME ] ) } )
else
   MsgBox("Das Restoreprogramm fehlt","RestoreData()")
   Return .f.
Endif

Return .t.





METHOD Reorg:ClearLog()
*----------------------

LOCAL LogWa
LOCAL cDbName := ::aFileList[2][1]
LOCAL aIndex  := ::aFileList[2][2]
LOCAL aKey    := ::aFileList[2][3]
LOCAL n

if WinMenu():Items( ) > 1
   MsgBox("Für die Reorganisation müsssen alle Fenster geschlossen sein", "Reindex" )
   Return
Endif

For n := 1 to len(aIndex)
   FErase(DataDrive + aIndex[n])
Next

DbUseArea( .t. ,  , DataDrive+cDbName , , .f. , .f. )
LogWa := Select()

If FileLock(LogWa)
   DbZap()
   DbUnlock()
Endif
DbCloseArea()

MsgBox("Log File gelöscht.", "Reorg:ClearLog()" )

Return