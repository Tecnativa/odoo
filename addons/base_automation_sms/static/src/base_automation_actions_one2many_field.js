/** @odoo-module **/

import { Component, useExternalListener, useEffect, useRef } from "@odoo/owl";
import { _t } from "@web/core/l10n/translation";
import { registry } from "@web/core/registry";
import { useThrottleForAnimation } from "@web/core/utils/timing";


const actionsOne2ManyField = {
    component: ActionsOne2ManyField,
    relatedFields: [
        { name: "name", type: "char" },
        {
            name: "state",
            type: "selection",
            selection: [
                ["code", _t("Execute Python Code")],
                ["object_create", _t("Create a new Record")],
                ["object_write", _t("Update the Record")],
                ["multi", _t("Execute several actions")],
                ["mail_post", _t("Send email")],
                ["followers", _t("Add followers")],
                ["remove_followers", _t("Remove followers")],
                ["next_activity", _t("Create next activity")],
                ["sms", _t("Send SMS")],
            ],
        },
        // Execute Python Code
        { name: "code", type: "text" },
        // Create
        { name: "crud_model_id", type: "many2one" },
        { name: "crud_model_name", type: "char" },
        // Add Followers
        { name: "partner_ids", type: "many2many" },
        // Message Post / Email
        { name: "template_id", type: "many2one" },
        { name: "mail_post_autofollow", type: "boolean" },
        {
            name: "mail_post_method",
            type: "selection",
            selection: [
                ["email", _t("Email")],
                ["comment", _t("Post as Message")],
                ["note", _t("Post as Note")],
            ],
        },
        // Schedule Next Activity
        { name: "activity_type_id", type: "many2one" },
        { name: "activity_summary", type: "char" },
        { name: "activity_note", type: "html" },
        { name: "activity_date_deadline_range", type: "integer" },
        {
            name: "activity_date_deadline_range_type",
            type: "selection",
            selection: [
                ["days", _t("Days")],
                ["weeks", _t("Weeks")],
                ["months", _t("Months")],
            ],
        },
        {
            name: "activity_user_type",
            type: "selection",
            selection: [
                ["specific", _t("Specific User")],
                ["generic", _t("Generic User")],
            ],
        },
        { name: "activity_user_id", type: "many2one" },
        { name: "activity_user_field_name", type: "char" },
    ],
};

registry.category("fields").add("base_automation_actions_one2many", actionsOne2ManyField);
