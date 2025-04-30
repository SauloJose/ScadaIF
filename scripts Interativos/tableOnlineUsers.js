/* Livre para uso sob licença MIT - Adaptado para ScadaBR - Atualizado 2025 */

// Configurações iniciais (botões fixos)
var config = {
    mostrar_id: true,
    mostrar_email: true,
    mostrar_telefone: false,
    mostrar_admin: false,
    mostrar_login: true
};

// Estilos
var cor_cabecalho_tabela = "#112b00";
var cor_texto_cabecalho_tabela = "white";
var cor_fundo_cabecalho_topo = "#112b00";
var cor_texto_cabecalho_topo = "white";

var tamanho_fonte = 12;
var largura = 440; // Largura fixa da tabela e cabeçalho
var classe_css = "tabelaOnline" + pointComponent.id;
var variavelKick = "kickUser";

// Criação
var s = "";

// Definir CSS
s += criarCSS();

// Cabeçalho principal
s += "<div style='background-color:" + cor_fundo_cabecalho_topo + "; padding:10px; text-align:center; border-radius:10px; margin-bottom:10px;'>";
s += "<h2 style='color:" + cor_texto_cabecalho_topo + "; font-family:Arial; margin:0;'>LISTA DE USUÁRIOS</h2>";
s += "</div>";

// Exibir o número de usuários online entre o cabeçalho e a tabela
var onlineUsers = getOnlineUsers();
s += "<div style='text-align:center; font-family:Arial; font-size:14px; margin-bottom:10px; color:#000;'>";
s += "<b>Usuários Online: " + onlineUsers.length + "</b>";
s += "</div>";

// Controles de seleção
s += criarControles();

// Criar a tabela inicial com os usuários online
s += "<div id='tabelaUsuariosContainer'>";
s += criarTabela(onlineUsers);
s += "</div>";

// Retornar HTML
return s;


// === Funções especiais ===

// Criar controles de seleção de colunas
function criarControles() {
    var controles = "<div style='margin-bottom:10px; font-family:Arial; font-size:13px;'>";
    controles += "Exibir: ";
    controles += criarCheckbox('mostrar_id', 'ID');
    controles += criarCheckbox('mostrar_email', 'Email');
    controles += criarCheckbox('mostrar_telefone', 'Telefone');
    controles += criarCheckbox('mostrar_admin', 'Admin');
    controles += criarCheckbox('mostrar_login', 'Login');
    controles += "</div>";
    return controles;
}

function criarCheckbox(nomeConfig, label) {
    var checked = config[nomeConfig] ? "checked" : "";
    return "<label style='margin-right:10px;'><input type='checkbox' onclick='toggleColumn(\"" + nomeConfig + "\", this.checked)' " + checked + "> " + label + "</label>";
}

// Função para alternar visibilidade
function toggleColumn(nomeConfig, valor) {
    config[nomeConfig] = valor;
    updateTable();
}

// Função para atualizar a tabela sem recarregar a página
function updateTable() {
    var onlineUsers = getOnlineUsers();
    var tabelaHTML = criarTabela(onlineUsers);
    document.getElementById("tabelaUsuariosContainer").innerHTML = tabelaHTML;
}

