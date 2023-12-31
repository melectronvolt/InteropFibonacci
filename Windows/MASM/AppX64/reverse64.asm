.code
; Commence la section de code.

; Début de la procédure 'Reverser' pour l'architecture x64.
Reverser proc
        push rbp
        ; Sauvegarde la valeur courante du pointeur de base (Base Pointer, BP) sur la pile.
        mov rbp, rsp
        ; Établit le pointeur de base pour la procédure courante. `rsp` est le pointeur de pile (Stack Pointer).
        push rsi
        ; Sauvegarde `rsi` (utilisé pour les index de source dans les opérations de chaîne) sur la pile.
        push rdi
        ; Sauvegarde `rdi` (utilisé pour les index de destination dans les opérations de chaîne) sur la pile.
        xor rax, rax
        ; Met `rax` à zéro. Utilisé pour initialiser ou effacer un registre.
        mov rdi, rcx
        ; Charge le premier paramètre (pointeur de source) dans `rdi`. Dans x64, les paramètres sont passés via les registres.
        mov rsi, rdx
        ; Charge le deuxième paramètre (pointeur de destination) dans `rsi`.
        mov rcx, r8
        ; Charge le troisième paramètre (nombre d'éléments) dans `rcx`.
        test rcx, rcx
        ; Vérifie si `rcx` est zéro (pour décider si la boucle doit être exécutée).
        lea rsi, [rsi + rcx*4 - 4]
        ; Calcule l'adresse du dernier élément du tableau source à lire.
        pushfq
        ; Sauvegarde les drapeaux d'état actuels sur la pile.
        std
        ; Active le mode de décrémentation pour les instructions de chaîne (lodsd).

@@:    lodsd
        ; Charge la valeur 32 bits à l'adresse pointée par `rsi` dans `eax`, puis incrémente `rsi`.
        mov [rdi], eax
        ; Stocke la valeur de `eax` à l'adresse pointée par `rdi`.
        add rdi, 4
        ; Incrémente `rdi` pour pointer vers l'emplacement de stockage suivant.
        dec rcx
        ; Décrémente `rcx` (le compteur du nombre d'éléments).
        jnz @B
        ; Si `rcx` n'est pas zéro, saute en arrière pour continuer la boucle.
        popfq
        ; Restaure les drapeaux d'état à partir de la pile.
        mov rax, 1
        ; Place la valeur de retour (1) dans `rax`.
        pop rdi
        ; Restaure la valeur originale de `rdi`.
        pop rsi
        ; Restaure la valeur originale de `rsi`.
        pop rbp
        ; Restaure la valeur originale de `rbp`.
        ret
        ; Retourne de la procédure, en utilisant `rbp` pour restaurer `rsp` et en sautant à l'adresse de retour sauvegardée.

Reverser endp
; Marque la fin de la procédure `Reverser`.

end
; Indique la fin du fichier source.
