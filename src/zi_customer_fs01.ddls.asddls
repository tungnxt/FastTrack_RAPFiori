@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer - Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_CUSTOMER_FS01
  as select from zcustomer_fs01
{
  key customer_id   as CustomerId,
      customer_name as CustomerName,
      @Semantics.eMail.address: true
      email         as Email,
      city          as City
}
