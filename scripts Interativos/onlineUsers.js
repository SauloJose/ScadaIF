/********************************************************
 * Projeto ScadaIF, 2025
 * 
 * Script para registrar usuários online no ScadaIF,
 * inspirado no Projeto Caracol e no System 302.
 * 
 * Funcionalidade:
 * - Obtém o nome do usuário logado no ScadaBR.
 * - Envia o nome via HTTP Receiver usando iframe/form.
 * - Cria data point no ScadaBR com lista de usuários ativos.
 * 
 * Licença: MIT
 ********************************************************/

/* Aguarda a página carregar para iniciar o registro */
if (testarNavegador() === "old") {
    setTimeout(registrarUsuariosOnline, 8500);
} else {
    window.onload = () => setTimeout(registrarUsuariosOnline, 3000);
}

/* Verifica se o navegador é Internet Explorer 8 ou anterior */
function testarNavegador() {
    const agente = navigator.userAgent;
    if (agente.includes("MSIE 8.0") || agente.includes("MSIE 7.0")) {
        return "old";
    }
    return "new";
}

/* Função principal: registra usuários online */
function registrarUsuariosOnline() {
    const urlReceiver = "/ScadaBR/httpds"; // URL relativa do HTTP Receiver
    const intervaloMinutos = 4; // Intervalo de registro (em minutos)

    // Não registrar na página de login
    if (window.location.href.includes("login.htm")) {
        return;
    }

    // Primeira tentativa de registro
    enviarInformacaoUsuario(urlReceiver);

    // Continuar enviando em intervalos regulares
    setInterval(() => {
        enviarInformacaoUsuario(urlReceiver);
    }, intervaloMinutos * 60000);
}

/* Envia o nome do usuário atual para o HTTP Receiver */
function enviarInformacaoUsuario(url) {
    const username = obterNomeUsuario();

    // Garante que o iframe/form exista
    if (!document.getElementById("onlineUsers_contentDiv")) {
        criarIframeFormulario(url);
    }

    // Preenche e envia o formulário
    const div = document.getElementById("onlineUsers_contentDiv");
    const input = div.querySelector("input[name='onlineuser']");
    const form = div.querySelector("form");

    if (input && form) {
        input.value = username;
        form.submit();
    }
}

/* Lê o nome do usuário logado no ScadaBR */
function obterNomeUsuario() {
    const elemento = document.querySelector("span.copyTitle > b");
    if (elemento) {
        return encodeURIComponent(elemento.innerText.trim());
    }
    return "unknown";
}

/* Cria iframe e formulário invisíveis para envio dos dados */
function criarIframeFormulario(url) {
    // Corrige "localhost" para "127.0.0.1" (evita erro de CORS no ScadaBR)
    if (window.location.hostname.includes("localhost")) {
        url = `${window.location.protocol}//127.0.0.1:${window.location.port}${url}`;
    }

    const div = document.createElement("div");
    div.id = "onlineUsers_contentDiv";
    div.style.display = "none";

    div.innerHTML = `
        <iframe name="onlineUsers_registerUsersFrame" style="display:none;"></iframe>
        <form target="onlineUsers_registerUsersFrame" method="POST" action="${url}">
            <input name="onlineuser" type="hidden" value="">
        </form>
    `;

    document.body.appendChild(div);
}
