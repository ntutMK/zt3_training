@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Transactional View for Purchase Order'

@Metadata.ignorePropagatedAnnotations: true

@VDM.viewType: #TRANSACTIONAL

define root view entity ZOB_R_PO
  as select from Zob_I_PO

  composition [0..*] of ZOB_R_Po_Item as _Item

{
  key PurchaseOrderId,

      OrderDate,
      SupplierId,
      SupplierName,
      BuyerId,
      BuyerName,

      @Semantics.amount.currencyCode: 'HeaderCurrency'
      TotalAmount,

      HeaderCurrency,
      DeliveryDate,
      Status,
      PaymentTerms,
      ShippingMethod,
      ControlTimestamp,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      CreateOn,
      @Semantics.user.localInstanceLastChangedBy: true
      ChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      ChangedOn,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChanged,

      _Item
}
