@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Consumption view for Purchase Order'

@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true

@VDM.viewType: #CONSUMPTION

define root view entity ZOB_U_C_PO
  provider contract transactional_query
  as projection on ZOB_U_R_PO

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

      /* Associations */
      _Item: redirected to composition child ZOB_U_C_PO_ITEM
}