// Criar tabela
function criarTabela(usernames) {
    var body = "";
    var header = "";
    var sdf = new java.text.SimpleDateFormat("HH:mm dd/MM/yyyy");
    var users = new com.serotonin.mango.db.dao.UserDao();

    usernames = usernames.sort(function (a, b) {
        return (a.toLowerCase() > b.toLowerCase()) ? 1 : -1;
    });

    // Cabeçalho da tabela
    header = "<tr>";
    if (config.mostrar_id) header += "<th>ID</th>";
    header += "<th>Usuário</th>";
    if (config.mostrar_email) header += "<th>E-mail</th>";
    if (config.mostrar_telefone) header += "<th>Telefone</th>";
    if (config.mostrar_admin) header += "<th>Admin?</th>";
    if (config.mostrar_login) header += "<th>Hora Login</th>";
    header += "<th>Ações</th>";
    header += "</tr>";

    // Corpo da tabela
    for (var i in usernames) {
        var thisUser = users.getUser(usernames[i]);
        if (usernames[i] == "unknown" || usernames[i] === null) {
            thisUser = {
                username: "Acesso Anônimo",
                id: "-",
                email: "-",
                phone: "-",
                admin: false
            };
        }

        // Preencher a tabela com os dados ou "N/A" caso não existam
        body += "<tr>";
        if (config.mostrar_id) body += "<td>" + (thisUser.id || "N/A") + "</td>";
        body += "<td>" + (thisUser.username || "N/A") + "</td>";
        if (config.mostrar_email) body += "<td>" + (thisUser.email || "N/A") + "</td>";
        if (config.mostrar_telefone) body += "<td>" + (thisUser.phone || "N/A") + "</td>";
        if (config.mostrar_admin) body += "<td>" + (thisUser.admin ? "Sim" : "Não") + "</td>";
        if (config.mostrar_login) {
            if (thisUser.username != "Acesso Anônimo") {
                body += "<td>" + sdf.format(thisUser.lastLogin) + "</td>";
            } else {
                body += "<td>-</td>";
            }
        }
        body += "<td><button class='btnDesconectar' onclick=\"disconnectUser('" + thisUser.username + "')\">Desconectar</button></td>";
        body += "</tr>";
    }

    // Adicionar a barra de rolagem horizontal
    var estiloOverflow = usernames.length > 10 ? " style='overflow-x:auto; display:block;'" : "";
    return "<div" + estiloOverflow + "><table class='" + classe_css + "'>" + header + body + "</table></div>";
}

// Buscar usuários online
function getOnlineUsers() {
    var minutos = 1;
    var onlineList = [];
    var since = time - (60000 * minutos);
    var names = new com.serotonin.mango.db.dao.PointValueDao();
    names = names.getPointValues(point.id, since);
    var size = names.size();

    for (var i = size; i > 0; i--) {
        var thisName = String(names.get((i - 1)).value);
        thisName = decodeURIComponent(thisName);

        if (!onlineList.includes(thisName)) {
            onlineList.push(thisName);
        }
    }
    return onlineList;
}

// Criar CSS interno e funções JS
function criarCSS() {
    var css = "";
    css += "<style>";

    css += "." + classe_css + "{";
    css += "  background-color: white;";
    css += "  font-family: Arial, Helvetica, sans-serif;";
    css += "  font-size: " + tamanho_fonte + "px;";
    css += "  border-collapse: collapse;";
    css += "  width: " + largura + "px;"; // Largura fixa de 440px
    css += "  min-width: 440px;"; // Garantir que a tabela tenha uma largura mínima
    css += "}";

    css += "." + classe_css + " th, ." + classe_css + " td {";
    css += "  border: 1px solid #ddd;";
    css += "  padding: 8px;";
    css += "}";

    css += "." + classe_css + " tr:hover { background-color: #f2f2f2; }";

    css += "." + classe_css + " th {";
    css += "  background-color: " + cor_cabecalho_tabela + ";";
    css += "  color: " + cor_texto_cabecalho_tabela + ";";
    css += "  width: 110px;"; // Ajuste o tamanho fixo do cabeçalho
    css += "}";

    // Estilo para os botões de desconectar
    css += ".btnDesconectar {";
    css += "  background-color: " + cor_fundo_cabecalho_topo + ";";
    css += "  color: white;";
    css += "  border: none;";
    css += "  border-radius: 5px;";
    css += "  padding: 5px 10px;";
    css += "  cursor: pointer;";
    css += "  font-size: 8pt;";
    css += "  margin: 2px;";
    css += "}";

    css += ".btnDesconectar:hover {";
    css += "  background-color: #0a4500;";
    css += "}";

    css += "</style>";

    // Funções para desconectar
    css += "<script>";
    css += "function disconnectUser(username) {";
    css += "  var xhr = new XMLHttpRequest();";
    css += "  xhr.open('POST', '/rest/v1/point-values/" + variavelKick + "/set', true);";
    css += "  xhr.setRequestHeader('Content-Type', 'application/json');";
    css += "  xhr.send(JSON.stringify({ 'dataType': 'ALPHANUMERIC', 'value': username }));";
    css += "  alert('Solicitado desconectar: ' + username);";
    css += "}";
    css += "</script>";

    return css;
}
