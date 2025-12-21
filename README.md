# tAds - ORM para Advantage Database Server

<p align="center">
  <img src="https://img.shields.io/badge/Language-Harbour-blue" alt="Harbour">
  <img src="https://img.shields.io/badge/GUI-FiveWin-green" alt="FiveWin">
  <img src="https://img.shields.io/badge/Database-ADS-orange" alt="ADS">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License">
</p>

**tAds** é uma biblioteca ORM (Object-Relational Mapping) para **Harbour/xBase** que simplifica o acesso ao **Advantage Database Server (ADS)** utilizando programação orientada a objetos.

## 📋 Características

- ✅ Acesso a tabelas via **RDD (ISAM)** e **SQL**
- ✅ Suporte a **múltiplas conexões** simultâneas
- ✅ Conexão **Local, Remota e via Internet**
- ✅ **DataSet** para execução de queries SQL
- ✅ Geração automática de **classes de tabelas**
- ✅ Suporte a **transações** (Begin, Commit, Rollback)
- ✅ Gerenciamento de **usuários e grupos**
- ✅ Funções de **backup e restore**
- ✅ Integração com **xBrowse** do FiveWin
- ✅ Compatível com **FiveWin** e modo console

## 📁 Estrutura do Projeto

```
tAds/
├── Source/
│   ├── tAds.prg              # Classe principal TAds
│   ├── tAdsConection.prg     # Classe de conexão tAdsConnection
│   ├── tAdsClassBuild.prg    # Gerador de classes de tabelas
│   ├── tAdsFunctions.prg     # Funções utilitárias
│   ├── tAdsManager.prg       # Gerenciador de tabelas
│   ├── tAdsSystem.prg        # Funções de sistema
│   ├── tAdsUsers.prg         # Gerenciamento de usuários
│   ├── tAdsBackup.prg        # Backup e restore
│   ├── tAdsScalarFunctions.prg
│   ├── tAdsPopUpBrowse.prg
│   └── tCtrlxBrowser.prg     # Integração com xBrowse
├── Include/
│   └── TAds.ch               # Arquivo de includes/defines
├── SourceOld/                # Funções legadas
└── WhatsNew.txt              # Histórico de versões
```

## 🚀 Instalação

1. Clone o repositório:
```bash
git clone https://github.com/giovanyvecchi/tAdsGit.git
```

2. Adicione os arquivos ao seu projeto `.hbp`:
```
path/to/tAds/Source/*.prg
```

3. Inclua o header nos seus arquivos `.prg`:
```harbour
#Include "FiveWin.ch"
#Include "TAds.ch"
```

## 📖 Uso Básico

### Configuração Inicial

```harbour
// Inicializa a configuração do tAds
TADS_START_CONFIG("C:\TEMP\", "senhaAdsSys")
```

### Conexão com o Banco de Dados

```harbour
// Cria uma conexão com o dicionário de dados
oConexao := tAdsConnection():New(1, .F.)
oConexao:cDataDictionary := "\\servidor\dados\MeuBanco.add"
oConexao:cUserLogin      := "adssys"
oConexao:cSenhaConnect   := "minhaSenha"
oConexao:nTpConnect      := 4  // 1=Local, 4=Internet

// Conecta
If oConexao:tAdsConnect()
   MsgInfo("Conectado com sucesso!")
EndIf

// Desconecta ao finalizar
oConexao:tAdsCloseConnect()
```

### Tipos de Conexão

| Valor | Descrição |
|-------|-----------|
| 1 | Conexão Local |
| 2 | Conexão Remota |
| 3 | Remota ou Local |
| 4 | Via Internet |
| 5 | Internet ou Local |
| 6 | Remota ou Internet |
| 7 | Remota, Internet ou Local |

### Abrindo Tabelas (Modo RDD/ISAM)

```harbour
// Abre tabela diretamente
oDb_Clientes := tAds():NewRdd("CLIENTES", 1, 60)

// Navegação
oDb_Clientes:GoTop()

Do While !oDb_Clientes:Eof()
   ? oDb_Clientes:VarGet("NOME")
   ? oDb_Clientes:VarGet("CIDADE")
   oDb_Clientes:Skip()
EndDo

// Fecha a tabela
oDb_Clientes:End()
```

