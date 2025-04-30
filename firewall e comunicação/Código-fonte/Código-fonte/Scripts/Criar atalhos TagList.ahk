requestAdmin()

;===================================================================
;= SUPERVISORIO IFAL PIN, 2024                                     =
;=                                                                 =
;= Este script é livre para uso nos termos da licença GNU GPL 2.   =
;= Para poder executar este script, é necessário usar o software   =
;= AutoHotkey. O AutoHotkey é licenciado sob a licença GNU GPL 2.  =
;= Optou-se por manter o código dos scripts sob a mesma licença do =
;= interpretador para evitar conflitos.                            =
;===================================================================


ProgramFilesX86 := A_ProgramFiles 
if A_IS64bitOS {
    ProgramFilesX86 := StrReplace(ProgramFilesX86, "Program Files", "Program Files (x86)",, 1)
    ProgramFilesX86 := StrReplace(ProgramFilesX86, "Arquivos de programas", "Arquivos de programas (x86)",, 1)
}
PrivateMenuOPC := A_Programs "\Smar\TagList600"
PublicMenuOPC := A_ProgramsCommon "\Smar\TagList600"
OPCInstallFolder := ProgramFilesX86 "\Smar\TagList CD600 v2.03"

if !FileExist(OPCInstallFolder "\TagList.exe") {
    OPCInstallFolder := ProgramFilesX86 "\Smar\TagList and LC700 OPC Server v8.55"
}

Gui, New
Gui +Resize
Gui, Add, Radio, vCriar Checked, Criar atalhos servidor OPC (todos os usuários)
Gui, Add, Radio, vRemover, Remover atalhos servidor OPC (todos os usuários)
Gui, Add, Button, x065 y050 w080 gCancel, Cancelar
Gui, Add, Button, x155 y050 w080 gProx, Próximo
Gui, Show, h080 w300, Caracol
return

GuiClose:
Cancel:
    ExitApp
return

Prox:
    Gui, Submit
    if (Criar) {
        setPermissions(OPCInstallFolder)
        criar_atalho(PublicMenuOPC, PrivateMenuOPC, OPCInstallFolder, ProgramFilesX86)
	}
    else {
        remover_atalho(PublicMenuOPC, PrivateMenuOPC, OPCInstallFolder, ProgramFilesX86)
	}
    ExitApp
return

criar_atalho(PublicMenuOPC, PrivateMenuOPC, OPCInstallFolder, ProgramFilesX86) {
    ; Antes de tudo, o servidor OPC deve estar instalado
    if !FileExist(OPCInstallFolder) {
        MsgBox, 16, Criar atalhos, O servidor OPC não foi encontrado. Certifique-se que ele está instalado`ne a versão é a correta (8.55).
		ExitApp
    }
    ; Método 1 (movendo atalhos da pasta do usuário para a pasta "All Users")
    else if FileExist(PrivateMenuOPC) and !FileExist(PublicMenuOPC) {
        FileCreateDir, %A_ProgramsCommon%\Smar\
		RunWait, %ComSpec% /c move "%PrivateMenuOPC%" "%A_ProgramsCommon%\Smar\",, Hide
		if (ErrorLevel = 1) {
			MsgBox, 16, Criar atalhos, Ocorreu um erro! Os atalhos não foram criados. (Método 1)
			ExitApp
		}
    }
    ; Método 2 (criando os principais atalhos manualmente)
    else if !FileExist(PrivateMenuOPC) and !FileExist(PublicMenuOPC) {
        try
        {
            FileCreateDir, %PublicMenuOPC%
            FileCreateShortcut, %OPCInstallFolder%\TAGLISTMP.pdf, %PublicMenuOPC%\Manual TagList (português).lnk
            FileCreateShortcut, %OPCInstallFolder%\TagList.exe, %PublicMenuOPC%\TagList.exe.lnk
            FileCreateShortcut, %OPCInstallFolder%\Howto - Adicionando Devices Genericos.doc, %PublicMenuOPC%\Howto - Adicionando Devices Genéricos.lnk
		}
        catch
        {
            MsgBox, 16, Criar atalhos, Ocorreu um erro! Os atalhos não foram criados. (Método 2)
            ExitApp
        }
    }    
    ; Aviso de Erro
    else if FileExist(PublicMenuOPC) {
        MsgBox, 16, Criar atalhos, Aparentemente os atalhos já foram criados!
        ExitApp
    }
    MsgBox, 64, Criar atalhos, Atalhos criados com sucesso!
}

remover_atalho(PublicMenuOPC, PrivateMenuOPC, OPCInstallFolder, ProgramFilesX86) {
    ; Método 1 (movendo atalhos de "All Users" para a pasta do usuário novamente)
    if FileExist(PublicMenuOPC) and !FileExist(PrivateMenuOPC) and FileExist(OPCInstallFolder) {
        FileCreateDir, %A_Programs%\Smar\
		RunWait, %ComSpec% /c move "%PublicMenuOPC%" "%A_Programs%\Smar\",, Hide
		if (ErrorLevel = 1) {
            MsgBox, 16, Remover atalhos, Ocorreu um erro! Os atalhos não foram removidos. (Método 1)
            ExitApp
        }
    }
    ; Método 2 (removendo os principais atalhos manualmente)
    else if FileExist(PublicMenuOPC) and ( FileExist(PrivateMenuOPC) or !FileExist(OPCInstallFolder) ) {
		FileRemoveDir, %PublicMenuOPC%, 1
		if (ErrorLevel = 1) {
            MsgBox, 16, Remover atalhos, Ocorreu um erro! Os atalhos não foram removidos. (Método 2)
            ExitApp
        }
		; Remover a pasta "Smar" do Menu Iniciar APENAS se ela estiver vazia
		FileRemoveDir, %A_ProgramsCommon%\Smar, 0
    }
    ; Aviso de Erro
    else if !FileExist(PublicMenuOPC) and !FileExist(PrivateMenuOPC) {
        MsgBox, 16, Remover atalhos, Erro! Não há atalhos para serem removidos!
        ExitApp
    }
    MsgBox, 64, Remover atalhos, Atalhos removidos com sucesso!
}

setPermissions(dir) {
	lang := ((A_Language = 0416) or (A_Language = 0816)) ? "Todos" : "Everyone"
	if (A_OSVersion = "WIN_XP") {
		RunWait, %ComSpec% /c cacls "%dir%" /T /E /P %lang%:R,, Hide
		RunWait, %ComSpec% /c cacls "%dir%" /T /E /P %lang%:W,, Hide
		RunWait, %ComSpec% /c cacls "%dir%" /T /E /P %lang%:C,, Hide
	}
	else {
		RunWait, %ComSpec% /c icacls "%dir%" /grant %lang%:(OI)(CI)RX /T,, Hide
		RunWait, %ComSpec% /c icacls "%dir%" /grant %lang%:(OI)(CI)W /T,, Hide
		RunWait, %ComSpec% /c icacls "%dir%" /grant %lang%:(OI)(CI)M /T,, Hide
	}

}

requestAdmin() {
    if (!A_IsAdmin) {
        if (A_OSVersion = "WIN_XP") {
            MsgBox, 48, Caracol, Você precisa executar este programa como administrador!
            ExitApp
        }
        if (A_IsCompiled) {
            Run *RunAs "%A_ScriptFullPath%" /restart
        } else {
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
        }
    }
}
