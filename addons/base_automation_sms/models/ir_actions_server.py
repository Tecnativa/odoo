# -*- coding: utf-8 -*-
# Part of Odoo. See LICENSE file for full copyright and licensing details.
from odoo import api, exceptions, fields, models, _

class ServerAction(models.Model):
    _inherit = "ir.actions.server"

    @api.depends('sms_template_id')
    def _compute_name(self):
        to_update = self.filtered(lambda x: x.base_automation_id and x.state == 'sms')
        for action in to_update:
            action.name = _(
                'Send SMS: %(template_name)s',
                template_name=action.sms_template_id.name
            )
