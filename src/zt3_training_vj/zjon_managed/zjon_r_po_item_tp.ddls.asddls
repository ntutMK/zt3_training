@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transactional Purchase Order Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZJON_R_PO_ITEM_TP 
  as select from ZJON_I_PO_ITEM as PurchaseOrderItem
  association to parent ZJON_R_PURC_ORDER_TP as _header on $projection.PurchaseOrderId = _header.PurchaseOrderId
{
  key PurchaseOrderItem.ItemId,
  key PurchaseOrderItem.PurchaseOrderId,
      PurchaseOrderItem.ItemNumber,
      PurchaseOrderItem.ProductId,
      PurchaseOrderItem.ProductName,
      PurchaseOrderItem.Quantity,
      @Semantics.amount.currencyCode : 'itemCurrency'
      PurchaseOrderItem.UnitPrice,
      @Semantics.amount.currencyCode : 'itemCurrency'
      PurchaseOrderItem.TotalPrice,
      PurchaseOrderItem.DeliveryDate,
      PurchaseOrderItem.WarehouseLocation,
      PurchaseOrderItem.ItemCurrency,
      PurchaseOrderItem.IsUrgent,
      PurchaseOrderItem.CreatedBy,
      PurchaseOrderItem.CreateOn,
      PurchaseOrderItem.ChangedBy,
      PurchaseOrderItem.ChangedOn,
      
      /* Associations */
      _header
}
