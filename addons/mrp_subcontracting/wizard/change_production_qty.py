from odoo import api, models


class ChangeProductionQty(models.TransientModel):
    _inherit = 'change.production.qty'

    @api.model
    def _need_quantity_propagation(self, move, qty):
        res = super()._need_quantity_propagation(move, qty)
        return res and not any(m.is_subcontract for m in move.move_dest_ids)

    @api.model
    def _update_product_qty(self, move, qty):
        res = super()._update_product_qty(move, qty)
        subcontract_moves = move.move_dest_ids.filtered(lambda m: m.is_subcontract)
        if subcontract_moves:
            # Actualizamos la cantidad del albarán de salida
            # En v16 se hace de otra manera que desconozco
            for m in move.production_id.picking_ids.move_ids_without_package:
                m.write({"product_uom_qty": m.move_dest_ids.product_uom_qty})
        return res
