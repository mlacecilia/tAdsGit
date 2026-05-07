/*-----------------------------------------------------------------------------*/
// Funções Relacionadas as propriedades de restrições aos Usuarios e Tabelas     
// Qualquer alteração ou modificação encaminhe para Giovany Vecchi               
// Giovany Vecchi 03/02/2015 giovanyvecchi@yahoo.com.br / giovanyvecchi@gmail.com
/*-----------------------------------------------------------------------------*/

#IFNDEF __DOS__

#include "fivewin.ch" 

#ELSE
 
#include "hbclass.ch" 

#DEFINE  CRLF CHR(13)+CHR(10)

#xtranslate MsgInfo(<cMsn>) => Alert( <cMsn> )
#xtranslate MsgStop(<cMsn>) => Alert( <cMsn> )

#xcommand DEFAULT <uVar1> := <uVal1> ;
   [, <uVarN> := <uValN> ] => ;
   If( <uVar1> == nil, <uVar1> := <uVal1>, ) ;;
   [ If( <uVarN> == nil, <uVarN> := <uValN>, ); ]

#ENDIF

#define ADS_DD_USER_PASSWORD           1101
#define ADS_DD_USER_GROUP_MEMBERSHIP   1102
#define ADS_DD_USER_BAD_LOGINS         1103

/*-----------------------------------------------------------------------------*/
//Usuarios conectados Ret {lc_lExecute,lc_hDatas,lc_aCompConnections,lc_aUsersDataDictionary,lc_aNamesConnections}
//lc_lExecute              > Se executou com sucesso
//lc_hDatas                > Hash da tabela com os dados dos usuarios conectados
//lc_aCompConnections      > Array com os nomes dos computadores conectados
//lc_aUsersDataDictionary  > Array com os nomes dos usuarios logados no dicionario de dados
//lc_aUsersDataDictionary  > Array com os nomes dos usuarios dos computadores conectados
FUNCTION TAds_UsersConnected(f_nConnection)
   Local lc_oDs_Qry                       := ""
   Local lc_lExecute                      := .F.
   Local lc_iFor                          := 0
   Local lc_hDatas                        := {=>}     //Hash da tabela com os dados dos usuarios conectados
   Local lc_aCompConnections              := {}       //Array com os nomes dos computadores conectados 
   Local lc_aUsersDataDictionary          := {}       //Array com os nomes dos usuarios logados no dicionario de dados
   Local lc_aNamesConnections             := {}       //Array com os nomes dos usuarios dos computadores conectados
  
   lc_oDs_Qry                    := tAds():DsNew(1,f_nConnection)
   lc_oDs_Qry:cQrySql            := "SELECT * FROM (EXECUTE PROCEDURE sp_mgGetConnectedUsers()) connectedUsers ;"
   lc_oDs_Qry:cQrySql            := "EXECUTE PROCEDURE sp_mgGetConnectedUsers() ;"
   lc_oDs_Qry:lDsCursorsToArray  := .T.
   lc_oDs_Qry:lDsCursorsToJson   := .T.
   lc_lExecute := lc_oDs_Qry:DsExecute()

   lc_hDatas                     := (lc_oDs_Qry:hDsCursorsHash['data'])

   For lc_iFor := 1 to len(lc_oDs_Qry:aDsCursorsData)
      aadd(lc_aCompConnections,lc_oDs_Qry:aDsCursorsData[lc_iFor,1])
   Next

   For lc_iFor := 1 to len(lc_oDs_Qry:aDsCursorsData)
      aadd(lc_aUsersDataDictionary,lc_oDs_Qry:aDsCursorsData[lc_iFor,3])
   Next

   For lc_iFor := 1 to len(lc_oDs_Qry:aDsCursorsData)
      aadd(lc_aNamesConnections,lc_oDs_Qry:aDsCursorsData[lc_iFor,5])
   Next

   lc_oDs_Qry:End()

RETURN {lc_lExecute,lc_hDatas,lc_aCompConnections,lc_aUsersDataDictionary,lc_aNamesConnections}
/*-----------------------------------------------------------------------------*/
FUNCTION TAds_CreateUser(f_nConnection,f_cUserName,f_cPassWord,f_cComment)
   Local lc_oDs_Qry := "", lc_lExecute := .F.
  
   Default f_cPassWord := "", f_cComment := ""
  
   lc_oDs_Qry := tAds():DsNew(2,f_nConnection)
   lc_oDs_Qry:cQrySql := "EXECUTE PROCEDURE sp_CreateUser(_cUserName_,_cNewPassWord_,_cComment_);"
   lc_oDs_Qry:DsAddVar("_cUserName_",f_cUserName)
   lc_oDs_Qry:DsAddVar("_cPassWord_",f_cPassWord)
   lc_oDs_Qry:DsAddVar("_cComment_",f_cComment)
   lc_lExecute := lc_oDs_Qry:DsExecute()

