///////////////////////////////////////////////////////////////////////////////
//
//  FileMgt
//
//
///////////////////////////////////////////////////////////////////////////////

#include "Gra.ch"
#include "Xbp.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "DMLB.ch"

PROCEDURE OpenDb(cDataDr, cDbName, aIndex, aKey, ShareUse, SysCheck)
   LOCAL OldFocus := SetAppFocus()
   LOCAL nEvent, mp1, mp2
   LOCAL oDlg
   LOCAL cAlias
   LOCAL nIndex
   LOCAL oStatic
   LOCAL test := .f.
   LOCAL i
   LOCAL DbNotOpen := .f.
   LOCAL aPos := CenterPos( {400,100}, AppDeskTop():CurrentSize() )
   LOCAL cClient := ""
   ShareUse := iif(ShareUse == NIL, .t., ShareUse)
   SysCheck := iif(SysCheck == NIL, .t., SysCheck)
   nIndex := 1

   oDlg := XbpDialog():new( AppDeskTop(), , aPos, {400,100}, , .F.)
   oDlg:title := "Opening "+cDbName
   oDlg:create()

   oStatic := XbpStatic():new(oDlg:drawingArea, ,{18,40}, {400,20} )
   oStatic:type := XBPSTATIC_TYPE_TEXT
   oStatic:options := XBPSTATIC_TEXT_VCENTER+XBPSTATIC_TEXT_LEFT
   oStatic:caption := "Indexierung von " + cDbName
   oStatic:create()
   SetMousePointer(1)

   *oDlg:Show()
   *SetAppFocus( oDlg )
   if !File( cDataDr+cDbName )
      MsgBox("Die Datei " + cDataDr+cDbName + " ist nicht vorhanden.","OpenErr()" )
      PostAppEvent( xbeP_Close,,,oDlg )
      AppQuit(.f.)
   endif
   for i := 1 to 5
      DbUseArea( .t. ,  , cDataDr+cDbName , , ShareUse , .f. )
      if Alias() == ""
         DbCloseArea()
         MsgBox("Probleme mit dem öffnen von " +cDataDr+cDbName+ " bei Versuch " + Str(i,1,0)+ " von 5","OpenDb()" )
         if i == 5
            DbNotOpen := .t.
         endif
      else
         Exit
      endif
   next

   SetMousePointer(0)
   cAlias := Alias()

   if NetErr()
      MsgBox("Die Datei " + cDataDr+cDbName + " kann nicht geöffnet werden","NetErr()" )
      PostAppEvent( xbeP_Close,,,oDlg )
      Break()
   Endif

   if DbNotOpen
      MsgBox("Die Datei " + cDataDr+cDbName + " kann nicht geöffnet werden","DbNotOpen" )
      PostAppEvent( xbeP_Close,,,oDlg )
      Break()
   Endif

   if File( DataDrive + "MGInReorg.SYS" ) .and. SysCheck
      MsgBox("Während der Reorganisation kann kein Programm gestartet werden.","MGInReorg.SYS" )
      Select( cAlias )
      DbCloseArea()
      PostAppEvent( xbeP_Close,,,oDlg )
      Break()
   Endif

   if File( DataDrive + "ZLagerKasse.SYS" ) .and. SysCheck
      MsgBox("Während die Kasse offen ist kann kein Programm gestartet werden.","ZlagerKasse.SYS" )
      Select( cAlias )
      DbCloseArea()
      PostAppEvent( xbeP_Close,,,oDlg )
      Break()
   Endif

*   if ReorgActive() .and. SysCheck
*      MsgBox("Während der Reorganisation kann kein Programm gestartet werden.","ReorgActive()" )
*      Select( cAlias )
*      DbCloseArea()
*      PostAppEvent( xbeP_Close,,,oDlg )
*      Break()
*   Endif

*   if RegActive() .and. SysCheck
*      MsgBox("Während das Kassenbuch offen ist, kann kein Programm gestartet werden.","RegActive()" )
*      Select( cAlias )
*      DbCloseArea()
*      PostAppEvent( xbeP_Close,,,oDlg )
*      Break()
*   Endif

   Select( cAlias )

   For nIndex := 1 to len(aIndex)
      if !File(cDataDr + aIndex[nIndex] )
         oStatic:Setcaption("Indexierung von " + cDbName + " nach " + aKey[nIndex] )
         NewIndex(oDlg, cDataDr, cAlias, aIndex[nIndex], aKey[nIndex])
      Endif
   next
   OrdListClear()
   For nIndex := 1 to len(aIndex)
      OrdListAdd(cDataDr + aIndex[nIndex], aKey[nIndex])
   next
   OrdSetFocus(1)
   SetAppFocus(OldFocus)
   oDlg:Destroy()
   RETURN


PROCEDURE NewIndex(oDraw, cDataDr, cAlias, cIndex, cKey)
*-------------------------------------------------------
   LOCAL nEvent, mp1, mp2
   LOCAL oProgress, oFrame

   SetMousePointer(1)

   oDraw:Show()
   SetAppFocus( oDraw )

   oFrame      := XbpStatic():new(oDraw:drawingArea, ,{12,10}, {367,12} )
   oFrame:Type := XBPSTATIC_TYPE_RECESSEDRECT
   oFrame:Create()

   oProgress         := ProgressBar():new( oDraw,, {12,10},  {367, 12})
   oProgress:create()
   oProgress:minimum := 1
   oProgress:maximum := Lastrec()
   oProgress:color   := GRA_CLR_BLUE

   OrdCreate(cDataDr + cIndex, ,cKey, {|| oProgress:increment(), &cKey } )

   DO WHILE .t.
      if File(cDataDr + cIndex)
         oFrame:Destroy()
         oProgress:Destroy()
         oDraw:Hide()
         SetMousePointer(0)

         return
      endif
   ENDDO
   oDraw:Hide()
   SetMousePointer(0)
   RETURN
