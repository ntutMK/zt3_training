@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view PO header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZJON_C_PURC_ORDER_ODATA_INT
  provider contract transactional_interface
  as projection on ZJON_R_PURC_ORDER_TP as PurchaseOrder
{
  key PurchaseOrderId,
      OrderDate,
      SupplierId,
      SupplierName,
      BuyerId,
      BuyerName,
      @Semantics.amount.currencyCode : 'HeaderCurrency'
      TotalAmount,
      HeaderCurrency,
      DeliveryDate,
      Status,
      PaymentTerms,
      ShippingMethod,
      ControlTimestamp,
      CreatedBy,
      CreateOn,
      ChangedBy,
      ChangedOn,
      LastChanged,
      /* Associations */
      _items : redirected to composition child ZJON_C_PO_ITEM_ODATA_INT
}
