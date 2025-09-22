INTERFACE zob_if_m_po
  PUBLIC.
  CONSTANTS gc_po_message_class TYPE symsgid VALUE `ZOB_PO`.

  CONSTANTS: BEGIN OF cs_status,
               new                TYPE char1 VALUE space,
               ready              TYPE char1 VALUE 'R',
               partially_complete TYPE char1 VALUE 'P',
               completed          TYPE char1 VALUE 'C',
               archived           TYPE char1 VALUE 'A',
             END OF cs_status.

ENDINTERFACE.