RETURN lc_lExecute
/*-----------------------------------------------------------------------------*/
FUNCTION TAds_ModifyUserProperty(f_nConnection,f_cUserName,f_cNewPassWord)
   Local lc_oDs_Qry := "", lc_lExecute := .F.
  
   lc_oDs_Qry := tAds():DsNew(2,f_nConnection)
   lc_oDs_Qry:cQrySql := "EXECUTE PROCEDURE sp_ModifyUserProperty(_cUserName_,'USER_PASSWORD',_cNewPassWord_);"
   lc_oDs_Qry:DsAddVar("_cUserName_",f_cUserName)
   lc_oDs_Qry:DsAddVar("_cNewPassWord_",f_cNewPassWord)
   lc_lExecute := lc_oDs_Qry:DsExecute()

RETURN lc_lExecute
/*-----------------------------------------------------------------------------*/
FUNCTION TAds_DropUser(f_nConnection,f_cUserName)
   Local lc_oDs_Qry := "", lc_lExecute := .F.
  
   lc_oDs_Qry := tAds():DsNew(2,f_nConnection)
   lc_oDs_Qry:cQrySql := "EXECUTE PROCEDURE sp_DropUser(_cUserName_);"
   lc_oDs_Qry:DsAddVar("_cUserName_",f_cUserName)
   lc_lExecute := lc_oDs_Qry:DsExecute()

RETURN lc_lExecute
/*-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------*/
FUNCTION TAds_CreateGroup(f_nConnection,f_cGroupName,f_cComment)
   Local lc_oDs_Qry := "", lc_lExecute := .F.
  
   Default f_cComment := ""
  
   lc_oDs_Qry := tAds():DsNew(2,f_nConnection)
   lc_oDs_Qry:cQrySql := "EXECUTE PROCEDURE sp_CreateGroup(_cGroupName_,_cComment_);"
   lc_oDs_Qry:DsAddVar("_cGroupName_",f_cGroupName)
   lc_oDs_Qry:DsAddVar("_cComment_",f_cComment)
   lc_lExecute := lc_oDs_Qry:DsExecute()

RETURN lc_lExecute
/*-----------------------------------------------------------------------------*/
FUNCTION TAds_ModifyGroupProperty(f_nConnection,f_cGroupName,f_cDataBaseProperty,f_cComment)
   Local lc_oDs_Qry := "", lc_lExecute := .F.
  
   Default f_cDataBaseProperty := "", f_cComment := ""
  
   lc_oDs_Qry := tAds():DsNew(2,f_nConnection)
   lc_oDs_Qry:cQrySql := "EXECUTE PROCEDURE sp_ModifyGroupProperty(_cGroupName_,_cDataBaseProperty_,_cComment_);"
   lc_oDs_Qry:DsAddVar("_cGroupName_",f_cGroupName)
   lc_oDs_Qry:DsAddVar("_cDataBaseProperty_",f_cDataBaseProperty)
   lc_oDs_Qry:DsAddVar("_cComment_",f_cComment)
   lc_lExecute := lc_oDs_Qry:DsExecute()

RETURN lc_lExecute
/*-----------------------------------------------------------------------------*/
FUNCTION TAds_DropGroup(f_nConnection,f_cGroupName)
   Local lc_oDs_Qry := "", lc_lExecute := .F.
  
   lc_oDs_Qry := tAds():DsNew(2,f_nConnection)
   lc_oDs_Qry:cQrySql := "EXECUTE PROCEDURE sp_DropGroup(_cGroupName_);"
   lc_oDs_Qry:DsAddVar("_cGroupName_",f_cGroupName)
   lc_lExecute := lc_oDs_Qry:DsExecute()

RETURN lc_lExecute
/*-----------------------------------------------------------------------------*/
FUNCTION TAds_AddUserToGroup(f_nConnection,f_cUserName,f_cGroupName)
   Local lc_oDs_Qry := "", lc_lExecute := .F.
  
   lc_oDs_Qry := tAds():DsNew(2,f_nConnection)
   lc_oDs_Qry:cQrySql := "EXECUTE PROCEDURE sp_AddUserToGroup(_cUserName_,_cGroupName_);"
   lc_oDs_Qry:DsAddVar("_cUserName_",f_cUserName)
   lc_oDs_Qry:DsAddVar("_cGroupName_",f_cGroupName)
   lc_lExecute := lc_oDs_Qry:DsExecute()

RETURN lc_lExecute
/*-----------------------------------------------------------------------------*/
FUNCTION TAds_RemoveUserFromGroup(f_nConnection,f_cUserName,f_cGroupName)
   Local lc_oDs_Qry := "", lc_lExecute := .F.
  
   lc_oDs_Qry := tAds():DsNew(2,f_nConnection)
   lc_oDs_Qry:cQrySql := "EXECUTE PROCEDURE sp_RemoveUserFromGroup(_cUserName_,_cGroupName_);"
   lc_oDs_Qry:DsAddVar("_cUserName_",f_cUserName)
   lc_oDs_Qry:DsAddVar("_cGroupName_",f_cGroupName)
   lc_lExecute := lc_oDs_Qry:DsExecute()

RETURN lc_lExecute
/*-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------*/
