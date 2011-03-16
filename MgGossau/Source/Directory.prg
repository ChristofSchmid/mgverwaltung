#include "Directry.ch"
#include "Gra.ch"
#include "Xbp.ch"
#include "Appevent.ch"
#include "Font.ch"
#include "Error.ch"


CLASS DirDialog from XbpDialog
   EXPORTED:
      VAR aDrives
      VAR aDir
      VAR StartDir
      VAR StartDrive
      VAR LastDir
      VAR LastDrive
      VAR CurrDir
      VAR CurrDrive
      VAR oComboBox
      VAR oListBox
      VAR aChildList
      VAR oOwner
      VAR DirSelected
      VAR windowMenu

      METHOD Create
      METHOD display
      METHOD LoadDir
      METHOD UpDir
      METHOD InDir
      METHOD SelectDir
      METHOD ShowDir
      METHOD Close
      METHOD LoadDrives
      METHOD ChangeDrive

   ENDCLASS


METHOD DirDialog:create( oParent, oOwner , ;
                          aPos   , aSize  , ;
                          aPParam, lVisible )
   ::XbpDialog:create( oParent, oOwner , ;
                       aPos   , aSize  , ;
                       aPParam, lVisible )

      ::aDrives     := {}
      ::aDir        := {}
      ::StartDir    := ""
      ::StartDrive  := ""
      ::LastDir     := 0
      ::LastDrive   := 1
      ::CurrDir     := 0
      ::CurrDrive   := "C"
      ::oComboBox   := NIL
      ::oListBox    := NIL
      ::aChildList  := NIL
      ::oOwner      := NIL
      ::DirSelected := ""

RETURN self


METHOD DirDialog:Close()
   ::setModalState( XBP_DISP_MODELESS )
   SetAppFocus(::oOwner)
   ::Destroy()
RETURN Self



