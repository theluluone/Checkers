VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Feuil1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit                             '/// Toutes les variables doivent �tre d�clar�es
Option Base 0                               '/// Les Arrays comment � "0"



'/// PROC�DURE  : Se d�clenche lorsqu'un double clic survient sur la feuille et transmet en param�tre la range de la cellule cliqu�e
'/// PARAM�TRE  : Range, Boolean
'/// RETOUR     : Aucun (�v�nement)
Private Sub Worksheet_BeforeDoubleClick(ByVal pTarget As Range, pCancel As Boolean)
Dim board As BoardModel
Dim pawn As PawnModel
Dim enemyPawn As PawnModel
Dim ysnp As YouShallNotPassModel
Dim deamonReapled As Integer
Dim turnCount As Integer
Dim validLap As Boolean

    'Si Cancel a sa valeur par d�faut ou �gal � False, alors apr�s la fin de cette proc�dure,
    'Excel va continuer en traitant le clic droit comme il le fait par d�faut.
    
    'Si Cancel est � True, alors Excel ne va pas faire son traitement habituel,
    'Excel consid�re que l��v�nement du clic droit est enti�rement pris en charge par la proc�dure.
    pCancel = True
    
    'on instancie un objet correspondant � notre plateau de jeu
    Set board = New BoardModel
   
    'repr�sente le compteur d'erreurs effectu�es par le bot
    deamonReapled = 0

    'selon la section dans laquelle on a cliqu�
    Select Case board.GetSection(pTarget)
    
        'si on a cliqu� sur le damier
        Case ESection.Game
        
            'selon la valeur actuelle de configuration de la partie
            Select Case board.ConfigPlayer
            
                'si en mode 2 joueurs
                Case EConfig.TwoPlayers
                    
                    'si l'action correspond au mouvement d'un pion
                    If Player.Run(pTarget) Then
                    
                        'v�rifie s'il y a un vainqueur
                        Call board.SearchWinner

                        'change la couleur afficher sur le plateau
                        Call board.SwitchTurn
                    
                    End If
                    
                'si en mode 1 joueur
                Case EConfig.SinglePlayer
                
                    'si l'action correspond au mouvement d'un pion
                    If Player.Run(pTarget) Then
                        Call board.SearchWinner
                        Call board.SwitchTurn
                        
                        's'il n'y a pas de vainqueur
                        If Not board.IsWinner Then
                            
                            'on appel le bot
                            Call BotManager.Run(board.TurnColor)

                            'v�rifie s'il y a un vainqueur
                            Call board.SearchWinner
                            
                            'change la couleur afficher sur le plateau
                            Call board.SwitchTurn
                                    
                        End If
                    End If
                
                'si en mode IA vs IA
                Case EConfig.Automate
                    
                    turnCount = 0
                    
                    'tant qu'il n'y a pas de vainqueur et qu'on a jou� moins de 300 tours
                    While Not board.IsWinner And turnCount < 300 And deamonReapled < 3
                    
                        Call BotManager.Run(board.TurnColor)
                        Call board.SearchWinner
                        Call board.SwitchTurn
                        
                    Wend
                    
                    
            End Select
            
            If deamonReapled = 3 Then
                MsgBox "Bot Failed"
            End If
                
        'cas de clic sur la configuration des joueurs, on incr�mente la configuration
        Case ESection.ConfigPlayer
        
            'on incr�mente le type de partie dans l'ordre -> 1joueurs, 2joueurs, ia vs ia
            If board.ConfigPlayer = EConfig.SinglePlayer Then
                board.ConfigPlayer = EConfig.TwoPlayers
            ElseIf board.ConfigPlayer = EConfig.TwoPlayers Then
                board.ConfigPlayer = EConfig.Automate
            Else
                board.ConfigPlayer = EConfig.SinglePlayer
            End If
        
        'cas de clic sur le bouton restart
        Case ESection.Restart
            'formate le plateau de jeux sur la feuille Excel
            Call board.FormatBoard
            'initialise les pions � leur position de d�part
            Call board.Initialisation
            
    End Select
End Sub
