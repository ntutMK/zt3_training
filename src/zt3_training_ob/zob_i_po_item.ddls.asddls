@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Basic view for Purchase Order Item'

@Metadata.ignorePropagatedAnnotations: true

@VDM.viewType: #BASIC

define view entity Zob_I_po_item
  as select from zob_po_item

{
  key item_id           as ItemId,
  key purchase_order_id as PurchaseOrderId,

      item_number           as ItemNumber,
      product_id            as ProductId,
      product_name          as ProductName,
      quantity              as Quantity,

      @Semantics.amount.currencyCode: 'ItemCurrency'
      unit_price            as UnitPrice,

      @Semantics.amount.currencyCode: 'ItemCurrency'
      total_price           as TotalPrice,

      delivery_date         as DeliveryDate,
      warehouse_location    as WarehouseLocation,
      item_currency         as ItemCurrency,
      is_urgent             as IsUrgent,
      created_by            as CreatedBy,
      create_on             as CreateOn,
      changed_by            as ChangedBy,
      changed_on            as ChangedOn
}
