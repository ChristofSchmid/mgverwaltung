DH   ³#PRINTER # #hp psc 2110# #A4# #hoch#
DH   ³#PUBLIC  # #MG     := 0   # #MG := MG + 1 #
DH   ³#PUBLIC  # #M      := ""  # #M  := Str(MG,3,0) #
DF   ³#FONT    # #F1            # #Arial# #10# #bold# #normal# #normal#
DF   ³#FONT    # #F2            # #Arial# #10# #normal# #normal# #normal#
DF   ³#FONT    # #F3            # #Arial# #12# #bold#  #normal# #normal#
DF   ³#FONT    # #F4            # #Courier New# #8# #normal# #normal# #normal#
DF   ³#FONT    # #F5            # #Courier New# #8# #bold# #normal# #normal#
DF   ³#FONT    # #F6            # #Courier New# #7# #normal# #normal# #kursiv#

DH   ³#TABELLE # #Anr     := "  " # #GetTabText('010',Anrede) #
DH   ³#TABELLE # #KGR     := "  " # #GetTabText('017',KGR) #
DH   ³#TABELLE # #DEBART  := "  " # #GetTabText('014',DEBART) #

K    ³
K    ³
KF3  ³     Neue Mitglieder laufendes Jahr und Vorjahr  #FAbsZ1                  #
KF3  ³     #Date    #
KF3  ³     #cFilter                                                                        #
K    ³
K    ³
KF1  ³      GU Nr     Anrede                                               Mitglieder Gruppe                         Status
KF1  ³               Name                                                Telefon                                            Eintritt  
KF1  ³               Strasse                                              Natel                                               Geburtstag 
KF1  ³               Plz  Ort                                              EMail  
K    ³
HF2  ³      #DEBNr #  #Anr                            #   #KGR                            #  #DebArt                #
HF2  ³                #Name                           #   #TEL                            #  #DebEDat # 
HF2  ³                #Strasse                        #   #NATEL                          #  #DebGDat #
HF2  ³                #Ort                            #   #EMail                          #
H    ³
F    ³
F    ³
F    ³
F    ³
FF3  ³     Seite #PA#
F    ³ 
EF3  ³      Seite #PA#       Total gelistet #M#