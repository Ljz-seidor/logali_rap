@AbapCatalog.sqlViewName: 'ZV_HCM_MAST_LJZ'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'HCM - Master (unmanaged)'
define root view z_i_hcm_master_ljz
  as select from zhcm_master_ljz
{
  key e_number       ,
      e_name         ,
      e_department   ,
      status         ,
      job_title      ,
      start_date     ,
      end_date       ,
      email          ,
      m_number       ,
      m_name         ,
      m_department   ,
      crea_date_time ,
      crea_uname     ,
      lchg_date_time ,
      lchg_uname     
}
