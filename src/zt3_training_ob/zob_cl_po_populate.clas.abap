CLASS zob_cl_po_populate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zob_cl_po_populate IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DELETE FROM zob_purc_order.
    DELETE FROM zob_po_item.

    DATA lt_po     TYPE STANDARD TABLE OF zob_purc_order.
    DATA lt_po_itm TYPE STANDARD TABLE OF zob_po_item.

    lt_po = VALUE #( client          = sy-mandt
                     supplier_id     = 'SUP1'
                     supplier_name   = 'SUP1 Name'
                     buyer_id        = 'BUY1'
                     buyer_name      = 'BUY1 Name'
                     header_currency = 'USD'
                     payment_terms   = 'A'
                     ( purchase_order_id = '00000000000000000001'
                       order_date        = '20250901'
                       total_amount      = '100'
                       delivery_date     = '20251001'
                       shipping_method   = 'A' )
                     ( purchase_order_id = '00000000000000000002'
                       order_date        = '20250901'
                       total_amount      = '150'
                       delivery_date     = '20251001'
                       shipping_method   = 'A' )
                     ( purchase_order_id = '00000000000000000003'
                       order_date        = '20250901'
                       total_amount      = '350'
                       delivery_date     = '20251001'
                       shipping_method   = 'A' )
                     ( purchase_order_id = '00000000000000000004'
                       order_date        = '20270901'
                       total_amount      = '350'
                       delivery_date     = '20271001'
                       shipping_method   = 'C' )
                     ( purchase_order_id = '00000000000000000005'
                       order_date        = '20270901'
                       total_amount      = '350'
                       delivery_date     = '20271001'
                       shipping_method   = 'C' ) ).

    lt_po_itm = VALUE #( client        = sy-mandt
                         item_currency = 'USD'
                         ( purchase_order_id  = '00000000000000000001'
                           item_id            = '00000000000000000001'
                           item_number        = '1'
                           product_id         = 'PROD1'
                           quantity           = '10'
                           unit_price         = '10'
                           total_price        = '100'
                           delivery_date      = '20251001'
                           warehouse_location = 'STOCKPILE1' )
                         ( purchase_order_id  = '00000000000000000002'
                           item_id            = '00000000000000000001'
                           item_number        = '1'
                           product_id         = 'PROD1'
                           quantity           = '10'
                           unit_price         = '15'
                           total_price        = '150'
                           delivery_date      = '20251001'
                           warehouse_location = 'STOCKPILE1' )
                         ( purchase_order_id  = '00000000000000000003'
                           item_id            = '00000000000000000001'
                           item_number        = '1'
                           product_id         = 'PROD1'
                           quantity           = '35'
                           unit_price         = '10'
                           total_price        = '350'
                           delivery_date      = '20251001'
                           warehouse_location = 'STOCKPILE1' )
                         ( purchase_order_id  = '00000000000000000004'
                           item_id            = '00000000000000000001'
                           item_number        = '1'
                           product_id         = 'PROD1'
                           quantity           = '5'
                           unit_price         = '10'
                           total_price        = '50'
                           delivery_date      = '20271001'
                           warehouse_location = 'STOCKPILE1' )
                         ( purchase_order_id  = '00000000000000000004'
                           item_id            = '00000000000000000002'
                           item_number        = '2'
                           product_id         = 'PROD2'
                           quantity           = '2'
                           unit_price         = '150'
                           total_price        = '300'
                           delivery_date      = '20271001'
                           warehouse_location = 'BULKY' )
                         ( purchase_order_id  = '00000000000000000005'
                           item_id            = '00000000000000000001'
                           item_number        = '1'
                           product_id         = 'PROD1'
                           quantity           = '20'
                           unit_price         = '10'
                           total_price        = '200'
                           delivery_date      = '20271001'
                           warehouse_location = 'STOCKPILE1' )
                         ( purchase_order_id  = '00000000000000000005'
                           item_id            = '00000000000000000002'
                           item_number        = '2'
                           product_id         = 'PROD2'
                           quantity           = '1'
                           unit_price         = '150'
                           total_price        = '150'
                           delivery_date      = '20271001'
                           warehouse_location = 'BULKY' ) ).

    INSERT zob_purc_order FROM TABLE @lt_po.
    INSERT zob_po_item FROM TABLE @lt_po_itm.

    out->write( 'PO data has been inserted' ).
  ENDMETHOD.
ENDCLASS.