### Operações CRUD

```harbour
// Criar novo registro
oDb_Clientes:Append()
oDb_Clientes:VarPut("NOME", "João Silva")
oDb_Clientes:VarPut("CIDADE", "São Paulo")
oDb_Clientes:VarPut("SALARIO", 5000.00)
oDb_Clientes:Commit(.T.)

// Ler registro
oDb_Clientes:Seek("João Silva", "NOME")
cNome := oDb_Clientes:VarGet("NOME")

// Atualizar registro
oDb_Clientes:RLock()
oDb_Clientes:VarPut("SALARIO", 6000.00)
oDb_Clientes:Commit(.T.)

// Excluir registro
oDb_Clientes:RLock()
oDb_Clientes:Delete()
```

### Executando Queries SQL (DataSet)

```harbour
// SELECT - Tipo 1
oDs := tAds():DsNew(1, 1)  // 1=Select, 1=Conexão
oDs:cQrySql := "SELECT * FROM CLIENTES WHERE CIDADE = 'São Paulo' ORDER BY NOME"
oDs:DsExecute()

Do While !(oDs:cAlias)->(Eof())
   ? (oDs:cAlias)->NOME
   (oDs:cAlias)->(DbSkip())
EndDo

oDs:End()

// INSERT/UPDATE/DELETE - Tipo 2
oDs := tAds():DsNew(2, 1)  // 2=Comando, 1=Conexão
oDs:cQrySql := "UPDATE CLIENTES SET ATIVO = TRUE WHERE CIDADE = 'São Paulo'"
oDs:DsExecute()
oDs:End()
```

### Variáveis em Queries

```harbour
oDs := tAds():DsNew(1)
oDs:cQrySql := "SELECT * FROM CLIENTES WHERE SALARIO > _Salario_ AND DT_CADASTRO >= _Data_"
oDs:DsAddVar("_Salario_", 3000.00)
oDs:DsAddVar("_Data_", Date() - 30)
oDs:DsExecute()
```

### Filtros AOF (Advantage Optimized Filter)

```harbour
oDb_Clientes := tAds():NewRdd("CLIENTES")

// Filtro simples
oDb_Clientes:Filter("CIDADE = 'São Paulo'")

// Filtro com variáveis
oDb_Clientes:Filter("SALARIO > _nSalario_", {{"_nSalario_", 2000.00}})

// Limpar filtro
oDb_Clientes:ClearFilter()
```

## 🏗️ Gerando Classes de Tabelas

O tAds pode gerar automaticamente classes para suas tabelas:

```harbour
// Gera classe para a tabela CLIENTES
TAds_CreateClassFromDatabase(1, "CLIENTES", "C:\MeuProjeto\DataBases\")
```

Isso cria um arquivo `DataBase_CLIENTES.prg`:

```harbour
CLASS DB_CLIENTES FROM TAds

   Data cTableName Init 'CLIENTES'
   
   METHOD OpenRdd(f_nConexao, f_nCache, f_lExclusive, f_lDataLoadOnSkip) Constructor
   METHOD End()

ENDCLASS
```

**Uso da classe gerada:**

```harbour
oDb_Clientes := DB_CLIENTES():OpenRdd()

oDb_Clientes:Seek(123, "CODIGO")
? oDb_Clientes:VarGet("NOME")

oDb_Clientes:End()
```

## 💾 Backup e Restore

```harbour
// Backup completo
tAds_BackupDataBase(1, "E:\BACKUP", Nil)

// Backup diferencial (após preparação)
tAds_BackupDataBase(1, "E:\BACKUP", "PrepareDiff")  // Prepara
tAds_BackupDataBase(1, "E:\BACKUP", "Diff")         // Executa diferencial

// Restore
tAds_RestoreDataBase("E:\BACKUP\MeuBanco.add", "C:\DADOS\MeuBanco.add", "senhaOrigem")
```

## 👥 Gerenciamento de Usuários

