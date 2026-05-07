////////////////////////////////////////////////////////////////////////////////////////////////////
// Funções e classes para acesso e conexão ao Dicionario de dados de Advantage                    //
// Qualquer alteração ou modificação encaminhe para Giovany Vecchi                                //
// Giovany Vecchi 04/11/2013 giovanyvecchi@yahoo.com.br / giovanyvecchi@gmail.com                 //
////////////////////////////////////////////////////////////////////////////////////////////////////

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

   #xcommand TEXT INTO <v> => #pragma __text|<v>+=%s+hb_eol();<v>:=""
   #xcommand TRY  => BEGIN SEQUENCE WITH {| oErr | Break( oErr ) }
   #xcommand CATCH [<!oErr!>] => RECOVER [USING <oErr>] <-oErr->
   #xcommand FINALLY => ALWAYS


#ENDIF

#Define FixCacheRecnos           60 // Numero ideal de registros em cache

#define HKEY_CLASSES_ROOT        2147483648
#define HKEY_CURRENT_USER        2147483649
#define HKEY_LOCAL_MACHINE       2147483650
#define HKEY_USERS               2147483651
#define HKEY_PERFORMANCE_DATA    2147483652
#define HKEY_CURRENT_CONFIG      2147483653
#define HKEY_DYN_DATA            2147483654

#define ADS_INC_USERCOUNT           0x00000001
#define ADS_STORED_PROC_CONN        0x00000002
#define ADS_COMPRESS_ALWAYS         0x00000004
#define ADS_COMPRESS_NEVER          0x00000008
#define ADS_COMPRESS_INTERNET       0x0000000C
#define ADS_REPLICATION_CONNECTION  0x00000010
#define ADS_UDP_IP_CONNECTION       0x00000020
#define ADS_IPX_CONNECTION          0x00000040
#define ADS_TCP_IP_CONNECTION       0x00000080
#define ADS_TCP_IP_V6_CONNECTION    0x00000100
#define ADS_NOTIFICATION_CONNECTION 0x00000200
// Reserved                         0x00000400
// Reserved                         0x00000800
#define ADS_TLS_CONNECTION          0x00001000
#define ADS_CHECK_FREE_TABLE_ACCESS 0x00002000

Static st_nCacheAds
Static St_aConnection, St_nConnectionDefault
Static St_cDirTmp