METHOD DirDialog:Display(DrawingArea)
*-------------------------
  LOCAL nEvent, mp1, mp2
   LOCAL oXbp

   oXbp := XbpCombobox():new( drawingArea, , {12,204}, {300,132}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabstop := .T.
   oXbp:type := XBPCOMBO_DROPDOWNLIST
   oXbp:itemSelected := {| uNIL1, uNIL2, obj | ::ChangeDrive( Subs( obj:getItem( obj:getData()[1] ),1,1 )  ) }
   oXbp:create()
   ::oComboBox := oXbp

   oXbp := XbpListBox():new( drawingArea, , {12,48}, {336,252}, { { XBP_PP_BGCLR, XBPSYSCLR_ENTRYFIELD } } )
   oXbp:tabStop := .T.
   oXbp:itemSelected := {| uNIL1, uNIL2, obj | ::LoadDir( obj:getItem( obj:getData()[1] ) ), ::ShowDir() }
   oXbp:itemMarked   := {| uNIL1, uNIL2, obj | ::ShowDir() }
   oXbp:create()
   ::oListBox := oXbp

   oXbp := XbpPushButton():new( drawingArea, , {324,312}, {24,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Up"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| ::UpDir() }

   oXbp := XbpPushButton():new( drawingArea, , {12,12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Auswählen"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| ::SelectDir(1), PostAppEvent(xbeP_Close,,,SELF) }

   oXbp := XbpPushButton():new( drawingArea, , {264,12}, {84,24}, { { XBP_PP_BGCLR, XBPSYSCLR_BUTTONMIDDLE }, { XBP_PP_FGCLR, -58 } } )
   oXbp:caption := "Abbrechen"
   oXbp:tabStop := .T.
   oXbp:create()
   oXbp:activate := {|| ::SelectDir(0), PostAppEvent(xbeP_Close,,,SELF) }

RETURN


METHOD DirDialog:LoadDir(Dir)
*----------------------------
LOCAL CurDir
LOCAL aDir
LOCAL i
LOCAL XDir   := {}

CurDir := CurDir( Dir )
aDir   := Directory( "*" , "D" )

For i := 1 to len( aDir)
   if "D" $ aDir[i][F_ATTR]
      if ! Alltrim( aDir[i][F_NAME] ) ==  "."
         aAdd(xDir, aDir[i])
      endif
   endif
next

ASort( xDir,,, {|aX,aY| upper( aX[1] ) < Upper( aY[1] ) } )

::CurrDir := xDir
::oListBox:Clear()
for i := 1 to len(::CurrDir)
   ::oListbox:AddItem( ::CurrDir[i][F_NAME])
NEXT
if ::oListBox:NumItems() > 0
   ::oListBox:SetData( {1} )
else
   ::oListbox:AddItem( " ")
   ::oListBox:SetData( {1} )
Endif
RETURN


METHOD DirDialog:ChangeDrive(Drive)
*-----------------------------
LOCAL OldFocus := SetAppFocus()
LOCAL OldDrive := CurDrive()
if !IsDriveReady(Drive)
   SetAppFocus(OldFocus)
   ::oComboBox:SetData( {::LastDrive} )
   ::CurrDrive := Subs( ::oComboBox:getItem( ::oComboBox:getData()[1] ),1,1 )
   CurDrive(::CurrDrive)
   ::LoadDir(::CurrDrive)
   ::ShowDir()
   Return
endif

::LastDrive := ::oComboBox:getData()[1]
::CurrDrive := Drive
CurDrive(::CurrDrive)

*CurDir := CurDir()
::LoadDir(::CurrDrive)
::ShowDir()
Return


METHOD DirDialog:UpDir()

RETURN


METHOD DirDialog:InDir()

RETURN


METHOD DirDialog:SelectDir( nMode )
*---------------------------
Do Case
   Case nMode == 1
   ::DirSelected := ::getTitle()
   Case nMode == 0
   ::DirSelected := ""
Endcase
RETURN


METHOD DirDialog:ShowDir()
*---------------------------
LOCAL CurDir := CurDir()
LOCAL SelDir := ::oListBox:getItem( ::oListBox:getData()[1] )
LOCAL cTitle

if Len(CurDir) > 0
   CurDir := "\" + CurDir
Endif

if ! Alltrim( SelDir ) == ".."
   SelDir := "\" + SelDir
else
   SelDir := Space(0)
Endif

cTitle := CurDrive()+ ":" + CurDir + SelDir
cTitle := Alltrim( cTitle )
::SetTitle(cTitle )

RETURN


METHOD DirDialog:LoadDrives( inDrive )
*------------------------------------
LOCAL i, n
LOCAL aDrive
LOCAL cDrive
LOCAL nExist    := .t.
LOCAL nReady    := .t.

LOCAL cOldDrive := CurDrive()       // Aktuelles Laufwerk merken
LOCAL bError    := ErrorBlock( {|e| Break(e) } )
LOCAL oError

For i := 1 to 27
   cDrive := Chr(64 + i)
   nExist   := .t.
   nReady   := .t.

      BEGIN SEQUENCE

         CurDrive( cDrive )               // Laufwerk ändern
         CurDir( cDrive )                 // Verzeichnis abfragen

      RECOVER USING oError                // Fehler ist aufgetreten

         IF oError:osCode == 21 &&DRIVE_NOT_READY
             nExist := .t.                 //
             nReady := .f.                 // Laufwerk nicht bereit
         ELSE
             nExist := .f.                 // Laufwerk nicht vorhanden
             nReady := .f.                 // Laufwerk nicht bereit
         ENDIF

      ENDSEQUENCE

   if nReady
      aDrive := Directory( cDrive, "V" )
      aAdd( ::aDrives, {cDrive, aDrive[1][F_NAME]} )
      ::oComboBox:Additem( cDrive + " " + aDrive[1][F_NAME] )
   endif
   if nExist .and. ! nReady
      aAdd( ::aDrives, {cDrive, "(nicht bereit)"} )
      ::oComboBox:Additem( cDrive + " " + "(nicht bereit)" )
   endif
next

ErrorBlock( bError )                // Fehler-Codeblock und
CurDrive( cOldDrive )               // Laufwerk zurücksetzen

if !inDrive == NIL
   for i:= 1 to ::oCombobox:numItems()
      if ::aDrives[i][1] == InDrive
         ::oComboBox:SetData( {i} )
         ::LastDrive := i
      endif
   next
else
   for i:= 1 to ::oCombobox:numItems()
      if ::aDrives[i][1] == ::CurrDrive
         ::oComboBox:SetData( {i} )
         ::LastDrive := i
      endif
   next
endif

*if ::oCombobox:numItems() > 0
*   ::oComboBox:SetData( {1} )
*   ::CurrDrive := Subs( ::oComboBox:getItem( ::oComboBox:getData()[1] ),1,1 )
*endif

Return





