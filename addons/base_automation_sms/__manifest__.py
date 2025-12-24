# -*- coding: utf-8 -*-
# Part of Odoo. See LICENSE file for full copyright and licensing details.

{
    'name': 'Automation Rules - SMS',
    'version': '1.0',
    'category': 'Sales/Sales',
    'depends': ['base_automation', 'sms'],
    'data': [
        'views/base_automation_views.xml',
    ],
    'assets': {
        'web.assets_backend': [
            'base_automation_sms/static/src/**/*',
        ],
    },
    'license': 'LGPL-3',
}
