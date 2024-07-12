@AbapCatalog.sqlViewName: 'ZV_EMPL_LJZ'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employee'
define root view Z_I_EMPLOYEE_LJZ
  as select from zemployee_ljz
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
