#NoEnv
#NoTrayIcon
full_command_line := DllCall("GetCommandLine", "str")

;===================================================================
;= Projeto Caracol, 2020                                           =
;=                                                                 =
;= Este script é livre para uso nos termos da licença GNU GPL 2.   =
;= Para poder executar este script, é necessário usar o software   =
;= AutoHotkey. O AutoHotkey é licenciado sob a licença GNU GPL 2.  =
;= Optou-se por manter o código dos scripts sob a mesma licença do =
;= interpretador para evitar conflitos.                            =
;===================================================================


if (!A_IsAdmin and (A_OSVersion <> "WIN_XP")) {
    try 
    {
        if (A_IsCompiled) {
            Run *RunAs "%A_ScriptFullPath%" /restart "%A_UserName%"
	    }
        else {
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%" "%A_UserName%"
	    }
    } 
    catch 
    {
    	MsgBox, 48, Informações, % "Você NÃO é administrador!`n" "Nome do usuário: " A_UserName
    }
    ExitApp
}

if (A_IsAdmin) and InStr(full_command_line, "/restart") and (A_Args[1] <> A_UserName) {
	MsgBox, 64, Informações, % "O usuário '" A_UserName "' é administrador.`n`nPorém o usuário atual '" A_Args[1] "' não é."
}
else if (A_IsAdmin) {
	MsgBox, 64, Informações, % "Você é administrador!`n" "Nome do usuário: " A_UserName
}
else if (!A_IsAdmin) {
	MsgBox, 48, Informações, % "Você NÃO é administrador!`n" "Nome do usuário: " A_UserName
}

if (A_IS64bitOS) {
	MsgBox, 64, Informações, Seu sistema é 64 bits
}
else {
	MsgBox, 64, Informações, Seu sistema é 32 bits
}
