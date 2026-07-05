@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer - Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_CUSTOMER_FS01
  as select from zcustomer_fs01
{
  key customer_id   as CustomerId,

      -- T14 Contact Quick View: the @Semantics.* annotations below are
      -- collected by the framework into a Communication.Contact card.
      -- fullName -> card title
      @Semantics.name.fullName: true
      customer_name as CustomerName,

      -- email -> rendered as a clickable mailto: link on the card
      @Semantics.eMail.address: true
      @Semantics.eMail.type: [#WORK]
      email         as Email,

      -- phone -> rendered as a clickable tel: link on the card
      @Semantics.telephone.type: [#WORK]
      phone         as Phone,

      -- address component (city) -> shown in the address block
      @Semantics.address.city: true
      city          as City
}
