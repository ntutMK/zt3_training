@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transactional Purchase Order Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZJON_R_PURC_ORDER_TP
  as select from ZJON_I_PURC_ORDER as PurchaseOrder
  composition [1..*] of ZJON_R_PO_ITEM_TP as _items
{
  key PurchaseOrder.PurchaseOrderId,
      PurchaseOrder.OrderDate,
      PurchaseOrder.SupplierId,
      PurchaseOrder.SupplierName,
      PurchaseOrder.BuyerId,
      PurchaseOrder.BuyerName,
      @Semantics.amount.currencyCode : 'HeaderCurrency'
      PurchaseOrder.TotalAmount,
      PurchaseOrder.HeaderCurrency,
      PurchaseOrder.DeliveryDate,
      PurchaseOrder.Status,
      PurchaseOrder.PaymentTerms,
      PurchaseOrder.ShippingMethod,
      PurchaseOrder.ControlTimestamp,
      PurchaseOrder.CreatedBy,
      PurchaseOrder.CreateOn,
      PurchaseOrder.ChangedBy,
      PurchaseOrder.ChangedOn,
      PurchaseOrder.LastChanged,
      
      /* Associations */
      _items
}