FUNCTION TADS_START_CONFIG(f_cDirTmp,f_cPassAdsSys)
   Local oConnectionTmp, cDirExpr := "", lCreateTmp := .F.
   Local aStructTmp := {}
   
   Default f_cDirTmp := HB_CURDRIVE()+":\"+CURDIR()+"\DADOSTMP\"
   Default f_cPassAdsSys := ""

   St_cDirTmp := f_cDirTmp 
   
   REQUEST DBFCDX , DBFFPT, DBFDBT
   REQUEST ADS , ADSX, ADSADTX, ADSKeyno, ADSKeycount, AdsGetRelKeyPos,  AdsSetRelKeyPos

   //WinExec("cmd.exe /c net config server /autodisconnect:65535",0)
   WinExec("cmd.exe /c net config server /autodisconnect:-1",0)
   //hb_libLoad( hb_libName( "rddads" + hb_libPostfix() ) )
   ///Hb_LibLoad("RDDADS.DLL")
   
   hb_rddADSRegister()
   Set( _SET_OPTIMIZE, .T. ) 
   //Set( _SET_AUTORDER, .T. )
   
   RddRegister( "ADS", 1 )      // ADS for Harbour
   RddSetDefault( "ADS" )       // ADS for Harbour

   //RddRegister( "ADS", 1 )      // ADS for Harbour
   //RddSetDefault( "ADS" )       // ADS for Harbour
   AdsLocking( .T. )
   AdsRightsCheck( .T. )
   AdsTestRecLocks( .T. )
   //ADSCACHEOPENTABLES( 10 ) // PADRÃO 0
   //AdsCacheOpenCursors( 60 ) // PADRÃO 25
   AdsSetDateFormat( "DD/MM/YYYY" )
   AdsSetEpoch("01/01/1990")
   AdsSetFileType( 3 ) /// 1 NTX / 2 CDX / 3 ADT

   AdsSetCharType(1)
   
   #ifdef __XHARBOUR__
      SET(_SET_HARDCOMMIT,.T.)  
   #else
      SET(106,.T.) 
   #endif

   ///SET(43,.F.)

   lMkDir(f_cDirTmp)
   FERASE(f_cDirTmp+"TADS_ERR.ADI")
   If !File(f_cDirTmp+"TADS_TMP.ADD")
      cDirExpr := StrTran(f_cDirTmp,"\","\\") 
      AdsSetServerType(1)
      TAds_CreateDataDictionary(cDirExpr+"TADS_TMP.ADD","Dicionario de dados temporario para TAds")
      lCreateTmp := .T.
   EndIf

   If lCreateTmp

      oConnectionTmp := tAdsConnection():New(121,.F.)
      oConnectionTmp:cDataDictionary  := f_cDirTmp+"TADS_TMP.ADD"
      oConnectionTmp:cSenhaConnect    := "" ///f_cPassAdsSys 
      oConnectionTmp:nTpConnect       := 1
      oConnectionTmp:tAdsConnect()

      if !Empty(f_cPassAdsSys)
         TAds_ModifyUserProperty(121,"adssys",f_cPassAdsSys)
      EndIf

      aadd(aStructTmp,{"STATUS","Short",2,0,1,"Status para Controle Interno",0})
      aadd(aStructTmp,{"Dt_Ocorrencia","Date",8,0,1,"Data da Ocorrencia do erro",Nil})
      aadd(aStructTmp,{"Hr_Ocorrencia","C",10,0,0,"Horas da Ocorrencia do erro",Nil})
      aadd(aStructTmp,{"cComputerName","C",50,0,0,"Nome do Computador ",Nil})
      aadd(aStructTmp,{"cInfoProcLine","C",100,0,0,"Linha e procedimento da chamada de DsNew()",Nil})
      aadd(aStructTmp,{"nErrorSql","N",7,0,0,"Numero do Erro retornado por AdsGetLastError",Nil})
      aadd(aStructTmp,{"cErrorSql","Memo",8,0,0,"Descricao do Erro retornado por AdsGetLastError",Nil})
      aadd(aStructTmp,{"cSqlScript","Memo",8,0,0,"Script Sql aplicado",Nil})
      aadd(aStructTmp,{"cErrorComplete","Memo",8,0,0,"Descrição completa do erro",Nil})

      TAds_CreateTableFromCode(121,"TADS_ERR",aStructTmp,"Tabela para registros de erros de tAds DataSet")

   Else

      oConnectionTmp := tAdsConnection():New(121,.F.)
      oConnectionTmp:cDataDictionary  := f_cDirTmp+"TADS_TMP.ADD"
      oConnectionTmp:cSenhaConnect    := f_cPassAdsSys 
      oConnectionTmp:nTpConnect       := 1
      oConnectionTmp:tAdsConnect()

   EndIf
   if !Empty(f_cPassAdsSys)
      f_cPassAdsSys := "passwd1"
      oConnectionTmp:cSenhaConnect    := f_cPassAdsSys 
   EndIf
   
RETURN NIL
///////////////////////////////////////////////////////////////////////////////
FUNCTION tAds_GetPathTemp()

RETURN St_cDirTmp
///////////////////////////////////////////////////////////////////////////////
FUNCTION tAds_GetConnectionDefault()

RETURN St_nConnectionDefault
///////////////////////////////////////////////////////////////////////////////
FUNCTION tAds_GetConnectionObj(f_nConexao)

   Default f_nConexao := St_nConnectionDefault

RETURN St_aConnection[f_nConexao]
///////////////////////////////////////////////////////////////////////////////
FUNCTION tAds_GetConnectionHandle(f_nConexao)

   Default f_nConexao := St_nConnectionDefault

RETURN St_aConnection[f_nConexao]:hConnectHandle
///////////////////////////////////////////////////////////////////////////////
Class tAdsConnection

   Data cDataDictionary    Init ""
   Data cUserLogin         Init "adssys"
   Data cSenhaConnect      Init ""
   Data cSenhaReConnect    Init ""
   Data nTpConnect         Init 7
   Data lConnected         Init .F.
   Data lDefault           Init .F.
   Data oTimerDefault   
   
   Data nConnection, hConnectHandle
   
   Data cTableAudit
   Data cComputerConnect
   Data cApplicationName
   
   Method New(f_nConnection,f_lDefault) Constructor
   Method tAdsConnect()
   Method tAdsReconnect()
   Method tAdsCloseConnect()
   Method tAdsAuditPut(f_cTxtAction)

EndClass
/*-----------------------------------------------------------------------------*/
Method New(f_nConnection,f_lDefault) Class tAdsConnection

   Default f_nConnection := 1, f_lDefault := .F.
   
   ::nConnection       := f_nConnection
   ::lDefault          := f_lDefault
   ::cComputerConnect  := ""

   If ::lDefault
      St_nConnectionDefault := f_nConnection
   EndIf
   
   If Hb_IsNil(St_aConnection)
      St_aConnection          := Array(121)
   EndIf

   If Hb_IsNil(St_nConnectionDefault)
      ::lDefault              := .T.
      St_nConnectionDefault   := f_nConnection
   EndIf

   St_aConnection[f_nConnection] := Self

Return Self
/*-----------------------------------------------------------------------------*/
Method tAdsConnect() Class tAdsConnection
   lOCAL lConectou := .F.
   Local lc_oReg, lc_oDs_ChecaAuditor
   
   ::cApplicationName := HB_FNameNameExt(GetModuleFileName(GetInstance()))

   /*
   lConectou := AdsConnect60( ::cDataDictionary,;
                              ::nTpConnect,;
                              ::cUserLogin,;
                              ::cSenhaConnect,;
                              (ADS_COMPRESS_INTERNET+ADS_TCP_IP_CONNECTION),;
                              @::hConnectHandle)
   */

   lConectou := AdsConnect60( ::cDataDictionary,;
                              ::nTpConnect,;
                              ::cUserLogin,;
                              ::cSenhaConnect,;
                              (ADS_COMPRESS_INTERNET+ADS_UDP_IP_CONNECTION),; /////+ADS_UDP_IP_CONNECTION),;
                              @::hConnectHandle)
   
   ///(ADS_COMPRESS_ALWAYS+ADS_UDP_IP_CONNECTION),; /////+ADS_UDP_IP_CONNECTION),;

   ::cSenhaReConnect := ENCRYPT(::cSenhaConnect,".wsp4")
   ::cSenhaConnect   := "0192837465" // hide in case of debug
   
   If !lConectou
      Return .F.
   EndIf
 
   ADSCACHEOPENTABLES( 0 ) // Padrão 0
   AdsCacheOpenCursors( nCacheAds() ) // Padrão 25
   
   ::lConnected    := .T.

   /*
   lc_oReg := TReg32():New( HKEY_LOCAL_MACHINE,;
          "System\CurrentControlSet\Control\ComputerName\ComputerName" )
   ::cComputerConnect := lc_oReg:Get("ComputerName")
   lc_oReg:Close()
   */
   ::cComputerConnect := Win_RegGet( HKEY_LOCAL_MACHINE,;
      "System\CurrentControlSet\Control\ComputerName\ComputerName", "ComputerName" )

   lc_oDs_ChecaAuditor := tAds():DsNew(1, ::nConnection)
   Text Into lc_oDs_ChecaAuditor:cQrySql 
      EXECUTE PROCEDURE sp_ViewQueryLogging() ;
   EndText
   lc_oDs_ChecaAuditor:DsExecute(,.F.) 
   If !Empty(lc_oDs_ChecaAuditor:VarGetAlltrim("Table"))
      ::cTableAudit := lc_oDs_ChecaAuditor:VarGetAlltrim("Table")
   EndIf    
   lc_oDs_ChecaAuditor:End()

Return .T.
/*-----------------------------------------------------------------------------*/
Method tAdsReconnect() Class tAdsConnection
   Local lc_lReConnect := .F.

   ::cSenhaConnect := DECRYPT(::cSenhaReConnect,".wsp4")

   lc_lReConnect := ::tAdsConnect()

Return lc_lReConnect
/*-----------------------------------------------------------------------------*/
Method tAdsCloseConnect() Class tAdsConnection
   Local hConnectionFocus := AdsConnection()
   Local hConnectionDefault := tAds_GetConnectionObj(St_nConnectionDefault):hConnectHandle
   
   ///? hConectionFocus, ::hConnectHandle, tAds_GetConnectionObj(1):hConnectHandle

   AdsConnection(::hConnectHandle)
   
   AdsCloseCachedTables(::hConnectHandle)

   //AdsCloseAllTables()
   If !AdsDisconnect(::hConnectHandle)
      AdsDisconnect(::hConnectHandle)
   EndIf
   hb_idleSleep(.2)
         
   If ::hConnectHandle <> hConnectionFocus
      AdsConnection(hConnectionFocus)
   Else
      If !::lDefault
         AdsConnection(hConnectionDefault)
      EndIf
   EndIf
   
   ::lConnected := .F.
   
Return NIL
/*-----------------------------------------------------------------------------*/
Method tAdsAuditPut(f_cTxtAction) Class tAdsConnection
   Local lc_ExecOk := .T. 
   
   if Hb_IsNil(::cTableAudit)
      Return Nil
   EndIf
   
   if Empty(::cTableAudit)
      Return Nil
   EndIf

   If !TAds_TableExist(::nConnection,::cTableAudit)
      Return Nil
   EndIf

   TRY 

      AdsConnection(::hConnectHandle)
      USE (::cTableAudit) ALIAS AUDITTMP NEW SHARED
      If NetErr()
         lc_ExecOk := .F.  ///break //Return Nil
      EndIf

      if lc_ExecOk
         AUDITTMP->(DbAppend())
         //("AUDITTMP")->ID               := tads
         AUDITTMP->(FieldPut(2,HB_DATETIME()))       ///(["Start Time"])       := HB_DATETIME()
         AUDITTMP->(FieldPut(3,.T.))                 ///(["Optimized"])        := .T.
         AUDITTMP->(FieldPut(4,0))                   ///(["Return Code"])      := 0
         AUDITTMP->(FieldPut(5,1))                   ///(["Rows Affected"])    := 1
         AUDITTMP->(FieldPut(6,HB_DATETIME()))       ///(["End Time"])         := HB_DATETIME()
         AUDITTMP->(FieldPut(7,0))                   ///(["Run Time"])         := 0
         AUDITTMP->(FieldPut(8,::cDataDictionary))   ///(["Database"])         := ::cDataDictionary
         AUDITTMP->(FieldPut(9,"adssys"))            ///(["User Name"])        := "adssys"
         AUDITTMP->(FieldPut(10,::cComputerConnect)) ///(["Connection Name"])  := ::cComputerConnect
         AUDITTMP->(FieldPut(11,::cApplicationName)) ///(["Application ID"])   := ::cDataDictionary
         AUDITTMP->(FieldPut(12,f_cTxtAction))       ///(["Query"])            := f_cTxtAction

         AUDITTMP->(DbCommit())
         AUDITTMP->(DBCloseArea())
      EndIf

   CATCH
   END


Return Nil
/*-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------*/
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
FUNCTION nCacheAds()

   If HB_ISNIL(st_nCacheAds)
      st_nCacheAds := FixCacheRecnos
   EndIf

Return st_nCacheAds

#IFNDEF __DOS__
#pragma BEGINDUMP

#include "P:\Projects\_ALL\Own\RddAds\BCC32\rddads.h"

#include "hbvm.h"
#include "hbapierr.h"
#include "hbapilng.h"
#include "hbstack.h"
#include "hbdate.h"

#include "rddsys.ch"


HB_FUNC( ADSFLUSHFILEBUFFERS )  //////  giovany
{
   ADSAREAP pArea;

   pArea = (ADSAREAP) hb_rddGetCurrentWorkAreaPointer();
   if( pArea )
      AdsFlushFileBuffers( pArea->hTable );
   else
      hb_errRT_DBCMD( EG_NOTABLE, 2001, NULL, "ADSFLUSHFILEBUFFERS" );
}


#pragma ENDDUMP

#ENDIF