```harbour
// Criar usuário
tAds_CreateUser(1, "joao", "senha123", "João da Silva")

// Alterar senha
tAds_ModifyUserProperty(1, "joao", "novaSenha")

// Criar grupo
tAds_CreateGroup(1, "VENDEDORES", "Grupo de vendedores")

// Adicionar usuário ao grupo
tAds_AddUserToGroup(1, "joao", "VENDEDORES")

// Remover usuário do grupo
tAds_RemoveUserFromGroup(1, "joao", "VENDEDORES")

// Excluir usuário
tAds_DropUser(1, "joao")
```

## 🔄 Transações

```harbour
// Inicia transação
tAds_BeginTransaction(1)

TRY
   oDb_Clientes:Append()
   oDb_Clientes:VarPut("NOME", "Teste")
   oDb_Clientes:Commit()
   
   oDb_Pedidos:Append()
   oDb_Pedidos:VarPut("COD_CLIENTE", oDb_Clientes:VarGet("CODIGO"))
   oDb_Pedidos:Commit()
   
   // Confirma transação
   tAds_CommitTransaction(1)
   
CATCH
   // Desfaz transação em caso de erro
   tAds_RollBackTransaction(1)
END
```

## 📊 Integração com xBrowse (FiveWin)

```harbour
oDb_Clientes := DB_CLIENTES():OpenRdd()

oBrw := TXBrowse():New(oWnd)
oBrw:cAlias := oDb_Clientes:cAlias
oBrw:SetRDD()
oBrw:CreateFromCode()

// Configura controle de navegação
oCtrlBrw := tCtrlxBrw():New(oBrw, oDb_Clientes)
```

## 🔧 Métodos Principais da Classe TAds

| Método | Descrição |
|--------|-----------|
| `NewRdd(cTable, nConn, nCache)` | Abre tabela em modo RDD |
| `DsNew(nTipo, nConn)` | Cria DataSet para SQL |
| `DsExecute()` | Executa query SQL |
| `VarGet(cCampo)` | Lê valor do campo |
| `VarPut(cCampo, uValor)` | Grava valor no campo |
| `Seek(uValor, cTag)` | Pesquisa registro |
| `Filter(cFiltro)` | Aplica filtro AOF |
| `Append()` | Cria novo registro |
| `Delete()` | Marca registro para exclusão |
| `RLock()` | Trava registro |
| `UnLock()` | Destrava registro |
| `Commit()` | Confirma alterações |
| `Skip(n)` | Avança/retrocede registros |
| `GoTop()` / `GoBottom()` | Vai para primeiro/último |
| `Eof()` / `Bof()` | Verifica fim/início |
| `End()` | Fecha tabela/DataSet |

## 📌 Constantes (TAds.ch)

```harbour
// Tipos de conexão
#Define df_ConnectLocal          1
#Define df_ConnectRemote         2
#Define df_ConnectInternet       4

// Tipos de arquivo
#Define df_FileCdx               2
#Define df_FileAdt               3

// Parâmetros de KeyCount
#Define df_nKeysVisibles         1
#Define df_nKeysAllIndex         2

// Parâmetros de Seek
#Define df_lSeekAproximadoOn     .T.
#Define df_lSeekAproximadoOff    .F.
```

## 📝 Requisitos

- **Harbour Compiler** (3.0+)
- **FiveWin** (opcional, para GUI)
- **Advantage Database Server** (10.1+)
- **RddAds** library

## 🔗 Links Úteis

- [Harbour Project](https://harbour.github.io/)
- [FiveWin](https://www.fivetech.net/)
- [SAP Advantage Database Server](https://www.sap.com/products/advantage-database-server.html)

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👤 Autor

**Giovany Vecchi**
- Email: giovanyvecchi@gmail.com
- GitHub: [@giovanyvecchi](https://github.com/giovanyvecchi)

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:

1. Fazer um Fork do projeto
2. Criar uma branch para sua feature (`git checkout -b feature/NovaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona NovaFeature'`)
4. Push para a branch (`git push origin feature/NovaFeature`)
5. Abrir um Pull Request

---

<p align="center">
  Desenvolvido com ❤️ para a comunidade Harbour/FiveWin
</p>
