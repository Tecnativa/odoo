odoo.define('sale_stock.QtyAtDateWidget', function (require) {
"use strict";

var core = require('web.core');
var QWeb = core.qweb;

var Widget = require('web.Widget');
var Context = require('web.Context');
var data_manager = require('web.data_manager');
var widget_registry = require('web.widget_registry');
var config = require('web.config');
var utils = require('web.utils');

var _t = core._t;
var time = require('web.time');

var QtyAtDateWidget = Widget.extend({
    template: 'sale_stock.qtyAtDate',
    events: _.extend({}, Widget.prototype.events, {
        'click .fa-info-circle': '_onClickButton',
    }),

    /**
     * @override
     * @param {Widget|null} parent
     * @param {Object} params
     */
    init: function (parent, params) {
        this.data = params.data;
        this.fields = params.fields;
        this._updateData();
        this._super(parent);
    },

    start: function () {
        var self = this;
        return this._super.apply(this, arguments).then(function () {
            self._setPopOver();
        });
    },

    _updateData: function() {
        // add some data to simplify the template
        if (this.data.scheduled_date) {
            // The digit info need to get from free_qty_today in master (instead of virtual_available_at_date)
            var qty_considered = this.data.state === 'sale' ? this.data.free_qty_today : this.data.virtual_available_at_date;
            this.data.will_be_fulfilled = utils.round_decimals(qty_considered, this.fields.virtual_available_at_date.digits[1]) >= utils.round_decimals(this.data.qty_to_deliver, this.fields.qty_to_deliver.digits[1]);
            this.data.will_be_late = this.data.forecast_expected_date && this.data.forecast_expected_date > this.data.scheduled_date;
            if (['draft', 'sent'].includes(this.data.state)){
                // Moves aren't created yet, then the forecasted is only based on virtual_available of quant
                this.data.forecasted_issue = !this.data.will_be_fulfilled && !this.data.is_mto;
            } else {
                // Moves are created, using the forecasted data of related moves
                this.data.forecasted_issue = !this.data.will_be_fulfilled || this.data.will_be_late;
            }
        }
    },

    updateState: function (state) {
        this.$el.popover('dispose');
        var candidate = state.data[this.getParent().currentRow];
        if (candidate) {
            this.data = candidate.data;
            this._updateData();
            this.renderElement();
            this._setPopOver();
        }
    },
    //--------------------------------------------------------------------------
    // Private
    //--------------------------------------------------------------------------
    /**
     * Set a bootstrap popover on the current QtyAtDate widget that display available
     * quantity.
     */
    _setPopOver: function () {
        var self = this;
        if (!this.data.scheduled_date) {
            return;
        }
        this.data.delivery_date = this.data.scheduled_date.clone().add(this.getSession().getTZOffset(this.data.scheduled_date), 'minutes').format(time.getLangDateFormat());
        // The grid view need a specific date format that could be different than
        // the user one.
        this.data.delivery_date_grid = this.data.scheduled_date.clone().add(this.getSession().getTZOffset(this.data.scheduled_date), 'minutes').format('YYYY-MM-DD');
        this.data.debug = config.isDebug();
        var $content = $(QWeb.render('sale_stock.QtyDetailPopOver', {
            data: this.data,
        }));
        var $forecastButton = $content.find('.action_open_forecast');
        $forecastButton.on('click', function(ev) {
            ev.stopPropagation();
            data_manager.load_action('stock.report_stock_quantity_action_product').then(function (action) {
                // Change action context to choose a specific date and product(s)
                // As grid_anchor is set to now() by default in the data, we need
                // to load the action first, change the context then launch it via do_action
                // additional_context cannot replace a context value, only add new
                //
                // in case of kit product, the forecast view show the kit's components
                self._rpc({
                    model: 'product.product',
                    method: 'get_components',
                    args: [[self.data.product_id.data.id]]
                }).then(function (res) {
                    var additional_context = {};
                    additional_context.grid_anchor = self.data.delivery_date_grid;
                    additional_context.search_default_warehouse_id = [self.data.warehouse_id.data.id];
                    action.context = new Context(action.context, additional_context);
                    action.domain = [
                        ['product_id', 'in', res]
                    ];
                    self.do_action(action);
                });
            });
        });
        var options = {
            content: $content,
            html: true,
            placement: 'left',
            title: _t('Availability'),
            trigger: 'focus',
            delay: {'show': 0, 'hide': 100 },
        };
        this.$el.popover(options);
    },

    //--------------------------------------------------------------------------
    // Handlers
    //--------------------------------------------------------------------------
    _onClickButton: function () {
        // We add the property special click on the widget link.
        // This hack allows us to trigger the popover (see _setPopOver) without
        // triggering the _onRowClicked that opens the order line form view.
        this.$el.find('.fa-info-circle').prop('special_click', true);
    },
});

widget_registry.add('qty_at_date_widget', QtyAtDateWidget);

return QtyAtDateWidget;
});
