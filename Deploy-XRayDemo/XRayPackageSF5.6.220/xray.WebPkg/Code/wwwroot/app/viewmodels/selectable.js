System.register(["./viewmodel"], function (exports_1, context_1) {
    "use strict";
    var __extends = (this && this.__extends) || (function () {
        var extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return function (d, b) {
            extendStatics(d, b);
            function __() { this.constructor = d; }
            d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
        };
    })();
    var __moduleName = context_1 && context_1.id;
    var viewmodel_1, Selectable;
    return {
        setters: [
            function (viewmodel_1_1) {
                viewmodel_1 = viewmodel_1_1;
            }
        ],
        execute: function () {
            Selectable = (function (_super) {
                __extends(Selectable, _super);
                function Selectable(name, selected) {
                    var _this = _super.call(this, name) || this;
                    _this.name = name;
                    _this.selected = selected;
                    return _this;
                }
                Selectable.prototype.copyFrom = function (other) {
                    this.name = other.name;
                };
                return Selectable;
            }(viewmodel_1.ViewModel));
            exports_1("Selectable", Selectable);
        }
    };
});
//# sourceMappingURL=selectable.js.map