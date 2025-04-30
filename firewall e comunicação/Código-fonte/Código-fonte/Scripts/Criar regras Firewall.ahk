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

; Caminhos para os executáveis CONF600 Plus e TagList600
CONF600Path := "Smar\CONF600 Plus v3.04\Conf600.exe"
Taglist600Path := "Smar\TagList CD600 v2.03\Taglist600.exe"
OPCEnumPath := A_WinDir "\System32\OpcEnum.exe"

if A_IS64bitOS {
    CONF600Path := StrReplace(CONF600Path, "Program Files", "Program Files (x86)",, 1)
    Taglist600Path := StrReplace(Taglist600Path, "Program Files", "Program Files (x86)",, 1)
    OPCEnumPath := StrReplace(OPCEnumPath, "System32", "SysWOW64",, 1)
}

Gui, New
Gui +Resize
Gui, Add, Radio, vCriar Checked, Criar regras de firewall
Gui, Add, Radio, vRemover, Remover regras de firewall
Gui, Add, Button, x065 y050 w080 gCancel, Cancelar
Gui, Add, Button, x155 y050 w080 gProx, Próximo
Gui, Show, h080 w300, Projeto Caracol
return

GuiClose:
Cancel:
    ExitApp
return

Prox:
    Gui, Submit
    ; Configurar firewall para CONF600 Plus, TagList600 e OPC Enumerator
    manageFirewall(Criar, "Smar CONF600 PLUS", CONF600Path)
    manageFirewall(Criar, "Smar TagList600", Taglist600Path)
    manageFirewall(Criar, "OPC Enumerator", OPCEnumPath)
    
    ; Desativar "Compartilhamento simples de arquivos" (forceguest)
    SetRegView, 64
    RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa, forceguest, 0
    MsgBox, 64, Projeto Caracol, Concluído!
    ExitApp
return

manageFirewall(Add, RuleName, Exec) {
    if Add {
        OldVar := "ENABLE"
        NewVar := "add rule action=allow enable=yes"
    }
    else {
        OldVar := "DISABLE"
        NewVar := "delete rule"
    }
    ; Criar e ativar/desativar regras de firewall
    if (A_OSVersion = "WIN_XP") {
        RunWait, netsh firewall add allowedprogram "%Exec%" "%RuleName%" %OldVar%,, Hide
    } 
    else {
        RunWait, netsh advfirewall firewall %NewVar% name="%RuleName% (in)" dir=in program="%Exec%",, Hide
        RunWait, netsh advfirewall firewall %NewVar% name="%RuleName% (out)" dir=out program="%Exec%",, Hide
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
